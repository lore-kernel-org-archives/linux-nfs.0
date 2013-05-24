Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53277 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751633Ab3EXWFu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 May 2013 18:05:50 -0400
Date: Fri, 24 May 2013 18:05:49 -0400
To: linux-nfs@vger.kernel.org
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        Julian Sikorski <belegdol@gmail.com>
Subject: [PATCH] svcrpc: fix failures to handle -1 uid's and gid's
Message-ID: <20130524220549.GA28309@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

As of f025adf191924e3a75ce80e130afcd2485b53bb8 "sunrpc: Properly decode
kuids and kgids in RPC_AUTH_UNIX credentials" any rpc containing a -1
(0xffff) uid or gid would fail with a badcred error.

Reported symptoms were xmbc clients failing on upgrade of the NFS
server; examination of the network trace showed them sending -1 as the
gid.

Reported-by: Julian Sikorski <belegdol@gmail.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svcauth_unix.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index c3f9e1e..06bdf5a 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -810,11 +810,15 @@ svcauth_unix_accept(struct svc_rqst *rqstp, __be32 *authp)
 		goto badcred;
 	argv->iov_base = (void*)((__be32*)argv->iov_base + slen);	/* skip machname */
 	argv->iov_len -= slen*4;
-
+	/*
+	 * Note: we skip uid_valid()/gid_valid() checks here for
+	 * backwards compatibility with clients that use -1 id's.
+	 * Instead, -1 uid or gid is later mapped to the
+	 * (export-specific) anonymous id by nfsd_setuser.
+	 * Supplementary gid's will be left alone.
+	 */
 	cred->cr_uid = make_kuid(&init_user_ns, svc_getnl(argv)); /* uid */
 	cred->cr_gid = make_kgid(&init_user_ns, svc_getnl(argv)); /* gid */
-	if (!uid_valid(cred->cr_uid) || !gid_valid(cred->cr_gid))
-		goto badcred;
 	slen = svc_getnl(argv);			/* gids length */
 	if (slen > 16 || (len -= (slen + 2)*4) < 0)
 		goto badcred;
@@ -823,8 +827,6 @@ svcauth_unix_accept(struct svc_rqst *rqstp, __be32 *authp)
 		return SVC_CLOSE;
 	for (i = 0; i < slen; i++) {
 		kgid_t kgid = make_kgid(&init_user_ns, svc_getnl(argv));
-		if (!gid_valid(kgid))
-			goto badcred;
 		GROUP_AT(cred->cr_group_info, i) = kgid;
 	}
 	if (svc_getu32(argv) != htonl(RPC_AUTH_NULL) || svc_getu32(argv) != 0) {
-- 
1.7.9.5

