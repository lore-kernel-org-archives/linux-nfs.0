Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BB4EC282E1
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 21:49:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1EA3320811
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 21:49:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bT75v2rD"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730630AbfDXVtC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 17:49:02 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:36579 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730434AbfDXVtC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 17:49:02 -0400
Received: by mail-it1-f195.google.com with SMTP id y10so8868993itc.1
        for <linux-nfs@vger.kernel.org>; Wed, 24 Apr 2019 14:49:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=p6uJAmQ10Dd0Tt6gToAVxYqc/Reqt+aDdRTtsPqvpjM=;
        b=bT75v2rD5AX3f1aY+3nPG1mtpox2hN6F3A41oOeOCI+E/d9UcUs5ikKoMf9C7dQMRB
         LV1GvJUJ+K2qR/yoQaeR4IGWDvVAN7Dj5aT6dXY+aEbKbwDM3bg5koXT8DwXj2CoOhPF
         zjleCPNXmKLJNdNc4Hcre1CWSChIhg6kU7J64mbEpvQd/FhVZnPwl2oMg34f6xsJiY5c
         JnGlE3TfgdYnMlLWa6kBKz24N+y6+CsEoAJUb17+oKoXW10HJYPHObZwX7ckLm1lz33K
         K0a47L25faXvgKFGvSGfGjWY50n/OSmf5IxtQXcVuegBbDY8dKXcFbUZBpXhnNBo0Kpr
         lkRQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=p6uJAmQ10Dd0Tt6gToAVxYqc/Reqt+aDdRTtsPqvpjM=;
        b=g9KokYygiBhCjdjAykK9l8f9p+8TDEOwXAftUItx3STwZX1fZjGhVW2wyEJTVw0qxn
         P1bUemXV4iYTvY0oXhJW2BaTvDZHRngFt/XfXakfQtnKKV7ekqJTjOFmJouy0GfgvcxI
         iQchQ0FwpLgeTYGdafPMjU7deTqnbiUzgQ/HgsskoGb3wyuGZuijUm7ioYELnwkujBHZ
         4d0Z4CdmhfQCULpjJbAv/0TxCF8RWouIybgKvbYB3bfz7ydXIwBQxkHZz00Aok4jOTfD
         b2lXoqQPm6j4XhVCfLWzQkVZ2vmwCYy9rQZcTuT09XhBUe8EoWltf/+9a2cfoZzP7/aL
         z7Mw==
X-Gm-Message-State: APjAAAXaSfs520z/pFDzo+7vaCr6YXge7CxdTOjizB0Oc9N3Y6H/xSSL
        O6CB4YUMC/nMXBZA218HhidvL5w=
X-Google-Smtp-Source: APXvYqxSvGI2Iu8uh15fcZDhwYuKDhs5ReT/ilfnMbOurL1LysLIp/kYM8KU+LNauTHBHZLFVMRnYg==
X-Received: by 2002:a02:6209:: with SMTP id d9mr24229572jac.34.1556142540955;
        Wed, 24 Apr 2019 14:49:00 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id x10sm9838282ita.4.2019.04.24.14.49.00
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Apr 2019 14:49:00 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/9] SUNRPC: Cache cred of process creating the rpc_client
Date:   Wed, 24 Apr 2019 17:46:42 -0400
Message-Id: <20190424214650.4658-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190424214650.4658-1-trond.myklebust@hammerspace.com>
References: <20190424214650.4658-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When converting kuids to AUTH_UNIX creds, etc we will want to use the
same user namespace as the process that created the rpc client.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/lockd/host.c             | 1 +
 fs/lockd/mon.c              | 1 +
 fs/nfs/client.c             | 1 +
 fs/nfs/mount_clnt.c         | 2 ++
 fs/nfsd/nfs4callback.c      | 1 +
 include/linux/sunrpc/clnt.h | 2 ++
 net/sunrpc/clnt.c           | 7 +++++++
 net/sunrpc/rpcb_clnt.c      | 9 +++++++--
 8 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index f0b5c987d6ae..d46081123f7c 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -458,6 +458,7 @@ nlm_bind_host(struct nlm_host *host)
 			.authflavor	= RPC_AUTH_UNIX,
 			.flags		= (RPC_CLNT_CREATE_NOPING |
 					   RPC_CLNT_CREATE_AUTOBIND),
