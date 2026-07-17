Received: from fhigh-b3-smtp.messagingengine.com (fhigh-b3-smtp.messagingengine.com [202.12.124.154])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DDEC52749F1
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 04:33:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.154
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784262839; cv=none; b=HZQDQ1cilMTnsUxWU3UIlaoA6c00eXb0iZiwhHP3KS/AmUo9KvvEeF03PxB1LSOaVbqkyZSeKXgEQ61yR45qkqnPc0nkmeEnCVj3zZsSb5EsUOG+KK7hpJgHF6720EdkOoIT2rJ5Ro/CtatQJV7BfEoS+E9S5yWM6L1p3YI3sVA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784262839; c=relaxed/simple;
	bh=FYTGrjpbttGQezkDmyLZLppfj6IUP7qNyH74iWuzxKU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=AJ6xzWZj7OUNKJgfeJibBRUkZayFrCAucgRZ/AqWceD4nhlkxDo4VU7zPzpbMyLGR+8FRJCe9G6K7A4eevI6Jz/X9idxwBqgjddMpw77/Sfv9VfANcGno5tU3mU/82FENq2VBX3y9ppiwXbR4zoJNsGmNwSzutuzHbQWTIApdAc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=WIJLVNf0; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=RVskP6AX; arc=none smtp.client-ip=202.12.124.154
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="WIJLVNf0";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="RVskP6AX"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 5B6307A0078;
	Fri, 17 Jul 2026 00:33:53 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-02.internal (MEProxy); Fri, 17 Jul 2026 00:33:53 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784262833;
	 x=1784349233; bh=MKz7zSBg6h/83wlgEHrS8dEM37A+8DH1lr+8okz5dbk=; b=
	WIJLVNf0eOmoeRtpJk0XUBn5msamkgJa16CbUP6+dm+UM1Gck0I79zzQnKrYxBI2
	otqztz6kalz/ZGuxIW/yTV/fOGfv87Bld6h+Po0aeweeMAFgdHgreDu1MD4WU1Cr
	Wi4SVhfulC+Rury54CaPmUh5dwkvkDjMp7MLLNN1PxHyGUme+UI9fDfTuZu0qio9
	cvYNgmaT+qTooK4E5L3PaHh/Ivb1qJNqXop4dkjC4cXRuCZJtVYjm6WtAfyurW99
	Db/Np9jNOsEtceyX689chfL8gZRr2dRQ2VjRvIH5qkMzxMhlul/+gD/Y4cgBZ1S9
	ZOEgAuF54JjPWskskUQbBg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784262833; x=1784349233; bh=M
	Kz7zSBg6h/83wlgEHrS8dEM37A+8DH1lr+8okz5dbk=; b=RVskP6AXWrOZfIE1p
	003cv6tUUvqzKXfNBArS23tyw96x153lmeJPZGG2RBpm4X3zm334AoQLx1Kag1BD
	63r3thKWhNarVtX0blqNWs2ucXpEPzLDfohwnrgcvSzmUDzAoGn2L0ukhWPCb6SD
	u+QX9UZc9s+fBcj0ObmVoc7oDA4YMOkuzh2LDJjOrWhbuxEA3ym1Aa4zRmM8RWwl
	vR03ZoalRk/15bhunPBmblitAIlx0ySNdh/yW7Xon2tL8hH0xdjp/gO1/QzL/lwX
	nU6ATyHPfzAhA3jcSUSEhvlmT4T7YRmxFsuTHNSeonM7aH8xNi5XTdpzRN5Vd2H0
	RoOGg==
X-ME-Sender: <xms:sbBZaithJsUEBsaEOUEFwOC_2RoMR15bUfpaXhAztK12y5MRxbohTA>
    <xme:sbBZarJCuUESLbCjdj9BYdLTpqO_wkzNTEGLnvLVdf3xIOc2rGkc9CCEZOS7NbDZx
    VPC-jO1IPvMvAebrxM8UwzaKk8dFo3fTRjiXn93d3sXjUPriUY>
X-ME-Received: <xmr:sbBZanmsqI7d_g7yeR_YUReyonlCStsuur2sxfiI6Q_TJHvVMA8HTj1Tl-MUnQFegDIHjftLa-uymaDgmCFDh77iHao3IN4>
X-ME-Proxy-Cause: dmFkZTFe1fPNt0teZMz+igsEg0Yi62Nw1HA3RWU9lajtn/KqgzCHwE0SDkRLEuN+X2bdVn
    +JxjBa/aSTWuozTeEfNHmtuHiUV9Fs0BisuGE4A6T2CuSFG0Kbv+f8y8Mx+y2wKStdSD9p
    PaPx17A/9gdYw6sCXZWoqwe8lNQRn2EzH+qt+7c1YcHbUG//gzMSJJTZ/alz3WThwvIjtT
    idS8iFF3/6rHUzD/jtcaZ1nbGsquEb2JQSEJPSew5ZS0S8U3+gbXCpYfG8PNx1QnJfm2Ft
    pgkeO93PTIHeEUjFLtz/B0GOYhyxjLHHwxBr0+PWJNH+dGjEfqQKxE8vXo/hgjfbNoODjY
    9jCViK31aFGnDaglYJ3Dgfvctmc9Iqz32BWGcM0u75hBM/cRTG2jqcTKl/cDvPx+NnifnM
    nCS+WcCqbK7qu3Xe9pe0lgf6MfUumCo9RtA6ddm5zsxAYKpu+PpMEtiSyQ4hVeQK5xOZa4
    ngtvdCAnfRclB05b5xm2tmQihgZboylIHjpHnhvdMxjkItHHuAXDYi7hH+EljNa+oBo1Z9
    gVBGwkyqqtwVksfrriwT13KJueVsvWlc/8sIRWttD7Xsp9wnc/kMqvAMt0LyKNmZuM8qev
    9Pw1BAnwoSh7Hd6UIYiiWGTaLujLzfTAtL09OkpddkEKkX3XTkYsfs0EPrFg
