From: Bob Bell <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>
Subject: [PATCH 1/3] NFS: Check nlinks count
Date: Tue, 15 Jan 2008 11:29:05 -0500
Message-ID: <20080115162905.GB18911@newbie.thebellsplace.net>
References: <20080115162658.GA18911@newbie.thebellsplace.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv03.macroped.com ([74.52.9.226]:57339 "EHLO
	srv03.macroped.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955AbYAOQ3H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jan 2008 11:29:07 -0500
Received: from newbie (c-75-67-251-249.hsd1.nh.comcast.net [75.67.251.249])
	(authenticated bits=0)
	by srv03.macroped.com (8.13.8/8.13.8) with ESMTP id m0FGUvOi020124
	for <linux-nfs@vger.kernel.org>; Tue, 15 Jan 2008 11:30:57 -0500
In-Reply-To: <20080115162658.GA18911-y89O8yXFYpDSsb2jM9SCN5/hYUUxywnI@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Philippe Armangau <armangau_philippe@emc.com>

Check the nlink count when updating an NFS inode, and mark the 
attributes invalid if it has changed.  If the inode is a directory, also 
invalidate the cached data so that the directory's contents will be 
refreshed.

Signed-off-by: Philippe Armangau <armangau_philippe@emc.com>
Acked-by: Bob Bell <bell_robert@emc.com>
---
 fs/nfs/inode.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 5747d49..3e85a70 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1063,6 +1063,12 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	memcpy(&inode->i_atime, &fattr->atime, sizeof(inode->i_atime));
 	nfsi->change_attr = fattr->change_attr;
 
+	if (inode->i_nlink != fattr->nlink) {
+		invalid |= NFS_INO_INVALID_ATTR;
+		if (S_ISDIR(inode->i_mode))
+			invalid |= NFS_INO_INVALID_DATA;
+	}
+
 	if ((inode->i_mode & S_IALLUGO) != (fattr->mode & S_IALLUGO) ||
 	    inode->i_uid != fattr->uid ||
 	    inode->i_gid != fattr->gid)
