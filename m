Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 100DD3B27FB;
	Fri, 19 Jun 2026 15:26:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781882814; cv=none; b=Uoh4/FR0/F1mkOlxdjZfw61V4sYNpqNtZqTptnmCeRxpVZ62KZgpRlhlrNVgCSr6QE/O0IN+cmtTZ0FzUnHpq3w7qArmiyNQC/N9VuMQRHLohA8ZXgpKKk8vvAiako9wjn8kIFRD3b6/v5ELxZ8Amlh+Z7eANngAvU8XCXRMoDQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781882814; c=relaxed/simple;
	bh=1hy8GsBfF5Qm55H4JbWI+zlGijgc64oFQmBHg2lPgRQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=LeaRDv7WmeUocPq9T7eAWnSXLhpMMDMMzRTzVlJCksaueb28gtq/sv+E11Fhp99xZ0CLHaV9oFJprqqEzsMU15EV2rw8bkoXXsotr9sVx6HLNYYJ7m0vACGhjHGNzcTBq5IfmGH8VTqMow3TTF3TEKi1tCV2m2KLPSoIiawRgCw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NbLoYVXd; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NbLoYVXd"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C673E1F00A3D;
	Fri, 19 Jun 2026 15:26:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781882812;
	bh=JWzcor2Zi0JVNOL1ygN5ZinfTDjx6btTmxsAgUsfew8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=NbLoYVXdZ01dHQcHMKTlKIPVBzip9KyxCylzMxZFOb8M6y/ZuZMVIK4aW45J9XadV
	 EJlRKv9ptjVy91d1h0z5HAe46ko5cniDlkkvRr6jGTGGXNWhIyM0WDk/PLjA/EXfmN
	 xoxGh0SZRH3E7ZuheJf4y8ifBAQw+qiZwN4kOmHRhQ0wYWrTIkT99yQB6BJSq+CYjo
	 hohvELxqXV95d94gqQqfvZ1q0DxkOAuwBoqomjyh/tdUTDJm8VvSKPeOwl1OSrfOhK
	 nhxGCQwEMokU1xmh2zd46sAt3neaG2cYtpPblk2PXSuKnqm3RV8DIxCgq9VcgOc8pO
	 u5bVHZhsdkqaA==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 19 Jun 2026 11:26:37 -0400
Subject: [PATCH v6 2/6] sunrpc: use per-net counts in svc_seq_show()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260619-exportd-netlink-v6-2-ddef3499793c@kernel.org>
References: <20260619-exportd-netlink-v6-0-ddef3499793c@kernel.org>
In-Reply-To: <20260619-exportd-netlink-v6-0-ddef3499793c@kernel.org>
To: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Chuck Lever <cel@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1043; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=1hy8GsBfF5Qm55H4JbWI+zlGijgc64oFQmBHg2lPgRQ=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqNV+3y3YRbc50qil2Aex7nQ9RtoGam7cOX1cC5
 2/7JpYR9siJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCajVftwAKCRAADmhBGVaC
 FTelEADD8pKSJofve5sMvpmJjF3hqOESA/PkujgGmvuW+oWTh3XbJLGHQNAXEed8WANTHjQnXbo
 b+dHFL1Yq8NmJ9KFslrpEjVE5kvtf3I5j2AkjDbKhwpws5jhH24pE/iTdnJmuIVRhg2YG/lb+6R
 T51DPjcLjuauaiFU/5Z+fJPLARtOk106WWDPMrPnQfPzPiGlx1GuZoaCBKzGU4MyuKvJQBPQ5z5
 keZ5f2Qsdzxf73lK6PJfBMLmVEwEyk8JaqoUXVACmAWfvx4ZgnzJPjJAy9MF2rMqm8fg4YhPGQe
 oHIQ0K2+bEk6u5Zf0FP5xOOkYixqgIPDGl3/DHCGl8mwiLnYaYXkKbr3v9lOceQAsLRaW8yu4n9
 Yped6pdwgS/Gu2NNp0cN1ZVVUBk9lGrPONf5EO95e9lwTK99tKaL/tiai2T7WAbFYHfJLCoz5iX
 iHxEYww1eoE573HN60cjzExcS2l9DZDA2Re3q9bMyGZOOwgOPifaLgsbDlgvHYfAk+hOecF0G5Y
 azzcndeXrzHME/6/JK6OxaEpLoeDCl0E+YP1Dpn/Udb5GEHQjyuYwA/7xCtMjqK1K3vtIu+xe9r
 Y36BIgnssvTcnzJfU9H4ZhgGyjQ+dWPjaOPzqmSvlh3alKqwaBWyjE89RbH4oj/cKHzctzXjR+b
 eiVwXwRUs2URrDw==
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

Assisted-by: Claude:claude-opus-4-6
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
2.54.0

