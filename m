From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 4/6] nfsd: convert nfs4_cb_conn struct to hold address in sockaddr_storage
Date: Fri, 14 Aug 2009 12:57:57 -0400
Message-ID: <1250269079-14629-5-git-send-email-jlayton@redhat.com>
References: <1250269079-14629-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: bfields@fieldses.org, chuck.lever@oracle.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55283 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754031AbZHNQ6H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Aug 2009 12:58:07 -0400
In-Reply-To: <1250269079-14629-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...rather than as a separate address and port fields. This will be
necessary for implementing callbacks over IPv6. Also, convert
gen_callback to use the standard rpcuaddr2sockaddr routine rather than
its own private one.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4callback.c     |   11 +-----
 fs/nfsd/nfs4state.c        |   81 +++++---------------------------------------
 include/linux/nfsd/state.h |    4 +-
 3 files changed, 13 insertions(+), 83 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 3fd23f7..81d1c52 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -377,7 +377,6 @@ static int max_cb_time(void)
 
 int setup_callback_client(struct nfs4_client *clp)
 {
-	struct sockaddr_in	addr;
 	struct nfs4_cb_conn *cb = &clp->cl_cb_conn;
 	struct rpc_timeout	timeparms = {
 		.to_initval	= max_cb_time(),
@@ -385,8 +384,8 @@ int setup_callback_client(struct nfs4_client *clp)
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
@@ -400,12 +399,6 @@ int setup_callback_client(struct nfs4_client *clp)
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
index bfc14d8..96a7423 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -897,76 +897,6 @@ find_unconfirmed_client_by_str(const char *dname, unsigned int hashval,
 	return NULL;
 }
 
-/* a helper function for parse_callback */
-static int
-parse_octet(unsigned int *lenp, char **addrp)
-{
-	unsigned int len = *lenp;
-	char *p = *addrp;
-	int n = -1;
-	char c;
-
-	for (;;) {
-		if (!len)
-			break;
-		len--;
-		c = *p++;
-		if (c == '.')
-			break;
-		if ((c < '0') || (c > '9')) {
-			n = -1;
-			break;
-		}
-		if (n < 0)
-			n = 0;
-		n = (n * 10) + (c - '0');
-		if (n > 255) {
-			n = -1;
-			break;
-		}
-	}
-	*lenp = len;
-	*addrp = p;
-	return n;
-}
-
-/* parse and set the setclientid ipv4 callback address */
-static int
-parse_ipv4(unsigned int addr_len, char *addr_val, unsigned int *cbaddrp, unsigned short *cbportp)
-{
-	int temp = 0;
-	u32 cbaddr = 0;
-	u16 cbport = 0;
-	u32 addrlen = addr_len;
-	char *addr = addr_val;
-	int i, shift;
-
-	/* ipaddress */
-	shift = 24;
-	for(i = 4; i > 0  ; i--) {
-		if ((temp = parse_octet(&addrlen, &addr)) < 0) {
-			return 0;
-		}
-		cbaddr |= (temp << shift);
-		if (shift > 0)
-		shift -= 8;
-	}
-	*cbaddrp = cbaddr;
-
-	/* port */
-	shift = 8;
-	for(i = 2; i > 0  ; i--) {
-		if ((temp = parse_octet(&addrlen, &addr)) < 0) {
-			return 0;
-		}
-		cbport |= (temp << shift);
-		if (shift > 0)
-			shift -= 8;
-	}
-	*cbportp = cbport;
-	return 1;
-}
-
 static void
 gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se)
 {
@@ -976,14 +906,21 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se)
 	if ((se->se_callback_netid_len != 3) || memcmp((char *)se->se_callback_netid_val, "tcp", 3))
 		goto out_err;
 
-	if ( !(parse_ipv4(se->se_callback_addr_len, se->se_callback_addr_val,
-	                 &cb->cb_addr, &cb->cb_port)))
+	cb->cb_addrlen = rpc_uaddr2sockaddr(se->se_callback_addr_val,
+					    se->se_callback_addr_len,
+					    (struct sockaddr *) &cb->cb_addr,
+					    sizeof(cb->cb_addr));
+
+	if (!cb->cb_addrlen || cb->cb_addr.ss_family != AF_INET)
 		goto out_err;
+
 	cb->cb_minorversion = 0;
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
index 3510ddd..fb0c404 100644
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
 	u32			cb_minorversion;
 	u32                     cb_ident;	/* minorversion 0 only */
-- 
1.6.0.6