+			.cred		= current_cred(),
 		};
 
 		/*
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 654594ef4f94..1eabd91870e6 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -82,6 +82,7 @@ static struct rpc_clnt *nsm_create(struct net *net, const char *nodename)
 		.version		= NSM_VERSION,
 		.authflavor		= RPC_AUTH_NULL,
 		.flags			= RPC_CLNT_CREATE_NOPING,
+		.cred			= current_cred(),
 	};
 
 	return rpc_create(&args);
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 90d71fda65ce..3ce44d5088a2 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -500,6 +500,7 @@ int nfs_create_rpc_client(struct nfs_client *clp,
 		.program	= &nfs_program,
 		.version	= clp->rpc_ops->version,
 		.authflavor	= flavor,
+		.cred		= current_cred(),
 	};
 
 	if (test_bit(NFS_CS_DISCRTRY, &clp->cl_flags))
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index d979ff4fee7e..cb7c10e9721e 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -163,6 +163,7 @@ int nfs_mount(struct nfs_mount_request *info)
 		.program	= &mnt_program,
 		.version	= info->version,
 		.authflavor	= RPC_AUTH_UNIX,
+		.cred		= current_cred(),
 	};
 	struct rpc_clnt		*mnt_clnt;
 	int			status;
@@ -249,6 +250,7 @@ void nfs_umount(const struct nfs_mount_request *info)
 		.version	= info->version,
 		.authflavor	= RPC_AUTH_UNIX,
 		.flags		= RPC_CLNT_CREATE_NOPING,
+		.cred		= current_cred(),
 	};
 	struct rpc_message msg	= {
 		.rpc_argp	= info->dirpath,
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index d219159b98af..70f1cf9c76b4 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -868,6 +868,7 @@ static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *c
 		.program	= &cb_program,
 		.version	= 1,
 		.flags		= (RPC_CLNT_CREATE_NOPING | RPC_CLNT_CREATE_QUIET),
+		.cred		= current_cred(),
 	};
 	struct rpc_clnt *client;
 	const struct cred *cred;
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 98bc9883b230..7cf616fac9f6 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -71,6 +71,7 @@ struct rpc_clnt {
 	struct dentry		*cl_debugfs;	/* debugfs directory */
 #endif
 	struct rpc_xprt_iter	cl_xpi;
+	const struct cred	*cl_cred;
 };
 
 /*
@@ -125,6 +126,7 @@ struct rpc_create_args {
 	unsigned long		flags;
 	char			*client_name;
 	struct svc_xprt		*bc_xprt;	/* NFSv4.1 backchannel */
+	const struct cred	*cred;
 };
 
 struct rpc_add_xprt_test {
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 8ff11dc98d7f..3d062db7baa1 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -394,6 +394,7 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args,
 	if (err)
 		goto out_no_clid;
 
+	clnt->cl_cred	  = get_cred(args->cred);
 	clnt->cl_procinfo = version->procs;
 	clnt->cl_maxproc  = version->nrprocs;
 	clnt->cl_prog     = args->prognumber ? : program->number;
@@ -439,6 +440,7 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args,
 out_no_path:
 	rpc_free_iostats(clnt->cl_metrics);
 out_no_stats:
+	put_cred(clnt->cl_cred);
 	rpc_free_clid(clnt);
 out_no_clid:
 	kfree(clnt);
@@ -627,6 +629,7 @@ static struct rpc_clnt *__rpc_clone_client(struct rpc_create_args *args,
 	new->cl_discrtry = clnt->cl_discrtry;
 	new->cl_chatty = clnt->cl_chatty;
 	new->cl_principal = clnt->cl_principal;
+	new->cl_cred = get_cred(clnt->cl_cred);
 	return new;
 
 out_err:
@@ -648,6 +651,7 @@ struct rpc_clnt *rpc_clone_client(struct rpc_clnt *clnt)
 		.prognumber	= clnt->cl_prog,
 		.version	= clnt->cl_vers,
 		.authflavor	= clnt->cl_auth->au_flavor,
+		.cred		= clnt->cl_cred,
 	};
 	return __rpc_clone_client(&args, clnt);
 }
