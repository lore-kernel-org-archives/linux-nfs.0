Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:57943 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752468AbbIPVV2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Sep 2015 17:21:28 -0400
Date: Wed, 16 Sep 2015 17:21:27 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: fix v4.2 SEEK on files over 2 gigs
Message-ID: <20150916212127.GA5169@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We're incorrectly assigning a loff_t return to an int.  If SEEK_HOLE or
SEEK_DATA returns an offset over 2^31 then the application will see a
weird lseek() result (usually -EIO).

Cc: stable@vger.kernel.org
Fixes: bdcc2cd14e4e "NFSv4.2: handle NFS-specific llseek errors"
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/nfs42proc.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index d731bbf974aa..0f020e4d8421 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -175,10 +175,12 @@ loff_t nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
 {
 	struct nfs_server *server = NFS_SERVER(file_inode(filep));
 	struct nfs4_exception exception = { };
-	int err;
+	loff_t err;
 
 	do {
 		err = _nfs42_proc_llseek(filep, offset, whence);
+		if (err >= 0)
+			break;
 		if (err == -ENOTSUPP)
 			return -EOPNOTSUPP;
 		err = nfs4_handle_exception(server, err, &exception);
-- 
2.4.3

