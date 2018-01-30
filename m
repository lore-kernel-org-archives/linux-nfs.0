Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:41752 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751410AbeA3TXG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Jan 2018 14:23:06 -0500
Received: by mail-lf0-f65.google.com with SMTP id f136so17033117lff.8
        for <linux-nfs@vger.kernel.org>; Tue, 30 Jan 2018 11:23:05 -0800 (PST)
MIME-Version: 1.0
From: Kenneth Dsouza <kdsouza@redhat.com>
Date: Wed, 31 Jan 2018 00:53:04 +0530
Message-ID: <CAA_-hQKaiEBUmKZj_o9fv-MOSvTgffACP8TrPPXGwk6x=MwkCA@mail.gmail.com>
Subject: [PATCH] nfs4_getfacl: Add support to accept more paths
To: linux-nfs@vger.kernel.org
Cc: bfields@fieldses.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, nfs4_getfacl accepts only a single path at a time, which
makes us run the command several times.
This patch will help us to list (ACL) on multiple files at a  time.
 nfs4getfacl file ...

---
 nfs4_getfacl/nfs4_getfacl.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/nfs4_getfacl/nfs4_getfacl.c b/nfs4_getfacl/nfs4_getfacl.c
index 5363096..bbbbb62 100644
--- a/nfs4_getfacl/nfs4_getfacl.c
+++ b/nfs4_getfacl/nfs4_getfacl.c
@@ -48,17 +48,13 @@ int main(int argc, char **argv)
 {
        struct nfs4_acl *acl;
        int res = 1;
-
+       int count = 1;
        execname = basename(argv[0]);

        if (argc < 2) {
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
@@ -68,12 +64,15 @@ int main(int argc, char **argv)
                res = 0;
                goto out;
        }
-       acl = nfs4_acl_for_path(argv[1]);
+       for (counter = 1; counter < agrc; counter++)    {
+       acl = nfs4_acl_for_path(argv[counter]);
        if (acl != NULL) {
+               printf("\n# file: %s\n", argv[counter]);
                nfs4_print_acl(stdout, acl);
                nfs4_free_acl(acl);
                res = 0;
        }
+       }
 out:
        return res;
 }
-- 
1.8.3.1