@@ -669,6 +673,7 @@ rpc_clone_client_set_auth(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
 		.prognumber	= clnt->cl_prog,
 		.version	= clnt->cl_vers,
 		.authflavor	= flavor,
+		.cred		= clnt->cl_cred,
 	};
 	return __rpc_clone_client(&args, clnt);
 }
@@ -882,6 +887,7 @@ rpc_free_client(struct rpc_clnt *clnt)
 	xprt_put(rcu_dereference_raw(clnt->cl_xprt));
 	xprt_iter_destroy(&clnt->cl_xpi);
 	rpciod_down();
+	put_cred(clnt->cl_cred);
 	rpc_free_clid(clnt);
 	kfree(clnt);
 	return parent;
@@ -946,6 +952,7 @@ struct rpc_clnt *rpc_bind_new_program(struct rpc_clnt *old,
 		.prognumber	= program->number,
 		.version	= vers,
 		.authflavor	= old->cl_auth->au_flavor,
+		.cred		= old->cl_cred,
 	};
 	struct rpc_clnt *clnt;
 	int err;
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 41a971ac1c63..5107fedb40f2 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -240,6 +240,7 @@ static int rpcb_create_local_unix(struct net *net)
 		.program	= &rpcb_program,
 		.version	= RPCBVERS_2,
 		.authflavor	= RPC_AUTH_NULL,
+		.cred		= current_cred(),
 		/*
 		 * We turn off the idle timeout to prevent the kernel
 		 * from automatically disconnecting the socket.
@@ -299,6 +300,7 @@ static int rpcb_create_local_net(struct net *net)
 		.program	= &rpcb_program,
 		.version	= RPCBVERS_2,
 		.authflavor	= RPC_AUTH_UNIX,
+		.cred		= current_cred(),
 		.flags		= RPC_CLNT_CREATE_NOPING,
 	};
 	struct rpc_clnt *clnt, *clnt4;
@@ -358,7 +360,8 @@ int rpcb_create_local(struct net *net)
 static struct rpc_clnt *rpcb_create(struct net *net, const char *nodename,
 				    const char *hostname,
 				    struct sockaddr *srvaddr, size_t salen,
-				    int proto, u32 version)
+				    int proto, u32 version,
+				    const struct cred *cred)
 {
 	struct rpc_create_args args = {
 		.net		= net,
@@ -370,6 +373,7 @@ static struct rpc_clnt *rpcb_create(struct net *net, const char *nodename,
 		.program	= &rpcb_program,
 		.version	= version,
 		.authflavor	= RPC_AUTH_UNIX,
+		.cred		= cred,
 		.flags		= (RPC_CLNT_CREATE_NOPING |
 					RPC_CLNT_CREATE_NONPRIVPORT),
 	};
@@ -744,7 +748,8 @@ void rpcb_getport_async(struct rpc_task *task)
 	rpcb_clnt = rpcb_create(xprt->xprt_net,
 				clnt->cl_nodename,
 				xprt->servername, sap, salen,
-				xprt->prot, bind_version);
+				xprt->prot, bind_version,
+				clnt->cl_cred);
 	if (IS_ERR(rpcb_clnt)) {
 		status = PTR_ERR(rpcb_clnt);
 		dprintk("RPC: %5u %s: rpcb_create failed, error %ld\n",
-- 
2.21.0

