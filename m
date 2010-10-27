From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsd changes for 2.6.37
Date: Wed, 27 Oct 2010 12:46:06 -0400
Message-ID: <20101027164606.GF6328@fieldses.org>
References: <20101026164549.GD19445@fieldses.org>
 <20101027145538.GC6328@fieldses.org>
 <20101027145929.GA5788@infradead.org>
 <201010271723.59734.arnd@arndb.de>
 <AANLkTinTm-LwjfBfoFUyp5Dj8S2hexnHGQGpZiOWqyMY@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>,
	Christoph Hellwig <hch@infradead.org>,
	Bryan Schumaker <bjschuma@netapp.com>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52308 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751101Ab0J0QqR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Oct 2010 12:46:17 -0400
In-Reply-To: <AANLkTinTm-LwjfBfoFUyp5Dj8S2hexnHGQGpZiOWqyMY-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 27, 2010 at 09:12:06AM -0700, Linus Torvalds wrote:
> On Wed, Oct 27, 2010 at 8:23 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> >
> > locks_delete_lock is also called with lock_flocks held and calls
> > fasync_helper...
> 
> We don't really have to use fasync_helper.
> 
> In fact, the whole interface is pretty broken for something like file
> locking, which isn't actually "fasync()". That whole "on/off as an
> argument" is just crazy. It would be _trivial_ to expose a version of
> fasync_helper() that takes a pre-allocated fasync_struct for add, and
> that has separate helper functions for the add/delete case so that you
> don't have the pointless crazy arguments (for "delete" the "fd"
> argument is useless, and I do hate "modal" functions that take what
> they should do as a flag).
> 
> Then fcntl_setlease() would trivially just allocate the dang thing before.
> 
> Something like the attached (UNTESTED!) perhaps?

Makes sense to me.  Testing....

--b.

> 
>                            Linus

