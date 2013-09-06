Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:55272 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751060Ab3IFTET (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Sep 2013 15:04:19 -0400
Date: Fri, 6 Sep 2013 15:03:46 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Nick Piggin <npiggin@kernel.dk>
Subject: Re: [PATCH 1/3] dcache: use IS_ROOT to decide where dentry is hashed
Message-ID: <20130906190346.GB23157@pad.fieldses.org>
References: <1378482230-16312-1-git-send-email-bfields@redhat.com>
 <20130906170044.GA6460@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130906170044.GA6460@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 06, 2013 at 10:00:44AM -0700, Christoph Hellwig wrote:
> On Fri, Sep 06, 2013 at 11:43:48AM -0400, J. Bruce Fields wrote:
> > diff --git a/fs/dcache.c b/fs/dcache.c
> > index b949af8..934f02d 100644
> > --- a/fs/dcache.c
> > +++ b/fs/dcache.c
> > @@ -393,7 +393,7 @@ static void __d_shrink(struct dentry *dentry)
> >  {
> >  	if (!d_unhashed(dentry)) {
> >  		struct hlist_bl_head *b;
> > -		if (unlikely(dentry->d_flags & DCACHE_DISCONNECTED))
> > +		if (unlikely(IS_ROOT(dentry)))
> 
> I think this needs a comment about why the IS_ROOT check is fine,
> destilled from your commit log.

How about this?:

 	if (!d_unhashed(dentry)) {
 		struct hlist_bl_head *b;
+		/*
+		 * Hashed dentries are normally on the dentry hashtable,
+		 * with the exception of those newly allocated by
+		 * d_obtain_alias, which are always IS_ROOT:
+		 */
 		if (unlikely(IS_ROOT(dentry)))
 			b = &dentry->d_sb->s_anon;
 		else

> Also while reviewing this I noticed that one of the two callers of
> __d_shrink already has the d_unhashed check - it might make sense to
> move it to the other caller as well if you touch this area anyway.
> (as a separate patch).

Sure.  That'd look like the following.

--b.

diff --git a/fs/dcache.c b/fs/dcache.c
index 113c82f..81db000 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -391,23 +391,21 @@ static struct dentry *d_kill(struct dentry *dentry, struct dentry *parent)
  */
 static void __d_shrink(struct dentry *dentry)
 {
-	if (!d_unhashed(dentry)) {
-		struct hlist_bl_head *b;
-		/*
-		 * Hashed dentries are normally on the dentry hashtable,
-		 * with the exception of those newly allocated by
-		 * d_obtain_alias, which are always IS_ROOT:
-		 */
-		if (unlikely(IS_ROOT(dentry)))
-			b = &dentry->d_sb->s_anon;
-		else
-			b = d_hash(dentry->d_parent, dentry->d_name.hash);
+	struct hlist_bl_head *b;
+	/*
+	 * Hashed dentries are normally on the dentry hashtable,
+	 * with the exception of those newly allocated by
+	 * d_obtain_alias, which are always IS_ROOT:
+	 */
+	if (unlikely(IS_ROOT(dentry)))
+		b = &dentry->d_sb->s_anon;
+	else
+		b = d_hash(dentry->d_parent, dentry->d_name.hash);
 
-		hlist_bl_lock(b);
-		__hlist_bl_del(&dentry->d_hash);
-		dentry->d_hash.pprev = NULL;
-		hlist_bl_unlock(b);
-	}
+	hlist_bl_lock(b);
+	__hlist_bl_del(&dentry->d_hash);
+	dentry->d_hash.pprev = NULL;
+	hlist_bl_unlock(b);
 }
 
 /**
@@ -902,7 +900,8 @@ static void shrink_dcache_for_umount_subtree(struct dentry *dentry)
 				dentry->d_op->d_prune(dentry);
 
 			dentry_lru_del(dentry);
-			__d_shrink(dentry);
+			if (!d_unhashed(dentry))
+				__d_shrink(dentry);
 
 			if (dentry->d_lockref.count != 0) {
 				printk(KERN_ERR
