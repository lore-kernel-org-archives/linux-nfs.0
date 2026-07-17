Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F16BB38836A
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 18:41:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784313680; cv=none; b=KRR19pYivccjPhknMVTrFqMZHNRm0LQet+hnh9Gg9V6Q6vgVlBOPLdis7Qz0PomSvBukXf2zhuuUftzqjftjEYLvHCCA1823vTkXDZNjJFQlIkQQj45zhJWB3oopBBcA7AZd5TRRzFyA6GjOmm4T1otj2unNArX/NJcBrzUkgsc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784313680; c=relaxed/simple;
	bh=4jWHt2KT+NB37/xIpRldUP+7Hx6pkRKTqLek0I5A59Q=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=PqLe0SCAUG0kwLuASYBRSl/XxIxyhg7q1/vkx0o0pf1CZ9rauUj/cPW80IO9WxhL16X2szY8cj7kumdYqI2M8LxJSGWAwRwaor9x+o7rCognhtBE2uL3qcwnoAU8Bvg3OT9M961gOe2KCA5Z2QhdDt+hbr3ypSmy+7BaK1H6Fso=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=CiSPEzuM; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="CiSPEzuM"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 536A91F00A3D;
	Fri, 17 Jul 2026 18:41:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784313678;
	bh=2Nc8v9RcLebWz83ostM45Doxs5+BPUJ/fH5s31O5NmQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=CiSPEzuMBbnqgCnwo3YEwAlYnrx7e0XG2tEtM67I1/CJljzl6fdkItQEd/rFyEnuR
	 sjoilEa+jgc99LVrT97c3XJoEnF7KnDdpH9Y74U9DHO4lp9YUv5PHrCr5uVKkN4w56
	 1DA+451kIgmRL6FVelNj0zs5Be71+fzLI620EhnI233NNxgkP1Ky1UAW/Ilp/ocwY3
	 ORPNDeecihPgPzU913/qb20N/UX4YIurPRFXeGGEU0dO71GySBCet35rK4lfQ5+7Hr
	 LRcl96KRK+HWgra6XnnnebLoJtIYRAoVRwrymohavxGoKVVSUozhbYTohCQNsWW2T0
	 Vp0AWZsQIz7Aw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 6/6] NFSD: Move nfsd_v4client() out of nfsd.h
Date: Fri, 17 Jul 2026 14:41:12 -0400
Message-ID: <20260717184112.507548-7-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260717184112.507548-1-cel@kernel.org>
References: <20260717184112.507548-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd_v4client() is the last user in nfsd.h of XDR-defined item
references. Once this helper moves out, <linux/nfs.h> and the other
XDR-specific headers nfsd.h includes have nothing left to provide,
and can be dropped.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfsd.h   | 5 +----
 fs/nfsd/nfssvc.c | 5 +++++
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 1cccf5a3c034..64315890eef5 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -146,10 +146,7 @@ extern u64 nfsd_io_cache_write __read_mostly;
 
 extern int nfsd_max_blksize;
 
-static inline int nfsd_v4client(struct svc_rqst *rq)
-{
-	return rq && rq->rq_prog == NFS_PROGRAM && rq->rq_vers == 4;
-}
+bool nfsd_v4client(struct svc_rqst *rqstp);
 
 /*
  * lockd binding
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 9cc8489978a3..c04ef9d180ce 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -207,6 +207,11 @@ int nfsd_minorversion(struct nfsd_net *nn, u32 minorversion, enum vers_op change
 	return 0;
 }
 
+bool nfsd_v4client(struct svc_rqst *rqstp)
+{
+	return rqstp && rqstp->rq_prog == NFS_PROGRAM && rqstp->rq_vers == 4;
+}
+
 bool nfsd_net_try_get(struct net *net) __must_hold(rcu)
 {
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
-- 
2.54.0

