# GitOps Infrastructure on google cloud profider using Terraform | PR-Driven CI/CD with GitHub Actions & OIDC

Dokumentasi ini merangkum implementasi arsitektur GitOps modern untuk mengotomatisasi penyediaan infrastruktur pada Google Cloud Platform (GCP). Proyek ini mengintegrasikan ekosistem GitHub Actions sebagai mesin CI/CD dengan Terraform sebagai alat *Infrastructure as Code* (IaC). Otomatisasi ini mengusung metode *PR-Driven Deployment*, di mana setiap perubahan kode infrastruktur yang didorong ke repositori akan memicu robot penguji dan pengeksekusi secara otomatis, memastikan status infrastruktur di cloud selalu sinkron dengan kode di repositori.

Aspek keamanan utama dalam proyek ini terletak pada penerapan metode autentikasi modern tanpa kunci (*keyless authentication*). Menggantikan metode lama yang menggunakan berkas JSON Service Account yang rentan bocor, proyek ini sukses mengonfigurasi federasi identitas menggunakan **Workload Identity Federation (OIDC)**. Melalui jembatan aman ini, Google Cloud dapat memvalidasi token berumur pendek yang diterbitkan oleh GitHub Actions secara langsung, memberikan hak akses temporal yang sangat aman dan sesuai dengan prinsip keamanan *least privilege*.

### Langkah-Langkah Setup dan Konfigurasi Sistem

**Langkah 1: Konfigurasi Workload Identity Federation di GCP**
Proses diawali dengan membuka Google Cloud Shell untuk membuat *Workload Identity Pool* bernama `github-pool-fix`. Di dalam wadah tersebut, dibuat sebuah OIDC Provider bernama `github-provider-fix` yang mengarah ke penerbit token resmi GitHub. Agar konfigurasi diterima oleh sistem keamanan GCP, perintah ditambahkan parameter `--attribute-condition` secara tertulis untuk memastikan hanya repositori tertentu (`wildanfq/demo`) yang diizinkan mengetuk jembatan federasi tersebut.

**Langkah 2: Sinkronisasi Izin Akses pada Service Account**
Setelah jembatan OIDC terbentuk, dilakukan pengikatan kebijakan IAM (*IAM Policy Binding*) pada Service Account target (`github-actions-sa`). Langkah ini memberikan peran sebagai `Workload Identity User` kepada *principal* repositori GitHub. Evaluasi berkala pada menu *Service Account Permissions* di GCP Console memastikan bahwa repositori GitHub tujuan telah terdaftar secara sah pada kolom *Principals with access*, sehingga GCP siap menerima penyamaran identitas (*impersonation*) dari robot CI/CD.

**Langkah 3: Pemetaan Kunci Rahasia pada GitHub Secrets**
Langkah berikutnya berpindah ke pengaturan repositori GitHub untuk mendaftarkan variabel sensitif. Tiga buah kunci utama dimasukkan ke dalam *Repository Secrets*, yaitu `GCP_PROJECT_ID`, `GCP_SERVICE_ACCOUNT`, dan variabel paling krusial `GCP_WORKLOAD_IDENTITY_PROVIDER` yang berisi jalur lengkap enkripsi objek provider hasil keluaran terminal GCP. Sinkronisasi string ini wajib dipastikan bersih dari spasi gaib agar proses jabat tangan (*handshake*) antar-platform tidak mengalami kegagalan target.

**Langkah 4: Penyusunan Berkas Kode Terraform di Lokal**
Infrastruktur didefinisikan secara deklaratif di dalam folder lokal komputer. Berkas `provider.tf` dikonfigurasi untuk menggunakan Google Cloud Storage (GCS) `belajar-gitops-tfstate-123` sebagai *remote backend* tempat penyimpanan berkas status (*state file*). Sementara itu, berkas `main.tf` dirancang secara minimalis untuk meluncurkan satu unit server virtual instans Compute Engine dengan tipe hemat `e2-micro` di zona `asia-southeast2-a`.

**Langkah 5: Penerapan Pipa Otomatisasi GitHub Actions**
Tahap akhir melibatkan pembuatan berkas manifes otomatisasi pada jalur `.github/workflows/deploy.yml`. Robot CI/CD dikonfigurasi menggunakan aksi resmi `google-github-actions/auth@v2` untuk membaca *secrets* OIDC dan menukarnya menjadi token akses GCP. Alur pipa kemudian diinstruksikan untuk menjalankan fungsi bertahap: memeriksa kode (*checkout*), memprakondisikan Terraform (`init`), memetakan rencana perubahan (`plan`), dan mengeksekusi pembuatan server secara otomatis (`apply`) begitu kode sukses di-*push* ke cabang utama.
