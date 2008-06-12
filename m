From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 27/37] rpc: remove some unused macros
Date: Thu, 12 Jun 2008 15:22:01 -0400
Message-ID: <20080612192201.24528.56591.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52364 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759520AbYFLTe5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:34:57 -0400
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: \"J. Bruce Fields\" <bfields@citi.umich.edu>

There used to be a print_hexl() function that used isprint(), now gone.
I don't know why NFS_NGROUPS and CA_RUN_AS_MACHINE were here.

I also don't know why another #define that's actually used was marked
"unused".

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/auth_gss/auth_gss.c |   13 +------------
 1 files changed, 1 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index ebfd630..834a831 100644
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

