From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH 8/9] fs: nfs: misused copy_to_user() return value
Date: Fri, 30 Jul 2010 15:09:50 +0400
Message-ID: <1280488190-20979-1-git-send-email-segooon@gmail.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

copy_to_user() returns nonzero value on error, this value may be any
value between 0 and requested count, not only requested count.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 fs/nfs/idmap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 21a84d4..a9f2cd5 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -362,7 +362,7 @@ idmap_pipe_upcall(struct file *filp, struct rpc_pipe_msg *msg,
 	unsigned long left;
 
 	left = copy_to_user(dst, data, mlen);
-	if (left == mlen) {
+	if (left)
 		msg->errno = -EFAULT;
 		return -EFAULT;
 	}
-- 
1.7.0.4
