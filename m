Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7128D4C754A
	for <linux-nfs@vger.kernel.org>; Fri, 25 Sep 2026 15:13:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790349216; cv=none; b=n5CsGVVrgoRtJrWLwsoGgoFYZQmJZAG3WBMPGsaOOqH/QxxqdbaDIjyK2sAbMGvxV2FiQxzvew42mhUU8Vobf+suAhHmd8sae+bE+o0NJzn+NeUvCHmeWQSLPOxSlr5F7+wRE6tp6uljGCK1R53zZtJ3nxc1NMHL/vajhadctmo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790349216; c=relaxed/simple;
	bh=pwfHzkbqzHHL5zUtAwZssQcuXMunOYvkPQTUOi7QIZ0=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=kSYpS0Th3xFGDe9iBK/BQnWaVu8tNoIso/QJG1SJ8lZv5X74MRnplME45wbRsg8ZFJqUE+9Nafmj534AW3cXLKeVUwJb2LRSQupl1JotSoM40CIFe5yaEK92/klzUir8WovVtnETbq2a8pEMz+jmzBPEz96BNQoAg2leB3ta8ec=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KQok1eqQ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KQok1eqQ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7E5D91F000FF;
	Fri, 25 Sep 2026 15:13:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790349200;
	bh=eOJ/x8tuGIoyOkf97SQz/XMA6PQHstiYXUOSn/a93NQ=;
	h=From:To:Cc:Subject:Date;
	b=KQok1eqQgJdModaUjIMaOQiF8Aswf5181Z7roIiknJ3KbwntfAPvgn6yCb3HeDWCP
	 xnu6DhqYbNPCmSC9BGrf05JafjzT6ZuXpt+7y1q+LDIHr5tWk874eA3bf0020MBhVk
	 WHCTe2u03TE9VUWxq8j+OXWip+qqU/jb2kqUxcM8bHtEohy7k7bRef5CNplFrTKhe2
	 /714zaC4k1EesStmWeU/GLgKUsVBpYfsPKmQVd1HV0v+fdf7unFpdRO6zkbK4Q3aaq
	 BhMM7gpj/eXDtwEhqVVSbMJRR6/y5R5r2JpF/QR1/xT1VWvdnkRxe58fXLz9DA1VFh
	 pBnwXDXQIZvvA==
From: Chuck Lever <cel@kernel.org>
To: Trond Myklebust <trond.myklebust@hammerspace.com>,
	Anna Schumaker <anna@kernel.org>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1] NFSv4.1: reject a minor version 0 CB_COMPOUND on the backchannel
Date: Fri, 25 Sep 2026 11:13:19 -0400
Message-ID: <20260925151319.528740-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfs4_callback_compound() selects the minor version 0 path from the
CB_COMPOUND header alone. A malicious or broken NFS server can send
a minor version 0 CB_COMPOUND over a session backchannel, where
rq_xprt is NULL. If the NFS client also holds a minor version 0
client ID in the same network namespace, the cb_ident lookup
succeeds and svc_xprt_set_valid() dereferences the NULL rq_xprt.

RFC 8881 Section 19.2.3 requires a CB_COMPOUND to carry the minor
version of the COMPOUND that created the session. Return
NFS4ERR_MINOR_VERS_MISMATCH for a minor version 0 CB_COMPOUND that
arrives on a backchannel.

Fixes: eccbbc7c00a5 ("nfsd: don't use sv_nrthreads in connection limiting calculations.")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs/callback_xdr.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 88e1af0fda01..378eacb5b6a9 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -951,7 +951,13 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp)
 	if (status == htonl(NFS4ERR_RESOURCE))
 		return rpc_garbage_args;
 
-	if (hdr_arg.minorversion == 0) {
+	if (hdr_arg.minorversion == 0 && svc_is_backchannel(rqstp)) {
+		/* RFC 8881 Section 19.2.3: a backchannel carries only the
+		 * minor version that created its session.
+		 */
+		pr_warn_ratelimited("NFS: NFSv4 backchannel callback with minor version 0\n");
+		status = htonl(NFS4ERR_MINOR_VERS_MISMATCH);
+	} else if (hdr_arg.minorversion == 0) {
 		cps.clp = nfs4_find_client_ident(SVC_NET(rqstp), hdr_arg.cb_ident);
 		if (!cps.clp) {
 			trace_nfs_cb_no_clp(rqstp->rq_xid, hdr_arg.cb_ident);
-- 
2.54.0

