Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EFED44BB7F9;
	Mon, 31 Aug 2026 16:15:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788192947; cv=none; b=ZClByg5lxR9j3yEWKP2z2Wf6CR4RvFXNcyKd3/zwYL+yGPWIIgpwmSYb2l5zEaXPGAhX7twPjvTwKAmd18zmmOn39ojsXN7GPOPBzWYjPVCrdikDY8/5+6TsoepjhN9X7FHikn+OzzCAraAsifzBVM16kD9WWMVXZDvivrSuvn0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788192947; c=relaxed/simple;
	bh=V+wvIGsJlzSDNv4WKj3Vpj9Bw7A+dysnBkXbj7sTYeg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=FEbYHIbO/2mZ7JZdOX65gRyG+LD3XJVsQ4EiwnWtiPD8PWnfIO+yDWvLxB+4hfeODDPpern57Nbmdy+wKSTR1QXh0rZwVfkr8nteZew10aizhGqNcXscSLVUjh733BOEWAV0DBpAoCtGcMaJR11hIIHpdXU7nLTgm3B4jjoCpUM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=dPAWNcLE; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="dPAWNcLE"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3B6271F00A3D;
	Mon, 31 Aug 2026 16:15:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788192945;
	bh=dtpz+uXivVuZd9+O4vrtoCG96NBwe0+gdme3nSBwjT8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=dPAWNcLEB/2zs6KOKGIayZpyi94BLmAbozxgk/s2zHn7vVdauOopb8TVi8f7XX7oP
	 I+9tu5AqI4guY9ixPAwO2up49m2qSt5qK/z/7PxcF243XSteyle5BNR34Mrp9JvzQR
	 WFop7qRxn6fSWhIElwEOCdK3outHvSZjaOS79z6Sclk2l2R/c5X0+IpD1I36tn2N1a
	 Pry8z/9cMvR8D0VO581kd/qH2Pt8u1v7lvgUv6xfSKlAawa0HGp9M4js3d+LBfYveM
	 MD0b9tiDgxt0UL/V5V2vs1X7Sd2pXcIgLComY4q6YXQbWglAU9P/JBOKb32SSmx5VA
	 2JvhTQi724kWQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 31 Aug 2026 12:14:47 -0400
Subject: [PATCH v4 05/14] NFSD: report listener creation failures through
 extack
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260831-nfsd-nl-hang-v4-5-0f4e89139409@kernel.org>
References: <20260831-nfsd-nl-hang-v4-0-0f4e89139409@kernel.org>
In-Reply-To: <20260831-nfsd-nl-hang-v4-0-0f4e89139409@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 Shuah Khan <shuah@kernel.org>
Cc: Slawomir Stepien <sst@poczta.fm>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org, 
 Trond Myklebust <trondmy@gmail.com>, linux-kselftest@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2186; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=V+wvIGsJlzSDNv4WKj3Vpj9Bw7A+dysnBkXbj7sTYeg=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqlaigtuikwgoHPp+2GT66KQKU9fhVZvx1/L5Y1
 YJW0W58GnGJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapWooAAKCRAADmhBGVaC
 FVdtD/4ukyznGIh5HgV7bqjYhpKnTMbvuqwvxMVTF8H77aMg0hP/yLExQ059nT/400lCFC9AT+0
 Dwe+Eva195NN4e8xdH1IhWAMO7Rpa+2EAp0S8OV7M6mIsDTpZloLxgw9LzOhZ2CILBdnMufadUP
 9Kq/LRDHmmHGO4ZfJkd7DQGVv2cp0N+p5bEQWpteHvyBpPpeFdtMHx9YwpndzPf4tVT4Vfd+d9u
 KwHs8PFVuHst82vJpDmFgnEb2gYp/mEGqi13ckCjQRb54XXwNwBHXDJANq5tvwCkjRBa7SJ3rDJ
 ntYNABLDT/xRcSl1Bn5Y/FaifmMvvS2TrBNX6vCWWV9yA4VqBhkcXCbfK/ZPbGx6I5uOyoypfp9
 0aobZEbOCYxR+HL0I5zU4PeWVb1VQ2EF00aLCzAdzInMLpXK5amo9XkLbZC58FcDYhnd/B0SSgd
 T+bGcpbcNnuKR6VR6x3hAF5glrjM7AYTvm7Lpil0XrYCMDfN4DdZo1gxZiUaPQ//7vq+FRrirnW
 gX7zrBpywI/UwmW0D3GlA0r+njO+B3e7q5ObwLaYWg967GNZ4W1CGRUyz6i8ZSbDKnp0c3R355A
 uh1nBmo1zvdXBXPHmPan5XSDUT6pRx+YRsCJUUwdQ8kQdukRUla8JSEA26MmEvM+hRsrzGPTDMG
 PDO2B4/2/pZ3LSw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd_nl_listener_set_doit() returns the raw errno from
svc_xprt_create_from_sa() and sets no extack. A failed LISTENER_SET
therefore tells userland only "Address already in use", or whatever else
the transport returned. It never tells userland which entry failed.

Record the attribute and the transport name of the entry whose errno the
call returns, and report both after the loop. NL_SET_BAD_ATTR() names the
entry, which the message alone cannot do: a request can carry several
entries with the same transport name.

The rejections in nfsd_nl_validate_listeners() other than -E2BIG and the
unsupported transport name still carry no extack. This patch does not
change them.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfsctl.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index d8135f38e69f..6cbdcee4b733 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -2089,7 +2089,9 @@ static int nfsd_nl_validate_listeners(struct genl_info *info)
 int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net *net = genl_info_net(info);
+	const struct nlattr *bad_attr = NULL;
 	struct svc_xprt *xprt, *tmp;
+	const char *bad_xprt = NULL;
 	const struct nlattr *attr;
 	struct svc_serv *serv;
 	LIST_HEAD(permsocks);
@@ -2208,8 +2210,22 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 		ret = svc_xprt_create_from_sa(serv, xcl_name, net, sa, 0,
 					      current_cred());
 		/* always save the latest error */
-		if (ret < 0)
+		if (ret < 0) {
+			bad_attr = attr;
+			bad_xprt = xcl_name;
 			err = ret;
+		}
+	}
+
+	/*
+	 * The ack carries the errno of the last entry that failed. Point at
+	 * that entry as well, since several entries can share a transport
+	 * name and the errno alone cannot tell them apart.
+	 */
+	if (err) {
+		NL_SET_BAD_ATTR(info->extack, bad_attr);
+		NL_SET_ERR_MSG_FMT(info->extack, "cannot create %s listener",
+				   bad_xprt);
 	}
 
 	if (!serv->sv_nrthreads && list_empty(&nn->nfsd_serv->sv_permsocks))

-- 
2.55.0

