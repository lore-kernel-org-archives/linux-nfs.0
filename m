Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D48D1449990
	for <linux-nfs@vger.kernel.org>; Thu,  9 Jul 2026 19:02:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783623776; cv=none; b=jyX3lt7cgl1NeKbROC8l9Qa5Uk4F2/1VNytP70f9JYrqOt9lp9I8eR9CrFtbVRdUUHk8aP7goUC4Lm43vDduQq7tZHLxrE105Ww91FKvgfUbXXakYSYZUJ37JdXCGrWHFYcvUR4r5KYBOlkrt/QJHufwAw4rmlB3g0Wgu0BLZh4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783623776; c=relaxed/simple;
	bh=1UOLMmghtVXxfdVciEIWTVe5rVt9XCJ9ICrutYRvPbQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=r9fHb11jv3xUi+AUAr/sT2j1ND1Ppd6+MBoQLr/v+qG+fVRhrSTAPHgqnyUo51tHKCyFVKZ1266vIIdP0yz35uZgkureIym5+P0GLNuhR+AemQbBw0XX+LFB8/PPLUhMhBoK1qAmnqYySQ1jUvbhKgVSiKxZ92YxYoveecbZmII=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DBVaSd9x; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DBVaSd9x"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2A5F41F00ACA;
	Thu,  9 Jul 2026 19:02:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783623774;
	bh=+QYBJQnvniVw6MG+D6HlXbFRtdlW8mUhH/YDJzC0En8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=DBVaSd9xqstzjlA0vFEIAFaTMpCtoPdtADUeuRu3jt4/cktdQXBzAvnvi6U0f93PJ
	 jL+1AOIdH1Xr8JODd1Pib60nCuhgOVXta3dwsOfWoFCCbIK1+yFLFmJGte0VSZHHXh
	 pDupG/BXMyh4MLmIyczT5bwCy21mPdGQkTNBVMXJjCN60CePIigXDVZmWC2EtdKd7E
	 TurAYnfhCqAGZFFqqRu2sChMK/u/0xGxD0Uyy+6ggOZl1fVAKYsN0fIJAVrvkx0qj/
	 ydxzN7rwrHY94HqvPbA7Enq2BSAxU66IhPVMMpDg8CGr4G5MYnbN4XOXjwVN5VYFkk
	 P3gCulMWU3zfA==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 09 Jul 2026 15:02:38 -0400
Subject: [PATCH pynfs 10/13] nfs4.1: fix COPY_NOTIFY args union arm name in
 XDR
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260709-copy-v1-10-849bf581d7cb@kernel.org>
References: <20260709-copy-v1-0-849bf581d7cb@kernel.org>
In-Reply-To: <20260709-copy-v1-0-849bf581d7cb@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1197; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=1UOLMmghtVXxfdVciEIWTVe5rVt9XCJ9ICrutYRvPbQ=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqT/BUWaEQ1TgcFJnEdQi9s6OyQh6wA+fmm8Erg
 a4RYe9wDEeJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCak/wVAAKCRAADmhBGVaC
 FYaMD/0VK84YN/qIGlor+MbMzkW+Xr4gxZt95LW0h2D2QOGPpVYCSaPvy9kRHqDxnCAgu+LEwZI
 n3y5U8qyyDwFfrLUPUnHOa2T5EzTGaX/vdamT4oSfymgegh8rQrun4s5WL3O7cXmYWVhQoZHXls
 2FPQXiGK075ucp5MRWGzdxbWAYC1mT0zCfhXr0LxtcKwLnUOHMlAV+GqGK45YKbLqfafnCl+eo7
 cnpsHGoAEuRtQ0yq7gl9GZG2L0X1l32EcyFs3ir0DY2UUK42lA/R1eXYYVlb+btgP45GjrBp5Fi
 XYBdqq8iHTe0/v3puuf2PR5k4DiNMtot2nH7zmuPOKBhhIbuVDu0OTaxiqLchTjqUEMFKkma2iB
 QhRe2XiMZ8ovFO0HCxy4uwFfh+wDt5Mfr4LvO+n4d63EwKvtub5GpdEl89ffayBMVNsLTloOm8Q
 usbdVdqWIUKC5GPwXWU40V2WtDLeAO22O4gh2KyjcjgRgUm4KTXUqWQodri/1eZY+cPCrkYPZM5
 S2rdYDf0lr+uj458ieyL90Vm0stB8o91+cEosVjcTQBw4NDffOKAeACrSiJ3zCEXniQmRxUctCf
 aZZHVztCp3Mnwj1NoNiBlKf+2p2WqNjFGyQfA4LJzhuS7QfvX/AuRxBsh3mcaqGpB20JrbNIz0M
 xR/AC4gPDvS4QmA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

The nfs_argop4 union arm for OP_COPY_NOTIFY was named opoffload_notify,
but nfs_ops derives the argop keyword from the operation name and so
looks for opcopy_notify (which is also the name of the COPY_NOTIFY4res
arm).  Because of the mismatch, op.copy_notify() raised TypeError and
the operation could not be constructed at all.

Rename the arm to opcopy_notify to match, enabling op.copy_notify().

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 nfs4.1/xdrdef/nfs4.x | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/nfs4.1/xdrdef/nfs4.x b/nfs4.1/xdrdef/nfs4.x
index f03eb538a298..e836aa684f9b 100644
--- a/nfs4.1/xdrdef/nfs4.x
+++ b/nfs4.1/xdrdef/nfs4.x
@@ -3346,7 +3346,7 @@ union nfs_argop4 switch (nfs_opnum4 argop) {
  /* Operations new to NFSv4.2 */
  case OP_ALLOCATE:      ALLOCATE4args opallocate;
  case OP_COPY:          COPY4args opcopy;
- case OP_COPY_NOTIFY:   COPY_NOTIFY4args opoffload_notify;
+ case OP_COPY_NOTIFY:   COPY_NOTIFY4args opcopy_notify;
  case OP_DEALLOCATE:    DEALLOCATE4args opdeallocate;
  case OP_IO_ADVISE:     IO_ADVISE4args opio_advise;
  case OP_LAYOUTERROR: LAYOUTERROR4args  oplayouterror;

-- 
2.55.0

