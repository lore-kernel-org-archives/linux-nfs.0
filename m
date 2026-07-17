Received: from fhigh-a7-smtp.messagingengine.com (fhigh-a7-smtp.messagingengine.com [103.168.172.158])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 359A538B7CD
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 09:30:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.158
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784280647; cv=none; b=nrrLeFHbaeOEek06aQO2l06Y7+q8VMPZN+jMiab4+7aZM8oF3hE/0JRb/PHomvpyJWU/nf4OEEBM+ZYGJs2FOvQ5D0bQfS7jCoj+83Yf0Fg9Eqe87gVPTRZ4Se2fN7LL8equfFhLVOp/h8WwN9xliqu9oa/Ogqr6Xsh3Ed/eKrY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784280647; c=relaxed/simple;
	bh=u2BqhWKtK+PI/r9ntQXsrzIIwjkVEF+2sulYlOglmIo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=MBXT+dg7C/EjMHOYK6OLBp/ukkrYud2IAVnXJUUGZo1tkWGLAPMk5ToLs4FRtjhnIXyGczXxPd5J2TRQLL+JgoYXE5nor+EzjGWgzOlgDvIJN9nNwaji4NmFoa4TZim+RQM/e8dSijQi6d7u0Iye3qvTiT0tQvRoi1PjWCw8Zf0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=aUXDV+ks; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=amMjGrZH; arc=none smtp.client-ip=103.168.172.158
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="aUXDV+ks";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="amMjGrZH"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfhigh.phl.internal (Postfix) with ESMTP id 43CA21400075;
	Fri, 17 Jul 2026 05:30:45 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-02.internal (MEProxy); Fri, 17 Jul 2026 05:30:45 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784280645;
	 x=1784367045; bh=MlHWIAB+Vg/rvF60JF3VQ5y2kOaIWr2vhXlFGD4vEq0=; b=
	aUXDV+ks482WJvvEviYKxZAjMaXTcTINtTc819zphIBNMIQ6lT7nxfaQHtpjTgsg
	EAX8Dii3vh4+ir0OqqnsZQr2ibEfWK1zk3B8BWPXn6IDYqlRHXswuwPGU0wlxroB
	D6ZXB4eLLvWsoJu2JvkgUzBRm++PcyAS06Lm0bNc78SJyuXqmQsN+YAO2qEz8t6Y
	xZH0c6O2hD8QqW0pb0LO04RXDHVVmxxaOd5kyBGBM7z67ehT89FSJWmjrrAKng6f
	TSt7Cx8QyMBIymTX5ifLT+JyvejMqOMHP4WD8KYVTmRqgsQA29fCimR0GnZXJ7FF
	MBqHdDVcZmp2hvuIlpAIbA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784280645; x=1784367045; bh=M
	lHWIAB+Vg/rvF60JF3VQ5y2kOaIWr2vhXlFGD4vEq0=; b=amMjGrZHH+utsUJ/F
	VrdFDB0Vt+QVs4wMJ7rq4hNfww0EYNLWC9l0tTy1gqOhDpx9i5ZRc/QaqApnBP+4
	7G4FWFtgS8SzeYI7xradvAaj2GBVRHTFSbx1D9lh0ZOxSZoEqXWc6flz0ShkRzBe
	61tr1ZfMHDwbIg0RF9W/BNFIdOstMyHEyvNM1Mg7yPxZu/j7VNn2wP2Ixre4Jtch
	37IpBqIv5ohFNlaSg0CxgcYA1Z2JgN4Q7hwx1MO/8i5a3erH1UhQXd6e+UthcKKL
	LsEqchxwdRTUDAZkDW+XyDP05qUW52FncDFr/rddLFzpjS1tjeWhsX1+YYosUMGl
	dY3gw==
X-ME-Sender: <xms:RfZZauX6uutvANPhFfqhVmFChT9PdVXo9ctrdxiiBMmfM_hPrcg3Iw>
    <xme:RfZZauTSkzTnZJjIiIwvFq8zvSJGhZJLDrL9D65q3wyGBd1_l5apjzWbxniJtsRG2
    wJZnSUYn2hHarmnPYpNm1nQnavXoO0OqSpLHICajobBJn4>
