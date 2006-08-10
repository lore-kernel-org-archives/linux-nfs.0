From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH] fix recursive nlm_file_mutex deadlock
Date: Thu, 10 Aug 2006 11:24:10 -0400
Message-ID: <1155223450.3666.48.camel@localhost.localdomain>
References: <44DA25D3.3010003@redhat.com>
	<1155159937.15624.22.camel@localhost>  <44DA5CBF.3040309@redhat.com>
	<1155167828.15624.70.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7]
	helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GBCGx-0007i0-1L
	for nfs@lists.sourceforge.net; Thu, 10 Aug 2006 08:16:35 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 4.30)
	id 1GBCCx-0006q8-P1
	for nfs@lists.sourceforge.net; Thu, 10 Aug 2006 08:12:27 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GBCCx-0004AP-66
	for nfs@lists.sourceforge.net; Thu, 10 Aug 2006 08:12:27 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1155167828.15624.70.camel@localhost>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, 2006-08-09 at 19:57 -0400, Trond Myklebust wrote:

> Here you go. Assuming this compiles, it ought to prevent the recursive
> call to mutex_lock(&nlm_file_mutex), _and_ speed up nlm_release_file()
> in the case where we know we're not going to free up the file.

Look like this issue can't be patched by any 10-minutes code (that
applies to both of us). 

We simply can't call nlm_release_file() as long as it requires
nlm_file_mutex (no matter where you move the locking line) within
nlm_traverse_files() code path. I'm ok with atomic variable though.

I always think nlm_file_mutex is used to protect nlm_files *list* (which
is a list of individual nlm_file) and file->f_sema is used to protect
the *individual* nlm_file. But I can be wrong (and will go to read the
code more).

In short, you patch will deadlock again.

-- Wendy

> 
> Cheers,
>   Trond
> 
> plain text document attachment (linux-2.6.18-009-
> make_nlm_file_f_count_atomic.dif)
> LOCKD: Make nlm_file->f_count an atomic
> 
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> This allows us to grab the mutex in nlm_release_file only if we suspect
> that the file needs to be freed.
> 
> The latter fixes a deadlock in which nlm_traverse_files() ends up calling
> mutex_lock(&nlm_file_mutex) recursively (the second time being by means of
> the call to nlm_release_file() in nlmsvc_free_block()).
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  fs/lockd/svclock.c          |    2 +-
>  fs/lockd/svcsubs.c          |   26 +++++++++++++++-----------
>  include/linux/lockd/lockd.h |    2 +-
>  3 files changed, 17 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
> index c9d4197..57dcb2d 100644
> --- a/fs/lockd/svclock.c
> +++ b/fs/lockd/svclock.c
> @@ -207,7 +207,7 @@ nlmsvc_create_block(struct svc_rqst *rqs
>  	block->b_daemon = rqstp->rq_server;
>  	block->b_host   = host;
>  	block->b_file   = file;
> -	file->f_count++;
> +	atomic_inc(&file->f_count);
>  
>  	/* Add to file's list of blocks */
>  	block->b_fnext  = file->f_blocks;
> diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
> index 2a4df9b..dfca9e7 100644
> --- a/fs/lockd/svcsubs.c
> +++ b/fs/lockd/svcsubs.c
> @@ -94,8 +94,10 @@ nlm_lookup_file(struct svc_rqst *rqstp, 
>  	mutex_lock(&nlm_file_mutex);
>  
>  	for (file = nlm_files[hash]; file; file = file->f_next)
> -		if (!nfs_compare_fh(&file->f_handle, f))
> +		if (!nfs_compare_fh(&file->f_handle, f)) {
> +			atomic_inc(&file->f_count);
>  			goto found;
> +		}
>  
>  	nlm_debug_print_fh("creating file for", f);
>  
> @@ -108,6 +110,7 @@ nlm_lookup_file(struct svc_rqst *rqstp, 
>  	memcpy(&file->f_handle, f, sizeof(struct nfs_fh));
>  	file->f_hash = hash;
>  	init_MUTEX(&file->f_sema);
> +	atomic_set(&file->f_count, 1);
>  
>  	/* Open the file. Note that this must not sleep for too long, else
>  	 * we would lock up lockd:-) So no NFS re-exports, folks.
> @@ -124,9 +127,8 @@ nlm_lookup_file(struct svc_rqst *rqstp, 
>  	nlm_files[hash] = file;
>  
>  found:
> -	dprintk("lockd: found file %p (count %d)\n", file, file->f_count);
> +	dprintk("lockd: found file %p (count %d)\n", file, atomic_read(&file->f_count));
>  	*result = file;
> -	file->f_count++;
>  	nfserr = 0;
>  
>  out_unlock:
> @@ -221,7 +223,7 @@ nlm_inspect_file(struct nlm_host *host, 
>  {
>  	if (action == NLM_ACT_CHECK) {
>  		/* Fast path for mark and sweep garbage collection */
> -		if (file->f_count || file->f_blocks || file->f_shares)
> +		if (atomic_read(&file->f_count) || file->f_blocks || file->f_shares)
>  			return 1;
>  	} else {
>  		nlmsvc_traverse_blocks(host, file, action);
> @@ -252,7 +254,7 @@ nlm_traverse_files(struct nlm_host *host
>  
>  			/* No more references to this file. Let go of it. */
>  			if (!file->f_blocks && !file->f_locks
> -			 && !file->f_shares && !file->f_count) {
> +			 && !file->f_shares && !atomic_read(&file->f_count)) {
>  				*fp = file->f_next;
>  				nlmsvc_ops->fclose(file->f_file);
>  				kfree(file);
> @@ -278,18 +280,20 @@ void
>  nlm_release_file(struct nlm_file *file)
>  {
>  	dprintk("lockd: nlm_release_file(%p, ct = %d)\n",
> -				file, file->f_count);
> -
> -	/* Lock file table */
> -	mutex_lock(&nlm_file_mutex);
> +				file, atomic_read(&file->f_count));
>  
>  	/* If there are no more locks etc, delete the file */
> -	if(--file->f_count == 0) {
> +	if (atomic_dec_and_test(&file->f_count)) {
> +		/*
> +		 * Note! nlm_inspect_file() will check file->f_count
> +		 * to see if we raced while taking nlm_file_mutex
> +		 */
> +		mutex_lock(&nlm_file_mutex);
>  		if(!nlm_inspect_file(NULL, file, NLM_ACT_CHECK))
>  			nlm_delete_file(file);
> +		mutex_unlock(&nlm_file_mutex);
>  	}
>  
> -	mutex_unlock(&nlm_file_mutex);
>  }
>  
>  /*
> diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
> index 0d92c46..59b63a1 100644
> --- a/include/linux/lockd/lockd.h
> +++ b/include/linux/lockd/lockd.h
> @@ -102,7 +102,7 @@ struct nlm_file {
>  	struct nlm_share *	f_shares;	/* DOS shares */
>  	struct nlm_block *	f_blocks;	/* blocked locks */
>  	unsigned int		f_locks;	/* guesstimate # of locks */
> -	unsigned int		f_count;	/* reference count */
> +	atomic_t		f_count;	/* reference count */
>  	struct semaphore	f_sema;		/* avoid concurrent access */
>  	int		       	f_hash;		/* hash of f_handle */
>  };
> -------------------------------------------------------------------------
> Using Tomcat but need to do more? Need to support web services, security?
> Get stuff done quickly with pre-integrated technology to make your job easier
> Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
> http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
> _______________________________________________ NFS maillist - NFS@lists.sourceforge.net https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
