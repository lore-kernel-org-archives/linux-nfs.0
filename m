Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f44.google.com ([209.85.192.44]:38284 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752208AbaHTK63 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Aug 2014 06:58:29 -0400
Received: by mail-qg0-f44.google.com with SMTP id e89so7203570qgf.17
        for <linux-nfs@vger.kernel.org>; Wed, 20 Aug 2014 03:58:28 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 20 Aug 2014 06:58:26 -0400
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Joe Perches <joe@perches.com>
Subject: Re: [PATCH] lockd: Remove unused b_fl member from struct nlm_block
Message-ID: <20140820065826.6def22d5@tlielax.poochiereds.net>
In-Reply-To: <53F47357.7050608@gmail.com>
References: <53F47357.7050608@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 20 Aug 2014 18:07:19 +0800
Kinglong Mee <kinglongmee@gmail.com> wrote:

> Fix left code by Joe Perches's patch,
> "locks: Remove unused conf argument from lm_grant"
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/lockd/svclock.c          | 26 +++++---------------------
>  include/linux/lockd/lockd.h |  1 -
>  2 files changed, 5 insertions(+), 22 deletions(-)
> 
> diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
> index 2a61701..796e63b 100644
> --- a/fs/lockd/svclock.c
> +++ b/fs/lockd/svclock.c
> @@ -245,7 +245,6 @@ nlmsvc_create_block(struct svc_rqst *rqstp, struct nlm_host *host,
>  	block->b_daemon = rqstp->rq_server;
>  	block->b_host   = host;
>  	block->b_file   = file;
> -	block->b_fl = NULL;
>  	file->f_count++;
>  
>  	/* Add to file's list of blocks */
> @@ -295,7 +294,6 @@ static void nlmsvc_free_block(struct kref *kref)
>  	nlmsvc_freegrantargs(block->b_call);
>  	nlmsvc_release_call(block->b_call);
>  	nlm_release_file(block->b_file);
> -	kfree(block->b_fl);
>  	kfree(block);
>  }
>  
> @@ -523,20 +521,13 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
>  	block = nlmsvc_lookup_block(file, lock);
>  
>  	if (block == NULL) {
> -		struct file_lock *conf = kzalloc(sizeof(*conf), GFP_KERNEL);
> -
> -		if (conf == NULL)
> -			return nlm_granted;
>  		block = nlmsvc_create_block(rqstp, host, file, lock, cookie);
> -		if (block == NULL) {
> -			kfree(conf);
> +		if (block == NULL)
>  			return nlm_granted;
> -		}
> -		block->b_fl = conf;

NAK. The b_fl member is not unused, as is evidenced by the assignment
above.

Joe's patch removed the conflock from the lm_grant callback since the
filesystem never set that parameter in the lm_grant callback. This call
however has nothing to do with lm_grant. It's done when the client
issues a NLM_TEST operation.

>  	}
>  	if (block->b_flags & B_QUEUED) {
> -		dprintk("lockd: nlmsvc_testlock deferred block %p flags %d fl %p\n",
> -			block, block->b_flags, block->b_fl);
> +		dprintk("lockd: nlmsvc_testlock deferred block %p flags %d\n",
> +			block, block->b_flags);
>  		if (block->b_flags & B_TIMED_OUT) {
>  			nlmsvc_unlink_block(block);
>  			ret = nlm_lck_denied;
> @@ -544,14 +535,8 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
>  		}
>  		if (block->b_flags & B_GOT_CALLBACK) {
>  			nlmsvc_unlink_block(block);
> -			if (block->b_fl != NULL
> -					&& block->b_fl->fl_type != F_UNLCK) {
> -				lock->fl = *block->b_fl;
> -				goto conf_lock;
> -			} else {
> -				ret = nlm_granted;
> -				goto out;
> -			}
> +			ret = nlm_granted;
> +			goto out;
>  		}
>  		ret = nlm_drop_reply;
>  		goto out;
> @@ -575,7 +560,6 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
>  		goto out;
>  	}
>  
> -conf_lock:
>  	dprintk("lockd: conflicting lock(ty=%d, %Ld-%Ld)\n",
>  		lock->fl.fl_type, (long long)lock->fl.fl_start,
>  		(long long)lock->fl.fl_end);
> diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
> index 219d796..ff82a32 100644
> --- a/include/linux/lockd/lockd.h
> +++ b/include/linux/lockd/lockd.h
> @@ -178,7 +178,6 @@ struct nlm_block {
>  	unsigned char		b_granted;	/* VFS granted lock */
>  	struct nlm_file *	b_file;		/* file in question */
>  	struct cache_req *	b_cache_req;	/* deferred request handling */
> -	struct file_lock *	b_fl;		/* set for GETLK */
>  	struct cache_deferred_req * b_deferred_req;
>  	unsigned int		b_flags;	/* block flags */
>  #define B_QUEUED		1	/* lock queued */


-- 
Jeff Layton <jlayton@primarydata.com>
