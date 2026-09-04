Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 324D852121C;
	Fri,  4 Sep 2026 19:42:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788550981; cv=none; b=pj0bjq7j6n3f0HvcnsDn0vBH/nnzfNbvGAilHywLkhjc+3OD5CWH/xzr5sPTw/1UQgO83xtZKtUcUoMxWWACqI6vpFGvrg0yxS6Gukg9GpP6Umz558q3Y/PCFlkFn/xy/o4oWVglEwdHz6V8NAa8698MbAV92t0wO98fLYLh62A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788550981; c=relaxed/simple;
	bh=/AdwIK6AeqCLwMkN7rIEC/Xz9ssthdQzeLlM/HNuEGM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:To:Cc; b=uikB1cwA846RWoQez3RqqL819gPV2uMZrd1fdzKJ7XvPcgAmTWg3pt3useZ0zHeOYjdHVvc68NoFda7jNe/4jRGzYzkiCCIYhMpYMMDyReew4kyAnvlLd8wUu9jnOmnPu995nmfGfu5AAbpp69xQ+0UiWUeUt2/If+YjeVXNS5o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=OMcU/YKT; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="OMcU/YKT"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8602A1F00A3D;
	Fri,  4 Sep 2026 19:42:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788550972;
	bh=pr9OfyLVQuN5Rx3bNQsJLYj1tIF/Zqhj511pC7wSZtI=;
	h=From:Date:Subject:To:Cc;
	b=OMcU/YKTo/KgjLF70QdwXeRAIHr1xpbNzN6MGU2dMN33ZCiKw1e/sQUbnEizcSIO+
	 tv+8erG/04hGqmzpaK41YquB14wrW4pWcODHofe9AWforjaqIFWmBuRDlwSlqNcWZm
	 Vj3DKS/bSZtIElW5V4OZJtsbLWkvJZ+1U0T10/Jw+LWAjajD83YoRNzixZpLKxHIRm
	 OOPaTyGjN62wWeFd9o79lk0ZY/TpH34v0rmQDxj/Wr87sooBhM/Wz8MS9OhGq6OnQ5
	 d3a9Sevh2vCzaJVdryCiz6REbwhACEEqR+53q4689gQQwdjrQlPB8jlpSUMDfrXMTG
	 7Otcn0BiRAtdg==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 04 Sep 2026 15:42:48 -0400
Subject: [PATCH] nfsd: shorten extack string returned with dodgy listener
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260904-nfsd-nl-hang-v1-1-8c8035b6294d@kernel.org>
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/6tWKk4tykwtVrJSqFYqSi3LLM7MzwNyDHUUlJIzE
 vPSU3UzU4B8JSMDIzMDSwMT3by04hTdvBxdkKSuRbJ5klGaUbKBRZqpElBLQVFqWmYF2Ljo2Np
 aAE0Dvv1eAAAA
X-Change-ID: 20260904-nfsd-nl-hang-8c7b2f2c08f5
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1137; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=/AdwIK6AeqCLwMkN7rIEC/Xz9ssthdQzeLlM/HNuEGM=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqmx87Oy/7jw4W7AXN3addy/mINDRLbiNSml9A0
 p6JeNYCRQeJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapsfOwAKCRAADmhBGVaC
 FQnnD/9aWPuZ+Ll9kyytf/60So2f+aQGRFxAMelLzNunGHlKJtpBRh+UOCMcP+RHdWwTmzC+ggf
 wT+K5o9dDPJ9+N3unCE4xl++sf/73l2Z1LpKgbeAeSO945HZYEe5dUSUEt3MGJJy0gm1YSveFN1
 ML1mvGwvE4Pwh4P5aCafHYO1gI3LhNqxfUIOKWiBIEGPsGlBHN3GOlmtX3g7nG48+EbzInFaAJW
 ruz0YvywvkLZxHvDY+TrXt06oxxMmJP2LPc/5dy0vHeGzXbrL6Or4FbWVpzK7zNFV9uu/7odAa8
 BId61ASZuaLgg91eO/JHuDSDonVLyIRVGJcnOI3v9x7BCzlMZAaX82z7BeNJRSe3DVZ08VPz23d
 8f+47cx0FjYrd8Va9Vy3d5eJopSmL/iXXHtqx/+ALTolNuDYLWXAlrnPyaDkLxoEGU90Yl7BiCJ
 vvwOqhGyRlV3nl0kH+BDGdmRQYLaqXraxB+MP95bGr0wjPk293j3FazqYfvgd/wrFS7Zp+1ipTF
 8+8P5kQp7vz2OqSoFMGErA254afhnTdbz7wvZDF1XXzSpQrV9RSyii0GE7ysJ2dwtRSPqu0lYU8
 Zm/+esFaurAVR1fs3vBZbP4k8Ubyd/H0Ca4s/nxqYmQj54j1R6065sMt5r1Gs+bWCIeNMbxdqaS
 8QlvjaEyzmkxfUQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

The kernel test robot reports:

>> fs/nfsd/nfsctl.c:2253:4: warning: 'snprintf' will always be truncated; specified size is 80, but format string expands to at least 94 [-Wformat-truncation]

Shorten the extack string in this case so that it will fit in 80 chars.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfsctl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index c6f6bc3b1281..9c55a7be1937 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -2251,7 +2251,7 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 					   bad_xprt);
 		else if (skipped_rpcb)
 			NL_SET_ERR_MSG_FMT(info->extack,
-					   "cannot create %s listener; rpcbind did not answer earlier, so some listeners are not registered",
+					   "cannot create %s listener; rpcbind did not answer earlier",
 					   bad_xprt);
 		else
 			NL_SET_ERR_MSG_FMT(info->extack,

---
base-commit: a5c1bd1a4490d86935bda04967726cf540c7b05a
change-id: 20260904-nfsd-nl-hang-8c7b2f2c08f5

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