X-ME-Received: <xmr:RfZZasP9XJ0PhqmoNLPWq-EfsrLT-t_4iKv8HPhtUHmsPw0YROBW5ixiYtKDcAmWHNemTdQM7SOisVoZWr1xxAV3YhtKPos>
X-ME-Proxy-Cause: dmFkZTEX57Ex8LbShfUXWkvJih4a1baE9EfQ6TgUPnJ0DaKnRO3Du70CAhhY681g13Zhbl
    7+6gjM4A0f7dNvQc03aRIz3FZBRqrxctlwbzsG3ndQuoUarocORY0qObpi2VHZQgoKrsuo
    Pz8T2Hzo9NtU7WBXPVmdapAMdiqKaX+pxxqioqIbP8tlHObQF+a7Mp8hX7zOHvDB6EOMWg
    1sbeLGfkgUP3SWNtJdyCx4zo2FvbCdw3kEs1ZvMn58hsAfPpvA+oTbrgQ0oPjv71NDjjPy
    WnL4ClTcOz8/DrmfPbmbnRXwAb95LZ30NPNsYA/6r5bUfJzKa9KuHLiAmSCPierLaaggm+
    W8Zh1hjDTUA4T+Ih17vat0dgoKWRkoLRJ4pH53GUYPB9A+Pt6JpPdvq0GTskFugz1pJ/Ey
    HDUY71vOzZ8RBhZRB1Kvz18IGdP3bG0vlbZlfOcc4QtcdjSFcsTi6o5JMKGpMSZBnH2whb
    rzreisfAezWcNcQvb25qdLSDBa2Off+UYSguP3Kqgq3VEkPodcB8PB4xAUT4fRdn+nqnH6
    CVCOA4PEthB57I1WAHa4PYRsjuMp30hm+xwkjyDb2L2NajAQ1UXEcoAPm5xnnQWIpMfIlA
    W+uHh5gQCoOElg3f06QUApP0yLBCrXQwlG853EPvHozbeDA7vSlnRAaRUeKg
X-ME-Proxy: <xmx:RfZZasStRnrJqz3nVxu0934wb9DFiJJ0w1FzdOpjT08oELnosh1rTQ>
    <xmx:RfZZaqjjWx8xgRvu2dBk85LsBzQP-eZ2PzzQDG-5ga8oGL6hGnzrvg>
    <xmx:RfZZal_9uAYSza42rRngMR04GRPtIhrcRAHaVg6n69fZ8Pu46JcDTQ>
    <xmx:RfZZahGyAxR3Xsxtibrpav2jicqU9aHds1-dm9o54szP02X3wVIgDg>
    <xmx:RfZZaj18jtDMhO7ub20CC6cSqJ9VlTXgmoNHqfKF2BQQwPOW11VQusA0>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 05:30:43 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 07/18] nfsd: remove subtlety from nfsd4_create_file()
Date: Fri, 17 Jul 2026 19:27:55 +1000
Message-ID: <20260717093001.1972119-8-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260717093001.1972119-1-neilb@ownmail.net>
References: <20260717093001.1972119-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

nfsd4_create_file() has a switch with cases for
NFS4_CREATE_EXCLUSIVE and NFS4_CREATE_EXCLUSIVE4_1 which are identical
except for one line which is marked "subtle" in both cases.

The difference boils down to a "goto".  For the EXCLUSIVE case the
target is "out:" which is after a setattr call.  For EXCLUSIVE4_1
the target is "set_attr:" which is the start of that setattr call.

In the EXCLUSIVE case 'attrs' will only contain the verifier.  Setting
these again is not harmful as discussed in the previous patch.  It will
also call commit_metadata().  In performance terms the cost of an extra
'commit' in the rare case of a replaying exclusive create is negligible.

So we can safely "goto setattr" in both cases and thus simplify the
code.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 2b9fad28a9ef..a311810abfde 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -390,22 +390,15 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			status = nfserr_exist;
 			break;
 		case NFS4_CREATE_EXCLUSIVE:
-			if (inode_get_mtime_sec(d_inode(child)) == v_mtime &&
-			    inode_get_atime_sec(d_inode(child)) == v_atime &&
-			    d_inode(child)->i_size == 0) {
-				open->op_created = true;
-				break;		/* subtle */
-			}
-			status = nfserr_exist;
-			break;
 		case NFS4_CREATE_EXCLUSIVE4_1:
 			if (inode_get_mtime_sec(d_inode(child)) == v_mtime &&
 			    inode_get_atime_sec(d_inode(child)) == v_atime &&
 			    d_inode(child)->i_size == 0) {
 				open->op_created = true;
-				goto set_attr;	/* subtle */
+				goto set_attr;
 			}
 			status = nfserr_exist;
+			break;
 		}
 		goto out;
 	}
-- 
2.50.0.107.gf914562f5916.dirty

