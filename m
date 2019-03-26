Return-Path: <SRS0=uQmJ=R5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62136C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 13:57:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3DFA22084B
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 13:57:45 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726277AbfCZN5o (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 26 Mar 2019 09:57:44 -0400
Received: from mx1.redhat.com ([209.132.183.28]:35556 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726175AbfCZN5o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Mar 2019 09:57:44 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id A616030833A0;
        Tue, 26 Mar 2019 13:57:43 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.76.0.95])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 4F0B017A78;
        Tue, 26 Mar 2019 13:57:41 +0000 (UTC)
From:   Kenneth D'souza <kdsouza@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     bfields@fieldses.org
Subject: [PATCH]  nfs4_getfacl: Add new option -c/--omit-header to not display comment header.
Date:   Tue, 26 Mar 2019 19:27:40 +0530
Message-Id: <20190326135740.16558-1-kdsouza@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Tue, 26 Mar 2019 13:57:43 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

With this patch the filename will not be printed.

    $ nfs4_getfacl /test/
    # file: /test/
    A::OWNER@:rwaDxtTcCy
    A::GROUP@:rwaDxtcy
    A::EVERYONE@:rwaDxtcy

    $ nfs4_getfacl -c /test/

    A::OWNER@:rwaDxtTcCy
    A::GROUP@:rwaDxtcy
    A::EVERYONE@:rwaDxtcy

Signed-off-by: Kenneth D'souza <kdsouza@redhat.com>
---
 man/man1/nfs4_getfacl.1     |  6 ++++++
 nfs4_getfacl/nfs4_getfacl.c | 13 ++++++++++---
 2 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/man/man1/nfs4_getfacl.1 b/man/man1/nfs4_getfacl.1
index 83067c9..001723e 100644
--- a/man/man1/nfs4_getfacl.1
+++ b/man/man1/nfs4_getfacl.1
@@ -28,6 +28,12 @@ flag is specified,
 .B nfs4_getfacl
 will list the NFSv4 ACLs of all files and directories recursively.
 
+If the
+.BR -c / --omit-header
+flag is specified,
+.B nfs4_getfacl 
+will not display the comment header (Do not print filename).
+
 The output format for an NFSv4 file ACL, e.g., is:
 .RS
 .nf
diff --git a/nfs4_getfacl/nfs4_getfacl.c b/nfs4_getfacl/nfs4_getfacl.c
index 5a9c911..8194e6f 100644
--- a/nfs4_getfacl/nfs4_getfacl.c
+++ b/nfs4_getfacl/nfs4_getfacl.c
@@ -46,6 +46,7 @@ static void usage(int);
 static void more_help();
 static char *execname;
 static void print_acl_from_path();
+static int ignore_comment = 0;
 
 static int recursive(const char *fpath, const struct stat *sb, int tflag, struct FTW *ftwbuf)
 {
@@ -57,6 +58,7 @@ static struct option long_options[] = {
         {"more-help",    0, 0, 'H' },
         {"help",         0, 0, 'h' },
         {"recursive",     0, 0, 'R' },
+	{"omit-header", 0, 0, 'c'},
         { NULL,          0, 0, 0,  },
 };
 
@@ -73,7 +75,7 @@ int main(int argc, char **argv)
 		goto out;
 	}
 
-	while ((opt = getopt_long(argc, argv, "HR?h", long_options, NULL)) != -1) {
+	while ((opt = getopt_long(argc, argv, "HR?hc", long_options, NULL)) != -1) {
 		switch(opt) {
 			case 'H':
 				more_help();
@@ -83,7 +85,9 @@ int main(int argc, char **argv)
 			case 'R':
 				do_recursive = 1;
 				break;
-
+			case 'c':
+				ignore_comment = 1; /* Do not display the comment header */
+				break;
 			default:
 				usage(1);
 				res = 0;
@@ -115,7 +119,10 @@ static void print_acl_from_path(const char *fpath)
 	struct nfs4_acl *acl;
 	acl = nfs4_acl_for_path(fpath);
 	if (acl != NULL) {
+		if(ignore_comment == 0)
 		printf("\n# file: %s\n", fpath);
+		else
+			printf("\n");
 		nfs4_print_acl(stdout, acl);
 		nfs4_free_acl(acl);
 	}
@@ -125,7 +132,7 @@ static void usage(int label)
 {
 	if (label)
 		fprintf(stderr, "%s %s -- get NFSv4 file or directory access control lists.\n", execname, VERSION);
-	fprintf(stderr, "Usage: %s [-R] file ...\n  -H, --more-help\tdisplay ACL format information\n  -?, -h, --help\tdisplay this help text\n  -R --recursive\trecurse into subdirectories\n", execname);
+	fprintf(stderr, "Usage: %s [-R] file ...\n  -H, --more-help\tdisplay ACL format information\n  -?, -h, --help\tdisplay this help text\n  -R --recursive\trecurse into subdirectories\n  -c, --omit-header\tDo not display the comment header (Do not print filename)\n", execname);
 }
 
 static void more_help()
-- 
2.20.1

