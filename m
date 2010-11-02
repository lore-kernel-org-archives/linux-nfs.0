Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7401 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752479Ab0KBNPG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Nov 2010 09:15:06 -0400
Subject: Re: Regression, bisected: sqlite locking failure on nfs
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Nick Bowler <nbowler@elliptictech.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        LKML Kernel <linux-kernel@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <20101101203315.GA3600@elliptictech.com>
References: <20101101175854.GA3550@elliptictech.com>
	 <D68536EB-6BE9-4DE4-B325-39FEF747092E@oracle.com>
	 <20101101181938.GA3875@elliptictech.com>
	 <187AEE96-9231-4899-9D65-A444503D2758@oracle.com>
	 <1288639376.5009.16.camel@heimdal.trondhjem.org>
	 <1288640536.5009.18.camel@heimdal.trondhjem.org>
	 <DA1E14E0-DCCD-4A6D-9471-E627D4BF2E85@oracle.com>
	 <1288640888.5009.19.camel@heimdal.trondhjem.org>
	 <1288642170.5009.23.camel@heimdal.trondhjem.org>
	 <20101101203315.GA3600@elliptictech.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 02 Nov 2010 09:14:31 -0400
Message-ID: <1288703671.2925.1.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-11-01 at 16:33 -0400, Nick Bowler wrote:
> On 2010-11-01 16:09 -0400, Trond Myklebust wrote:
> > Urgh, but nlmclnt_bind_host() will still set .saddress.
> > 
> > OK. Here is take 2 of the patch...
> [...]
> > NLM: Fix a regression in lockd
> 
> Problem occurs with this one (on top of 2.6.37-rc1), too :(
> 

OK. Can you please try the following? It only differs from the last one
by a small bugfix, and a WARN_ON() in order to try to catch other
occurrences of the same bug.

Cheers
  Trond
------------------------------------------------------------------------------------------------
NLM: Fix a regression in lockd

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Nick Bowler reports:
There are no unusual messages on the client... but I just logged into
the server and I see lots of messages of the following form:

  nfsd: request from insecure port (192.168.8.199:35766)!
  nfsd: request from insecure port (192.168.8.199:35766)!
  nfsd: request from insecure port (192.168.8.199:35766)!
  nfsd: request from insecure port (192.168.8.199:35766)!
  nfsd: request from insecure port (192.168.8.199:35766)!

Bisected to commit 9247685088398cf21bcb513bd2832b4cd42516c4 (SUNRPC:
Properly initialize sock_xprt.srcaddr in all cases)

Apparently, removing the 'transport->srcaddr.ss_family = family' from
xs_create_sock() triggers this due to nlmclnt_lookup_host() incorrectly
initialising the srcaddr family to AF_UNSPEC.

Reported-by: Nick Bowler <nbowler@elliptictech.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/lockd/host.c             |   11 ++++-------
 include/linux/lockd/lockd.h |    1 +
 net/sunrpc/clnt.c           |    2 ++
 3 files changed, 7 insertions(+), 7 deletions(-)


diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 25e21e4..ed0c59f 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -124,7 +124,7 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 			continue;
 		if (host->h_server != ni->server)
 			continue;
-		if (ni->server &&
+		if (ni->server && ni->src_len != 0 &&
 		    !rpc_cmp_addr(nlm_srcaddr(host), ni->src_sap))
 			continue;
 
@@ -167,6 +167,7 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 	host->h_addrlen = ni->salen;
 	rpc_set_port(nlm_addr(host), 0);
 	memcpy(nlm_srcaddr(host), ni->src_sap, ni->src_len);
+	host->h_srcaddrlen = ni->src_len;
 	host->h_version    = ni->version;
 	host->h_proto      = ni->protocol;
 	host->h_rpcclnt    = NULL;
@@ -238,9 +239,6 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
 				     const char *hostname,
 				     int noresvport)
 {
-	const struct sockaddr source = {
-		.sa_family	= AF_UNSPEC,
-	};
 	struct nlm_lookup_host_info ni = {
 		.server		= 0,
 		.sap		= sap,
@@ -249,8 +247,6 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
 		.version	= version,
 		.hostname	= hostname,
 		.hostname_len	= strlen(hostname),
-		.src_sap	= &source,
-		.src_len	= sizeof(source),
 		.noresvport	= noresvport,
 	};
 
@@ -357,7 +353,6 @@ nlm_bind_host(struct nlm_host *host)
 			.protocol	= host->h_proto,
 			.address	= nlm_addr(host),
 			.addrsize	= host->h_addrlen,
-			.saddress	= nlm_srcaddr(host),
 			.timeout	= &timeparms,
 			.servername	= host->h_name,
 			.program	= &nlm_program,
@@ -376,6 +371,8 @@ nlm_bind_host(struct nlm_host *host)
 			args.flags |= RPC_CLNT_CREATE_HARDRTRY;
 		if (host->h_noresvport)
 			args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
+		if (host->h_srcaddrlen)
+			args.saddress = nlm_srcaddr(host);
 
 		clnt = rpc_create(&args);
 		if (!IS_ERR(clnt))
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index a34dea4..2dee05e 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -43,6 +43,7 @@ struct nlm_host {
 	struct sockaddr_storage	h_addr;		/* peer address */
 	size_t			h_addrlen;
 	struct sockaddr_storage	h_srcaddr;	/* our address (optional) */
+	size_t			h_srcaddrlen;
 	struct rpc_clnt		*h_rpcclnt;	/* RPC client to talk to peer */
 	char			*h_name;		/* remote hostname */
 	u32			h_version;	/* interface version */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 9dab957..fba8b29 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -322,6 +322,8 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 		args->servername = servername;
 	}
 
+	WARN_ON(args->saddress && args->saddress->sa_family != args->address->sa_family);
+
 	xprt = xprt_create_transport(&xprtargs);
 	if (IS_ERR(xprt))
 		return (struct rpc_clnt *)xprt;

