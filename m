From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH] NFS: Allow any value for the "retry" option
Date: Mon, 28 Apr 2008 15:09:21 -0400
Message-ID: <20080428190920.2127.26205.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:44117 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936792AbYD1TJX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Apr 2008 15:09:23 -0400
Received: by an-out-0708.google.com with SMTP id d31so1251627and.103
        for <linux-nfs@vger.kernel.org>; Mon, 28 Apr 2008 12:09:23 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The kernel NFS mount option parser should ignore the retry= mount option
since it is meaningful only in user space.  Today it expects a number
rather than arbitrary text, so it ignores the option if the value is
numeric, but chokes if there are other characters in the value.

Change it to allow any text (except ",") as its value.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 39938d3..0c94034 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -136,7 +136,6 @@ static match_table_t nfs_mount_option_tokens = {
 	{ Opt_acdirmin, "acdirmin=%u" },
 	{ Opt_acdirmax, "acdirmax=%u" },
 	{ Opt_actimeo, "actimeo=%u" },
-	{ Opt_userspace, "retry=%u" },
 	{ Opt_namelen, "namlen=%u" },
 	{ Opt_mountport, "mountport=%u" },
 	{ Opt_mountvers, "mountvers=%u" },
@@ -150,6 +149,7 @@ static match_table_t nfs_mount_option_tokens = {
 	{ Opt_clientaddr, "clientaddr=%s" },
 	{ Opt_mounthost, "mounthost=%s" },
 	{ Opt_mountaddr, "mountaddr=%s" },
+	{ Opt_userspace, "retry=%s" },
 
 	{ Opt_err, NULL }
 };

