Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 610DA576ED0;
	Wed, 23 Sep 2026 15:31:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790177496; cv=none; b=kqSDijp2D62wsXjZwou3s9fJ9lJw+Qz51VIgXoteJLsJBwT3/rl0hIg19iZTycOfNDzWLxsBXR+yKNbhkGsjr0jXwJJZMYn1b+DoBLn7/sywIRzhF1aUrYLTchuDMXssPgSbLuS9UgmCFtR6cdvPesWvA1Dv+4QJTMjYrY5o2FA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790177496; c=relaxed/simple;
	bh=xX9XhkpOXj1Cb9rbMympF2NdN69EjApoTlQ7aXuya04=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=H0hcvI4YxflTG4wowFQ5DUQP4jmz8Dco/TWC6+WIZrD0f+NTvun5aemfTZ80xEzCPiLQDgIVDnGBWsrlzpBc+xYxvssJjgIUlByFwjJUnQ67Uq4FH9VEDeDoxDoeCk7oodElGYTDjlahaPbzYUASnoKbzHY534e0XdcnNAZ6FRk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Jijp5b2k; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Jijp5b2k"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A85911F00898;
	Wed, 23 Sep 2026 15:31:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790177489;
	bh=6ASRleEWYyVlo5W4I727TEqskFbsxMPvO1Pmz4MNgbM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Jijp5b2k2LWpu5FZFPtPNVkT2WTPcQ1+U7REKoiy9pEKFJOPgdkizInQcIzlh9GWv
	 D4bkeAIk6Mqu+ZeLBiK4iqQxcsSHZBE9NIYRbdbnegS2Bg1nmblmUX6nFwCXKGqARN
	 +ox2zqxdiiUTJ3pz2oc9y0VCBxoXrwvFiv+0GWxKPyusxYEzrqWhwtEIO1EA5U5PYH
	 qhb6oaVT02Mnc7ixb7S12szAnK0MVR6xFfVkDgBpjnAbj4vcM6j/Ag/J7FPesFeu3P
	 j96ER7HHijz0PpckMEJMt79bajxK9/C8TnH9leHctJ/JtYD+A0mRhIMsON1V3eTVPq
	 AOF1H4Cio1ZLA==
From: Jeff Layton <jlayton@kernel.org>
Date: Wed, 23 Sep 2026 11:30:50 -0400
Subject: [PATCH v2 1/2] lockd: allow SERVER_SET without a gracetime
 attribute
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260923-nfsd-testing-v2-1-bfba431122c8@kernel.org>
References: <20260923-nfsd-testing-v2-0-bfba431122c8@kernel.org>
In-Reply-To: <20260923-nfsd-testing-v2-0-bfba431122c8@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Shuah Khan <shuah@kernel.org>
Cc: Scott Mayhew <smayhew@redhat.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3157; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=xX9XhkpOXj1Cb9rbMympF2NdN69EjApoTlQ7aXuya04=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqs/DOO2bXzNKKju7ttA2L0i3HS9UVB89bqVkdy
 8Za9MoBL4WJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCarPwzgAKCRAADmhBGVaC
 FaXtD/4/m/r/f1HMkSt37i870QxPKWL+7GNoacSKjLsXBMhQJf4oNZLJw8S2Bd7GyghhxauU1I7
 SHs1BUTEoVVcAvDt9gwsgZo0woJBoUC8JkGQJWQFX3/4PIUD1WV642am7+wrtA6LdwZn0IO7x0G
 nnkuab8puzwCh9Z5hiooEMhmfQR8H1fw102PuBV6yTpYIs66G0bBarmqFkGIeLQK01lsE2S+/3y
 KTu95ZFtQI/bEZqGAFzw1tcA69J64P9EXvgdaj+bOdaxUTWgs5UXRJn5CWS9r5Q68/6CaClXUvl
 YHLU0tGtTNq5qi4rP147FX4eEsgjNyz+yW+aoSF7JhaWJgWfPpoNd6h0IJfF1JgLdXj9DTNdPuO
 nbEgrRlrs2Hp3Czr/K1dODgBblW/BeoCExLJnlyXepGsBnt+MiKPS28Q/5TjfI6yMFzTjL71/gV
 n1U8phZUExzczuN1gR/Lunu+0ea/54p5qP3fMfswqstnhUpMN+V5FAtuob3UiafyTbULr328MR7
 oJ4JyMkXO0FWZpC7ImeRtq3+d9k0jbngLc3xih7PP6yQ6Jx/iRrcOVoJFZgoB2WDB/KzzRh+ZQa
 bg6n3e/JPqYmjOxFHZnUFhalGDp0b8QTIMwwVHrQPVIuxZDGLwMmWA7lFp0Sy7olkKLF69MEiPQ
 KKIR1ZwVgNdWWWg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

