Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 695D53E92B5;
	Fri, 17 Jul 2026 11:09:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784286565; cv=none; b=TcFtgC66bezZaN1ThetJr3Yq7OcvoOZfw9FGoYTH2dRbpk8mmQlCY3dNQRUDIHxKH/vKZBQTEteEsBgMRxLbGKioNa0Cm62LdRgyVPsxF4vrh+LZqxqUtj+mWXVVawPx9gT3fkRTepwMrT1w2s4nvliRIpDXVdeRjio+Bd/waaA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784286565; c=relaxed/simple;
	bh=LgX43C5w6ErEJtn9G9F480eMc9PQ5s0RHgGS80lklNY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ZmQKBPV5pLZCK9Jdz/7KG56KwwC+x5cuUkOu6RqBe1rPBUgLp+dCwaPi116sQoNTpgyHh0Br69dUHoyOxSOk3AclJ1bglyGywP1WlZN1eB8Z9N3r0cfzYRNhFqYqERBL/FtBCqvCvS0W0lOm1rvQj39uAbwq7SoxGkbZ2YyNV50=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=QZGbZ3OL; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="QZGbZ3OL"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BFA0B1F00ACA;
	Fri, 17 Jul 2026 11:09:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784286551;
	bh=U0eL/g1AAcmWX9GDVXpdXWwHQhg+pyE8z8K4+jPAEoE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=QZGbZ3OLhNr74SbSk6dqnRx2M6Syi1X2BmnCEqph5yJMZxiMUaJYTnOdUwZtO9/y4
	 /7ks4UWE6eVmq/Jdcscl7Z36VJqUyrxRVxuxM6LxkOvrAF1tSoFgYnJOs7HRqhScTK
	 n8O/moDqAZeEfz/42XyuifigliZ45GBbKOr/vr3/HgT2GT16UEl4lpa0uUX8wHfTCn
	 5StcgTgQTxhdPy6xXRPazLKEYU5hw+FmkVnOIKUkz61NMotCUlbbhVDfq+apPlmOaY
	 x9JtddMHi9PLozofyb9t6LkIb3zpMvdhWOC0o4sEjXJiIjc+8uvjO90FaJplsyYNDd
	 UE5FZLedPtqNw==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 17 Jul 2026 07:08:54 -0400
Subject: [PATCH v7 2/6] sunrpc: use per-net counts in svc_seq_show()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260717-exportd-netlink-v7-2-b7ce17b83b60@kernel.org>
References: <20260717-exportd-netlink-v7-0-b7ce17b83b60@kernel.org>
In-Reply-To: <20260717-exportd-netlink-v7-0-b7ce17b83b60@kernel.org>
To: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Chuck Lever <cel@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1024; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=LgX43C5w6ErEJtn9G9F480eMc9PQ5s0RHgGS80lklNY=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqWg1SD6uT33Oy6u/qbWQj89M9n1W/lxkpfjcp2
 peTvIyjKlWJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaloNUgAKCRAADmhBGVaC
 FXrdD/9Bd1W90I21ePfUsVPtH+0UdY+e03NcFQG6zn9NTepueFwFqELZIrH4uDwzTrHyt4TW7F7
 Jp7IaDdsi7UAvIxpJysvtZHteVg8BpbrO4j8naPpEKLYqjkxHe6pO1/maBeAQlqePhyI+aB+o/B
 DOluXU5I01areEfQf98ZpimNNo6XeeUiHJN6wEzNQ7r58hr69xT3Cqg+lq/qMO3H8Yd/iPQPDd2
 kNQNC3Gxe6WrF2n0YxbNA2tj831dYEhHRtYyOiWzcabcge3jBvJiK7uGsXl0YxsV/g3nhIH/FT1
 /xzl4DFaiN7mEjJbRKtTgKNEZqq+ig7E5vxlBalIqLDrUB20DxNQ74v3EVRLV1++WzMkVUCiucT
 C+HcYCJLwfkJ0r11jEZKe79GloCf+5YSdEcdYXoMsyimOUFqsXLUP2dRZN+4n41TbdMhW06j6Zk
 oM1zNqq2cOM6RP5L3l7rY4jVWlKUH0/lniExTUQfLfHZXoPdu03W8S1tciabQk4x0TmchmxRyvU
 1Sg4k7Lu5OabRC+Qcg75yF1b0qGHT3rQ4cd6TRsTuq0Pc1JU2kD0I0tU7TR3wIKY/XwiHM38KoU
 RwX+XOkn6LbI0Y4jojTLU3kWfdNBoNUi1/HVZIefR52LSwXqyI5UwW/i1W0fkfntpfE6GfHbMsI
 YliOPKT/1hA0oRA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Update svc_seq_show() to read from the per-netns
statp->vs_count[] arrays instead of the global
svc_version->vs_count[].

The only caller is nfsd, which always allocates vs_count via
svc_stat_alloc_counts() in nfsd_net_init(), so the per-netns
arrays are always available.

This makes /proc/net/rpc/nfsd report per-network-namespace
procedure call counts.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 net/sunrpc/stats.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index 7093e18ac26c..d08711bee18e 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -108,7 +108,7 @@ void svc_seq_show(struct seq_file *seq, const struct svc_stat *statp)
 		for (j = 0; j < vers->vs_nproc; j++) {
 			count = 0;
 			for_each_possible_cpu(k)
-				count += per_cpu(vers->vs_count[j], k);
+				count += per_cpu(statp->vs_count[i][j], k);
 			seq_printf(seq, " %lu", count);
 		}
 		seq_putc(seq, '\n');

-- 
2.55.0

