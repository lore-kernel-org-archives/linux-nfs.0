From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 2/11] nfsd: ADD new function infrastructure
Date: Wed, 22 Apr 2009 11:07:45 +0530
Message-ID: <OF23168751.EE5F7DD1-ON652575A0.00162F2C-652575A0.001EEC27@in.ibm.com>
References: <20090325133607.16437.33288.sendpatchset@localhost.localdomain> <20090325133647.16437.59567.sendpatchset@localhost.localdomain> <20090422025427.GC29663@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jlayton@redhat.com, Krishna Kumar <krikku@gmail.com>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([59.145.155.3]:57809 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329AbZDVFiN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2009 01:38:13 -0400
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id n3M5c9KX017123
	for <linux-nfs@vger.kernel.org>; Wed, 22 Apr 2009 11:08:09 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3M5XwWX4120742
	for <linux-nfs@vger.kernel.org>; Wed, 22 Apr 2009 11:03:58 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id n3M5c96b013340
	for <linux-nfs@vger.kernel.org>; Wed, 22 Apr 2009 15:38:09 +1000
In-Reply-To: <20090422025427.GC29663@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"J. Bruce Fields" <bfields@fieldses.org> wrote on 04/22/2009 08:24:27 AM:

> > +static int k_nfsd_thread(void *unused)
> > +{
> > +   while (!kthread_should_stop()) {
> > +      schedule_timeout_interruptible(NFSD_CACHE_JIFFIES);
> > +
> > +      if (kthread_should_stop())
> > +         break;
> > +
> > +      daemon_free_entries();
> > +   }
> > +   __set_current_state(TASK_RUNNING);
>
> Is this necessary?  The comment before schedule_timeout() claims "The
> current task state is guaranteed to be TASK_RUNNING when this routine
> returns."

Right, it is not required.

> > +static inline struct fhcache *
> > +nfsd_get_fhcache(__u32 auth)
> > +{
> > +   struct fhcache      *fh, **fhp, **ffhp = NULL;
> > +   int         depth = 0;
> > +   unsigned int      hash;
> > +   struct fhcache_hbucket   *fhb;
> > +
> > +   if (!auth)
> > +      return NULL;
> > +
> > +   hash = jhash_1word(auth, 0xfeedbeef) & FHPARM_HASH_MASK;
> > +   fhb = &fhcache_hash[hash];
> > +
> > +   spin_lock(&fhb->pb_lock);
> > +   for (fhp = &fhb->pb_head; (fh = *fhp); fhp = &fh->p_next) {
> > +      if (fh->p_auth == auth) {
> > +         /* Same inode */
> > +         if (unlikely(!fh->p_filp)) {
> > +            /*
> > +             * Someone is racing in the same code, and
> > +             * this is the first reference to this file.
> > +             */
> > +            spin_unlock(&fhb->pb_lock);
>
> The locking seems over-complicated.  But I have to admit, I don't
> understand it yet.

I have one new lock - k_nfsd_lock, that is used to add/delete the entry to
nfsd_daemon_free_list. Lock is used by either the daemon, or when an
operation results in creating or deleting a cache entry (read and
unlink).

>
> > +            return NULL;
> > +         }
> > +
> > +         /*
> > +          * Hold an extra reference to dentry/exp since these
> > +          * are released in fh_put(). 'file' already has an
> > +          * extra hold from the first lookup which was never
> > +          * dropped.
>
> Why not take a reference on the file instead of the dentry?

I am holding an extra reference to file in the first lookup, but unless
I hold dentry also, it gets freed up by fh_put.

> > +   depth = nfsdstats.ra_size*11/10;
>
> Help, I'm confused--what's the meaning of this calculation?

That is original code, and I also find it confusing :) What I understand is
that when an entry is not found in the cache, ra_depth[10] is incremented,
and
when it is found, ra_depth[0] is incremented (unless the hash table entry
contains elements in the range of 20-30 or more, then ra_depth[2], [3],
etc,
get incremented. It seems to give an indication of the efficiency of the
hash
table.

thanks,

- KK