lockd_nl_server_set_doit() required LOCKD_A_SERVER_GRACETIME via
GENL_REQ_ATTR_CHECK(), but all three attributes are optional in
lockd.yaml and each is applied independently below. The effect was that
the tcp and udp ports could not be set on their own.

nfsdctl hits this: with a [lockd] section that sets "port" but no
"grace-time", it sends SERVER_SET with only the two port attributes, and
"nfsdctl autostart" aborts with EINVAL before configuring anything.

Drop the check, along with the now-redundant outer test for "any
attribute present". The gracetime range check is unaffected.

Fixes: 9a28ac1762a7 ("lockd: add netlink control interface")
Assisted-by: LLM
Reported-by: Scott Mayhew <smayhew@redhat.com>
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/lockd/svc.c | 50 ++++++++++++++++++++++----------------------------
 1 file changed, 22 insertions(+), 28 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index f0e1a58c9106..8e1b1735acaf 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -704,7 +704,8 @@ static struct svc_program	nlmsvc_program = {
  * @info: netlink metadata and command arguments
  *
  * This updates the per-net values. When updating the values in the init_net
- * namespace, also update the "legacy" global values.
+ * namespace, also update the "legacy" global values. Every attribute is
+ * optional; only the ones present in @info are changed.
  *
  * Return 0 on success or a negative errno.
  */
@@ -714,38 +715,31 @@ int lockd_nl_server_set_doit(struct sk_buff *skb, struct genl_info *info)
 	struct lockd_net *ln = net_generic(net, lockd_net_id);
 	const struct nlattr *attr;
 
-	if (GENL_REQ_ATTR_CHECK(info, LOCKD_A_SERVER_GRACETIME))
-		return -EINVAL;
+	attr = info->attrs[LOCKD_A_SERVER_GRACETIME];
+	if (attr) {
+		u32 gracetime = nla_get_u32(attr);
 
-	if (info->attrs[LOCKD_A_SERVER_GRACETIME] ||
-	    info->attrs[LOCKD_A_SERVER_TCP_PORT] ||
-	    info->attrs[LOCKD_A_SERVER_UDP_PORT]) {
-		attr = info->attrs[LOCKD_A_SERVER_GRACETIME];
-		if (attr) {
-			u32 gracetime = nla_get_u32(attr);
+		if (gracetime > nlm_grace_period_max)
+			return -EINVAL;
 
-			if (gracetime > nlm_grace_period_max)
-				return -EINVAL;
+		ln->gracetime = gracetime;
 
-			ln->gracetime = gracetime;
-
-			if (net == &init_net)
-				nlm_grace_period = gracetime;
-		}
+		if (net == &init_net)
+			nlm_grace_period = gracetime;
+	}
 
-		attr = info->attrs[LOCKD_A_SERVER_TCP_PORT];
-		if (attr) {
-			ln->tcp_port = nla_get_u16(attr);
-			if (net == &init_net)
-				nlm_tcpport = ln->tcp_port;
-		}
+	attr = info->attrs[LOCKD_A_SERVER_TCP_PORT];
+	if (attr) {
+		ln->tcp_port = nla_get_u16(attr);
+		if (net == &init_net)
+			nlm_tcpport = ln->tcp_port;
+	}
 
-		attr = info->attrs[LOCKD_A_SERVER_UDP_PORT];
-		if (attr) {
-			ln->udp_port = nla_get_u16(attr);
-			if (net == &init_net)
-				nlm_udpport = ln->udp_port;
-		}
+	attr = info->attrs[LOCKD_A_SERVER_UDP_PORT];
+	if (attr) {
+		ln->udp_port = nla_get_u16(attr);
+		if (net == &init_net)
+			nlm_udpport = ln->udp_port;
 	}
 	return 0;
 }

-- 
2.55.0

