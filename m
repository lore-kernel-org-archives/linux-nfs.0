From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/4] nfsd: convert nfs4_callback struct to hold address in sockaddr_storage
Date: Wed, 17 Jun 2009 14:15:38 -0400
Message-ID: <1245262541-9362-2-git-send-email-jlayton@redhat.com>
References: <1245262541-9362-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, bfields@fieldses.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:60752 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757380AbZFQSPs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jun 2009 14:15:48 -0400
In-Reply-To: <1245262541-9362-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...rather than as a separate address and port fields. This will be
necessary for implementing callbacks over IPv6.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4callback.c     |   11 ++---------
 fs/nfsd/nfs4state.c        |   13 +++++++++----
 include/linux/nfsd/state.h |    4 ++--
 3 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index f4fab69..0358563 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -368,7 +368,6 @@ static int max_cb_time(void)
 
 int setup_callback_client(struct nfs4_client *clp)
 {
-	struct sockaddr_in	addr;
 	struct nfs4_cb_conn *cb = &clp->cl_cb_conn;
 	struct rpc_timeout	timeparms = {
 		.to_initval	= max_cb_time(),
@@ -376,8 +375,8 @@ int setup_callback_client(struct nfs4_client *clp)
 	};
 	struct rpc_create_args args = {
 		.protocol	= IPPROTO_TCP,
-		.address	= (struct sockaddr *)&addr,
-		.addrsize	= sizeof(addr),
+		.address	= (struct sockaddr *) &cb->cb_addr,
+		.addrsize	= cb->cb_addrlen,
 		.timeout	= &timeparms,
 		.program	= &cb_program,
 		.prognumber	= cb->cb_prog,
@@ -391,12 +390,6 @@ int setup_callback_client(struct nfs4_client *clp)
 	if (!clp->cl_principal && (clp->cl_flavor >= RPC_AUTH_GSS_KRB5))
 		return -EINVAL;
 
-	/* Initialize address */
-	memset(&addr, 0, sizeof(addr));
-	addr.sin_family = AF_INET;
-	addr.sin_port = htons(cb->cb_port);
-	addr.sin_addr.s_addr = htonl(cb->cb_addr);
-
 	/* Create RPC client */
 	client = rpc_create(&args);
 	if (IS_ERR(client)) {
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d5caf2a..edb03d4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -932,7 +932,7 @@ parse_octet(unsigned int *lenp, char **addrp)
 
 /* parse and set the setclientid ipv4 callback address */
 static int
-parse_ipv4(unsigned int addr_len, char *addr_val, unsigned int *cbaddrp, unsigned short *cbportp)
+parse_ipv4(unsigned int addr_len, char *addr_val, struct sockaddr_in *s4)
 {
 	int temp = 0;
 	u32 cbaddr = 0;
@@ -941,6 +941,8 @@ parse_ipv4(unsigned int addr_len, char *addr_val, unsigned int *cbaddrp, unsigne
 	char *addr = addr_val;
 	int i, shift;
 
+	s4->sin_family = AF_INET;
+
 	/* ipaddress */
 	shift = 24;
 	for(i = 4; i > 0  ; i--) {
@@ -951,7 +953,7 @@ parse_ipv4(unsigned int addr_len, char *addr_val, unsigned int *cbaddrp, unsigne
 		if (shift > 0)
 		shift -= 8;
 	}
-	*cbaddrp = cbaddr;
+	s4->sin_addr.s_addr = htonl(cbaddr);
 
 	/* port */
 	shift = 8;
@@ -963,7 +965,7 @@ parse_ipv4(unsigned int addr_len, char *addr_val, unsigned int *cbaddrp, unsigne
 		if (shift > 0)
 			shift -= 8;
 	}
-	*cbportp = cbport;
+	s4->sin_port = htons(cbport);
 	return 1;
 }
 
@@ -977,12 +979,15 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se)
 		goto out_err;
 
 	if ( !(parse_ipv4(se->se_callback_addr_len, se->se_callback_addr_val,
-	                 &cb->cb_addr, &cb->cb_port)))
+			  (struct sockaddr_in *) &cb->cb_addr)))
 		goto out_err;
+	cb->cb_addrlen = sizeof(struct sockaddr_in);
 	cb->cb_prog = se->se_callback_prog;
 	cb->cb_ident = se->se_callback_ident;
 	return;
 out_err:
+	cb->cb_addr.ss_family = AF_UNSPEC;
+	cb->cb_addrlen = 0;
 	dprintk(KERN_INFO "NFSD: this client (clientid %08x/%08x) "
 		"will not receive delegations\n",
 		clp->cl_clientid.cl_boot, clp->cl_clientid.cl_id);
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 0ae4752..95a925c 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -81,8 +81,8 @@ struct nfs4_delegation {
 /* client delegation callback info */
 struct nfs4_cb_conn {
 	/* SETCLIENTID info */
-	u32                     cb_addr;
-	unsigned short          cb_port;
+	struct sockaddr_storage	cb_addr;
+	size_t			cb_addrlen;
 	u32                     cb_prog;
 	u32                     cb_ident;
 	/* RPC client info */
-- 
1.6.0.6

