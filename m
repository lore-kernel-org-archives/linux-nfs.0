Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E931848122C;
	Tue,  1 Sep 2026 13:40:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788270023; cv=none; b=GcsyJUaTFt3jX3HZ7IFUfJ34ybo7DkbARocQL3kfv8Gp0Y/A2v79BIx9NzB2rBjrNxT9gdrSIyfqDuSqKjdS9b8UrQOEf3KvBu3ex5jXU7Dkq05BEfVm4eedpVMSG8vKLsXpz65DKoeiaGuOG3F9bqAJdZC3kM/Mu11wtbNP3AY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788270023; c=relaxed/simple;
	bh=0ZW6OKmjiCCSRO6Fjj9N+K8OBoj3fMRkesMtY3+fw6Q=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=unmwM9a8pPeM/qDGMcZEA7H+eo7LNwrMbhVvDzZGSjXVnjton7QXEYOF58KBLq29orNoJWoFHlQ+OT1wLmrnX1jyhXNAJSP11GU3oRZKlj85MnhapMbo7gNP66dx5k31NSClabAU1E9gtriWqZx7MUtfYwUXfdqUWyLVGaKTaUc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BXpltTdF; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BXpltTdF"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2A6721F00A3F;
	Tue,  1 Sep 2026 13:40:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788270021;
	bh=XSLyqYMtkJhmknYEk7fox4brPcvHsyc4eE1EzL2dIX0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=BXpltTdFfbCL10QZDOq2YsVdG8oJ0TDdHuFfl39VSZNEZX9dkrCcgWm3VZo+co8Nz
	 KQyUYWz1Bt4W97W+h6t2QWUIJqXGP6161BzRtHESXMv0XzNPOou/P9XlXtO2pn8XKv
	 pD0JvqZtxOLQEQdwZocikSYCE4ZuNl4gjREGEIxQUV1A05msZDMoKDtd3uFHPBS3BR
	 wU6ICMgayirQ87MkynoxjQTrAs1Tp2bA18j0yxzqqp9zdxwOu0d8LPD0fIrhcmXVQR
	 TB5IiwQTQygiAIGBu3zHDBNeFQABWJSB2BKD0t7hqmp9MQep7hjlSirCVQTi5f2ndT
	 w7+bX1Mo91Exg==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 01 Sep 2026 09:39:49 -0400
Subject: [PATCH v5 11/15] SUNRPC: check rpc_sockaddr2uaddr() for failure
 when registering
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260901-nfsd-nl-hang-v5-11-a540d86668b0@kernel.org>
References: <20260901-nfsd-nl-hang-v5-0-a540d86668b0@kernel.org>
In-Reply-To: <20260901-nfsd-nl-hang-v5-0-a540d86668b0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1171; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=0ZW6OKmjiCCSRO6Fjj9N+K8OBoj3fMRkesMtY3+fw6Q=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqltWwPXSjtVcQ0LEyV5Mj3Kv/bLSpNGQp1wRjU
 pYzs1HP8TyJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapbVsAAKCRAADmhBGVaC
 FTygEADVcH3u0KK4da5JRenYyMehx+L3tdUOnBhzK1hR+PAqZ+jWNyAKc8oogJTkY+Q+W/m8UKk
 tVAP46TC/UxFOYoEShfH4tGAvV7pPaQZc0x2bVm7dDhH1sxQVKUqej31FXKSxwDDks+MkWepm19
 cOjf5ClbqNzPeuLnCdZ6Urgm3tlYQ8067Gas0Om6DF0DToYNevhv50DxCCTNosRmsX/l5jdaYaj
 s/2L/y9eFkW9GD2Fwto2LbTpfOUaOIfJSsGF1dOlicS8Z1T2qpJgJia8nQWcu4PAwNQjsvnFRad
 8z1bNNyYXb1WT8p7Jbecfr0zMkqGx0LwoGs86LEwYjUmxWIEBC2CK/5a9zCQUmII6KmvltsQJr1
 dRLuilx8fhYKIg6eL5BQAwY7cQbcrOtoZ1SYQ40CZ1IlT3k4U2UL5xNR7/iFWm4nKLC5guzj6bF
 4moFooc9RFGOxRj3vP5zBLgl8vPDezlD7trnrBx7Unj7e5mNmGQ3uHhNEn/oe2nAdBpz2qwZ+pG
 0bhabFpIGZKloTgfN9wkG7rUWtKcZGQbf2xa8XW60z2lszY2mQazUNn0EglKAY4uJDK8xVjCwfF
 6Wqt6VXTbTwJYBFGg9/XOzufJuh5ZdxBgkkc2I5JoNHcnn8rakssuq3OyLgmks00rr/JHqNa65q
 l/lPkrFqWXNGL2A==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

rpcb_register_inet4() and rpcb_register_inet6() store the universal
address unchecked. rpc_sockaddr2uaddr() returns NULL when its GFP_KERNEL
kstrdup() fails, and encode_rpcb_string() then calls strlen() on it.

Return -ENOMEM instead.

Fixes: ba809130bc26 ("SUNRPC: Remove duplicate universal address generation")
Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 net/sunrpc/rpcb_clnt.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 7255c1e07eec..397919f2a38b 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -518,6 +518,8 @@ static int rpcb_register_inet4(struct sunrpc_net *sn,
 	int result;
 
 	map->r_addr = rpc_sockaddr2uaddr(sap, GFP_KERNEL);
+	if (!map->r_addr)
+		return -ENOMEM;
 
 	msg->rpc_proc = &rpcb_procedures4[RPCBPROC_UNSET];
 	if (port != 0) {
@@ -544,6 +546,8 @@ static int rpcb_register_inet6(struct sunrpc_net *sn,
 	int result;
 
 	map->r_addr = rpc_sockaddr2uaddr(sap, GFP_KERNEL);
+	if (!map->r_addr)
+		return -ENOMEM;
 
 	msg->rpc_proc = &rpcb_procedures4[RPCBPROC_UNSET];
 	if (port != 0) {

-- 
2.55.0

