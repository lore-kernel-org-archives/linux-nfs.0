Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:52915 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2392167AbeHPTF3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Aug 2018 15:05:29 -0400
Received: by mail-it0-f68.google.com with SMTP id d9-v6so6981573itf.2
        for <linux-nfs@vger.kernel.org>; Thu, 16 Aug 2018 09:06:06 -0700 (PDT)
Subject: [PATCH v2 3/4] nfsd: Use correct credential for NFSv4.0 callback
 with GSS
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, simo@redhat.com
Date: Thu, 16 Aug 2018 12:06:04 -0400
Message-ID: <20180816160604.2230.32275.stgit@klimt.1015granger.net>
In-Reply-To: <20180816160404.2230.55488.stgit@klimt.1015granger.net>
References: <20180816160404.2230.55488.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've had trouble when operating a multi-homed Linux NFS server with
Kerberos using NFSv4.0. Lately, I've seen my clients reporting
this (and then hanging):

May  9 11:43:26 manet kernel: NFS: NFSv4 callback contains invalid cred

The client-side commit f11b2a1cfbf5 ("nfs4: copy acceptor name from
context to nfs_client") appears to be related, but I suspect this
problem has been going on for some time before that.

RFC 7530 Section 3.3.3 says:
> For Kerberos V5, nfs/hostname would be a server principal in the
> Kerberos Key Distribution Center database.  This is the same
> principal the client acquired a GSS-API context for when it issued
> the SETCLIENTID operation ...

In other words, an NFSv4.0 client expects that the server will use
the same GSS principal for callback that the client used to
establish its lease. For example, if the client used the service
principal "nfs@server.domain" to establish its lease, the server
is required to use "nfs@server.domain" when performing NFSv4.0
callback operations.

The Linux NFS server currently does not. It uses a common service
principal for all callback connections. Sometimes this works as
expected, and other times -- for example, when the server is
accessible via multiple hostnames -- it won't work at all.

This patch scrapes the target name from the client credential,
and uses that for the NFSv4.0 callback credential. That should
be correct much more often.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4callback.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 1f04d2a..0e9ff86 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -769,7 +769,14 @@ void cleanup_callback_cred(void)
 static struct rpc_cred *get_backchannel_cred(struct nfs4_client *clp, struct rpc_clnt *client, struct nfsd4_session *ses)
 {
 	if (clp->cl_minorversion == 0) {
-		return get_rpccred(callback_cred);
+		char *principal = clp->cl_cred.cr_targ_princ ?
+					clp->cl_cred.cr_targ_princ : "nfs";
+		struct rpc_cred *cred;
+
+		cred = rpc_lookup_machine_cred(principal);
+		if (!IS_ERR(cred))
+			get_rpccred(cred);
+		return cred;
 	} else {
 		struct rpc_auth *auth = client->cl_auth;
 		struct auth_cred acred = {};
