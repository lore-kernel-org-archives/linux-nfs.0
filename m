Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34607 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752931Ab1LEIOS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2011 03:14:18 -0500
Received: by mail-bw0-f46.google.com with SMTP id zv3so1472947bkb.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Dec 2011 00:14:18 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 08/10] fix compiler warnings around get_output use of argv
Date: Mon,  5 Dec 2011 10:14:12 +0200
Message-Id: <1323072852-18448-1-git-send-email-benny@tonian.com>
In-Reply-To: <4EDC7C4E.1040901@tonian.com>
References: <4EDC7C4E.1040901@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 ctl.c |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/ctl.c b/ctl.c
index e5d16e3..f1d878d 100644
--- a/ctl.c
+++ b/ctl.c
@@ -52,7 +52,7 @@ static int __token_count(token_t *t);
 static const char * __token_next(token_t *t);
 static const char * __token_str(token_t *t);
 static int __token_next_int(token_t *t);
-static int get_output(char *prog, const char **argv);
+static int get_output(char *prog, char * const *argv);
 static char *find_dm_name(int major, int minor);
 static void hexdump(char *p, int len, int off);
 
@@ -277,7 +277,7 @@ get_vers(bl_comm_msg_t *msg, bl_comm_res_t *res, int *len)
 bl_comm_res_t *
 get_dm(bl_comm_msg_t *msg, bl_comm_res_t *res, int *lenp)
 {
-	const char	*argv[4] = {"dmsetup", "table", NULL, NULL};
+	char	*argv[4] = {"dmsetup", "table", NULL, NULL};
 	char	buf[128],
 		*name;
 	int	major,
@@ -298,7 +298,7 @@ get_dm(bl_comm_msg_t *msg, bl_comm_res_t *res, int *lenp)
 		return res;
 	}
 	argv[2] = name;
-	if (((fd = get_output("/sbin/dmsetup", argv)) == -1) ||
+	if (((fd = get_output("/sbin/dmsetup", (char * const *)argv)) == -1) ||
 	    ((fp = fdopen(fd, "r")) == NULL)) {
 		printf("%s: get_output/fdopen failed\n", __func__);
 		res->res_status = PNFS_BLOCK_FAILURE;
@@ -479,7 +479,7 @@ set_operation(int op)
 static char *
 find_dm_name(int major, int minor)
 {
-	const char	*argv[5] = {"dmsetup", "ls", "--target", "striped", NULL};
+	char * const argv[5] = {"dmsetup", "ls", "--target", "striped", NULL};
 	char		buf[128],
 			*name;
 	const char	*majmin;
@@ -549,7 +549,7 @@ error:
 }
 
 static int
-get_output(char *prog, const char **argv)
+get_output(char *prog, char * const *argv)
 {
 	int	fildes[2];
 	
@@ -567,13 +567,11 @@ get_output(char *prog, const char **argv)
 			close(fildes[0]);
 			dup2(fildes[1], 1);
 			dup2(fildes[1], 2);
-			if (execv(prog, argv) == -1) {
-				perror("execv");
-				exit(1);
-			}
-			break;
+			execv(prog, argv);
+			perror("execv");
+			exit(1);
 			
-			default:
+		default:
 			close(fildes[1]);
 			return fildes[0];
 	}
-- 
1.7.6

