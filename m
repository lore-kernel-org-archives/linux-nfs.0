From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 3/4] knfsd: convert knfsd to kthread API
Date: Thu, 05 Jun 2008 11:28:40 +1000
Message-ID: <48474148.1050200@melbourne.sgi.com>
References: <1212591796-22144-1-git-send-email-jlayton@redhat.com>
	<1212591796-22144-2-git-send-email-jlayton@redhat.com>
	<1212591796-22144-3-git-send-email-jlayton@redhat.com>
	<1212591796-22144-4-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1212591796-22144-4-git-send-email-jlayton@redhat.com>
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
> This patch is rather large, but I couldn't figure out a way to break it
> up that would remain bisectable. It does several things:
>
> - change svc_thread_fn typedef to better match what kthread_create expects
> - change svc_pool_map_set_cpumask to be more kthread friendly. Make it
>   take a task arg and and get rid of the "oldmask"
> - have svc_set_num_threads call kthread_create directly
> - eliminate __svc_create_thread
>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>
>   

Acked-by: Greg Banks <gnb@melbourne.sgi.com>
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index 582acb1..825936b 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -21,6 +21,7 @@
> @@ -46,7 +47,7 @@
> @@ -399,18 +400,19 @@ update_thread_usage(int busy_threads)
>  /*
>   * This is the NFS server kernel thread
>   */
> -static void
> -nfsd(struct svc_rqst *rqstp)
> +static int
> +nfsd(void *vrqstp)
>  {
> +	struct svc_rqst *rqstp = (struct svc_rqst *) vrqstp;
>   

Not that it matters, but you don't actually need a cast here.
> @@ -425,14 +427,18 @@ nfsd(struct svc_rqst *rqstp)
> @@ -454,15 +460,25 @@ nfsd(struct svc_rqst *rqstp)
> @@ -471,25 +487,23 @@ nfsd(struct svc_rqst *rqstp)
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -22,7 +22,7 @@
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -18,6 +18,7 @@
> @@ -291,15 +292,14 @@ svc_pool_map_put(void)
> @@ -307,26 +307,17 @@ svc_pool_map_set_cpumask(unsigned int pidx, cpumask_t *oldmask)
> @@ -579,47 +570,6 @@ out_enomem:
> @@ -688,7 +638,9 @@ found_pool:
> @@ -704,18 +656,32 @@ svc_set_num_threads(struct svc_serv *serv, struct svc_pool *pool, int nrservs)
>   
All good.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.
