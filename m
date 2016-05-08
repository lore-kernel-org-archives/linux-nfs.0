Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:46036 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbcEHOQj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 May 2016 10:16:39 -0400
Date: Sun, 8 May 2016 15:16:29 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Tony Lindgren <tony@atomide.com>
Cc: Christoph Hellwig <hch@lst.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Subject: Re: NFSroot hangs with bad unlock balance in Linux next
Message-ID: <20160508141629.GF2694@ZenIV.linux.org.uk>
References: <20160505220344.GE5995@atomide.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160505220344.GE5995@atomide.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 05, 2016 at 03:03:44PM -0700, Tony Lindgren wrote:
> Hi,
> 
> Looks like Linux next with NFSroot hangs for me at some point booting
> into init. Then after a while it produces "BUG: bad unlock balance
> detected!".
> 
> This happens at least with omap5-uevm and igepv5. Not sure yet if it
> also happens on other boards, the ones I'm seeing it happen both have
> USB Ethernet controller. They usually hang after the system starts
> being idle some tens of seconds into booting.
> 
> I tried to bisect it down with no luck. I do have the following
> trace, does that provide any clues?

> kworker/0:2/112 is trying to release lock (&nfsi->rmdir_sem) at:
> [<c03a7f98>] nfs_async_unlink_release+0x20/0x68
> but there are no more locks to release!

Very strange.  We grab that rwsem at the entry into nfs_call_unlink()
and then either release it there and return or call nfs_do_call_unlink().
Which arranges for eventual call of nfs_async_unlink_release() (via
->rpc_release); nfs_async_unlink_release() releases the rwsem.  Nobody else
releases it (on the read side, that is).

The only kinda-sorta possibility I see here is that the inode we are
unlocking in that nfs_async_unlink_release() is not the one we'd locked
in nfs_call_unlink() that has lead to it.  That really shouldn't happen,
though...  Just to verify whether that's what we are hitting, could you
try to reproduce that thing with the patch below on top of -next and see
if it triggers any of those WARN_ON?

diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index d367b06..dbbb4c9 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -64,6 +64,10 @@ static void nfs_async_unlink_release(void *calldata)
 	struct dentry *dentry = data->dentry;
 	struct super_block *sb = dentry->d_sb;
 
+	if (WARN_ON(data->parent != dentry->d_parent) ||
+	    WARN_ON(data->parent_inode != dentry->d_parent->d_inode)) {
+		printk(KERN_ERR "WTF2[%pd4]", dentry);
+	}
 	up_read(&NFS_I(d_inode(dentry->d_parent))->rmdir_sem);
 	d_lookup_done(dentry);
 	nfs_free_unlinkdata(data);
@@ -114,7 +118,8 @@ static void nfs_do_call_unlink(struct nfs_unlinkdata *data)
 
 static int nfs_call_unlink(struct dentry *dentry, struct nfs_unlinkdata *data)
 {
-	struct inode *dir = d_inode(dentry->d_parent);
+	struct dentry *parent = dentry->d_parent;
+	struct inode *dir = d_inode(parent);
 	struct dentry *alias;
 
 	down_read(&NFS_I(dir)->rmdir_sem);
@@ -152,6 +157,12 @@ static int nfs_call_unlink(struct dentry *dentry, struct nfs_unlinkdata *data)
 		return ret;
 	}
 	data->dentry = alias;
+	data->parent = parent;
+	data->parent_inode = dir;
+	if (WARN_ON(parent != alias->d_parent) ||
+	    WARN_ON(dir != parent->d_inode)) {
+		printk(KERN_ERR "WTF1[%pd4]", alias);
+	}
 	nfs_do_call_unlink(data);
 	return 1;
 }
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index ee8491d..b01a7f1 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1471,6 +1471,8 @@ struct nfs_unlinkdata {
 	struct nfs_removeargs args;
 	struct nfs_removeres res;
 	struct dentry *dentry;
+	struct dentry *parent;
+	struct inode *parent_inode;
 	wait_queue_head_t wq;
 	struct rpc_cred	*cred;
 	struct nfs_fattr dir_attr;
