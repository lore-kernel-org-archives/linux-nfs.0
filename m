Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:13078 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754128Ab2EVO6N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 May 2012 10:58:13 -0400
Subject: Re: [PATCH 3/4] SUNRPC: Add RPC based upcall mechanism for RPCGSS
 auth
From: Simo Sorce <simo@redhat.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "bfields@redhat.com" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <4FBB9551.9010407@parallels.com>
References: <1337087550-9821-1-git-send-email-simo@redhat.com>
	 <1337087550-9821-4-git-send-email-simo@redhat.com>
	 <20120522124728.GB891@fieldses.org>
	 <1337691607.16840.178.camel@willson.li.ssimo.org>
	 <4FBB91EE.3010307@parallels.com>
	 <1337692966.16840.181.camel@willson.li.ssimo.org>
	 <4FBB9551.9010407@parallels.com>
Content-Type: multipart/mixed; boundary="=-cdmda4z1HNzDyil4SJvF"
Date: Tue, 22 May 2012 10:58:04 -0400
Message-ID: <1337698684.16840.184.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-cdmda4z1HNzDyil4SJvF
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Tue, 2012-05-22 at 17:32 +0400, Stanislav Kinsbursky wrote:
> It actually means, that no hard-coded init_net references should appear - and 
> that's all. Required network context have to be taken from currently existent 
> objects (like RPC client, RPC service, etc) and, if not available (it's very 
> rare case - like NFS mount call), from current->nsproxy->net_ns.
> You don't need to do anything special except this.
> There will be a problem with your patches in container, because you are using 
> unix socket. But this problem is not in your patches but in unix sockets 
> themselves. So don't worry about it.

Can you tell me if the attached patches are all you think is needed ?
If they are, I'll squash them in with other fixes and will send out a
new patch set.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

--=-cdmda4z1HNzDyil4SJvF
Content-Disposition: attachment; filename="0001-make-upcall.c-container-safe.patch"
Content-Type: text/x-patch; name="0001-make-upcall.c-container-safe.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

>From 887918f5173b6b989fb8b8ff7738c842ed741f3d Mon Sep 17 00:00:00 2001
From: Simo Sorce <simo@redhat.com>
Date: Tue, 22 May 2012 10:27:16 -0400
Subject: [PATCH 1/2] make upcall.c container safe

