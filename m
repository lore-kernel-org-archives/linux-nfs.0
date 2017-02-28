Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.mpynet.fi ([82.197.21.85]:59713 "EHLO mx2.mpynet.fi"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751461AbdB1U3n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 28 Feb 2017 15:29:43 -0500
From: Tomohiro Kusumi <tkusumi@tuxera.com>
To: <viro@zeniv.linux.org.uk>, <linux-fsdevel@vger.kernel.org>,
        <trond.myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>
CC: Tomohiro Kusumi <tkusumi@tuxera.com>
Subject: [PATCH 2/3] nfs: use SEEK_CUR/SET
Date: Tue, 28 Feb 2017 21:45:22 +0200
Message-ID: <20170228194523.2054-2-tkusumi@tuxera.com>
In-Reply-To: <20170228194523.2054-1-tkusumi@tuxera.com>
References: <20170228194523.2054-1-tkusumi@tuxera.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Tomohiro Kusumi <tkusumi@tuxera.com>
---
 fs/nfs/dir.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index fad8104..95712e1 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -972,9 +972,9 @@ static loff_t nfs_llseek_dir(struct file *filp, loff_t offset, int whence)
 			filp, offset, whence);
 
 	switch (whence) {
-		case 1:
+		case SEEK_CUR:
 			offset += filp->f_pos;
-		case 0:
+		case SEEK_SET:
 			if (offset >= 0)
 				break;
 		default:
-- 
2.9.3

