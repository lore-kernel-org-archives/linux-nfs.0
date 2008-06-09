From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 4/6] rpc: remove some unused macros
Date: Mon,  9 Jun 2008 16:51:34 -0400
Message-ID: <1213044696-32741-5-git-send-email-bfields@citi.umich.edu>
References: <1213044696-32741-1-git-send-email-bfields@citi.umich.edu>
 <1213044696-32741-2-git-send-email-bfields@citi.umich.edu>
 <1213044696-32741-3-git-send-email-bfields@citi.umich.edu>
 <1213044696-32741-4-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:48634 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751856AbYFIUvi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Jun 2008 16:51:38 -0400
In-Reply-To: <1213044696-32741-4-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There used to be a print_hexl() function that used isprint(), now gone.
I don't know why NFS_NGROUPS and CA_RUN_AS_MACHINE were here.

I also don't know why another #define that's actually used was marked
"unused".

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/auth_gss/auth_gss.c |   13 +------------
 1 files changed, 1 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 92a820e..ff0c2a4 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -63,22 +63,11 @@ static const struct rpc_credops gss_nullops;
 # define RPCDBG_FACILITY	RPCDBG_AUTH
 #endif
 
-#define NFS_NGROUPS	16
-
-#define GSS_CRED_SLACK		1024		/* XXX: unused */
+#define GSS_CRED_SLACK		1024
 /* length of a krb5 verifier (48), plus data added before arguments when
  * using integrity (two 4-byte integers): */
 #define GSS_VERF_SLACK		100
 
-/* XXX this define must match the gssd define
-* as it is passed to gssd to signal the use of
-* machine creds should be part of the shared rpc interface */
-
-#define CA_RUN_AS_MACHINE  0x00000200
-
-/* dump the buffer in `emacs-hexl' style */
-#define isprint(c)      ((c > 0x1f) && (c < 0x7f))
-
 struct gss_auth {
 	struct kref kref;
 	struct rpc_auth rpc_auth;
-- 
1.5.5.rc1