---
 net/sunrpc/auth_gss/gss_rpc_upcall.c |   17 +++++++++--------
 net/sunrpc/auth_gss/gss_rpc_upcall.h |    3 ++-
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_rpc_upcall.c b/net/sunrpc/auth_gss/gss_rpc_upcall.c
index 50a1a8c742e4b43a500e4a3b8d3ce9d51fca08ee..1ea8fd87204fcf248035b0e3056c261aaf63cd89 100644
--- a/net/sunrpc/auth_gss/gss_rpc_upcall.c
+++ b/net/sunrpc/auth_gss/gss_rpc_upcall.c
@@ -92,14 +92,14 @@ struct rpc_procinfo gssp_procedures[] = {
 
 static const struct rpc_program gssp_program;
 
-static int gssp_rpc_create(struct rpc_clnt **_clnt)
+static int gssp_rpc_create(struct net *xprt_net, struct rpc_clnt **_clnt)
 {
 	static const struct sockaddr_un gssp_localaddr = {
 		.sun_family		= AF_LOCAL,
 		.sun_path		= GSSPROXY_SOCK_PATHNAME,
 	};
 	struct rpc_create_args args = {
-		.net		= &init_net,
+		.net		= xprt_net,
 		.protocol	= XPRT_TRANSPORT_LOCAL,
 		.address	= (struct sockaddr *)&gssp_localaddr,
 		.addrsize	= sizeof(gssp_localaddr),
@@ -129,7 +129,7 @@ out:
 	return result;
 }
 
-static struct rpc_clnt *get_clnt(bool global_clnt)
+static struct rpc_clnt *get_clnt(struct net *xprt_net, bool global_clnt)
 {
 	struct rpc_clnt *clnt;
 	int err;
@@ -139,7 +139,7 @@ static struct rpc_clnt *get_clnt(bool global_clnt)
 	if (global_clnt && gssp_clnt)
 		return gssp_clnt;
 
-	err = gssp_rpc_create(&clnt);
+	err = gssp_rpc_create(xprt_net, &clnt);
 	if (err) {
 		mutex_unlock(&gssp_clnt_mutex);
 		return NULL;
@@ -164,13 +164,13 @@ static void kill_clnt(struct rpc_clnt *clnt)
 	mutex_unlock(&gssp_clnt_mutex);
 }
 
-static int gssp_call(struct rpc_message *msg)
+static int gssp_call(struct net *xprt_net, struct rpc_message *msg)
 {
 	struct rpc_clnt *clnt;
 	int status;
 
 	/* for now always create new one */
-	clnt = get_clnt(false);
+	clnt = get_clnt(xprt_net, false);
 
 	status = rpc_call_sync(clnt, msg, 0);
 	if (status < 0) {
@@ -213,7 +213,8 @@ static int gssp_call(struct rpc_message *msg)
 			GSSX_max_princ_sz + \
 			sizeof(struct svc_cred))
 
-int gssp_accept_sec_context_upcall(struct gssp_upcall_data *data)
+int gssp_accept_sec_context_upcall(struct net *xprt_net,
+				struct gssp_upcall_data *data)
 {
 	struct gssx_arg_accept_sec_context arg;
 	struct gssx_res_accept_sec_context res;
@@ -272,7 +273,7 @@ int gssp_accept_sec_context_upcall(struct gssp_upcall_data *data)
 	res.delegated_cred_handle = &delegcred;
 
 	/* make upcall */
-	ret = gssp_call(&msg);
+	ret = gssp_call(xprt_net, &msg);
 
 	/* we need to fetch all data even in case of error so
 	 * that we can free special strctures is they have been allocated */
diff --git a/net/sunrpc/auth_gss/gss_rpc_upcall.h b/net/sunrpc/auth_gss/gss_rpc_upcall.h
index b09217740493e83979f8dc690b812d396db6e54c..327a1952be688bcc445d7314ad6e4feb6a44deef 100644
--- a/net/sunrpc/auth_gss/gss_rpc_upcall.h
+++ b/net/sunrpc/auth_gss/gss_rpc_upcall.h
@@ -37,7 +37,8 @@ struct gssp_upcall_data {
 	int minor_status;
 };
 
-int gssp_accept_sec_context_upcall(struct gssp_upcall_data *data);
+int gssp_accept_sec_context_upcall(struct net *xprt_net,
+				struct gssp_upcall_data *data);
 void gssp_free_upcall_data(struct gssp_upcall_data *data);
 
 #endif /* _GSS_RPC_UPCALL_H */
-- 
1.7.7.6


--=-cdmda4z1HNzDyil4SJvF
Content-Disposition: attachment; filename="0002-make-svcauth_gss.c-container-safe.patch"
Content-Type: text/x-patch; name="0002-make-svcauth_gss.c-container-safe.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

>From 6efe0d79d2e3bbece469c28074b1f09c89ad63a3 Mon Sep 17 00:00:00 2001
From: Simo Sorce <simo@redhat.com>
Date: Tue, 22 May 2012 10:27:26 -0400
Subject: [PATCH 2/2] make svcauth_gss.c container safe

---
 net/sunrpc/auth_gss/svcauth_gss.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index e06c6e01e6c4ad3cee8138069b2d75229f064233..5db8841690bc4e42f1c8954b0d28552b5ad7eff4 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1213,7 +1213,7 @@ static int svcauth_gss_proxy_init(struct svc_rqst *rqstp,
 	ret = SVC_CLOSE;
 
 	/* Perform synchronous upcall to gss-proxy */
-	status = gssp_accept_sec_context_upcall(&ud);
+	status = gssp_accept_sec_context_upcall(rqstp->rq_xprt->xpt_net, &ud);
 	if (status) {
 		goto out;
 	}
-- 
1.7.7.6


--=-cdmda4z1HNzDyil4SJvF--

