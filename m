Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.42
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794765846;
	b=3Q951bXSJgNwNkRXj0bYRnhN2/raa4cZH/vQoqsBElTuajwYSXv4Rba9xhkKUH5Cy1Dc
	 Q6On+aBDsstOEh0tWHv2diRTuiHTDDM78rWIWg6TIBr2C35rzrLXaMkZ9Yu73fliYDZmU
	 VIf3wYnMtGoWtoIrw/IqrkvyZIEzC0Q6upn90cEWe18AV2kIRzcM/+pdE6KZIpuAX7dx8
	 PCkVg4/H8rmo9FwujxfIwSYg1Q9kHYR2tV37ECoL2r2BOWWkra5PMwbGyB0b0uJXDdi6d
	 DIlYRZunr70FOmxoGlfNGuVznUD7eEgSaeaAzk90S2T5ggfwGh1Voe9CYNw5QIwAnTg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794765846;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=jCob8yxVUbZMrzUJynGorNZ6cDsRus7pIoTivcXFIek=;
	b=YLadtGxjulVdELpTJdnI8/cH/H8tHRgJBWWXC2STa2kcejZA7GDSVix6/BFuzTvKhtI5
	 fNVlAXcUDXNNAxVUYFLtFXmQ5JV+iI0MhIlFXMOBFHhq8f/TkZG8AaazJ+YyE5tsfLsjD
	 IbA9bNhLlOimfS6kdmpyQy9pW9KxVzn/0/SUTbMCSeml4rTOIeUMh1HfuR6R3Ol+3Tqyl
	 kA6fdv+cWJdjYFl6X2AfpOTuFUYy+DMZVdBs1OafsVh9Mrqx8bWQ9ZPmDDi9kjmxZOFoX
	 9350yybURm8yzDs5htH9i4T0/ZjZC88ALsuxsf2Jldy7UnR9l+5/GoDx6nSExyYLeag==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=IBD9fQPZ;
	arc=none smtp.remote-ip=209.85.221.42
Received: from mail-wr1-f42.google.com (mail-wr1-f42.google.com [209.85.221.42])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3F1FD606A8AC
	for <linux-nfs@vger.kernel.org>; Sun, 15 Nov 2026 18:04:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3F1FD606A8AC
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=IBD9fQPZ
Received: by mail-wr1-f42.google.com with SMTP id ffacd0b85a97d-48e10a70540so1411314f8f.1
        for <linux-nfs@vger.kernel.org>; Sun, 15 Nov 2026 10:04:05 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794765844; x=1795370644; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=jCob8yxVUbZMrzUJynGorNZ6cDsRus7pIoTivcXFIek=;
        b=IBD9fQPZzDEKg2bdACsPtBrqMrB7RpYNzqy1KmrygLKNqfGgfMBRaPWVmtSMny9Uyo
         zZZXZUcxGun91msLJSPue4OSf8KXgtednCc0ci+LHlwiRCT7BYfwj6SD9fUlUIoUNNdM
         HjfCIWv0XLZodUGxpASoDy920nowWC6vgr7iHYUYL+7eC7K2ekWYt+yxN8xnL5lTbX+/
         iPXMXBJgcRIoFjYblNIEP9XDiGpFeZaYRykIxOLk9q0/b6fE1AF+H2k0K17e9FL8HjA/
         bPcXWcQ7jEc4YWkcaZbecSnNezqq4f/KgXnLXzb11BA99Sp4jVEommfOUsdvdRwp16i1
         ptAg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794765844; x=1795370644;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=jCob8yxVUbZMrzUJynGorNZ6cDsRus7pIoTivcXFIek=;
        b=WF/+QRY/3brGZaXu/fyp7szXKB5J7v1Mx/LoHXJ3SDmTb1FnhxyjK6srHFf10bWHR+
         QnT8MbPgfPG44wcIT1kLCJ/LWvOHe/H1h/KZdneX1YGHbc9LW4M3GG3wvcrfStM4Fw9c
         1shdG91yXcb2SURKgJH/g+bHlR0jX6Ug85LjRjHegvJ7JHRvA04vgOHRMuaLHXCWK5TV
         tlEDhKuY1VcWyhS4sy62uOQkWyFMaDkM3NjeRqyT0K4Vef6FhEg/dGSnzhaQd9pA0DQa
         uA9quyxMsP13WgHiTx/WTE6bzSvYoCh+rvSoaK4hhkELrksHaKpTCa8wWH35gvbyWeCg
         xsNw==
X-Forwarded-Encrypted: i=1; AL+hErGepWSOWn4Dn7lBV4ua4LBw7xMO6uGE8bvtwjdnjBVPxvhaPrkuwqGSnopd77pIThdGyuAwEFhBsqg=@vger.kernel.org
X-Gm-Message-State: APuU4Z/5CcIctFANNlZCdUOBmwXal/TEqkdA5jx+VO5N+JCVXDNjY4fQ
	MTmUoYldX1GWPTnvIHktPHssdCpTjc2HRcl46OmgrujimprkhyXL9XSO
