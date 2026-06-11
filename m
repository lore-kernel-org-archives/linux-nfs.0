Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B33F53876CD;
	Thu, 11 Jun 2026 20:01:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781208071; cv=none; b=hhtmn/XFJ+RHv5Rdkend2zNptlHE+AK43p5F49XYK8gZhwxcNmpGXeAyyxuNEmNTrzsSJ/iBFFtwOvRA0RLBnlw2NBW8boBqeoKXTOAPJu4BOSYVOAMs4IWZR70e6PE1N6kPsQpenw2gyE5Zt45rPBEcrSME/KnFpY8QozUl0T8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781208071; c=relaxed/simple;
	bh=Y3Refx3U+1MwPJc+L4cH/cuc329E0HvcikHFuid8Gu4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=dcqz3hHKdD2Yyl05vPU6TDeHq4bRNP6+/Cv4Gw+GT88I7oNTFg8TgDfoasXNl0w1+ovH7ObhuqS53c46Qo4/Lx2T8jOC9laJeN6LhxwrCUrqxifMrH9kNjhFGDX6KXGQ7EmlnPtqZhwJtr8zt6e9MdA8/fR8ufUfPhtkm/VmhQo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hNBKR+lB; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hNBKR+lB"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D6F331F00A3D;
	Thu, 11 Jun 2026 20:01:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781208070;
	bh=EIvDc9e32Avr/1wmv5aA/9WeNHs1QKKqt2zypgSG0Ts=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hNBKR+lBHFuiZ8f981vVg8BLx7Ltlieo5RZ2XAL80POGUGGmne6f3l+VMZTCPpK3/
	 BIwmK+xVT2JAejudh71TmzpMMqJUu8YAAcOqAO9YQRv2Ta8b4vuwWADHN/mfvPJ9kJ
	 JVT3V9RusuR0KaDsNyc7PABJVbW3Bt1TB3ANs4EiOU389Gc2HDczqyZ24VcRUkvfMi
	 f9dsg2fkawP4zewzj+ZMpN3gZFtDm7s6TYLxHtRTCGDS8nbOEHski06HYpgehLW+oI
	 N3345eGTNoego369MLR32cGF0sPQiGltLYhB/WQT3cgtEyDQ9ZLFTywfPoRcUawcSk
	 lK6vlZearZKuw==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 11 Jun 2026 16:00:47 -0400
Subject: [PATCH v2 04/21] sunrpc: defer rq_argp and rq_resp free until
 after RCU grace period
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20260611-nfsd-testing-v2-4-5b90e276f2d9@kernel.org>
References: <20260611-nfsd-testing-v2-0-5b90e276f2d9@kernel.org>
In-Reply-To: <20260611-nfsd-testing-v2-0-5b90e276f2d9@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Chris Mason <clm@meta.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1846; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=Y3Refx3U+1MwPJc+L4cH/cuc329E0HvcikHFuid8Gu4=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqKxP9MT1/bJzxeiEqCIMa53QQDcfC4ZrhUZNsi
 HEPzmYdCS6JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaisT/QAKCRAADmhBGVaC
 Fe5DD/42Yp/MeTrR73d38q/CmPeiIrtpC8z+YGkKPbxb9OXLtSC1xcjDUepvtv54SfrDsd/Hz+D
 GX+eTl1Aef/6XIb4tdyjgjG2ok7gZIArVi3XvREr+xKV1smB2PxT+vk5kDiJJfxewVwE0CxOg4Z
 nMJ7H6vYbAvdnxKXuKWUTQ7n/wEsmc3tOFe2LEe0TRqTtJ58jGV4SA3YeN18m4OXXLMLulEwXWO
 BPW7RGGM9MQa/w8tofj+IrcBI+/BzB1Ls6qKT/Juz/quEk4D0p7GD44v8odsT0A3CO6n3DtlRop
 mmFKmwY3GtVSk5Jr/eLUOb1R1SW8qvUDPdvBdyvWU0WY+FT9UqJ1SHy22gkDcggnD8W8e+/IyFC
 MWWwPaOEi5M1VTAvvHf20MRA4AwHF06wx+CJU6+HwsOIxZbHcJF5f7+/GvVNvB9SohuPGmILqsv
 w9xWT823tWhhi2hxvyNK5NHQKpsOF6CX92sSiBuEAoqLu6FOPfiw4CO/nIdYEySKxYy7b0HY7k+
 Z7WTi1YH8hEw+EyK+c+4NotlFx4Kh4PpdXERG/Y3uKVJKO006xXJJKO9SN18Ooj/Oc3KPmjHPwM
 LJE1YCjvgy2bujyZMceFTS2nJ91rLd0duYgaOm59wJIcX00QyNAZ4VBWidwBnuVuXmPIkCMmDJp
 nHd3FNs4yRlNJgw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

svc_rqst_free() frees rqstp->rq_argp and rqstp->rq_resp synchronously
via kfree(), but defers the rqstp struct free via kfree_rcu().  After
svc_exit_thread() calls list_del_rcu() and svc_rqst_free(), there is
a window where RCU readers that started before list_del_rcu() can still
traverse the thread list and find the rqstp.  These readers (e.g.
nfsd_nl_rpc_status_get_dumpit()) dereference rqstp->rq_argp, which has
already been freed — a use-after-free.

Fix this by moving the kfree of rq_argp and rq_resp into an explicit
call_rcu() callback alongside the struct free.  Resources not accessed
by RCU readers (bvec, buffer pages, scratch folio, auth_data) remain
synchronously freed.

Fixes: 812443865c5f ("sunrpc: add a rcu_head to svc_rqst and use kfree_rcu to free it")
Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 net/sunrpc/svc.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 86d39610cf0a..dd80a2eaaa74 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -716,6 +716,15 @@ svc_release_buffer(struct svc_rqst *rqstp)
 	}
 }
 
+static void svc_rqst_free_rcu(struct rcu_head *head)
+{
+	struct svc_rqst *rqstp = container_of(head, struct svc_rqst, rq_rcu_head);
+
+	kfree(rqstp->rq_resp);
+	kfree(rqstp->rq_argp);
+	kfree(rqstp);
+}
+
 static void
 svc_rqst_free(struct svc_rqst *rqstp)
 {
@@ -724,10 +733,8 @@ svc_rqst_free(struct svc_rqst *rqstp)
 	svc_release_buffer(rqstp);
 	if (rqstp->rq_scratch_folio)
 		folio_put(rqstp->rq_scratch_folio);
-	kfree(rqstp->rq_resp);
-	kfree(rqstp->rq_argp);
 	kfree(rqstp->rq_auth_data);
-	kfree_rcu(rqstp, rq_rcu_head);
+	call_rcu(&rqstp->rq_rcu_head, svc_rqst_free_rcu);
 }
 
 static struct svc_rqst *

-- 
2.54.0

