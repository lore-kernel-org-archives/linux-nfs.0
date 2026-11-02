Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793651915;
	b=xwhsPXM1mAEmjegVg4DcJf5EnlJLGwmx0oZ0dloVjcIPNR+hWEVjc2wRySJ9ZIHz5EcO
	 MLxsKOVbY3wHe39W2QGUxzm/leEE7rYcHoHgtVtTGYBJTBPttg8ackdHJLanS6HlsAbau
	 HeDZSe0nMx4sCoYhJ+Afr9SR8zdSYZLKHQEHNELrj1BKCr0KQuiQKQbtrFtgJZwmsXryD
	 6VhkAqt/2L2elRYyflHQqYh7K4eF8NDlDcKaE3cMI8EDfYZTvJHHkUWNYoEfzkIiBeM/p
	 /KBC43AGeZagIzdPdZSgm7gexjkxCIr/ejtHAeI/r9/vbLUMd91D+pWHJc4EuU8W9Hg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793651915;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=df9x564ZsWQ1YlCAdFuR+tc6g3AdQ2uglH2tG8Nzp2g=;
	b=3B/lOO0nBMLWjxyEj5OlJAFKwmkCwQOWjqUV0eA5BSd51ms3A0LRmKb9fVuySsPK0n6+
	 TfqCSrT/z77y7K2YoftVYC2DW6MKF4fg6SyH/zPgf8xOtfdbty1I9J0VZr30XiiVbeBE9
	 TXk+j0IOuMN+mT3U7NXnt8RGnSc4g9DOdaGqCwUUhW5OD5OrRIDKe1F9hdHL+LpmvnkjK
	 FRuNxAvmOtA5epoSe0TwXU2bdT8fbpjHrPApFGE5whG4mfhWsTBo4AwQEjISAr1AygMHH
	 DvlenbvBCB4MKznOU4MC+lgvj/DRHg0u2MHFiipJCpRZagEhKzPU+aMTXdhwx83SbQw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LM3sDaqR;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E090F606A32D;
	Mon,  2 Nov 2026 20:38:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LM3sDaqR
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E9F9F1F00A16;
	Mon,  2 Nov 2026 20:38:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793651914;
	bh=df9x564ZsWQ1YlCAdFuR+tc6g3AdQ2uglH2tG8Nzp2g=;
	h=From:Subject:Date:To:Cc;
	b=LM3sDaqRE8I2qEmkyJYeBxfLvRw8nV7lmWUScSCm21foYbPvaaUN6fLnk4czVmYT0
	 7eCUDNjkQOISABXaY018YeQdeYWcVb0zEaxwdxI9nSPbTYVBZ44cb0vv7KRrgpisiw
	 3XR3YI8QwqepMXCTiX0hU6XskJjlgp1c0RZkIVDZS0yLhXNuJqv6U3dY+h85ZWco2x
	 3Nl/z+fb+F/nGQr3PRW6Qf9DQ6bxbfjrQ4PVvu7jK/BojIe/uvfAuzuGBzDIj2f8Af
	 4DI1TtVvsAGtmYYBhHgnpQ2XNWn0MkoThCLOojmVpnWpd0LYGY79oOkvZoBch5/Mk6
	 uHts09ndfbdaA==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 0/2] nfsd: more delegated timestamp fixes
Date: Mon, 02 Nov 2026 15:38:08 -0500
Message-Id: <20261102-deleg-cb-getattr-times-v1-0-ca0326d88623@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/x3MSwqEMBBF0a1IjS1IahBatyIOYnydLmg/JEEEc
 e8Gh2dw70UZSZGpby5KODTrtlbYtqHw82sE61xNYsRZa4Rn/BE5TBxRfCmJiy7I/PG+E2ekm6y
 jGu8JXz3f8TDe9wPYL2U5aAAAAA==
X-Change-ID: 20261102-deleg-cb-getattr-times-8aa926029b16
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=680; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=8zSd3J/2kYNwxJPhf/PPw+gedCJ9TUNUnrEoLsz/m5g=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq6PTDeCTPzMEO6jlw6LpqH1m+xVyGa04u/EqDa
 F32l8lK2GyJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCauj0wwAKCRAADmhBGVaC
 FS/OEAC4WnG4uN5TUmB+QY0cyQcAblkI/eDxBa77Z+PdAkEU2JGxzRPkKSqLtYpchEAYp+PZ8lo
 QHizWPxUHkVoNw7weGSODQYT+sn+QbX/+q0TBW95rM0Z1fEICxBVtRh7ncgilF8NLSbY6j9Xl0n
 D6jlE5pHbv8lqhqD2XKyCsv5/9/Kg3XFVKWTYiA20bVSYm4hDITKv1dILEuhAlFvbURGDzppefo
 1F/8+gubceC/k3k9epI+RwOiXVIRegz3wq7NolFYKtTWcZdcrtmvX+tNWbFCtTw3UJqNwEq+D/j
 t9mNsowzWPUJNvv3WdAwWdm4WtuRA7wDXG/ZOoaQthx4k0eHogsgKHS+3UvKyscTnaVchwCjkYS
 cmvF+pCqFjnCp0LcZPf5jukO3Mg5sThrBIvfR31clrbE1rYv9D50yZS0lTZP9F8tfv6v4EIxNMS
 8zwsan08HllRChar6dp1xq/fzxID47p3Z1Fdrn2kO7FKxfUpINSXLQngsWjzDYgUheiDtjeG0Z8
 kLIx6wDdVNItUKyZRvAwdqTO57juei1JOKW9HiS/yGWVzj1YvZ2Yyf1SdPDU6ZAe2/Gu/9A19Y2
 xOzsL7zMf28h0yaoqffj3Osb5rYC0owiLNERMM6FnbWjStexujDSc9P755Bgvl84wfpQxBGAKVW
 K6vEd5L3K6jo1wg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Chuck recently added a new DELEG27 pynfs test that fails against nfsd.
These patches fix the behavior of delegated timestamps (again), such
that DELEG27 now passes.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Jeff Layton (2):
      nfsd: Report vetted delegated timestamps in GETATTR replies
      nfsd: Honor delegated timestamps when change and size match

 fs/nfsd/nfs4state.c | 15 ++++++++++++++-
 fs/nfsd/nfs4xdr.c   |  6 ------
 2 files changed, 14 insertions(+), 7 deletions(-)
---
base-commit: 08f97dfc517b50a00a41ce99f5af7b6ce2814592
change-id: 20261102-deleg-cb-getattr-times-8aa926029b16

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

