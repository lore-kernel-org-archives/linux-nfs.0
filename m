From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 1/4] knfsd: Replace lock_kernel with a mutex for nfsd
	thread startup/shutdown locking.
Date: Thu, 05 Jun 2008 10:47:37 +1000
Message-ID: <484737A9.508@melbourne.sgi.com>
References: <1212591796-22144-1-git-send-email-jlayton@redhat.com>
	<1212591796-22144-2-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1212591796-22144-2-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton wrote:
> From: Neil Brown <neilb@suse.de>
>
>
>   
Sorry; I know this was posted before but now that I'm back home I've had
a chance to review it in slightly more depth so I have some more comments.
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 5ac00c4..d601a77 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -441,6 +441,8 @@ static ssize_t write_threads(struct file *file, char *buf, size_t size)
> @@ -450,22 +452,26 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
> @@ -496,10 +502,12 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
>   
These are fine.

> @@ -566,14 +574,13 @@ static ssize_t write_versions(struct file *file, char *buf, size_t size)
>   
I notice there's no change to write_versions(), even though that
function checks nfsd_serv for NULL and implicitly expects the svc_serv
to be created while it's running.
> @@ -603,9 +610,7 @@ static ssize_t write_ports(struct file *file, char *buf, size_t size)
> @@ -614,10 +619,8 @@ static ssize_t write_ports(struct file *file, char *buf, size_t size
> @@ -655,7 +658,6 @@ static ssize_t write_ports(struct file *file, char *buf, size_t size)
> @@ -666,13 +668,22 @@ static ssize_t write_ports(struct file *file, char *buf, size_t size)
> @@ -691,13 +702,13 @@ static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
>   
All good.

I notice there's no change to write_leasetime().  That calls
nfs4_reset_lease(), which seems to want to only be called when nfsd is
not started (according to my reading of the comment preceding the
function), and which uses the BKL to protect the variable
user_lease_time.  Perhaps that path should be changed to use the new
nfsd_mutex also?

Similarly with write_recoverydir().  That calls nfs4_reset_recoverydir()
which uses client_mutex to protect user_recovery_dirname[], but that
variable is only used during nfsd startup.  Perhaps that path should use
the new nfsd_mutex also?
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index 941041f..040b3c2 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -53,11 +53,27 @@
> @@ -190,13 +206,14 @@ void nfsd_reset_versions(void)
> @@ -223,7 +240,7 @@ int nfsd_create_serv(void)
> @@ -282,6 +299,8 @@ int nfsd_set_nrthreads(int n, int *nthreads)
> @@ -316,7 +335,6 @@ int nfsd_set_nrthreads(int n, int *nthreads)
> @@ -325,7 +343,6 @@ int nfsd_set_nrthreads(int n, int *nthreads)
> @@ -334,8 +351,8 @@ int
> @@ -363,7 +380,7 @@ nfsd_svc(unsigned short port, int nrservs)
> @@ -399,7 +416,7 @@ nfsd(struct svc_rqst *rqstp)
> @@ -417,11 +434,13 @@ nfsd(struct svc_rqst *rqstp)
> @@ -477,7 +496,7 @@ nfsd(struct svc_rqst *rqstp)
> @@ -486,7 +505,7 @@ out:
>   
All good.
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index 01c7e31..7bffaff 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -461,7 +461,8 @@ svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
> @@ -578,9 +579,10 @@ out_enomem:
> @@ -674,7 +676,7 @@ found_pool:
> @@ -722,7 +724,8 @@ svc_set_num_threads(struct svc_serv *serv, struct svc_pool *pool, int nrservs)
>   

All good.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.