X-Gm-Gg: AYBFou0XwRghlsbmJYC652Drz5v9LLVRv2eSuNt2UZld5GMusg8CEcDXruQ2JpuToQJ
	KbaYzpMeRfcGpHUN70Hwk5EYREDl+h7WLPoSLJnyIjuDs0NSrJWb1XddnRGVVYg9h/zo39aEgWi
	TGAIM/m7N441zPrus/1MkqTU+yu8hriXfRtG8RlS/1Zuq+k6AfvGEkEagxk8D5td0vdANyEKyS2
	scuZrUWeiMon1l2qn7PMwmOkUxYF9/5ORIuFZRgYA/U7mUNxk/ASlw75yLS0QN4VV8icSiPefAo
	bbeiM8M3jNmWb5w6YSjPTfgSEBM5UHPM6dPhlWBRrGKK8dGkwwZwJwhgLsz6rXjwySmjRlmLrll
	kteVpZbdZpiFERZiBOo2237qzaaU37BrhaKfYVmrgyVJZy2/+ZTWW9NQE7T7ogfl88kNFNLZ476
	kiTU1cvTo3jM3WF44D0XMruVbr2BH5zRqQph85iNJdXuyz9OQPaNvoatxffGG+wlFlFqloKxCwu
	NNXkswXgLOvQSBWziS1bU4SVDU8U+JrTsxvdmHU3PUUWNOXRo1blOJ6vQQ5b+aj/ildPFErrp2Q
	rCfUtI8K15xoQBTTjZCkmwjq
X-Received: by 2002:a05:6000:1841:b0:48f:d7cd:a5ac with SMTP id ffacd0b85a97d-49c6b97336emr21325466f8f.0.1794765843381;
        Sun, 15 Nov 2026 10:04:03 -0800 (PST)
Received: from infinity ([2001:b07:5d26:7a6a:365a:60ff:fe0d:cfc6])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-49c60f8c248sm17980448f8f.58.2026.11.15.10.04.01
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 15 Nov 2026 10:04:02 -0800 (PST)
From: koraynilay <koray.fra@gmail.com>
To: David Sterba <dsterba@suse.com>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Sungjong Seo <sj1557.seo@samsung.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Konstantin Komarov <almaz.alexandrovich@paragon-software.com>,
	Paulo Alcantara <pc@manguebit.org>
Cc: Chris Mason <mason@kernel.org>,
	Yuezhang Mo <yuezhang.mo@sony.com>,
	Jan Kara <jack@suse.cz>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Ronnie Sahlberg <ronniesahlberg@gmail.com>,
	Shyam Prasad N <sprasad@microsoft.com>,
	Bharath SM <bharathsm@microsoft.com>,
	Sergey Senozhatsky <senozhatsky@chromium.org>,
	ChenXiaoSong <chenxiaosong@chenxiaosong.com>,
	"Darrick J . Wong" <djwong@kernel.org>,
	Sean Smith <defendthedisabled@gmail.com>,
	Andrey Albershteyn <aalbersh@kernel.org>,
	Pedro Falcato <pfalcato@suse.de>,
	Amir Goldstein <amir73il@gmail.com>,
	=?UTF-8?q?Pali=20Roh=C3=A1r?= <pali@kernel.org>,
	linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	exfat@lists.linux.dev,
	ntfs3@lists.linux.dev,
	linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-api@vger.kernel.org,
	koraynilay <koray.fra@gmail.com>
Subject: [RFC PATCH v4 02/10] vfs: add fileattr_has_fsx_mask()
Date: Sun, 15 Nov 2026 19:03:35 +0100
Message-ID: <20261115180343.576773-3-koray.fra@gmail.com>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261115180343.576773-1-koray.fra@gmail.com>
References: <20261115180343.576773-1-koray.fra@gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Add fileattr_has_fsx_mask() as a helper to let filesystems check for
unsupported xflags while allowing supported ones. Can be used in the
same way as fileattr_has_fsx().

Also make fileattr_has_fsx() a wrapper around fileattr_has_fsx_mask().

Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.4.7
Signed-off-by: koraynilay <koray.fra@gmail.com>
---
 include/linux/fileattr.h | 21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

diff --git a/include/linux/fileattr.h b/include/linux/fileattr.h
index 42b92ccdc583..ba7ed3b387d8 100644
--- a/include/linux/fileattr.h
+++ b/include/linux/fileattr.h
@@ -65,6 +65,23 @@ int copy_fsxattr_to_user(const struct file_kattr *fa, struct fsxattr __user *ufa
 void fileattr_fill_xflags(struct file_kattr *fa, u32 xflags);
 void fileattr_fill_flags(struct file_kattr *fa, u32 flags);
 
+/**
+ * fileattr_has_fsx_mask - check for extended flags/attributes
+ * @fa:				fileattr pointer
+ * @allowed_xflags_mask:	additional xflags permitted
+ *
+ * Return: true if any attributes are present that are not represented in
+ * ->flags or @allowed_xflags_mask.
+ */
+static inline bool fileattr_has_fsx_mask(const struct file_kattr *fa,
+					 u32 allowed_xflags_mask)
+{
+	return fa->fsx_valid &&
+		((fa->fsx_xflags & ~(FS_XFLAG_COMMON | allowed_xflags_mask)) ||
+		 fa->fsx_extsize != 0 || fa->fsx_projid != 0 ||
+		 fa->fsx_cowextsize != 0);
+}
+
 /**
  * fileattr_has_fsx - check for extended flags/attributes
  * @fa:		fileattr pointer
@@ -74,9 +91,7 @@ void fileattr_fill_flags(struct file_kattr *fa, u32 flags);
  */
 static inline bool fileattr_has_fsx(const struct file_kattr *fa)
 {
-	return fa->fsx_valid &&
-		((fa->fsx_xflags & ~FS_XFLAG_COMMON) || fa->fsx_extsize != 0 ||
-		 fa->fsx_projid != 0 ||	fa->fsx_cowextsize != 0);
+	return fileattr_has_fsx_mask(fa, 0);
 }
 
 int vfs_fileattr_get(struct dentry *dentry, struct file_kattr *fa);
-- 
2.56.0

