Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from blatinox.fr ([51.254.120.209]:33854 "EHLO vps202351.ovh.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751677AbdJATlN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 1 Oct 2017 15:41:13 -0400
From: =?UTF-8?q?J=C3=A9r=C3=A9my=20Lefaure?=
        <jeremy.lefaure@lse.epita.fr>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: =?UTF-8?q?J=C3=A9r=C3=A9my=20Lefaure?=
        <jeremy.lefaure@lse.epita.fr>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 09/18] nfsd: use ARRAY_SIZE
Date: Sun,  1 Oct 2017 15:30:47 -0400
Message-Id: <20171001193101.8898-10-jeremy.lefaure@lse.epita.fr>
In-Reply-To: <20171001193101.8898-1-jeremy.lefaure@lse.epita.fr>
References: <20171001193101.8898-1-jeremy.lefaure@lse.epita.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Using the ARRAY_SIZE macro improves the readability of the code.

Found with Coccinelle with the following semantic patch:
@r depends on (org || report)@
type T;
T[] E;
position p;
@@
(
 (sizeof(E)@p /sizeof(*E))
|
 (sizeof(E)@p /sizeof(E[...]))
|
 (sizeof(E)@p /sizeof(T))
)

Signed-off-by: Jérémy Lefaure <jeremy.lefaure@lse.epita.fr>
---
 fs/nfsd/fault_inject.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index 34c1c449fddf..3ec72c931ac5 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -11,6 +11,7 @@
 #include <linux/nsproxy.h>
 #include <linux/sunrpc/addr.h>
 #include <linux/uaccess.h>
+#include <linux/kernel.h>
 
 #include "state.h"
 #include "netns.h"
@@ -125,8 +126,6 @@ static struct nfsd_fault_inject_op inject_ops[] = {
 	},
 };
 
-#define NUM_INJECT_OPS (sizeof(inject_ops)/sizeof(struct nfsd_fault_inject_op))
-
 int nfsd_fault_inject_init(void)
 {
 	unsigned int i;
@@ -137,7 +136,7 @@ int nfsd_fault_inject_init(void)
 	if (!debug_dir)
 		goto fail;
 
-	for (i = 0; i < NUM_INJECT_OPS; i++) {
+	for (i = 0; i < ARRAY_SIZE(inject_ops); i++) {
 		op = &inject_ops[i];
 		if (!debugfs_create_file(op->file, mode, debug_dir, op, &fops_nfsd))
 			goto fail;
-- 
2.14.1

