Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34033 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932687Ab2C1XJf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Mar 2012 19:09:35 -0400
Date: Wed, 28 Mar 2012 19:09:31 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfsd4: use auth_unix unconditionally on backchannel
Message-ID: <20120328230931.GA13231@fieldses.org>
References: <1332337929-18580-1-git-send-email-jlayton@redhat.com>
 <1332337929-18580-4-git-send-email-jlayton@redhat.com>
 <20120323121208.GA3219@fieldses.org>
 <20120323133111.GA2991@fieldses.org>
 <1332516024.3087.1.camel@lade.trondhjem.org>
 <20120323152220.GA4953@fieldses.org>
 <1332516863.3087.10.camel@lade.trondhjem.org>
 <20120323115337.28bff808@corrin.poochiereds.net>
 <20120323121218.74461807@corrin.poochiereds.net>
 <20120323170405.GA6089@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120323170405.GA6089@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a bandaid.

I have a series of patches that actually implement the correct behavior,
but that may not quite be ready for 3.4.

--b.

commit 2f026867c76171d26f003b211063ff0562097d5e
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Mar 28 14:18:16 2012 -0400

    nfsd4: use auth_unix unconditionally on backchannel
    
    This isn't actually correct, but it works with the Linux client, and
    agrees with the behavior we used to have before commit 80fc015bdfe.
    
    Later patches will implement the spec-mandated behavior (which is to use
    the security parameters explicitly given by the client in create_session
    or backchannel_ctl).
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 0840fc4..c8e9f63 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -645,7 +645,6 @@ static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *c
 		.timeout	= &timeparms,
 		.program	= &cb_program,
 		.version	= 0,
-		.authflavor	= clp->cl_flavor,
 		.flags		= (RPC_CLNT_CREATE_NOPING | RPC_CLNT_CREATE_QUIET),
 	};
 	struct rpc_clnt *client;
@@ -656,6 +655,7 @@ static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *c
 		args.client_name = clp->cl_principal;
 		args.prognumber	= conn->cb_prog,
 		args.protocol = XPRT_TRANSPORT_TCP;
+		args.authflavor = clp->cl_flavor;
 		clp->cl_cb_ident = conn->cb_ident;
 	} else {
 		if (!conn->cb_xprt)
@@ -665,6 +665,7 @@ static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *c
 		args.bc_xprt = conn->cb_xprt;
 		args.prognumber = clp->cl_cb_session->se_cb_prog;
 		args.protocol = XPRT_TRANSPORT_BC_TCP;
+		args.authflavor = RPC_AUTH_UNIX;
 	}
 	/* Create RPC client */
 	client = rpc_create(&args);
