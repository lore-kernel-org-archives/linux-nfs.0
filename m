Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5493 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750910Ab3IFT36 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Sep 2013 15:29:58 -0400
Date: Fri, 6 Sep 2013 15:29:34 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Nick Piggin <npiggin@kernel.dk>
Subject: Re: [PATCH 2/3] dcache: Don't set DISCONNECTED on "pseudo
 filesystem" dentries
Message-ID: <20130906192933.GC23157@pad.fieldses.org>
References: <1378482230-16312-1-git-send-email-bfields@redhat.com>
 <1378482230-16312-2-git-send-email-bfields@redhat.com>
 <20130906170339.GB6460@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130906170339.GB6460@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 06, 2013 at 10:03:39AM -0700, Christoph Hellwig wrote:
> On Fri, Sep 06, 2013 at 11:43:49AM -0400, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > I can't for the life of me see any reason why anyone would care whether
> > a dentry that is never hooked into the dentry cache would need
> > DCACHE_DISCONNECTED set.
> 
> __d_shrink did before your PATCH 1/3.

Well, d_alloc_pseudo dentries aren't even hashed, so even d_shrink
didn't actually reach that DCACHE_DISCONNECTED check.

Uh, maybe change that "would" above to a "should".

> 
> With that fixed your patch looks fine.
> 
> > +/*
> > + * For filesystems that do not actually use the dentry cache at all, and
> > + * only ever deal in IS_ROOT() dentries:
> > + */
> 
> If you document the function it really should be a kerneldoc comment.
> 
> Also the description, while technically correct, isn't all that useful.
> 
> It need an explanation why the filesystem is fine with unhashed
> dentries, and the reason is that it never performs any lookups as it
> pins the dentries in memory.

Makes sense--result follows.

Thanks for the review.

--b.

commit 089d891965374b4262973e51839fe361e2ca3cf0
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Jun 29 16:20:47 2012 -0400

    dcache: Don't set DISCONNECTED on "pseudo filesystem" dentries
    
    I can't for the life of me see any reason why anyone should care whether
    a dentry that is never hooked into the dentry cache would need
    DCACHE_DISCONNECTED set.
    
    This originates from 4b936885ab04dc6e0bb0ef35e0e23c1a7364d9e5 "fs:
    improve scalability of pseudo filesystems", which probably just made the
    false assumption the DCACHE_DISCONNECTED was meant to be set on anything
    not connected to a parent somehow.
    
    So this is just confusing.  Ideally the only uses of DCACHE_DISCONNECTED
    would be in the filehandle-lookup code, which needs it to ensure
    dentries are connected into the dentry tree before use.
    
    I left d_alloc_pseudo there even though it's now equivalent to
    __d_alloc(), just on the theory the name is better documentation of its
    intended use outside dcache.c.
    
    Cc: Nick Piggin <npiggin@kernel.dk>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/dcache.c b/fs/dcache.c
index 7208b38..2255359 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1313,12 +1313,17 @@ struct dentry *d_alloc(struct dentry * parent, const struct qstr *name)
 }
 EXPORT_SYMBOL(d_alloc);
 
+/**
+ * d_alloc_pseudo - allocate a dentry (for lookup-less filesystems)
+ * @sb: the superblock
+ * @name: qstr of the name
+ *
+ * For a filesystem that just pins its dentries in memory and never
+ * performs lookups at all, return an unhashed IS_ROOT dentry.
+ */
 struct dentry *d_alloc_pseudo(struct super_block *sb, const struct qstr *name)
 {
-	struct dentry *dentry = __d_alloc(sb, name);
-	if (dentry)
-		dentry->d_flags |= DCACHE_DISCONNECTED;
-	return dentry;
+	return __d_alloc(sb, name);
 }
 EXPORT_SYMBOL(d_alloc_pseudo);
 
