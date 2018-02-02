Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:41866 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752334AbeBBUde (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Feb 2018 15:33:34 -0500
Received: by mail-lf0-f66.google.com with SMTP id f136so33284572lff.8
        for <linux-nfs@vger.kernel.org>; Fri, 02 Feb 2018 12:33:33 -0800 (PST)
MIME-Version: 1.0
From: Kenneth Dsouza <kdsouza@redhat.com>
Date: Sat, 3 Feb 2018 02:03:31 +0530
Message-ID: <CAA_-hQKxopVaXHT+m3CpTfjNZjbMaYO-1D2DM1CFKZxJa4050Q@mail.gmail.com>
Subject: [PATCH v2] nfs4_getfacl: Add support to accept more paths
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Update man page with information for multiple file path support.

Signed-off-by: Kenneth D'souza <kdsouza@redhat.com>
---
 man/man1/nfs4_getfacl.1     |  7 ++++++-
 nfs4_getfacl/nfs4_getfacl.c | 18 +++++++++---------
 2 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/man/man1/nfs4_getfacl.1 b/man/man1/nfs4_getfacl.1
index fc092be..b556e1a 100644
--- a/man/man1/nfs4_getfacl.1
+++ b/man/man1/nfs4_getfacl.1
@@ -9,7 +9,7 @@
 nfs4_getfacl \- get NFSv4 file/directory access control lists
 .SH SYNOPSIS
 .B nfs4_getfacl [-H]
-.I file
+file ...
 .SH DESCRIPTION
 .B nfs4_getfacl
 will display the NFSv4 Access Control List (ACL) for
@@ -28,6 +28,7 @@ The output format for an NFSv4 file ACL, e.g., is:
 .RS
 .nf

+# file: /somedir
 A::OWNER@:rwatTnNcCy
 A::alice@nfsdomain.org:rxtncy
 A::bob@nfsdomain.org:rwadtTnNcCy
@@ -42,6 +43,10 @@ In the example output above, the user
`alice@nfsdomain.org' has the equivalent
 of "read" and "execute" permissions, `bob@nfsdomain.org' has "read" and
 "write", and both `GROUP@' and `EVERYONE@' have "read".

+.B nfs4_getfacl
+reads a list of files from standard input. The ACL listings of
+multiple files are separated by blank lines.
+
 Refer to the
 .BR nfs4_acl (5)
 manpage for detailed information about NFSv4 ACL terminology and syntax.
diff --git a/nfs4_getfacl/nfs4_getfacl.c b/nfs4_getfacl/nfs4_getfacl.c
index 5363096..b5f72c7 100644
--- a/nfs4_getfacl/nfs4_getfacl.c
+++ b/nfs4_getfacl/nfs4_getfacl.c
@@ -48,6 +48,7 @@ int main(int argc, char **argv)
 {
        struct nfs4_acl *acl;
        int res = 1;
+       int counter = 1;

        execname = basename(argv[0]);

@@ -55,10 +56,6 @@ int main(int argc, char **argv)
                fprintf(stderr, "%s: you must specify a path.\n", execname);
                usage(0);
                goto out;
-       } else if (argc > 2) {
-               fprintf(stderr, "%s: currently, you may only specify a
single path.\n", execname);
-               usage(0);
-               goto out;
        } else if (!strcmp(argv[1], "-?") || !strcmp(argv[1], "-h") ||
!strcmp(argv[1], "--help")) {
                usage(1);
                res = 0;
@@ -68,11 +65,14 @@ int main(int argc, char **argv)
                res = 0;
                goto out;
        }
-       acl = nfs4_acl_for_path(argv[1]);
-       if (acl != NULL) {
-               nfs4_print_acl(stdout, acl);
-               nfs4_free_acl(acl);
-               res = 0;
+       for (counter = 1; counter < argc; counter++) {
+               acl = nfs4_acl_for_path(argv[counter]);
+               if (acl != NULL) {
+                       printf("\n# file: %s\n",argv[counter]);
+                       nfs4_print_acl(stdout, acl);
+                       nfs4_free_acl(acl);
+                       res = 0;
+               }
        }
 out:
        return res;
--
2.9.5