X-ME-Proxy: <xmx:sbBZakKVPxomvAL5mApxtiQ1kZZOKPWXAyoIgygsunX2uJZaWRHuCg>
    <xmx:sbBZak6oeYi_2yHDPZQvmvG-ISn7odOyH9mhopfO_xhEF_TP9gGXyg>
    <xmx:sbBZag3cGsQLinzWsCVL6inJ4Sf-BEzz6MEXCc1CsvEqb3BTiCbpdQ>
    <xmx:sbBZaifWJ9Ek-gKQHl2XTX1rn-QYwHWDhgJNWsoUCm8-J3iG30PDaA>
    <xmx:sbBZagM22D07KstgeE6e4z9D6R2H9FVYd0SKpejKeuISwZMouhxHa8Go>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 00:33:51 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v4 13/18] nfsd: open-code nfsd4_vfs_create() into nfsd4_create_file()
Date: Fri, 17 Jul 2026 14:31:11 +1000
Message-ID: <20260717043242.1865905-14-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260717043242.1865905-1-neilb@ownmail.net>
References: <20260717043242.1865905-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

Having this sub function separate doesn't really add clarity, and merging
allows for some refactoring and ultimately using a different VFS
interface.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 76 +++++++++++++++++++++-------------------------
 1 file changed, 34 insertions(+), 42 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index c04a021d9719..c3bec447a43e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -202,46 +202,6 @@ static inline bool nfsd4_create_is_exclusive(int createmode)
 		createmode == NFS4_CREATE_EXCLUSIVE4_1;
 }
 
-static __be32
-nfsd4_vfs_create(struct svc_fh *fhp, struct dentry **child,
-		 struct nfsd4_open *open)
-{
-	struct file *filp;
-	struct path path;
-	int oflags;
-
-	oflags = O_CREAT | O_LARGEFILE;
-	/*
-	 * For the EXCLUSIVE modes we do our own uniqueness tests
-	 * so don't want O_EXCL.
-	 */
-	if (open->op_createmode == NFS4_CREATE_GUARDED)
-		oflags |= O_EXCL;
-
-	switch (open->op_share_access & NFS4_SHARE_ACCESS_BOTH) {
-	case NFS4_SHARE_ACCESS_WRITE:
-		oflags |= O_WRONLY;
-		break;
-	case NFS4_SHARE_ACCESS_BOTH:
-		oflags |= O_RDWR;
-		break;
-	default:
-		oflags |= O_RDONLY;
-	}
-
-	path.mnt = fhp->fh_export->ex_path.mnt;
-	path.dentry = *child;
-	filp = dentry_create(&path, oflags, open->op_iattr.ia_mode,
-			     current_cred());
-	*child = path.dentry;
-
-	if (IS_ERR(filp))
-		return nfserrno(PTR_ERR(filp));
-
-	open->op_filp = filp;
-	return nfs_ok;
-}
-
 /*
  * Implement NFSv4's unchecked, guarded, and exclusive create
  * semantics for regular files. Open state for this new file is
@@ -396,9 +356,41 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	} else if (create_status) {
 		status = create_status;
 	} else {
-		status = nfsd4_vfs_create(fhp, &child, open);
-		if (status == nfs_ok)
+		struct file *filp;
+		struct path path;
+		int oflags;
+
+		oflags = O_CREAT | O_LARGEFILE;
+		/*
+		 * For the EXCLUSIVE modes we do our own uniqueness tests
+		 * so don't want O_EXCL.
+		 */
+		if (open->op_createmode == NFS4_CREATE_GUARDED)
+			oflags |= O_EXCL;
+
+		switch (open->op_share_access & NFS4_SHARE_ACCESS_BOTH) {
+		case NFS4_SHARE_ACCESS_WRITE:
+			oflags |= O_WRONLY;
+			break;
+		case NFS4_SHARE_ACCESS_BOTH:
+			oflags |= O_RDWR;
+			break;
+		default:
+			oflags |= O_RDONLY;
+		}
+
+		path.mnt = fhp->fh_export->ex_path.mnt;
+		path.dentry = child;
+		filp = dentry_create(&path, oflags, open->op_iattr.ia_mode,
+				     current_cred());
+		child = path.dentry;
+
+		if (IS_ERR(filp)) {
+			status = nfserrno(PTR_ERR(filp));
+		} else {
+			open->op_filp = filp;
 			open->op_created = open->op_filp->f_mode & FMODE_CREATED;
+		}
 	}
 	end_creating(child);
 	if (status != nfs_ok)
-- 
2.50.0.107.gf914562f5916.dirty

