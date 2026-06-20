Implementasi arsitektur GitOps modern untuk mengotomatisasi provisioning infrastruktur di Google Cloud Platform (GCP). Solusi ini menggabungkan GitHub Actions sebagai mesin CI/CD dan Terraform sebagai alat *Infrastructure as Code* (IaC). Dengan pendekatan *PR-Driven Deployment*, setiap perubahan kode infrastruktur yang masuk ke repositori akan memicu proses validasi dan deployment secara otomatis, sehingga kondisi infrastruktur di cloud selalu selaras dengan kode yang tersimpan di Git.

Keamanan sistem ditingkatkan melalui penerapan *keyless authentication* menggunakan **Workload Identity Federation (OIDC)**. Metode ini menggantikan penggunaan file JSON Service Account yang berisiko bocor. Dengan OIDC, GitHub Actions dapat memperoleh token akses sementara yang diverifikasi langsung oleh Google Cloud, sehingga akses menjadi lebih aman dan sesuai prinsip *least privilege*.

## 1. Konfigurasi Workload Identity Federation di GCP

Proses dimulai dengan membuat **Workload Identity Pool** (`github-pool-fix`) dan **OIDC Provider** (`github-provider-fix`) melalui Google Cloud Shell. Provider dikonfigurasi untuk menerima token resmi dari GitHub dan dibatasi menggunakan `--attribute-condition` agar hanya repositori tertentu (`wildanfq/demo`) yang dapat mengakses federasi identitas tersebut.

## 2. Pemberian Hak Akses Service Account

Setelah federasi identitas berhasil dibuat, Service Account `github-actions-sa` diberikan izin **Workload Identity User** melalui IAM Policy Binding. Konfigurasi ini memungkinkan GitHub Actions melakukan *impersonation* terhadap Service Account secara aman tanpa memerlukan kredensial permanen.

## 3. Konfigurasi GitHub Secrets

Pada repositori GitHub, dibuat tiga *Repository Secrets* utama:

* `GCP_PROJECT_ID`
* `GCP_SERVICE_ACCOUNT`
* `GCP_WORKLOAD_IDENTITY_PROVIDER`

Nilai `GCP_WORKLOAD_IDENTITY_PROVIDER` harus berisi resource path lengkap dari Workload Identity Provider yang telah dibuat di GCP. Pastikan tidak terdapat kesalahan format atau karakter tersembunyi agar proses autentikasi berjalan lancar.

## 4. Pembuatan Infrastruktur dengan Terraform

Infrastruktur didefinisikan secara deklaratif menggunakan Terraform. File `provider.tf` dikonfigurasi untuk menyimpan *Terraform State* pada bucket Google Cloud Storage `belajar-gitops-tfstate-123`, sedangkan `main.tf` digunakan untuk membuat satu instance Google Compute Engine bertipe `e2-micro` di zona `asia-southeast2-a`.

## 5. Implementasi CI/CD dengan GitHub Actions

Tahap terakhir adalah membuat workflow GitHub Actions pada `.github/workflows/deploy.yml`. Workflow menggunakan aksi `google-github-actions/auth@v2` untuk melakukan autentikasi OIDC ke GCP. Setelah berhasil terautentikasi, pipeline akan menjalankan tahapan `terraform init`, `terraform plan`, dan `terraform apply` secara otomatis setiap kali perubahan berhasil di-*push* ke branch utama.

Dengan konfigurasi ini, proses provisioning infrastruktur menjadi otomatis, aman, terukur, dan sepenuhnya mengikuti prinsip GitOps modern.
