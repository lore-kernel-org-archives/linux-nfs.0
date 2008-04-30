From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 1/6] NFS: Allow any value for the "retry" option
Date: Wed, 30 Apr 2008 11:59:42 -0400
Message-ID: <20080430155941.32402.20312.stgit@manray.1015granger.net>
References: <20080430154011.32402.42101.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: jlayton@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.248]:33449 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755439AbYD3P7o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Apr 2008 11:59:44 -0400
Received: by hs-out-0708.google.com with SMTP id 4so444321hsl.5
        for <linux-nfs@vger.kernel.org>; Wed, 30 Apr 2008 08:59:44 -0700 (PDT)
In-Reply-To: <20080430154011.32402.42101.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The kernel NFS mount option parser should ignore the retry= mount option
since it is meaningful only in user space.  Today it expects a number
rather than arbitrary text, so it ignores the option if the value is
numeric, but chokes if there are other characters in the value.

Change it to allow any text (except ",") as its value.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index fa220dc..d199f7c 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -101,6 +101,8 @@ enum {
 static match_table_t nfs_mount_option_tokens = {
 	{ Opt_userspace, "bg" },
 	{ Opt_userspace, "fg" },
+	{ Opt_userspace, "retry=%s" },
+
 	{ Opt_soft, "soft" },
 	{ Opt_hard, "hard" },
 	{ Opt_intr, "intr" },
@@ -136,7 +138,6 @@ static match_table_t nfs_mount_option_tokens = {
 	{ Opt_acdirmin, "acdirmin=%u" },
 	{ Opt_acdirmax, "acdirmax=%u" },
 	{ Opt_actimeo, "actimeo=%u" },
-	{ Opt_userspace, "retry=%u" },
 	{ Opt_namelen, "namlen=%u" },
 	{ Opt_mountport, "mountport=%u" },
 	{ Opt_mountvers, "mountvers=%u" },

