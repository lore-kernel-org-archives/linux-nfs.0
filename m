Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 47F2A7E0E4
	for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2026 20:46:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783889163; cv=none; b=ETKydo7NAFb/QJscvIstQN3j23Fsrf72XYI8sD5Zpg61nZaA01RaZvOtNick1tOfTfywmaueRUSBnm8/rNXgVkjfMN21ocZDKZOeD48mznMMv/0bS1ClbJiYWlf88BzGH36fvebYsn0xac3313sR46OuwlBsjW1TgDtpXNFDiOc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783889163; c=relaxed/simple;
	bh=YBG/7VGKyo38lrX4mxtr0j2Bm6EOFMo2GYA4hgMQOMk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=F05OuGu13ePyotKahf2Dk0+O8SOqHX/H+mEnYI4m2tToE0Iwq3KaniRMuLsMhq1CYgNMfZ9AEL11+C0qu2g2dlGXBv75HMgmaO9IDeEi48aJFazRyTaUr0+p7t37FHVps5oCIWUtuTWc4ytE/gIzbffOE8aHM5fBttlpRqaq7kY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bmU1Mi46; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bmU1Mi46"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A66621F00A3D;
	Sun, 12 Jul 2026 20:46:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783889162;
	bh=Kj7tNUCWMpEM1YDIXR7JWd/Ig+7qZZpjlM2sMqw+3FY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=bmU1Mi467X47a4rZpUcKEsmptmNdEPnxjI6EGP6aYpLqLRvBYItd3NiSeme0e2tZk
	 wK6XkTYRA7Qd4BZdG1Dv7OebsiXfwNOkRvSID1BdEcP8LLi0ZPvKtAJ6lY6byGMxVh
	 MdIKKfiUxocHGVJ6PCftcUW8kdlH++bwVPzf5H40D4QdsTFYbUqeK4vT/ViGF5WnZS
	 66Rssod/qrYGQotf49tJNanKua+z/gMf3n7yj63PaMpPz2UW+AtwGhtlwNqPDQQ5Qi
	 R4ZvmwN7fnIwUNcGX+yC9C+Wrcc1IysRU6RSrWQGxjsVPMZanH3hkoXt9B5lbStDnx
	 YQAPoNZj0rVtg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 8/9] NFSD: Relocate nfsd4_set_netaddr()
Date: Sun, 12 Jul 2026 16:45:53 -0400
Message-ID: <20260712204554.125308-9-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260712204554.125308-1-cel@kernel.org>
References: <20260712204554.125308-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Clean up: Common practice in the Linux kernel is to avoid the use of
static inline functions when there is only a single call site. The
30-line helper function is removed from a header pulled into ~25 .c
files, removing <linux/sunrpc/addr.h> from that header's transitive
include surface, dropping a now-redundant <linux/sunrpc/msg_prot.h>
include, and reducing the function's visibility to the one translation
unit that uses it.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4proc.c | 31 +++++++++++++++++++++++++++++++
 fs/nfsd/nfsd.h     | 33 ---------------------------------
 2 files changed, 31 insertions(+), 33 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 669896be08b6..59889cdca109 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2313,6 +2313,37 @@ nfsd4_offload_cancel(struct svc_rqst *rqstp,
 	return nfs_ok;
 }
 
+static __be32
+nfsd4_set_netaddr(struct sockaddr *addr, struct nfs42_netaddr *netaddr)
+{
+	struct sockaddr_in *sin = (struct sockaddr_in *)addr;
+	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)addr;
+	unsigned int port;
+	size_t ret_addr, ret_port;
+
+	switch (addr->sa_family) {
+	case AF_INET:
+		port = ntohs(sin->sin_port);
+		sprintf(netaddr->netid, "tcp");
+		netaddr->netid_len = 3;
+		break;
+	case AF_INET6:
+		port = ntohs(sin6->sin6_port);
+		sprintf(netaddr->netid, "tcp6");
+		netaddr->netid_len = 4;
+		break;
+	default:
+		return nfserr_inval;
+	}
+	ret_addr = rpc_ntop(addr, netaddr->addr, sizeof(netaddr->addr));
+	ret_port = snprintf(netaddr->addr + ret_addr,
+			    RPCBIND_MAXUADDRLEN + 1 - ret_addr,
+			    ".%u.%u", port >> 8, port & 0xff);
+	WARN_ON(ret_port >= RPCBIND_MAXUADDRLEN + 1 - ret_addr);
+	netaddr->addr_len = ret_addr + ret_port;
+	return 0;
+}
+
 static __be32
 nfsd4_copy_notify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		  union nfsd4_op_u *u)
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 81312b11b5c2..33015657b16f 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -18,8 +18,6 @@
 #include <linux/nfs4.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/svc_xprt.h>
-#include <linux/sunrpc/msg_prot.h>
-#include <linux/sunrpc/addr.h>
 
 #include <uapi/linux/nfsd/debug.h>
 
@@ -450,37 +448,6 @@ enum {
 
 extern const u32 nfsd_suppattrs[3][3];
 
-static inline __be32 nfsd4_set_netaddr(struct sockaddr *addr,
-				    struct nfs42_netaddr *netaddr)
-{
-	struct sockaddr_in *sin = (struct sockaddr_in *)addr;
-	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)addr;
-	unsigned int port;
-	size_t ret_addr, ret_port;
-
-	switch (addr->sa_family) {
-	case AF_INET:
-		port = ntohs(sin->sin_port);
-		sprintf(netaddr->netid, "tcp");
-		netaddr->netid_len = 3;
-		break;
-	case AF_INET6:
-		port = ntohs(sin6->sin6_port);
-		sprintf(netaddr->netid, "tcp6");
-		netaddr->netid_len = 4;
-		break;
-	default:
-		return nfserr_inval;
-	}
-	ret_addr = rpc_ntop(addr, netaddr->addr, sizeof(netaddr->addr));
-	ret_port = snprintf(netaddr->addr + ret_addr,
-			    RPCBIND_MAXUADDRLEN + 1 - ret_addr,
-			    ".%u.%u", port >> 8, port & 0xff);
-	WARN_ON(ret_port >= RPCBIND_MAXUADDRLEN + 1 - ret_addr);
-	netaddr->addr_len = ret_addr + ret_port;
-	return 0;
-}
-
 static inline bool bmval_is_subset(const u32 *bm1, const u32 *bm2)
 {
 	return !((bm1[0] & ~bm2[0]) ||
-- 
2.54.0

