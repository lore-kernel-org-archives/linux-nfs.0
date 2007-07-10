From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] [RESEND] Improve idmap parallelism
Date: Mon, 09 Jul 2007 23:18:44 -0400
Message-ID: <1184037524.6468.93.camel@heimdal.trondhjem.org>
References: <1173723596.19257.12.camel@dyn9047022153>
	<1173726535.6436.58.camel@heimdal.trondhjem.org>
	<1173752235.6428.5.camel@heimdal.trondhjem.org>
	<1184020369.16851.41.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>
To: Frank Filz <ffilzlnx@us.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I86FX-0001kx-Ek
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 20:18:51 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1//xH17nxWTwuNTKpGEqy1Ys7c8mqYuKgA=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I86FX-0001s4-LU
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 20:18:52 -0700
In-Reply-To: <1184020369.16851.41.camel@dyn9047022153>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, 2007-07-09 at 15:32 -0700, Frank Filz wrote:
> Not sure if this got lost in the noise, resending...

This one I'm less sure about: I have some long held ideas about how I
want to restructure the idmapper cache.

      * For one thing, I want to get completely rid of the locking: this
        is a write-once cache, so it should be using RCU.
      * Secondly, the idmap cache should never have been a
        per-nfs_client structure. We should rather be using a single
        global cache that can translate between any owner/owner_group to
        a uid/gid and any uid/gid to any owner/owner_group (as long as
        we know to which NFSv4 domain the server belongs).

Cheers
  Trond


