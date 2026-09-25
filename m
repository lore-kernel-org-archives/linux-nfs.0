Received: from linux.microsoft.com (linux.microsoft.com [13.77.154.182])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 71A5F1C28E;
	Fri, 25 Sep 2026 01:53:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=13.77.154.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790301194; cv=none; b=A4EFCkRZd1v3nB8c22M3sy9aWWxpyDwDZe9cjtqD1LSJLxhnIJ881NhDv5mjEtRuEjLInuqOCEfdq4DgXK1YfCgSru9w9Tzc0FrRiRQ1AGjP05UpLD7TrxxwYWHnMnFNJ4xnCX0gM/td8sOlG0SGc/qGuwmXcZcOD46VHSpGqgo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790301194; c=relaxed/simple;
	bh=YbP9veqAGPQV0A9tHwhK7hbHLARLTMv35+KZa84WjIY=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=J6JcHVnVhe29fIVXnbhT6f17+x/zkEh+p0/ifIBIStumRCM3+50sayg3p6HY4g6DGsG/f9G1p+CwummmWH6mKb2Pi9iSDAjQUqeeQEyLthqC4s+9cXEvEHg8b0Mr8h7XTpzGg3y+UyrAg6tFw0+aAS9vJKJR34Xj0q2nPZBGW8Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.microsoft.com; spf=pass smtp.mailfrom=linux.microsoft.com; dkim=pass (1024-bit key) header.d=linux.microsoft.com header.i=@linux.microsoft.com header.b=Gywd1wS4; arc=none smtp.client-ip=13.77.154.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.microsoft.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.microsoft.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.microsoft.com header.i=@linux.microsoft.com header.b="Gywd1wS4"
Received: from mac.lan (unknown [4.194.122.170])
	by linux.microsoft.com (Postfix) with ESMTPSA id 86BF620B7167;
	Thu, 24 Sep 2026 18:52:10 -0700 (PDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 linux.microsoft.com 86BF620B7167
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linux.microsoft.com;
	s=default; t=1790301143;
	bh=WjVR2YR+EpxqRtke2XnuOUpQtN11VbZdN/DOg2qh+sk=;
	h=From:To:Cc:Subject:Date:From;
	b=Gywd1wS4vhQ/pIWDj4fpAl0HTPCgy1XcAQUZJNzq0vMXZkYq98bnXNnf9xkyLbN1p
	 XYIWy6ngdNfMgvTKX4KsD5fwsYlCxoWUs/d+JPeTJ2uoGtArFyrZI4KQeoJ4+aFwlw
	 4eFUqtulAtKhSELZPDnBmpKNAqf435WwM5NiLSPY=
From: "Cen Zhang (Microsoft)" <cenzhang@linux.microsoft.com>
To: Chuck Lever <cel@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	AutonomousCodeSecurity@microsoft.com,
	Francis Perron <francis@akrites.dev>,
	tgopinath@linux.microsoft.com,
	kys@microsoft.com,
	Cen Zhang <cenzhang@linux.microsoft.com>
Subject: [PATCH] sunrpc: reject AUTH_TLS on backchannel to prevent NULL-deref in svcauth_tls_accept
Date: Thu, 24 Sep 2026 21:52:51 -0400
Message-ID: <20260925015251.21168-1-cenzhang@linux.microsoft.com>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

svcauth_tls_accept() dereferences rqstp->rq_xprt unconditionally when
it tests xprt->xpt_ops->xpo_handshake, but on the NFSv4.1 backchannel
path (svc_process_bc), rq_xprt is NULL because no server-side transport
exists. A malicious NFS server can send AUTH_TLS (flavor 7) on the
backchannel to trigger a NULL pointer dereference in the client kernel.

  general protection fault, probably for non-canonical address
   0xdffffc0000000001
  KASAN: null-ptr-deref in range [0x0000000000000008-0x000000000000000f]
  RIP: 0010:svcauth_tls_accept+0x258/0x820
  svc_authenticate+0x2ab/0x3e0
  svc_process_common+0x8ff/0x1cf0
  svc_process_bc+0x5a8/0xbb0
  nfs4_callback_svc+0xcf/0x170

Reject AUTH_TLS early when rq_xprt is NULL, since TLS transport
upgrade is meaningless on the backchannel which has no svc_xprt.

Fixes: 74aaf96feaca ("SUNRPC: Teach server to recognize RPC_AUTH_TLS")
Reported-by: AutonomousCodeSecurity@microsoft.com
Reviewed-by: Francis Perron <francis@akrites.dev>
Signed-off-by: Cen Zhang (Microsoft) <cenzhang@linux.microsoft.com>
Assisted-by: GitHub-Copilot:claude-opus-4.6
---
 net/sunrpc/svcauth_unix.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 31a1bc60a5f6..42149139e58d 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -1129,6 +1129,12 @@ svcauth_tls_accept(struct svc_rqst *rqstp)
 		return SVC_DENIED;
 	}
 
+	/* AUTH_TLS is not valid on backchannel (rq_xprt is NULL) */
+	if (!xprt) {
+		rqstp->rq_auth_stat = rpc_autherr_badcred;
+		return SVC_DENIED;
+	}
+
 	/* Signal that mapping to nobody uid/gid is required */
 	cred->cr_uid = INVALID_UID;
 	cred->cr_gid = INVALID_GID;

-- 
2.55.0
