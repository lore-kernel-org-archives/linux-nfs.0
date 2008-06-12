From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/5] NFS: Allow any value for the "retry" option
Date: Thu, 12 Jun 2008 12:37:33 -0400
Message-ID: <20080612163732.13197.18349.stgit@manray.1015granger.net>
References: <20080612163416.13197.92911.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:65283 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518AbYFLQhi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jun 2008 12:37:38 -0400
Received: by py-out-1112.google.com with SMTP id p76so1685277pyb.10
        for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 09:37:38 -0700 (PDT)
In-Reply-To: <20080612163416.13197.92911.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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
index ef27035..9f38309 100644
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

