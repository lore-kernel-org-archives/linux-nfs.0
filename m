Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:50384 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145AbcEIPjj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2016 11:39:39 -0400
Date: Mon, 9 May 2016 16:39:33 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Tony Lindgren <tony@atomide.com>
Cc: Eric Dumazet <edumazet@google.com>, linux-nfs@vger.kernel.org,
        Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@lst.de>, linux-omap@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-arm-kernel@lists.infradead.org
Subject: Re: NFSroot hangs with bad unlock balance in Linux next
Message-ID: <20160509153932.GJ2694@ZenIV.linux.org.uk>
References: <20160505220344.GE5995@atomide.com>
 <20160508141629.GF2694@ZenIV.linux.org.uk>
 <20160509073235.GI2694@ZenIV.linux.org.uk>
 <CANn89iK5H-SokYE1r+OO3sPmQ1vpGqYGbE4x1QLn44wdyvH0cw@mail.gmail.com>
 <20160509151219.GF5995@atomide.com>
 <20160509152138.GG5995@atomide.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160509152138.GG5995@atomide.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 09, 2016 at 08:21:38AM -0700, Tony Lindgren wrote:

> Looks like with both patches applied I still also get this eventually:
> 
> =====================================
> [ BUG: bad unlock balance detected! ]
> 4.6.0-rc7-next-20160509+ #1264 Not tainted
> -------------------------------------

Lockdep warnings are noise.  To make them STFU try the following incremental;
I'll fold it into #work.lookups and #for-next.  Note that it will do nothing
to hangs - those are completely unrelated and you need Eric's patch to deal
with them.

diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index d367b06..1868246 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -64,7 +64,7 @@ static void nfs_async_unlink_release(void *calldata)
 	struct dentry *dentry = data->dentry;
 	struct super_block *sb = dentry->d_sb;
 
-	up_read(&NFS_I(d_inode(dentry->d_parent))->rmdir_sem);
+	up_read_non_owner(&NFS_I(d_inode(dentry->d_parent))->rmdir_sem);
 	d_lookup_done(dentry);
 	nfs_free_unlinkdata(data);
 	dput(dentry);
@@ -117,10 +117,10 @@ static int nfs_call_unlink(struct dentry *dentry, struct nfs_unlinkdata *data)
 	struct inode *dir = d_inode(dentry->d_parent);
 	struct dentry *alias;
 
-	down_read(&NFS_I(dir)->rmdir_sem);
+	down_read_non_owner(&NFS_I(dir)->rmdir_sem);
 	alias = d_alloc_parallel(dentry->d_parent, &data->args.name, &data->wq);
 	if (IS_ERR(alias)) {
-		up_read(&NFS_I(dir)->rmdir_sem);
+		up_read_non_owner(&NFS_I(dir)->rmdir_sem);
 		return 0;
 	}
 	if (!d_in_lookup(alias)) {
@@ -142,7 +142,7 @@ static int nfs_call_unlink(struct dentry *dentry, struct nfs_unlinkdata *data)
 			ret = 0;
 		spin_unlock(&alias->d_lock);
 		dput(alias);
-		up_read(&NFS_I(dir)->rmdir_sem);
+		up_read_non_owner(&NFS_I(dir)->rmdir_sem);
 		/*
 		 * If we'd displaced old cached devname, free it.  At that
 		 * point dentry is definitely not a root, so we won't need
