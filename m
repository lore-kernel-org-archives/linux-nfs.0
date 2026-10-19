Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 88BD243E48B
	for <linux-nfs@vger.kernel.org>; Mon, 19 Oct 2026 11:46:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792410400; cv=none; b=BM0LePt2/VpzXeSDSFcPFVH5Z92486ZwmHTeXoPnBpGJn7blTezCSobUOeVahhnBmmUQAANq1+RisTJNYcFEyY7nmorQXYUwwOSe+B/fKBBDtV2fwEP1YP96u/+GFBgKlerlLzeVzXI1O1LnGqzA9NFrsh0VBJLcVLPyKrHSob8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792410400; c=relaxed/simple;
	bh=hZ7Wsr2SqgEK1L9vQUajjOJtUgVK/34m8TQjbqaOp0g=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=FX5KrAJMGQ6YrfBmFekmwZ79DNRsl1SJaT9P5coI2aquqEmesMYs8rS/gjiamaD0HDvHjg5iWv0MAsAhgn7ncbPHVsXldf76o7A/0mRZbSQZ6w7AbnrgGwEfSG7ZResrdxhRTb21kSm5MjNKgADjQ5lin6C4hoybEoQkmr5nv3c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=F/z1d7Nf; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="F/z1d7Nf"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 17F3B1F000C6;
	Mon, 19 Oct 2026 11:46:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792410399;
	bh=y6KDdESeQgheGjfbeLuOizJXON9g54kAiR1OeISazbo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=F/z1d7Nf0m692E7tO1obc14wfQl68OIlGmjaL3PcMX3dZTTzecWHhWdDUpqsZToct
	 PVpDI0MbW94QtVg7FP80f+kU5OgD4VIQgdk0CUZR3M48VTGVGEeMB7lAkXFhWnSCPs
	 toPzIB+NmZfF1YeW2bbupag1r9nhUVi1QWdjnBePK/KZeqLChgAK8mGvPi2sF7PTLe
	 GptFoTcKx6hmlz/EAe01WsbQrZeotqp/rkoSN/tBvYmm6+qaYjiH/suUzQaiXHE4c5
	 MqIVYYKikr67+cZpv0FaUTHYSq84rG7nE7bDk39HnnkgwR3/dC+uZceNwd2nCrmZW8
	 NmavHox/9CCtA==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 19 Oct 2026 07:46:21 -0400
Subject: [PATCH nfs-utils v2 1/7] mountd: accept -L for --no-netlink
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261019-netlink-noproc-v2-1-7d09a49b574b@kernel.org>
References: <20261019-netlink-noproc-v2-0-7d09a49b574b@kernel.org>
In-Reply-To: <20261019-netlink-noproc-v2-0-7d09a49b574b@kernel.org>
To: Steve Dickson <steved@redhat.com>
Cc: Ben Coddington <bcodding@hammerspace.com>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=955; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=hZ7Wsr2SqgEK1L9vQUajjOJtUgVK/34m8TQjbqaOp0g=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq1gMc2Sw5smAHEEUZfLgqyPIhlXD/xybG5FKQc
 RXl5v3rZ1OJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCatYDHAAKCRAADmhBGVaC
 FY9jD/9yEAvoKrg71DwSOf/rH5A2zHfYp3Lih/CaMOSXo9l5rfpwJ5fz6+QPIo+mPqmB5WE52gz
 Y99Rkl8HcdYrT9dtUgHDoXKcuVJFibmnX1zxOC9CAEAE/hcGO8H9KKJ/jPBcnIrXBpW7RFTO8py
 AAKMHvbY5QQgGDtvLcbA8F2X66sgp3ar+NPvaz9Ao567JJZcJtwK03KL0StYdRuf0Vm/yp2Npf3
 zegKh1CTluASvJXYVOZHcDb0ycx+Le3Hho4k7vQGaqHaLpoJQ1FOd43k3QNWRD8b1J/mBqoFzay
 eMty1LHTt00k+SsMCc1gJIfu3PINMqhJhFDyIVdptPIoaoFEYH3SXdluDukuOWWVWOxxmL4TlIs
 tUbeenOaKXUT33hXgSY0gQwG8wyBnE5X/p70jzwaHgKAkrEoZfqx3alScNDx4WyAjBJbGkWdXJB
 /izbEyVlC+OA4Z+PxhrPVc3vWpol9nk5UIrfxbSULFG8yG/FHec5l1yGhnEWRfgphApfi/53Qbo
 O2jwKMHY6iHkJmSMa9G0jsn6k6BshyPUTfNJ8kT6n0ZcWSaDYz9NvPc03xRuomiTSiQKYDKoWUZ
 lyigQgoxJHrO4MwBXIFCSA3nk8kDt98vlzd3c+dQ1bIRueWzfHUAst3g4bcqsp6jYYafjysk3zV
 uYoBKzg8S77Q5tA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

The -L short option was documented and handled but left out of
shortopts, so "rpc.mountd -L" prints the usage and exits 1.

Fixes: 60c383830537 ("mountd/exportd/exportfs: add --no-netlink option to disable netlink")
Reviewed-by: Benjamin Coddington <bcodding@hammerspace.com>
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 utils/mountd/mountd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 92d8c4690efc..da1124b5c411 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -81,7 +81,7 @@ static struct option longopts[] =
 	{ "apply-root-cred", 0, 0, 'c' },
 	{ NULL, 0, 0, 0 }
 };
-static char shortopts[] = "o:nFd:p:P:hH:N:V:vurs:t:gliT:c";
+static char shortopts[] = "o:nFd:p:P:hH:N:V:vurs:t:gliLT:c";
 
 #define NFSVERSBIT(vers)	(0x1 << (vers - 1))
 #define NFSVERSBIT_ALL		(NFSVERSBIT(2) | NFSVERSBIT(3) | NFSVERSBIT(4))

-- 
2.56.0

