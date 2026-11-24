Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795549760;
	b=SiSvy92Kw4GX5JqDOGekJFAQIkXdb8kYQDYCGLUmZTeJSTtRBsgpZ9NCoPlyaI3fcOB/
	 JUEQreKYo+vU/YtTrHx+Isho/NbekPVGr+E/a53VEFgoGHG/QvmkVIUb7/c12KXwVNDuM
	 3oP7+ZjF554Ink+/jl49GO55tNHwN1pUzh9GV1AMjI5WMCuXRT5uEmaF58Fe/IIkCJDYm
	 t5s3BpsvF99PfTqnH4VdB3da91Xm8ckt73ZllvjBAZYu/CLnQLqInnnNce2Kk93ujMWO6
	 /9UsHN+USd3eIKHJ8g8O2BGwwVzlbzeF3FwpQtjdNYBHwIAx1YOHSXSxgWvFWAQtbXA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795549760;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=O1sulBnWgifgRMkdtGNHeEVxcExsX6g4uHI//kcD3cY=;
	b=m+W6/gmt/22sEclWzE62C1KLmS5hWtBQ4MOc94dOx91c2YFOIoaXE3qzlnQ33riPe0Sn
	 qSgiw7EYks/KcJR3IAYYn/YiPFgXpo5TsGJPTxneucTa4IfdkGzp6qxAY7P5xunxUJ6mH
	 I7dKcoILRJCp+t71DnbOgNnSA0WqoYkGwCisluwXl4ELw5SKbDfVnwfSrkoS/Dz4VSR7M
	 LFiI6PhXlUEje8S+AGi3mDebgrmpAZvf+T2bmuK0Ag+gyKQA3xcG8A8bkxjSHApedDPGp
	 YVz6yJlijEDNakQhTzTkm7CfI3GxgFRb1AaA+YEDxmJJVjaOAAo+TC3pKvQIKrt37Cw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SWPJNDcS;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 55AD3606A687;
	Tue, 24 Nov 2026 19:49:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SWPJNDcS
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2AC491F000EE;
	Tue, 24 Nov 2026 19:49:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795549759;
	bh=O1sulBnWgifgRMkdtGNHeEVxcExsX6g4uHI//kcD3cY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=SWPJNDcSaN19zHnKDDnPFlYNsKmevgV/OmfcYfhCwG7Zk5aRcD3Vt58Rgxo2egG2a
	 C5lZRywzbrvrPTXEmd+95XvTZ2m6z5gqC0jK4NM64DzR0qfXStiF+wteDBNI0ZYU8b
	 PH1kAXILQKpG4yzz1HMPb0rGV7aA7Gks+GMs6qe8hRABt46q05S28kDULZgSh7zJLa
	 lWu1TLfDPWAWpwjUxf/ZUVSKlDFvGZKRYjtmnzWsLReUjr+gfoXRKQZeCgna0NrFho
	 tFlKijuT5oMcPKvCRUDy9Lwi+3ubgEcQZDci+hA4j3ldYLu3wO8OnPW4zmBKPU7DEx
	 AGWguc/4SozeQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 24 Nov 2026 14:48:44 -0500
Subject: [PATCH v3 05/12] nfsd: set ctime when a SETATTR with delegated
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
Message-Id: <20261124-delegts-fixes-v3-5-6fe4ba705aef@kernel.org>
References: <20261124-delegts-fixes-v3-0-6fe4ba705aef@kernel.org>
In-Reply-To: <20261124-delegts-fixes-v3-0-6fe4ba705aef@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: =?utf-8?q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2624; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=V+uisbAXQbtu6CUcAF+y90uRiUdPfbX3WCLXoBKW1Sc=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrBeo15l8Er9ZdYcWSSeVc0qRXmc8mKN31XSnUw
 eTHJAiaI/aJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawXqNQAKCRAADmhBGVaC
 FaQaD/9+cV1SoTKEE9H7zjBvQSuiF9SJzELkx59brYHuDmV1HRRukTRRkFHHqCQFrxwJE/ixipy
 yoWxtcQWTgE4pl4ydslWWkxCgSQGURk6WydmqNFZKMH+svrT20kGiPaGD2wGbcvPntIQe6sKXnb
 QecJg2RAhD89jDwhH7QAmOJD1SKbDOC0W3iL6tp2/naYmPT/XyGRUGIgvdcQy46OWzFbinzaQl3
 Vox+bj9m9S6yPew1cdcZF/YQYJG5zXTbDFanCC8fkPZA3iHn4rUAsUoxcBXlUtrV7+io8R8l6zA
 dO/KI3BCkKEc4BO38OPDwoEhG3lHEvGV1nsBaTP4I3UCmCwDrOZHTIr1+g0OVE9rq/nzcPANFIa
 m1wc2VZ3bkjxbGJcwkW0DHOYi8MWB9EC85NzyKI32H2CuBDrQt4eK6d7jj0v+dnKWBmuh2ZC/RD
 FIHox4UzaE1d2r9kYxR3Bg1PI5EcvmqNsQDCROZ0GhDJ+7FuA8PME2e9YSN/wykByQ5Wv1o2CsS
 yU51W9cchtc2Psb7+Nrv+i5gWyNgcxoT4R0Wh6xO+TT/8DfUzk3OIl/f3RF6onFeMsLiwdy/Z5A
 eH/0RY0gUTMEOnejLsUyT4USHttF+SSna5jtqtLA8x8Lsdf9cko2OUXgU2jAfjVCIwDmmCD4Vk7
 QRQXm+CS6wJr4dQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

__nfsd_setattr() adds ATTR_CTIME only when ATTR_DELEG is clear, to keep
a delegated atime-only update from moving ctime. But ATTR_DELEG is set
for the whole iattr, so a holder's chmod or chown sent along with a
delegated atime changes the mode or owner without updating ctime.

Add ATTR_CTIME unless the request is a delegated atime-only update. A
delegated mtime whose ctime fails vetting now moves ctime to the current
time instead of leaving ctime alone. Since ctime moves, set dl_setattr
whenever the delegated mtime is applied. Otherwise DELEGRETURN of a
written file restamps the vetted mtime and atime to the current time.

Fixes: f9a348e0de19 ("nfsd: don't set the ctime on delegated atime updates")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4proc.c | 6 +++---
 fs/nfsd/vfs.c      | 8 +++++---
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index b76320c265e1..f8473d0923b8 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1378,10 +1378,10 @@ vet_deleg_attrs(struct nfsd4_setattr *setattr, struct nfs4_delegation *dp)
 
 	if (setattr->sa_bmval[2] & FATTR4_WORD2_TIME_DELEG_MODIFY) {
 		if (nfsd4_vet_deleg_time(&iattr->ia_mtime, &dp->dl_mtime, &now)) {
+			/* ctime moves too, so DELEGRETURN needn't restamp */
+			dp->dl_setattr = true;
 			iattr->ia_ctime = iattr->ia_mtime;
-			if (nfsd4_vet_deleg_time(&iattr->ia_ctime, &dp->dl_ctime, &now))
-				dp->dl_setattr = true;
-			else
+			if (!nfsd4_vet_deleg_time(&iattr->ia_ctime, &dp->dl_ctime, &now))
 				iattr->ia_valid &= ~(ATTR_CTIME | ATTR_CTIME_SET);
 		} else {
 			iattr->ia_valid &= ~(ATTR_CTIME | ATTR_CTIME_SET |
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

