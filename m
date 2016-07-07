Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:58986 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981AbcGGFzA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jul 2016 01:55:00 -0400
From: Oleg Drokin <green@linuxhacker.ru>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH 2/2] staging/lustre: Prevent spurious EPERM on mkdir
Date: Thu,  7 Jul 2016 01:53:47 -0400
Message-Id: <1467870827-2959489-3-git-send-email-green@linuxhacker.ru>
In-Reply-To: <1467870827-2959489-1-git-send-email-green@linuxhacker.ru>
References: <1467870827-2959489-1-git-send-email-green@linuxhacker.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

if the name already exists, but we don't have write permissions
in the parent

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/namei.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 9321bd8..4c3dde1 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -544,8 +544,12 @@ static struct dentry *ll_lookup_nd(struct inode *parent, struct dentry *dentry,
 	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir="DFID"(%p),flags=%u\n",
 	       dentry, PFID(ll_inode2fid(parent)), parent, flags);
 
-	/* Optimize away (CREATE && !OPEN). Let .create handle the race. */
-	if ((flags & LOOKUP_CREATE) && !(flags & LOOKUP_OPEN))
+	/* Optimize away (CREATE && !OPEN). Let .create handle the race.
+	 * but only if we have write permissions there, otherwise we need
+	 * to proceed with lookup. LU-4185
+	 */
+	if ((flags & LOOKUP_CREATE) && !(flags & LOOKUP_OPEN) &&
+	    (inode_permission(parent, MAY_WRITE | MAY_EXEC) == 0))
 		return NULL;
 
 	if (flags & (LOOKUP_PARENT|LOOKUP_OPEN|LOOKUP_CREATE))
-- 
2.7.4

