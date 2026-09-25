Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4E3BA4B0E41
	for <linux-nfs@vger.kernel.org>; Fri, 25 Sep 2026 15:13:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790349247; cv=none; b=c8oWU8a2bHWNj2BiwB1UIHd6kI2Mvtb6kcOS9h8M2TFnZ62GH2lk1rZ4H5qDTyPkJlumtyhrYu80sQW5B75vWtE3irewGur2L2iDxKvT1Xsi6Xk5o+6pEDmNZEJlPXuv+RenF8l3gGL7qG4bcojDvr3LczSRbTAJjQvXNdwfhSU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790349247; c=relaxed/simple;
	bh=KpYp3Mv+QrwWXLluF6ROL9BmfajLQBDxaE3yt3F8kh0=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=fMWO5cW6qkTq1qHhhNG7I8C4BXX4z2PHEK4sqcaVcEvNxrpK35v1cUwoPvegocnJRF27unrDRZrWFnpfvnVEFoTZ6N2lADaZLZKodLa7J+83tfl1OLJmCz8shD3HoHLpvvwMxwx8KXOg0MkTtJfyXCGL6bPy1U34myxOl1DlOCc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jq6DPUNJ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jq6DPUNJ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A7B381F000FF;
	Fri, 25 Sep 2026 15:13:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790349225;
	bh=Gjf7UVQEaozUfXFZkg/2YO5wW/cx3wk5Kl5E28uAi7E=;
	h=From:To:Cc:Subject:Date;
	b=jq6DPUNJEaB2g1AJXRpT9dTfVQ5mCKXZAJ0UPkRRGWCiGK1i9YBAflrRJKAWJnGzy
	 VVo1Up6wIOpWUBIXF6fYOGwWtQol5hYqarshRoEwIRerH818/PFhA8pOvL+h+qcT3X
	 Dep/F2zlpn5QLwsYWd5eLxe1dH1QH3aQso6nQsVpDtvKHV975PmX7nBn5bum+OZuF4
	 YoFs11gma49s1bH5O7OExNxN0jrBsGGCOouFqAdvZ9ayOpTyTC9NGZrwiqDTkVZg3K
	 27rFCtTolZg8b/hKKpqbPfzg0detSy+PmaNAOSGkZCo0Fog7JrqWkWQdgUyvEW/O+V
	 giRZF2d0hecqw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1] SUNRPC: offer RPC-with-TLS only on services that implement it
Date: Fri, 25 Sep 2026 11:13:43 -0400
Message-ID: <20260925151343.529200-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

svcauth_tls_accept() offers STARTTLS on every service whose
transport class has a handshake method. The NFSv4.0 callback
service listens on TCP, so an NFS server that sends CB_NULL with
AUTH_TLS gets a STARTTLS reply. The callback thread then blocks in
svc_tcp_handshake() for up to SVC_HANDSHAKE_TO, waiting for a
handshake the NFS client is not configured to complete. The
callback service runs a small thread pool shared by every NFSv4.0
server in the network namespace, so a malicious server can stall
callbacks from other servers by repeating the probe on each
reconnect. lockd has the same exposure. It runs a single thread on
every NFS client host to receive NLM_GRANTED callbacks and does not
support RPC-with-TLS.

Add a per-service flag that a service sets when it implements
RPC-with-TLS, and have svcauth_tls_accept() answer an AUTH_TLS
probe on any other service with a plain AUTH_NULL verifier, as
RFC 9289 Section 4.1 prescribes for a server that does not support
TLS. NFSD is the only service that sets the flag.

Fixes: 74aaf96feaca ("SUNRPC: Teach server to recognize RPC_AUTH_TLS")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfssvc.c           | 1 +
 include/linux/sunrpc/svc.h | 2 ++
 net/sunrpc/svcauth_unix.c  | 2 +-
 3 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index ffc58a76c1fc..3705dba837e7 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -680,6 +680,7 @@ int nfsd_create_serv(struct net *net, bool no_rpcbind)
 		return -ENOMEM;
 	}
 	serv->sv_reply_sent = nfsd_cache_reply_sent;
+	serv->sv_tls = true;
 
 	/* svc_bind() reads this, so set it first. */
 	serv->sv_no_rpcbind = no_rpcbind;
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index bdff8ccb92c7..5af08e326146 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -91,6 +91,8 @@ struct svc_serv {
 	bool			sv_is_pooled;	/* is this a pooled service? */
 	/* Caller registers with rpcbind itself. Set before svc_bind(). */
 	bool			sv_no_rpcbind;
+	/* Service implements RPC-with-TLS; offer STARTTLS to AUTH_TLS probes. */
+	bool			sv_tls;
 	struct svc_pool *	sv_pools;	/* array of thread pools */
 	int			(*sv_threadfn)(void *data);
 
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 1e5a421ef2cb..ad8a73653e42 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -1151,7 +1151,7 @@ svcauth_tls_accept(struct svc_rqst *rqstp)
 	if (cred->cr_group_info == NULL)
 		return SVC_CLOSE;
 
-	if (xprt->xpt_ops->xpo_handshake) {
+	if (xprt->xpt_ops->xpo_handshake && rqstp->rq_server->sv_tls) {
 		p = xdr_reserve_space(&rqstp->rq_res_stream, XDR_UNIT * 2 + 8);
 		if (!p)
 			return SVC_CLOSE;
-- 
2.54.0

