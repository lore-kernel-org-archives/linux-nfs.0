Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 84DB636B91A
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 13:50:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790949030; cv=none; b=D8Ztho5XpAzh5ITmwVVQ1kGgWRb11U6CHJOeF9GNU31mRBascOBTZ7oiRE60Q7+6e/XAdp4T3BHrFNYGDrphuWJwATE1P648F6huh+/JhVStF0Y3ed4ODvljxwZMZvY3nOCERgQ/XCbh+4M8f5+poouFAu8dUh8VeQ3vE4TV9CA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790949030; c=relaxed/simple;
	bh=fGDDHYUKZImBjtf+NI72FRa0hnxs87tPGm8ocNISgaw=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=laGzxsoJzNS8ZmpC9hL7zkQt9CZBFK0qGkdV4ieFah3D8qGBcbIUlDSMCUTgv7gcmrGuve3FxZFDvr2tdtJvaJDWjE/9aGvknGEg7kULxqS45yjQ+TOSwNnAdkffcscqLON7Oe92PCFCfkrt9hvNEOS8oAd5rXn0PeM4R6p94gI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=C5bM5Aky; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="C5bM5Aky"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CAD991F000FF;
	Fri,  2 Oct 2026 13:50:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790949029;
	bh=7uGgFj4Dyn1QJuQtg7IZDa2g+O/u+su7sYuJKj1gELk=;
	h=From:To:Cc:Subject:Date;
	b=C5bM5AkyW33PPPIX+Da5Ecvya5TdE+Kj3f+mm4pbld3eUyhxSrs0zRF9HueMsWYzD
	 r9lifEOJpHhaVnVx4WZT2sQIKOH4Qj9rTeRGMPfgP7i2mVM0Q7AQjOIqnUz0xrF9gT
	 P0Ml9Y1TuXVQGZ1VDdp0+0IzI5qOpl7s9N1yiU6yk2ZczTz33qamAmN5iMFOlXh8Uq
	 LpMZDx2finoShJUypkEVqMdsNqGBHpEp1KBUzZOvWbDNb6Y4ncfrhlAemdGxRyXUBr
	 F+93fOfqaH2J9vAg7diOwvhARUjhJiay7aj2aC861SANOjiMV19Pad+/DJNUmSP9QD
	 hNusr/RermLSw==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: preserve RQ_SECURE across request deferral
Date: Fri,  2 Oct 2026 09:50:27 -0400
Message-ID: <20261002135027.72494-1-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Commit 319951eba0fc ("SUNRPC: Remove ->xpo_secure_port()") moved the
setting of RQ_SECURE from svc_recv() into each transport's
->xpo_recvfrom(). But a deferred request is replayed through
svc_deferred_recv(), which bypasses ->xpo_recvfrom(), so RQ_SECURE is
no longer recomputed for it. The replaying thread instead carries
whatever RQ_SECURE value was left behind by the last request it
processed, and svc_defer() does not save the original value.

An AUTH_SYS request from a privileged port can therefore be deferred
on an ip_map or export cache upcall and then replayed by a thread
whose RQ_SECURE is clear (e.g. a newly created nfsd thread, whose
svc_rqst is zero-allocated). nfsd_setuser_and_check_port() then
rejects it with nfserr_perm on an export that lacks "insecure".
Conversely, a request from an unprivileged port can be replayed with
a stale RQ_SECURE set and pass that check.

Deferral is most likely right after an NFS server restart, when the
auth caches are empty and every client reconnects at once: if a pool
has no idle threads, cache_wait_req() waits only one second for the
upcall before deferring. This was observed as NFSv3 clients getting
EPERM shortly after a server reboot.

Save RQ_SECURE in struct svc_deferred_req when the request is first
deferred and restore it in svc_deferred_recv(). Restoring the saved
bit, rather than recomputing it from the peer address, keeps it
correct for transports such as RDMA that set RQ_SECURE
unconditionally.

Fixes: 319951eba0fc ("SUNRPC: Remove ->xpo_secure_port()")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-opus-5-5
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 include/linux/sunrpc/svc.h | 1 +
 net/sunrpc/svc_xprt.c      | 7 +++++++
 2 files changed, 8 insertions(+)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index bdff8ccb92c77..2906481644f7a 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -382,6 +382,7 @@ struct svc_deferred_req {
 	struct sockaddr_storage	daddr;	/* where reply must come from */
 	size_t			daddrlen;
 	void			*xprt_ctxt;
+	bool			secure;	/* RQ_SECURE of the original request */
 	struct cache_deferred_req handle;
 	int			argslen;
 	__be32			args[];
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 0de613b36fffc..bf5b2cdad35ea 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -1343,6 +1343,7 @@ static struct cache_deferred_req *svc_defer(struct cache_req *req)
 		memcpy(&dr->addr, &rqstp->rq_addr, rqstp->rq_addrlen);
 		dr->addrlen = rqstp->rq_addrlen;
 		dr->daddr = rqstp->rq_daddr;
+		dr->secure = test_bit(RQ_SECURE, &rqstp->rq_flags);
 		dr->argslen = rqstp->rq_arg.len >> 2;
 
 		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base,
@@ -1377,6 +1378,12 @@ static noinline int svc_deferred_recv(struct svc_rqst *rqstp)
 	rqstp->rq_addrlen     = dr->addrlen;
 	rqstp->rq_daddr       = dr->daddr;
 	rqstp->rq_xprt_ctxt   = dr->xprt_ctxt;
+	/*
+	 * ->xpo_recvfrom() is bypassed for a deferred request, so the
+	 * replaying thread's RQ_SECURE is stale from whatever request
+	 * it handled last. Restore the value computed at receive time.
+	 */
+	assign_bit(RQ_SECURE, &rqstp->rq_flags, dr->secure);
 
 	dr->xprt_ctxt = NULL;
 	svc_xprt_received(rqstp->rq_xprt);
-- 
2.52.0

