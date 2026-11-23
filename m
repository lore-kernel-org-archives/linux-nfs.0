Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795438766;
	b=SKNgvlMnQUkI24373Z2iFdcG6wCHP9NR2HL0zIWANORwl1TxvCbTI2D2ZON4hUvgzNmP
	 ZskmFBLMJaJKsrGarMqSU+JeXM3YpBkK8VfLFLtQNnXhxQlsFgz2mFA6pYlmWbBq4Wech
	 cGpGfPegMu5wDnSMyTY6KBF/Cd3nNylydW+ZqTPYfTeKUvHvPLnw3tmArArcq7bERleoW
	 eFZgiryGFoqjtRi2apsm8SX+FU/CXX285E8Pa+alebOBzsp0esEb5mPKFISfY1Vp4b/C1
	 /tblvyLnTJnhlBq28RuAj0OOtteyiDKiF62KU2PjBJ7pDRyrnegVBBPOQAK5KNNovUQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795438766;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=o7VUWAvWtX5sGVrRow+zG01aPrQuOXpmeRpIVAuay58=;
	b=lxD6j+G7264vATC/w9qViTVJMSFBYY+4jQeGhRU+ZKPVbUSFk79dIENmQjyecgYWbgtR
	 EcaNKC12Q/KWjp7rut2j7G5xbGVjdXNL1ogGN/djjT1qyFk6xs7zxgcVmoQrMis922eXS
	 ng/cskH1R5Yt9cFcBWXuNGhjP4sL7nfyqjwwwV9rSQRxsyHuUpiCpjC/h2mvHuGG7KTQd
	 JhscssFV9zftHIxbkiLsPjF7zRwVnwImtrk19zpUAEOgOcpHc6icJCiHYxCDYVRXND8Pe
	 WxudDSRv7tNCvK1WjhlH1w2+xSHS9y91fd7kEFLILlYo2bQUUkVZGs7p2FjUbYeR62Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=O6wrHaUx;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5DCFF606A6A3;
	Mon, 23 Nov 2026 12:59:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=O6wrHaUx
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 01FD81F0089E;
	Mon, 23 Nov 2026 12:59:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795438765;
	bh=o7VUWAvWtX5sGVrRow+zG01aPrQuOXpmeRpIVAuay58=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=O6wrHaUx/wJ6kUp6a6KJR3VaQMkn3Y86u1AINx9WrZApLm0DOCZqkA9JcwFdVprk5
	 WV/Y2omZMwyNcDY+n5ANsOuut630frAQjwK3Ui7kUtrEcIu/KjqFaJLF7ppiI6XDj1
	 2oy0EddbTnCRnBp6f5H1HVUqjHjqJnEJQGJ6/gpjY+rZxcLqj2cKoCU3ALO8H+lxEN
	 g9+hoO2Cf6GDPDy4H9EfW7CXL2FiiHQD3wI66lFashtqcHvPm0Zig7MUwJvbMR1Ks5
	 jm8+MNi+4vAUa2XAFp1IQktGgpZV1KR1UxnJzBrTPB7RQNvpdvJVyYoyqocQXYHO/S
	 L91AfltV2N/ow==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 23 Nov 2026 04:59:08 -0800
Subject: [PATCH v2 05/11] nfsd: set ctime when a SETATTR with delegated
 times changes other attributes
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
Message-Id: <20261123-delegts-fixes-v2-5-960ce0fb2fed@kernel.org>
References: <20261123-delegts-fixes-v2-0-960ce0fb2fed@kernel.org>
In-Reply-To: <20261123-delegts-fixes-v2-0-960ce0fb2fed@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: =?utf-8?q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1594; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=h8ugCBOHBA0RP/swXkvD2da7g0RgbCp5NS6vZC524/w=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrBDil9AJxzi7TK91lCCcPEisEqebkU34zTG3SD
 GCDjIEANQmJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawQ4pQAKCRAADmhBGVaC
 FVdnEACRsObR13pS52TrIaN/5r1xFbbMb83GcGZmwaZD8FZVsPBakA1T4yfZezgTQex8f0KYCqL
 T1Gc5xBXUcotzRBzP7DAc1ElZdFDAYhtFtmO5v0lHYNMVZt9SNg20zXf5A/b6fpq3ERo6PV9M0a
 0DjiSpmrg/yCynrF0OhTSX/GlZOaxu2uQV9I8MTq3SBSslIk1f0/QrDdr2DS5ey429wex8CTJ/S
 qjrpJgw9+O41DPoQsPAxjH+WZ7++KFstEQsJNqP1ikgvsUABUbl5TMjVCcl2AzR2iYPhCAqx5zv
 77lLRYFEcdGQClp+IKutknkArEV6pi4EohYway/yhLCSZnv0bsfU+qCp9jGG0uSI7Mas0dXbrx7
 4BoI6L92fWuRM/OctHoh/uazGOKrZ6/0slS4cpTJAftJ/GjF+18192JJVU5dxIH80MtJJBCA/pt
 VpbL9FFTV/yug+LqTxkEAbHTNb/J2jFUq1T28a3vKrNVwEKA/CKfGOIFAwR0N256fEhy1+2QBkf
 X2OQr84CJN43+YqSJ5wgfgiHxzrEaCPDqXpe5xTFczraOnjHjhOWQaqKDEPhGUXKmSlcr1V/1mT
 EoOSUdxZuyxW4N8KxjJbJXsmzavEQasJYU15QfIQumR/7TsakNu7SQmFU9yGmLg+VQxUuzmGcp2
 Z6r2IM6baMAereg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

__nfsd_setattr() adds ATTR_CTIME only when ATTR_DELEG is clear, to keep
a delegated atime-only update from moving ctime. But ATTR_DELEG is set
for the whole iattr, so a holder's chmod or chown sent along with a
delegated atime changes the mode or owner without updating ctime.

Add ATTR_CTIME unless the request is a delegated atime-only update. A
delegated mtime whose ctime fails vetting now moves ctime to the current
time instead of leaving ctime alone.

Fixes: f9a348e0de19 ("nfsd: don't set the ctime on delegated atime updates")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/vfs.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 4a5674e583cc..7bc251d55c3c 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -513,10 +513,12 @@ static int __nfsd_setattr(struct dentry *dentry, struct iattr *iap)
 	/*
 	 * If ATTR_DELEG is set, then this is an update from a client that
 	 * holds a delegation. If this is an update for only the atime, the
-	 * ctime should not be changed. If the update contains the mtime
-	 * too, then ATTR_CTIME should already be set.
+	 * ctime should not be changed. Any other attribute change, such as
+	 * a mode or owner change sent along with a delegated atime, must
+	 * update the ctime.
 	 */
-	if (!(iap->ia_valid & ATTR_DELEG))
+	if (!(iap->ia_valid & ATTR_DELEG) ||
+	    (iap->ia_valid & ~(ATTR_DELEG | ATTR_ATIME | ATTR_ATIME_SET)))
 		iap->ia_valid |= ATTR_CTIME;
 
 	return notify_change(&nop_mnt_idmap, dentry, iap, NULL);

-- 
2.56.1

