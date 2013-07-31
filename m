Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f53.google.com ([209.85.128.53]:48488 "EHLO
	mail-qe0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067Ab3GaXAy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Jul 2013 19:00:54 -0400
Received: by mail-qe0-f53.google.com with SMTP id f6so745050qej.12
        for <linux-nfs@vger.kernel.org>; Wed, 31 Jul 2013 16:00:53 -0700 (PDT)
Date: Wed, 31 Jul 2013 18:00:51 -0500
From: Quentin Barnes <qbarnes@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: don't allow nfs_find_actor to match inodes of the
 wrong type
Message-ID: <20130731230051.GB31859@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Quite frankly, all I care about in a situation like this is that the
> client doesn't Oops.

Certainly, and his patch does do that, but it's also pointing out
there's another bug running around.  And once you fix that bug, the
original patch is no longer needed.

> If a server is really this utterly broken, then there is no way we can
> fix it on the client, and we're not even going to try.

Of course.  But you also don't want to unnecessarily leave the
client with an invalid inode that's not properly flagged and
possibly leave another bug unfixed.

Here is a example patch that I feel better addresses the problem:


commit 2d6b411eea04ae4398707b584b8d9e552606aaf7
Author: Quentin Barnes <qbarnes@yahoo-inc.com>
Date:   Wed Jul 31 17:50:35 2013 -0500

    Have nfs_refresh_inode_locked() ensure that it doesn't return without
    flagging invalid inodes (ones that don't match its fattr type).
    
    nfs_refresh_inode() already does this, so we need to check the return
    status from nfs_check_inode_attributes() before returning from
    nfs_refresh_inode_locked().
    
    Once this hole is plugged, there will be no invalid inode references
    returned by nfs_fhget(), so no need to check in nfs_find_actor().

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index af6e806..d2263a5 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -244,8 +244,6 @@ nfs_find_actor(struct inode *inode, void *opaque)
 
 	if (NFS_FILEID(inode) != fattr->fileid)
 		return 0;
-	if ((S_IFMT & inode->i_mode) != (S_IFMT & fattr->mode))
-		return 0;
 	if (nfs_compare_fh(NFS_FH(inode), fh))
 		return 0;
 	if (is_bad_inode(inode) || NFS_STALE(inode))
@@ -1269,9 +1267,16 @@ static int nfs_inode_attrs_need_update(const struct inode *inode, const struct n
 
 static int nfs_refresh_inode_locked(struct inode *inode, struct nfs_fattr *fattr)
 {
+	int	status;
+
 	if (nfs_inode_attrs_need_update(inode, fattr))
 		return nfs_update_inode(inode, fattr);
-	return nfs_check_inode_attributes(inode, fattr);
+
+	status = nfs_check_inode_attributes(inode, fattr);
+	if (status)
+		nfs_invalidate_inode(inode);
+
+	return status;
 }
 
 /**
