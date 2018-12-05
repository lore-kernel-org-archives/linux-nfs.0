Return-Path: <SRS0=3CSe=OO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9353C04EB8
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 02:10:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 990AE2081C
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 02:10:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 990AE2081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726735AbeLECK6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Dec 2018 21:10:58 -0500
Received: from mx1.redhat.com ([209.132.183.28]:41986 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725834AbeLECK6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Dec 2018 21:10:58 -0500
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 2D18C308A953;
        Wed,  5 Dec 2018 02:10:58 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.67.116.10])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 294EF103BAB3;
        Wed,  5 Dec 2018 02:10:54 +0000 (UTC)
From:   Kenneth D'souza <kdsouza@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     bfields@fieldses.org
Subject: [PATCH] Add support for -L(logical) and -P(physical) option in nfs4_getfacl.
Date:   Wed,  5 Dec 2018 07:40:51 +0530
Message-Id: <20181205021051.8700-1-kdsouza@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Wed, 05 Dec 2018 02:10:58 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Kenneth D'souza <kdsouza@redhat.com>
---
 man/man1/nfs4_getfacl.1     | 18 +++++++++++++-
 nfs4_getfacl/nfs4_getfacl.c | 47 +++++++++++++++++++++++++++++++++----
 2 files changed, 59 insertions(+), 6 deletions(-)

diff --git a/man/man1/nfs4_getfacl.1 b/man/man1/nfs4_getfacl.1
index 83067c9..940a2b5 100644
--- a/man/man1/nfs4_getfacl.1
+++ b/man/man1/nfs4_getfacl.1
@@ -8,7 +8,7 @@
 .SH NAME
 nfs4_getfacl \- get NFSv4 file/directory access control lists
 .SH SYNOPSIS
-.B nfs4_getfacl [-HR]
+.B nfs4_getfacl [-HRLP]
 file ...
 .SH DESCRIPTION
 .B nfs4_getfacl 
@@ -28,6 +28,22 @@ flag is specified,
 .B nfs4_getfacl
 will list the NFSv4 ACLs of all files and directories recursively.
 
+If the
+.BR -L / --logical
+flag is specified,
+.B nfs4_getfacl
+will follow symbolic links to directories. The default behavior is to follow
+symbolic link arguments, and skip symbolic links encountered in subdirectories.
+Only effective in combination with -R.
+
+If the
+.BR -P / --physical
+flag is specified,
+.B nfs4_getfacl
+will not follow symbolic links to directories. This also skips symbolic link
+arguments.
+Only effective in combination with -R.
+
 The output format for an NFSv4 file ACL, e.g., is:
 .RS
 .nf
diff --git a/nfs4_getfacl/nfs4_getfacl.c b/nfs4_getfacl/nfs4_getfacl.c
index 5a9c911..dd5c1b9 100644
--- a/nfs4_getfacl/nfs4_getfacl.c
+++ b/nfs4_getfacl/nfs4_getfacl.c
@@ -46,9 +46,19 @@ static void usage(int);
 static void more_help();
 static char *execname;
 static void print_acl_from_path();
+static int walk_type = 0;
+static void logical();
 
 static int recursive(const char *fpath, const struct stat *sb, int tflag, struct FTW *ftwbuf)
 {
+	if ((tflag == FTW_SL) && (walk_type == 2))
+                return 0;
+
+        if ((tflag == FTW_SL) && (walk_type == 1)) {
+                logical(fpath);
+                return 0;
+        }
+
 	print_acl_from_path(fpath);
 	return 0;
 }
@@ -56,14 +66,16 @@ static int recursive(const char *fpath, const struct stat *sb, int tflag, struct
 static struct option long_options[] = {
         {"more-help",    0, 0, 'H' },
         {"help",         0, 0, 'h' },
-        {"recursive",     0, 0, 'R' },
+        {"recursive",    0, 0, 'R' },
+	{"logical",	 0, 0, 'L' },
+	{"physical",     0, 0, 'P' },
         { NULL,          0, 0, 0,  },
 };
 
 int main(int argc, char **argv)
 {
 	int opt, res = 1;
-        int do_recursive = 0;
+        int flag, do_recursive = 0;
 	
 	execname = basename(argv[0]);
 
@@ -73,7 +85,7 @@ int main(int argc, char **argv)
 		goto out;
 	}
 
-	while ((opt = getopt_long(argc, argv, "HR?h", long_options, NULL)) != -1) {
+	while ((opt = getopt_long(argc, argv, "HR?hLP", long_options, NULL)) != -1) {
 		switch(opt) {
 			case 'H':
 				more_help();
@@ -84,6 +96,22 @@ int main(int argc, char **argv)
 				do_recursive = 1;
 				break;
 
+			case 'L':
+                                if (walk_type != 0) {
+                                        fprintf(stderr, "More than one walk type specified\n");
+                                        goto out;
+                                }
+                                walk_type = 1;  /* Follow all symbolic links */
+                                break;
+
+                        case 'P':
+                                if (walk_type != 0) {
+					fprintf(stderr, "More than one walk type specified\n");
+                                        goto out;
+                                }
+                                walk_type = 2;  /* Skip all symbolic links */
+                                break;
+
 			default:
 				usage(1);
 				res = 0;
@@ -99,7 +127,10 @@ int main(int argc, char **argv)
 
 	for(; optind < argc; optind++) {
 		if(do_recursive) {
-			if (nftw(argv[optind], recursive, 20, 0) == -1)
+			if (walk_type == 2 || walk_type == 1)
+                        flag = FTW_PHYS;
+
+			if (nftw(argv[optind], recursive, 20, flag) == -1)
 				printf("Invalid filename: %s\n", argv[optind]);
 		}
 		else
@@ -121,11 +152,17 @@ static void print_acl_from_path(const char *fpath)
 	}
 }
 
+static void logical(const char *fpath)
+{
+        if (nftw(fpath, recursive, 20, 0) == -1)
+                printf("Invalid filename: %s\n", fpath);
+}
+
 static void usage(int label)
 {
 	if (label)
 		fprintf(stderr, "%s %s -- get NFSv4 file or directory access control lists.\n", execname, VERSION);
-	fprintf(stderr, "Usage: %s [-R] file ...\n  -H, --more-help\tdisplay ACL format information\n  -?, -h, --help\tdisplay this help text\n  -R --recursive\trecurse into subdirectories\n", execname);
+	fprintf(stderr, "Usage: %s [-RPL] file ...\n  -H, --more-help\tdisplay ACL format information\n  -?, -h, --help\tdisplay this help text\n  -R, --recursive\trecurse into subdirectories\n  -L, --logical\t\tlogical walk, follow symbolic links\n  -P, --physical\tphysical walk, do not follow symbolic links\n", execname);
 }
 
 static void more_help()
-- 
2.17.2