>  fs/fcntl.c         |   66 +++++++++++++++++++++++++++++++++++++++------------
>  fs/locks.c         |   17 ++++++++++++-
>  include/linux/fs.h |    5 ++++
>  3 files changed, 71 insertions(+), 17 deletions(-)
> 
> diff --git a/fs/fcntl.c b/fs/fcntl.c
> index f8cc34f..dcdbc6f 100644
> --- a/fs/fcntl.c
> +++ b/fs/fcntl.c
> @@ -640,7 +640,7 @@ static void fasync_free_rcu(struct rcu_head *head)
>   * match the state "is the filp on a fasync list".
>   *
>   */
> -static int fasync_remove_entry(struct file *filp, struct fasync_struct **fapp)
> +int fasync_remove_entry(struct file *filp, struct fasync_struct **fapp)
>  {
>  	struct fasync_struct *fa, **fp;
>  	int result = 0;
> @@ -666,21 +666,28 @@ static int fasync_remove_entry(struct file *filp, struct fasync_struct **fapp)
>  	return result;
>  }
>  
> +struct fasync_struct *fasync_alloc(void)
> +{
> +	return kmem_cache_alloc(fasync_cache, GFP_KERNEL);
> +}
> +
>  /*
> - * Add a fasync entry. Return negative on error, positive if
> - * added, and zero if did nothing but change an existing one.
> - *
> - * NOTE! It is very important that the FASYNC flag always
> - * match the state "is the filp on a fasync list".
> + * NOTE! This can be used only for unused fasync entries:
> + * entries that actually got inserted on the fasync list
> + * need to be released by rcu - see fasync_remove_entry.
>   */
> -static int fasync_add_entry(int fd, struct file *filp, struct fasync_struct **fapp)
> +void fasync_free(struct fasync_struct *new)
>  {
> -	struct fasync_struct *new, *fa, **fp;
> -	int result = 0;
> +	kmem_cache_free(fasync_cache, new);
> +}
>  
> -	new = kmem_cache_alloc(fasync_cache, GFP_KERNEL);
> -	if (!new)
> -		return -ENOMEM;
> +/*
> + * Insert a new entry into the fasync list.  Return the pointer to the
> + * old one if we didn't use the new one.
> + */
> +struct fasync_struct *fasync_insert_entry(int fd, struct file *filp, struct fasync_struct **fapp, struct fasync_struct *new)
> +{
> +        struct fasync_struct *fa, **fp;
>  
>  	spin_lock(&filp->f_lock);
>  	spin_lock(&fasync_lock);
> @@ -691,8 +698,6 @@ static int fasync_add_entry(int fd, struct file *filp, struct fasync_struct **fa
>  		spin_lock_irq(&fa->fa_lock);
>  		fa->fa_fd = fd;
>  		spin_unlock_irq(&fa->fa_lock);
> -
> -		kmem_cache_free(fasync_cache, new);
>  		goto out;
>  	}
>  
> @@ -702,13 +707,42 @@ static int fasync_add_entry(int fd, struct file *filp, struct fasync_struct **fa
>  	new->fa_fd = fd;
>  	new->fa_next = *fapp;
>  	rcu_assign_pointer(*fapp, new);
> -	result = 1;
>  	filp->f_flags |= FASYNC;
>  
>  out:
>  	spin_unlock(&fasync_lock);
>  	spin_unlock(&filp->f_lock);
> -	return result;
> +	return fa;
> +}
> +
> +/*
> + * Add a fasync entry. Return negative on error, positive if
> + * added, and zero if did nothing but change an existing one.
> + *
> + * NOTE! It is very important that the FASYNC flag always
> + * match the state "is the filp on a fasync list".
> + */
> +static int fasync_add_entry(int fd, struct file *filp, struct fasync_struct **fapp)
> +{
> +	struct fasync_struct *new;
> +
> +	new = fasync_alloc();
> +	if (!new)
> +		return -ENOMEM;
> +
> +	/*
> +	 * fasync_insert_entry() returns the old (update) entry if
> +	 * it existed.
> +	 *
> +	 * So free the (unused) new entry and return 0 to let the
> +	 * caller know that we didn't add any new fasync entries.
> +	 */
> +	if (fasync_insert_entry(fd, filp, fapp, new)) {
> +		fasync_free(new);
> +		return 0;
> +	}
> +
> +	return 1;
>  }
>  
>  /*
> diff --git a/fs/locks.c b/fs/locks.c
> index 4de3a26..9ff3f66 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -1515,6 +1515,7 @@ EXPORT_SYMBOL_GPL(vfs_setlease);
>  int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
>  {
>  	struct file_lock fl, *flp = &fl;
> +	struct fasync_struct *new;
>  	struct inode *inode = filp->f_path.dentry->d_inode;
>  	int error;
>  
> @@ -1523,13 +1524,25 @@ int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
>  	if (error)
>  		return error;
>  
> +	new = fasync_alloc();
> +	if (!new)
> +		return -ENOMEM;
> +
>  	lock_flocks();
>  
>  	error = __vfs_setlease(filp, arg, &flp);
>  	if (error || arg == F_UNLCK)
>  		goto out_unlock;
>  
> -	error = fasync_helper(fd, filp, 1, &flp->fl_fasync);
> +	/*
> +	 * fasync_insert_entry() returns the old entry if any.
> +	 * If there was no old entry, then it used 'new' and
> +	 * inserted it into the fasync list. Clear new so that
> +	 * we don't release it here.
> +	 */
> +	if (!fasync_insert_entry(fd, filp, &flp->fl_fasync, new))
> +		new = NULL;
> +
>  	if (error < 0) {
>  		/* remove lease just inserted by setlease */
>  		flp->fl_type = F_UNLCK | F_INPROGRESS;
> @@ -1541,6 +1554,8 @@ int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
>  	error = __f_setown(filp, task_pid(current), PIDTYPE_PID, 0);
>  out_unlock:
>  	unlock_flocks();
> +	if (new)
> +		fasync_free(new);
>  	return error;
>  }
>  
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 240eb1d..d487772 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1310,6 +1310,11 @@ struct fasync_struct {
>  
>  /* SMP safe fasync helpers: */
>  extern int fasync_helper(int, struct file *, int, struct fasync_struct **);
> +extern struct fasync_struct *fasync_insert_entry(int, struct file *, struct fasync_struct **, struct fasync_struct *);
> +extern int fasync_remove_entry(struct file *, struct fasync_struct **);
> +extern struct fasync_struct *fasync_alloc(void);
> +extern void fasync_free(struct fasync_struct *);
> +
>  /* can be called from interrupts */
>  extern void kill_fasync(struct fasync_struct **, int, int);
>  

