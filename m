Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F08B226F2BF
	for <linux-nfs@vger.kernel.org>; Sun, 23 Aug 2026 01:40:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787449227; cv=none; b=ammx39WtsSVI71tNsGxqP3r0TKCRI+jooXGuiTHY2HpOEJj34R9uPVeyerXVi3CPvvElpl1VQkzbu5ZTB1W4rlXMEiOctfze2xkJvXvonKxCGHdJbAvDmAsUd1duHE5wl8QEem6HDxZF8LlAdAAuoV5JdoLE2z1vV1eedQK63Og=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787449227; c=relaxed/simple;
	bh=aLpwcXrcvTGjjzm436iJYyobF8BiKm+87qnb5HfsBH4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=igddz4zrUaljMHYDxtWoREzXqV3il272amVoS7aSNQQc80nN+TznPIcydzLAB1o0EUhFw1saoLPxUsPjrswhQ42t+FhN82RHrjQMYCb4VJAD9dJSgDSJ/4EXKp47ZfuqXSOXylyWHUlj44cWYzdEPmbibSH5qZy6S3F40CqjFJ8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mN3WkDkd; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mN3WkDkd"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2F4081F00A3A;
	Sun, 23 Aug 2026 01:40:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787449225;
	bh=PhygjQgbvy5TttGgIaqGkRxl2XRfSIf536i3cTzZTm8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=mN3WkDkd2jwKS6x4IIJhY+mwM01Pb50wAJAZbInrPPQC9ywZxnAca2EahJy1zB/Sh
	 udH2vsIS9wVLnKqYSeW1Xh6uKcB/PJPSUQoDa9b9FIRQa8bfJZh4L8ka03P2oJlNEt
	 qSm9HZIUluS/Ecgv/u7M8S4d4vniFCOIIsQ+ZIuoK8W3hoSkOdKrNUh7nP+JuTk5mB
	 2G4TAhDJXun32tOivTfCykUDZMWHEQ9bt5PSECpIUgcjG7n4b2/xyFh1Lwwrq30EBb
	 Gi1VAi21IEQMycj4XmonDTvHkD6PDhKBTYLNdKcDAFSkWwQppbuocCfa5AV1i1wTv3
	 rYcuhE1fqv1AQ==
From: Chuck Lever <cel@kernel.org>
Date: Sat, 22 Aug 2026 21:40:15 -0400
Subject: [PATCH v3 1/2] lockd: Fix use-after-free in nlmsvc_retry_blocked
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260822-lockd-retry-blocked-uaf-v3-1-761661eae60c@kernel.org>
References: <20260822-lockd-retry-blocked-uaf-v3-0-761661eae60c@kernel.org>
In-Reply-To: <20260822-lockd-retry-blocked-uaf-v3-0-761661eae60c@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>, 
 Shuangpeng Bai <shuangpeng.kernel@gmail.com>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=2116; i=cel@kernel.org;
 h=from:subject:message-id; bh=aLpwcXrcvTGjjzm436iJYyobF8BiKm+87qnb5HfsBH4=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqik+Ht9Ez4GAH0A137RdIMb0qnvn1hEJsFKGR2
 8hgsFztnIyJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaopPhwAKCRAzarMzb2Z/
 l6VpEAChFFtQTEl1Umaplx+RxYAN0K5zoFFUW2j3LpM+Z8Oya/MwXgP9NK94iI6dRSjgeI6Y0Kh
 2iMQcCbyLaJp/X9mkCTQCQMTeZ1sbdRgk5+Qj48UXHznJ8j5kl9eHQslcRCrBEIUHva3teDQpMw
 WUKA6iDAHdXFgIip+lL+8aacDMs/TcpnM7gA21fACZoExUPVbV9g/lGEWLrIxcCemNuk5F+HLVT
 NbAfCthgykHXY30T8MtsH7doMHuoikuM5DEYIWcPvT22UexCysfP4N0aF2o3fIEpwRHUiy6ivSs
 SkwxEcKrPYki1thbBgzKXiZKpmXWb8Hu4kzcv3UFR3UQ2/5AxydXJssMcavPh4s3lnxLqpoi8gO
 Onz5LU5oi2F/GbtHatQDUhJ4Wbh+JWddHRo885ZzBPGHz7G56XN1/C26GLLBC86EXoVXu/P2Gua
 pSPEJCgOeFjsB2cjo2j1OK7x0b09g8Lmm4SrgmBRWKYa8rrOWf6fbfvlqriiMlloLku+nKwEoT7
 wcrAhht55nDv6Cl7jyJPm1GGE6P4LvyCyWxNdVRl0sUnEhBYHbJ3yFZRid8wg0eweH08eUcuWr8
 DSnBDO9pjmLio/4NQf40bkiJcx96F52Gus99C4ugEXLVCqp5zO4Kc62MN+DuBfTvbHuLcKOWYs+
 RCN2NXpcZMH+bcQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nlmsvc_retry_blocked() examines the block at the head of nlm_blocked
under nlm_blocked_lock, then releases the lock before calling
nlmsvc_grant_blocked() or retry_deferred_block(). The nlm_blocked list
reference is all that keeps the block alive across that window.
nlmsvc_grant_blocked() does take one of its own, but not until after
the lock has been dropped. Unmounting the nfsd filesystem while a lock
request is still blocked reaches nlmsvc_traverse_blocks(), which drops
the list reference and frees the block along with the nlm_rqst hanging
off it.

  BUG: KASAN: slab-use-after-free in nlm_async_call+0xd6/0x230
  Read of size 8 at addr ffff88811b04c808 by task lockd/8377
    nlm_async_call+0xd6/0x230
    nlmsvc_retry_blocked+0x61c/0x800
    lockd+0x144/0x1c0
  Freed by task 8392:
    nlmsvc_release_block+0x231/0x290
    nlmsvc_traverse_blocks+0x139/0x1b0
    nlm_traverse_files+0x1aa/0xa00
    nlmsvc_free_host_resources+0x12/0x60
    nlm_shutdown_hosts_net+0x127/0x280
    lockd_down+0xd5/0x1c0

Take a reference before releasing nlm_blocked_lock and drop it once
the retry has run.

Fixes: 0e4ac9d93515 ("lockd: handle fl_grant callbacks")
Reported-by: Shuangpeng Bai <shuangpeng.kernel@gmail.com>
Closes: https://lore.kernel.org/linux-nfs/20260818235808.3458075-1-shuangpeng.kernel@gmail.com/
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/lockd/svclock.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index e628b5d35507..8d83283d3e21 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -1023,6 +1023,7 @@ nlmsvc_retry_blocked(struct svc_rqst *rqstp)
 			timeout = block->b_when - jiffies;
 			break;
 		}
+		kref_get(&block->b_count);
 		spin_unlock(&nlm_blocked_lock);
 
 		dprintk("nlmsvc_retry_blocked(%p, when=%ld)\n",
@@ -1033,6 +1034,7 @@ nlmsvc_retry_blocked(struct svc_rqst *rqstp)
 			retry_deferred_block(block);
 		} else
 			nlmsvc_grant_blocked(block);
+		nlmsvc_release_block(block);
 		spin_lock(&nlm_blocked_lock);
 	}
 	spin_unlock(&nlm_blocked_lock);

-- 
2.54.0

