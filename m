Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ADE0E5452BD
	for <linux-nfs@vger.kernel.org>; Wed,  9 Sep 2026 12:56:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788958612; cv=none; b=avQvor0hjjbJnWkIyRnqIzSmR28tUPsgUII/BIXd3O2l6zimwBsgGnXLimnuLIdRDFrhYTxmYnEwJfioEZI1xxVYBMNdk02zfBy03DInN3lvaOM+/RvdiGjdtkgDcN2+oRKnUg0sf+k/mLTgOVFv+TRyqfeu6phZ1KmRWw17LoM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788958612; c=relaxed/simple;
	bh=n/q+ozY2ZofxMAnB7m8rFvBzSpajSFDWbYpcTGwC1Qg=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=LWP7epXMT3meWhBXA5Z+kJotddoHA1T1vK5XBYKlgELONFLE2CYJ6oYKvtaT9+AxTBoNhAlN6KMMLnZXcHCSbkeftTeTh8PWhtoGzcOeBBs/BJhZ0anorUvzNyDUNhieYjJawbceMLGnvZTS/vEL4uclD5Hp/epVik0LfTTvFS4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Nz2kZR+2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Nz2kZR+2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C39EF1F00A3A;
	Wed,  9 Sep 2026 12:56:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788958610;
	bh=bPZ42aX/IqFkXEUJoHMA/dlu5hbYJWg9IP5ELg0LrJE=;
	h=From:Subject:Date:To:Cc;
	b=Nz2kZR+2t5Hmbo6ijNq2bMUqHcs+h7mtGXZIa0I7imJBWKcXUjKSTugfwkX5Uxaf7
	 /GHEpHyW45qUR+cAEKZmBss18oidAAMPBaJQsK7tgDwDtieWY2yoch5q+b3dpCwDjh
	 dPdqrI1HR42StGru+Ca1a4q7y8M1MMc+FHG4a1uJp1EXLaH5L5JTlkpUu9/Y416wlb
	 ZfFuGUXJVVLpv+iWmuwUfk3UiSAhf1q/Z9kxFP4s8Qkf251YhU+9C6LR6n5lX9Nf1b
	 5rf1VBul4AzWKzzw1Otxz0yQmFX24NArslHW1RSUQo7HuLGUrFQy/VDE7yngZ2F7D1
	 mDX8AUziwOFtg==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH nfs-utils 0/5] mountd: fixes for netlink up/downcall
 interfaces
Date: Wed, 09 Sep 2026 08:56:43 -0400
Message-Id: <20260909-nl-crossmnt-v1-0-4064b5a3bd85@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/x3MTQqEMAxA4atI1hNoiz8drzK40Bo14ERpVATx7
 haX3+K9C5Qik0KdXRDpYOVFEuwngzC1MhJynwzOuNJ8jUeZMcRF9S8b+qLweVfZUDkLqVgjDXy
 +tx/IoLhvPCs09/0ADkFd02gAAAA=
X-Change-ID: 20260908-nl-crossmnt-85584b71c721
To: Steve Dickson <steved@redhat.com>, 
 =?utf-8?q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=955; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=n/q+ozY2ZofxMAnB7m8rFvBzSpajSFDWbYpcTGwC1Qg=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqoVeQ80hchs0qiCnop4ARX7SHdk49Nje97xr5P
 BVGV/LakdmJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqFXkAAKCRAADmhBGVaC
 FWihD/9ZCQfJTX6FKz92UsakGszsKEnJEhUHCKNDcRwKfy3PLUQQFVUlCvKDfS7hv2ajAjkFv/K
 UsYQYdlFRcL+VURto0e6E4ptpHZ4JwJsTh79lIXnbGZVmlKWLZg9PQz/6fBb5Nazukb5jCTaI8O
 oiNIC5un/ingD1rphkfEHpBkVU5cPvbzVbAPg5kIj+DTNZcmKBJSQzUNqRaVI4+JB/QA/R2ZoDg
 nMqJtJa0WBumFfXVmGyR5XiJNztfFTrLy5N+ZnErqmbEJdE0Gyy+CUWwn036Y8Oo2+rJJlxRl+C
 z6bD2yGPpSOvDPQv7FNYUcTDFMW0yB1v0KnJX7fGkUpT3D9I8Ja1n6afNuWx7+YypK2/ZkGSMH/
 y3fZUTQy4ucVNxWqNKCbrs+DscPBLKwYlhhj04fb0Yl1rIn0Ocn2BMLGN/+apaD3Ph3y5E1oaVB
 492mkHR6LrpHa2xrSU+iXL/KcHRzV8F9ERF5DFpHUKJ+dcbjMnVWGgeEGWI9ZOwptNw28h7MOVQ
 Ev+ouRPdRuOCyONKTh2WjoO/OieJeDC0xCSXHO0gmdXNv0k9L8LyKGfJoprSCyX54i2D5NNEQAj
 308CdimuHLBieX6rte7fH3j5BURq35S6qVvE3VCYK+eHpEYWICR1d/B8j34Twt8m1Ixa+Fjz2hJ
 EPXdBq5tXRM8/WA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Mantas reported a problem with his configuration that was using crossmnt
and autofs to export a number of btrfs filesystems. Some analysis with
Claude also uncovered a few other bugs. This patchset is the result.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Jeff Layton (5):
      mountd: factor out the per-path export attribute computation
      mountd: handle unmountable paths and junctions in the netlink downcall
      mountd: answer requests the kernel rejects on the netlink downcall
      mountd: don't leak the parent export's fsid onto crossmnt submounts
      mountd: retry unresolvable fsid lookups on the netlink downcall

 support/export/cache.c | 1046 +++++++++++++++++++++++++++++++++++-------------
 1 file changed, 757 insertions(+), 289 deletions(-)
---
base-commit: 630393e9c73667b3fda6a7507cb5171ec0ec38dc
change-id: 20260908-nl-crossmnt-85584b71c721

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

