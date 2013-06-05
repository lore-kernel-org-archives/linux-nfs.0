Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:4022 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754642Ab3FELnx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jun 2013 07:43:53 -0400
Date: Wed, 5 Jun 2013 07:43:09 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: viro@zeniv.linux.org.uk, matthew@wil.cx, dhowells@redhat.com,
        sage@inktank.com, smfrench@gmail.com, swhiteho@redhat.com,
        Trond.Myklebust@netapp.com, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        piastryyy@gmail.com
Subject: Re: [PATCH v1 08/11] locks: convert fl_link to a hlist_node
Message-ID: <20130605074309.051ff75f@corrin.poochiereds.net>
In-Reply-To: <20130604215950.GE15594@fieldses.org>
References: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
	<1370056054-25449-9-git-send-email-jlayton@redhat.com>
	<20130604215950.GE15594@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 4 Jun 2013 17:59:50 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, May 31, 2013 at 11:07:31PM -0400, Jeff Layton wrote:
> > Testing has shown that iterating over the blocked_list for deadlock
> > detection turns out to be a bottleneck. In order to alleviate that,
> > begin the process of turning it into a hashtable. We start by turning
> > the fl_link into a hlist_node and the global lists into hlists. A later
> > patch will do the conversion of the blocked_list to a hashtable.
> 
> Even simpler would be if we could add a pointer to the (well, a) lock
> that a lockowner is blocking on, and then we'd just have to follow a
> pointer.  I haven't thought that through, though, perhaps that's hard ot
> make work....
> 
> --b.
> 

I considered that as well and it makes sense for the simple local
filesystem case where you just track ownership based on fl_owner_t.

But...what about lockd? It considers ownership to be a tuple of the
nlm_host and the pid sent in a lock request. I can't seem to wrap my
brain around how to make such an approach work there. I'll confess
though that I haven't tried *too* hard yet though since I had bigger
problems to sort through at the time. Maybe we can consider that for a
later set?

> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/locks.c         |   32 ++++++++++++++++----------------
> >  include/linux/fs.h |    2 +-
> >  2 files changed, 17 insertions(+), 17 deletions(-)
> > 
> > diff --git a/fs/locks.c b/fs/locks.c
> > index fc35b9e..5ed056b 100644
> > --- a/fs/locks.c
> > +++ b/fs/locks.c
> > @@ -163,8 +163,8 @@ int lease_break_time = 45;
> >  #define for_each_lock(inode, lockp) \
> >  	for (lockp = &inode->i_flock; *lockp != NULL; lockp = &(*lockp)->fl_next)
> >  
> > -static LIST_HEAD(file_lock_list);
> > -static LIST_HEAD(blocked_list);
> > +static HLIST_HEAD(file_lock_list);
> > +static HLIST_HEAD(blocked_list);
> >  
> >  /* Protects the two list heads above */
> >  static DEFINE_SPINLOCK(file_lock_lock);
> > @@ -173,7 +173,7 @@ static struct kmem_cache *filelock_cache __read_mostly;
> >  
> >  static void locks_init_lock_heads(struct file_lock *fl)
> >  {
> > -	INIT_LIST_HEAD(&fl->fl_link);
> > +	INIT_HLIST_NODE(&fl->fl_link);
> >  	INIT_LIST_HEAD(&fl->fl_block);
> >  	init_waitqueue_head(&fl->fl_wait);
> >  }
> > @@ -207,7 +207,7 @@ void locks_free_lock(struct file_lock *fl)
> >  {
> >  	BUG_ON(waitqueue_active(&fl->fl_wait));
> >  	BUG_ON(!list_empty(&fl->fl_block));
> > -	BUG_ON(!list_empty(&fl->fl_link));
> > +	BUG_ON(!hlist_unhashed(&fl->fl_link));
> >  
> >  	locks_release_private(fl);
> >  	kmem_cache_free(filelock_cache, fl);
> > @@ -486,7 +486,7 @@ static inline void
> >  locks_insert_global_blocked(struct file_lock *waiter)
> >  {
> >  	spin_lock(&file_lock_lock);
> > -	list_add(&waiter->fl_link, &blocked_list);
> > +	hlist_add_head(&waiter->fl_link, &blocked_list);
> >  	spin_unlock(&file_lock_lock);
> >  }
> >  
> > @@ -494,7 +494,7 @@ static inline void
> >  locks_delete_global_blocked(struct file_lock *waiter)
> >  {
> >  	spin_lock(&file_lock_lock);
> > -	list_del_init(&waiter->fl_link);
> > +	hlist_del_init(&waiter->fl_link);
> >  	spin_unlock(&file_lock_lock);
> >  }
> >  
> > @@ -502,7 +502,7 @@ static inline void
> >  locks_insert_global_locks(struct file_lock *waiter)
> >  {
> >  	spin_lock(&file_lock_lock);
> > -	list_add_tail(&waiter->fl_link, &file_lock_list);
> > +	hlist_add_head(&waiter->fl_link, &file_lock_list);
> >  	spin_unlock(&file_lock_lock);
> >  }
> >  
> > @@ -510,7 +510,7 @@ static inline void
> >  locks_delete_global_locks(struct file_lock *waiter)
> >  {
> >  	spin_lock(&file_lock_lock);
> > -	list_del_init(&waiter->fl_link);
> > +	hlist_del_init(&waiter->fl_link);
> >  	spin_unlock(&file_lock_lock);
> >  }
> >  
> > @@ -705,7 +705,7 @@ static struct file_lock *what_owner_is_waiting_for(struct file_lock *block_fl)
> >  {
> >  	struct file_lock *fl, *ret = NULL;
> >  
> > -	list_for_each_entry(fl, &blocked_list, fl_link) {
> > +	hlist_for_each_entry(fl, &blocked_list, fl_link) {
> >  		if (posix_same_owner(fl, block_fl)) {
> >  			ret = fl->fl_next;
> >  			if (likely(ret))
> > @@ -867,7 +867,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
> >  				goto out;
> >  			error = FILE_LOCK_DEFERRED;
> >  			locks_insert_block(fl, request);
> > -			if (list_empty(&request->fl_link))
> > +			if (hlist_unhashed(&request->fl_link))
> >  				locks_insert_global_blocked(request);
> >  			goto out;
> >    		}
> > @@ -882,10 +882,10 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
> >  	 * Now that we know the request is no longer blocked, we can take it
> >  	 * off the global list. Some callers send down partially initialized
> >  	 * requests, so we only do this if FL_SLEEP is set. Also, avoid taking
> > -	 * the lock if the list is empty, as that indicates a request that
> > +	 * the lock if the hlist is unhashed, as that indicates a request that
> >  	 * never blocked.
> >  	 */
> > -	if ((request->fl_flags & FL_SLEEP) && !list_empty(&request->fl_link))
> > +	if ((request->fl_flags & FL_SLEEP) && !hlist_unhashed(&request->fl_link))
> >  		locks_delete_global_blocked(request);
> >  
> >  	/*
> > @@ -2277,11 +2277,11 @@ static int locks_show(struct seq_file *f, void *v)
> >  {
> >  	struct file_lock *fl, *bfl;
> >  
> > -	fl = list_entry(v, struct file_lock, fl_link);
> > +	fl = hlist_entry(v, struct file_lock, fl_link);
> >  
> >  	lock_get_status(f, fl, *((loff_t *)f->private), "");
> >  
> > -	list_for_each_entry(bfl, &blocked_list, fl_link) {
> > +	hlist_for_each_entry(bfl, &blocked_list, fl_link) {
> >  		if (bfl->fl_next == fl)
> >  			lock_get_status(f, bfl, *((loff_t *)f->private), " ->");
> >  	}
> > @@ -2295,14 +2295,14 @@ static void *locks_start(struct seq_file *f, loff_t *pos)
> >  
> >  	spin_lock(&file_lock_lock);
> >  	*p = (*pos + 1);
> > -	return seq_list_start(&file_lock_list, *pos);
> > +	return seq_hlist_start(&file_lock_list, *pos);
> >  }
> >  
> >  static void *locks_next(struct seq_file *f, void *v, loff_t *pos)
> >  {
> >  	loff_t *p = f->private;
> >  	++*p;
> > -	return seq_list_next(v, &file_lock_list, pos);
> > +	return seq_hlist_next(v, &file_lock_list, pos);
> >  }
> >  
> >  static void locks_stop(struct seq_file *f, void *v)
> > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > index ccb44ea..07a009e 100644
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -934,7 +934,7 @@ int locks_in_grace(struct net *);
> >   */
> >  struct file_lock {
> >  	struct file_lock *fl_next;	/* singly linked list for this inode  */
> > -	struct list_head fl_link;	/* doubly linked list of all locks */
> > +	struct hlist_node fl_link;	/* node in global lists */
> >  	struct list_head fl_block;	/* circular list of blocked processes */
> >  	fl_owner_t fl_owner;
> >  	unsigned int fl_flags;
> > -- 
> > 1.7.1
> > 


-- 
Jeff Layton <jlayton@redhat.com>