> On Mon, 2007-03-12 at 22:17 -0400, Trond Myklebust wrote:
> > On Mon, 2007-03-12 at 15:08 -0400, Trond Myklebust wrote:
> > > On Mon, 2007-03-12 at 11:19 -0700, Frank Filz wrote:
> > > > Resend: I sent this awhile ago, but it may have been missed with the excitement of Connectathon, weddings, and honeymoons. I've verified it compiles against 2.6.21 (I originally tested it on 2.6.20).
> > > 
> > > You forgot the Linux Storage and Filesystem Workshop and FAST. It has
> > > been an exciting life in the past 2 months. :-)
> > > 
> > > At first glance it looks OK. I'll take it for a spin...
> > 
> > Hmm... Apart from having been mangled by your mailer, I immediately
> > started getting major complaints about scheduling under a spin lock.
> 
> My apologies on the formatting.
> 
> > Looking more closely, it seems you are holding the read lock while
> > calling rpc_queue_upcall(), which again will result in a call to
> > idmap_pipe_upcall(). That won't work since copy_to_user() is allowed to
> > sleep.
> 
> Ah, oops. I have rewritten the code using rwsem to avoid this problem.
> This may not have caused a problem in my testing because the only
> contention should be the write, which shouldn't be attempted until after
> the copy_to_user is done (given the serialization of upcalls). Still, no
> excuse for faulty coding.
> 
> > In addition, there were several leakages of the read lock.
> 
> Fixed those.
> 
> I ran the same testing overnight on this updated patch.
> 
> Here is the re-submitted patch:
> 
> This patch improves idmap parallelism by reducing the serialization of
> idmap lookups.  Currently, each client can only process one idmap lookup
> at a time, potentially delaying other lookups that might be satisfied by
> the in kernel cache while waiting for a user space lookup.
> 
> The existing code uses two mutexes, but one of them is held the entire
> time of the lookup.
> 
> The biggest change this patch makes is to re-order lock use so that one
> lock serializes multiple user space lookups (for the same nfs_client).
> This lock is only held when the kernel cache lookup fails and a user
> space lookup must occur. The other lock is used to protect the in kernel
> cache (a pair of hash tables). This lock is only held when the internal
> cache is being accessed. Further, since most accesses are lookups, this
> second lock is changed to a read-write lock.
> 
> After acquiring the mutex, a second cache lookup is made just in case a
> user space lookup had been in progress for this id.
> 
> I tested this using fsstress on an SMP machine. While testing, I put in
> some metering code which showed as many as 1000 cache lookups satisfied
> while an upcall was in progress, and noted occasional lookups for the id
> that an upcall was in progress for.
> 
> This patch was modified from an initial patch by Usha Ketineni.
> 
> Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
> 
> diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
> index 9d4a6b2..6c5c0f8 100644
> --- a/fs/nfs/idmap.c
> +++ b/fs/nfs/idmap.c
> @@ -36,6 +36,7 @@
>  
>  #include <linux/module.h>
>  #include <linux/mutex.h>
> +#include <linux/rwsem.h>
>  #include <linux/init.h>
>  #include <linux/types.h>
>  #include <linux/slab.h>
> @@ -86,9 +87,9 @@ struct idmap_hashtable {
>  struct idmap {
>  	struct dentry        *idmap_dentry;
>  	wait_queue_head_t     idmap_wq;
> -	struct idmap_msg      idmap_im;
> +	struct idmap_msg      idmap_im;      /* protected by mutex */
>  	struct mutex          idmap_lock;    /* Serializes upcalls */
> -	struct mutex          idmap_im_lock; /* Protects the hashtable */
> +	struct rw_semaphore   idmap_im_lock; /* Protects the hashtable */
>  	struct idmap_hashtable idmap_user_hash;
>  	struct idmap_hashtable idmap_group_hash;
>  };
> @@ -127,7 +128,7 @@ nfs_idmap_new(struct nfs_client *clp)
>  	}
>  
>          mutex_init(&idmap->idmap_lock);
> -        mutex_init(&idmap->idmap_im_lock);
> +        init_rwsem(&idmap->idmap_im_lock);
>  	init_waitqueue_head(&idmap->idmap_wq);
>  	idmap->idmap_user_hash.h_type = IDMAP_TYPE_USER;
>  	idmap->idmap_group_hash.h_type = IDMAP_TYPE_GROUP;
> @@ -243,14 +244,28 @@ nfs_idmap_id(struct idmap *idmap, struct
> idmap_hashtable *h,
>  	if (namelen >= IDMAP_NAMESZ)
>  		return -EINVAL;
>  
> +	down_read(&idmap->idmap_im_lock);
> +	he = idmap_lookup_name(h, name, namelen);
> +	if (he != NULL) {
> +		*id = he->ih_id;
> +		up_read(&idmap->idmap_im_lock);
> +		return 0;
> +	}
> +	up_read(&idmap->idmap_im_lock);
> +
>  	mutex_lock(&idmap->idmap_lock);
> -	mutex_lock(&idmap->idmap_im_lock);
>  
> +	/* Attempt lookup again in case we blocked
> +	 * because another attempt on this name
> +	 * was in progress.
> +	 */
> +	down_read(&idmap->idmap_im_lock);
>  	he = idmap_lookup_name(h, name, namelen);
>  	if (he != NULL) {
>  		*id = he->ih_id;
> -		ret = 0;
> -		goto out;
> +		up_read(&idmap->idmap_im_lock);
> +		mutex_unlock(&idmap->idmap_lock);
> +		return 0;
>  	}
>  
>  	memset(im, 0, sizeof(*im));
> @@ -266,15 +281,15 @@ nfs_idmap_id(struct idmap *idmap, struct
> idmap_hashtable *h,
>  	add_wait_queue(&idmap->idmap_wq, &wq);
>  	if (rpc_queue_upcall(idmap->idmap_dentry->d_inode, &msg) < 0) {
>  		remove_wait_queue(&idmap->idmap_wq, &wq);
> +		up_read(&idmap->idmap_im_lock);
>  		goto out;
>  	}
>  
>  	set_current_state(TASK_UNINTERRUPTIBLE);
> -	mutex_unlock(&idmap->idmap_im_lock);
> +	up_read(&idmap->idmap_im_lock);
>  	schedule();
>  	current->state = TASK_RUNNING;
>  	remove_wait_queue(&idmap->idmap_wq, &wq);
> -	mutex_lock(&idmap->idmap_im_lock);
>  
>  	if (im->im_status & IDMAP_STATUS_SUCCESS) {
>  		*id = im->im_id;
> @@ -283,7 +298,6 @@ nfs_idmap_id(struct idmap *idmap, struct
> idmap_hashtable *h,
>  
>   out:
>  	memset(im, 0, sizeof(*im));
> -	mutex_unlock(&idmap->idmap_im_lock);
>  	mutex_unlock(&idmap->idmap_lock);
>  	return (ret);
>  }
> @@ -304,14 +318,30 @@ nfs_idmap_name(struct idmap *idmap, struct
> idmap_hashtable *h,
>  
>  	im = &idmap->idmap_im;
>  
> +	down_read(&idmap->idmap_im_lock);
> +	he = idmap_lookup_id(h, id);
> +	if (he != 0) {
> +		memcpy(name, he->ih_name, he->ih_namelen);
> +		ret = he->ih_namelen;
> +		up_read(&idmap->idmap_im_lock);
> +		return ret;
> +	}
> +	up_read(&idmap->idmap_im_lock);
> +
>  	mutex_lock(&idmap->idmap_lock);
> -	mutex_lock(&idmap->idmap_im_lock);
>  
> +	/* Attempt lookup again in case we blocked
> +	 * because another attempt on this id
> +	 * was in progress.
> +	 */
> +	down_read(&idmap->idmap_im_lock);
>  	he = idmap_lookup_id(h, id);
>  	if (he != 0) {
>  		memcpy(name, he->ih_name, he->ih_namelen);
>  		ret = he->ih_namelen;
> -		goto out;
> +		up_read(&idmap->idmap_im_lock);
> +		mutex_unlock(&idmap->idmap_lock);
> +		return ret;
>  	}
>  
>  	memset(im, 0, sizeof(*im));
> @@ -327,15 +357,15 @@ nfs_idmap_name(struct idmap *idmap, struct
> idmap_hashtable *h,
>  
>  	if (rpc_queue_upcall(idmap->idmap_dentry->d_inode, &msg) < 0) {
>  		remove_wait_queue(&idmap->idmap_wq, &wq);
> +		up_read(&idmap->idmap_im_lock);
>  		goto out;
>  	}
>  
>  	set_current_state(TASK_UNINTERRUPTIBLE);
> -	mutex_unlock(&idmap->idmap_im_lock);
> +	up_read(&idmap->idmap_im_lock);
>  	schedule();
>  	current->state = TASK_RUNNING;
>  	remove_wait_queue(&idmap->idmap_wq, &wq);
> -	mutex_lock(&idmap->idmap_im_lock);
>  
>  	if (im->im_status & IDMAP_STATUS_SUCCESS) {
>  		if ((len = strnlen(im->im_name, IDMAP_NAMESZ)) == 0)
> @@ -346,7 +376,6 @@ nfs_idmap_name(struct idmap *idmap, struct
> idmap_hashtable *h,
>  
>   out:
>  	memset(im, 0, sizeof(*im));
> -	mutex_unlock(&idmap->idmap_im_lock);
>  	mutex_unlock(&idmap->idmap_lock);
>  	return ret;
>  }
> @@ -391,7 +420,7 @@ idmap_pipe_downcall(struct file *filp, const char
> __user *src, size_t mlen)
>          if (copy_from_user(&im_in, src, mlen) != 0)
>  		return (-EFAULT);
>  
> -	mutex_lock(&idmap->idmap_im_lock);
> +	down_write(&idmap->idmap_im_lock);
>  
>  	ret = mlen;
>  	im->im_status = im_in.im_status;
> @@ -451,7 +480,7 @@ idmap_pipe_downcall(struct file *filp, const char
> __user *src, size_t mlen)
>  		idmap_update_entry(he, im_in.im_name, namelen_in, im_in.im_id);
>  	ret = mlen;
>  out:
> -	mutex_unlock(&idmap->idmap_im_lock);
> +	up_write(&idmap->idmap_im_lock);
>  	return ret;
>  }
>  
> @@ -463,10 +492,10 @@ idmap_pipe_destroy_msg(struct rpc_pipe_msg *msg)
>  
>  	if (msg->errno >= 0)
>  		return;
> -	mutex_lock(&idmap->idmap_im_lock);
> +	down_write(&idmap->idmap_im_lock);
>  	im->im_status = IDMAP_STATUS_LOOKUPFAIL;
>  	wake_up(&idmap->idmap_wq);
> -	mutex_unlock(&idmap->idmap_im_lock);
> +	up_write(&idmap->idmap_im_lock);
>  }
>  
>  /* 
> 
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
