From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] Wrap buffers used for rpc debug printks into RPC_IFDEBUG
Date: Thu, 21 Feb 2008 10:57:45 +0300
Message-ID: <47BD2EF9.4010309@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:48484 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751027AbYBUIcK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 03:32:10 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for the noise, but here's the v3 of this compilation fix :)

There are some places, which declare the char buf[...] on the stack
to push it later into dprintk(). Since the dprintk sometimes (if the 
CONFIG_SYSCTL=n) becomes an empty do { } while (0) stub, these buffers
cause gcc to produce appropriate warnings.

Wrap these buffers with RPC_IFDEBUG macro, as Trond proposed, to 
compile them out when not needed.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 0822646..1ed8bd4 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -153,7 +153,7 @@ lockd(struct svc_rqst *rqstp)
 	 */
 	while ((nlmsvc_users || !signalled()) && nlmsvc_pid == current->pid) {
 		long timeout = MAX_SCHEDULE_TIMEOUT;
-		char buf[RPC_MAX_ADDRBUFLEN];
+		RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 
 		if (signalled()) {
 			flush_signals(current);
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index ecc06c6..3431751 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -171,7 +171,7 @@ void nfs_callback_down(void)
 static int nfs_callback_authenticate(struct svc_rqst *rqstp)
 {
 	struct nfs_client *clp;
-	char buf[RPC_MAX_ADDRBUFLEN];
+	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 
 	/* Don't talk to strangers */
 	clp = nfs_find_client(svc_addr(rqstp), 4);
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 0130b34..1eb771d 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -101,7 +101,7 @@ static __be32 nfsd_setuser_and_check_port(struct svc_rqst *rqstp,
 {
 	/* Check if the request originated from a secure port. */
 	if (!rqstp->rq_secure && EX_SECURE(exp)) {
-		char buf[RPC_MAX_ADDRBUFLEN];
+		RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 		dprintk(KERN_WARNING
 		       "nfsd: request from insecure port %s!\n",
 		       svc_print_addr(rqstp, buf, sizeof(buf)));
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 1d3e5fc..c475977 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -175,7 +175,7 @@ static int svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
 	size_t		base = xdr->page_base;
 	unsigned int	pglen = xdr->page_len;
 	unsigned int	flags = MSG_MORE;
-	char		buf[RPC_MAX_ADDRBUFLEN];
+	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 
 	slen = xdr->len;
 
@@ -716,7 +716,7 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 	struct socket	*newsock;
 	struct svc_sock	*newsvsk;
 	int		err, slen;
-	char		buf[RPC_MAX_ADDRBUFLEN];
+	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 
 	dprintk("svc: tcp_accept %p sock %p\n", svsk, sock);
 	if (!sock)
@@ -1206,10 +1206,10 @@ static struct svc_xprt *svc_create_socket(struct svc_serv *serv,
 	struct socket	*sock;
 	int		error;
 	int		type;
-	char		buf[RPC_MAX_ADDRBUFLEN];
 	struct sockaddr_storage addr;
 	struct sockaddr *newsin = (struct sockaddr *)&addr;
 	int		newlen;
+	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 
 	dprintk("svc: svc_create_socket(%s, %d, %s)\n",
 			serv->sv_program->pg_name, protocol,
