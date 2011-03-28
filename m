Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:46950 "EHLO
	mail.parisc-linux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753324Ab1C1CyZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Mar 2011 22:54:25 -0400
Date: Sun, 27 Mar 2011 20:54:23 -0600
From: Matthew Wilcox <matthew@wil.cx>
To: Ryan Mallon <ryan@bluewatersys.com>
Cc: viro@zeniv.linux.org.uk, dchinner@redhat.com, Trond.Myklebust@netapp.com,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH 1/2] Add unlocked version of igrab.
Message-ID: <20110328025423.GN13806@parisc-linux.org>
References: <1301277361-9453-1-git-send-email-ryan@bluewatersys.com> <1301277361-9453-2-git-send-email-ryan@bluewatersys.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1301277361-9453-2-git-send-email-ryan@bluewatersys.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Mar 28, 2011 at 02:56:00PM +1300, Ryan Mallon wrote:
> Commit 250df6ed274d767da844a5d9f05720b804240197 "fs: protect
> inode->i_state with inode->i_lock" changes igrab to acquire inode->i_lock,
> however some callees, notably nfs_inode_add_request, already hold the lock
> when calling igrab.

I think a better solution to your problem is to notice that this is
called in the context of doing a write to an inode.  That means we
must already have a reference count on this inode, so it can't possibly
be in I_FREEING or I_WILL_FREE.  That means we can just call __iget()
instead ... except that __iget isn't exported to modules.

So we could just bump the refcount by hand ... or we could
EXPORT_SYMBOL(__iget).


Or Al's going to swear a lot about what NFS is doing here and how it's
utterly misdesigned.  Anyway, this patch could be part of the solution.


diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 85d7525..330cef3 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -390,7 +390,7 @@ static int nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
 	error = radix_tree_insert(&nfsi->nfs_page_tree, req->wb_index, req);
 	BUG_ON(error);
 	if (!nfsi->npages) {
-		igrab(inode);
+		__iget(inode);
 		if (nfs_have_delegation(inode, FMODE_WRITE))
 			nfsi->change_attr++;
 	}

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
