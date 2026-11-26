Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.46
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795710710;
	b=f+8aJvWQXGvre9wEQaxW4UvM7i8LINpRP+xtpvNgFxwINXwkySbAvLiowEq4sHJYBi9X
	 hK5N8A2euiNskS2nqbTwr6a1krdq8A00/RaGRjHDaILHvnSQ9V2iXS6yFSwFSZAoV2czT
	 tbvrhIsvnamPgHBXq6q1eMIB/v6QCOF6poMU5Vh4rSFQFARIeaBKpKmXvuX81/HkABMWq
	 f2gQ2CQqBcA3hvhA5AM2TMcGx97ipcI/qYNoeer8K6sw6Y9hgg2an5ok3YKceg4qGoLAv
	 HNfoA+c2kd3g6C7v+22Zxp7kZ2Qxw5E7c1nhTKq08OzDSqDDR/0g71d0cCgWk0DgdKQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795710710;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=6DGKGHZD1sWqO2WRSY4U0udOhpGKQXiV3WJqb4Fx1ZI=;
	b=E0e6VnrL21QtkPW18tT3WeulZE6EH7CA8bESTUlSvOubF0UTMTl1iepsfJ7TEUpyizWJ
	 ZBiVksTg1goHnNXWKOV2FVDKxzEMEXlFNIXirlOGubXMNj38X8hKtQT5QPiENj9DhyTbb
	 kQ4mFzEjpA6clUxSR3nE+kU1uGKtLO4u09ApVL7/Djn6qk9+Hk4+ZARDd+mtpG0tiqMiO
	 QhHDOOIRZv+UtuYrjx2vFZfcwcSu/c8yZ7jYn9NRbuq37QiGRrWUDFdSm2wwT8RSBAZgy
	 j0Z7HhrRySNkg+vtIP8z7ooCYoieTZmy4fPgmUA5tbIZJ30c0wUsW7GrGEXWWexWW7g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=NgzesBph;
	arc=none smtp.remote-ip=209.85.128.46
Received: from mail-wm1-f46.google.com (mail-wm1-f46.google.com [209.85.128.46])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 216F5606A6AD
	for <linux-nfs@vger.kernel.org>; Thu, 26 Nov 2026 16:31:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 216F5606A6AD
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=NgzesBph
Received: by mail-wm1-f46.google.com with SMTP id 5b1f17b1804b1-4bb72b44a97so61874025e9.0
        for <linux-nfs@vger.kernel.org>; Thu, 26 Nov 2026 08:31:49 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795710708; x=1796315508; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=6DGKGHZD1sWqO2WRSY4U0udOhpGKQXiV3WJqb4Fx1ZI=;
        b=NgzesBpha5/UiuwtyApe4LBXa4J/ZEE9RKL51o52cHEQZvDJx1Io0LkMX9T4hggZMH
         yMa0nLXZDeXh3OTT5Dceu8BR+qdcmeSaC9RWK6GGdpgvq67OWwu0N8mw3xfC+ykgxBkA
         yEoRN9ICF95EXoJwq1ROoEh5ttxJozEqUgS4kFy2WgRT3O8gDHMMShxwnJZV/bfNq8gV
         94Ff+uDAmyBMb5RFFUJa2wayxciw/19DqrWBprAc5PQ2xTH4mJm64KnLuI4iptKk72YS
         FGHpM0M/l0unSVUyE9VXt42T1xN0phYdlNSwj0GuBcjfL5tAcfYo3HAercHmLDLsdKJ/
         INoQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795710708; x=1796315508;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=6DGKGHZD1sWqO2WRSY4U0udOhpGKQXiV3WJqb4Fx1ZI=;
        b=kBvbduiEjypYCSdCkuW6g3qHfYAOEZbj4gj3H2dTKaPevy+7ckg4slgV1IsXOLg/uJ
         wUouDpJYA8xs8Ve/pUG6oPF3ILu8YGL3bDVbkm6mvGoZgiCX0x0nTRj6T+qAZG7qLGvE
         YHqHkNaJjY5eg+HjK6EZ8pPu5RBnvXMOTnSeFMKRpmV7pkRglfbu4Y/ZxPF69tpAXvOK
         XJCXAFwlI2Fv8Er5tnJCWkMi4avrN5R0olN3HemL/rWdSccoZSm7Z7wcdPvc/auQYAHx
         uArjffpfLkRqBiGllLFC+Ui/AsfKoMWLTTpsvoyN6Uj+UDXP+b3VEVXQTaGcoXhvYzaT
         tOmA==
X-Forwarded-Encrypted: i=1; AL+hErG9zs5KQ2pGoBAkV8nM2YFO0Uvsia/5RCsIuGTdtv8AsV3opgkRBQjBdipuY7DCnsLuOZg0vwKXgvs=@vger.kernel.org
X-Gm-Message-State: APuU4Z+j3hiSw32Z1yo73A4d5g60YWtD5zYR+pj5k538Ekw49QXjmu0y
	fs8FrtV5wZcjcl7/jVmLR/+67nm+RYR/khEGikDP4GtbwRyS+AZgZ7kr
X-Gm-Gg: AZFdTZeUfySau0vEo0Cp22vnrVoiTgQ0i03HCWWAYObMvtoFhUNneA0T/H7zfJOpYyg
	wyYsP5THg/eeHeUom5cz1rxkO1GGULH6dJjxVCjg3812jxFWVrkU0/k6fDNts0QJXHIQrrthIjP
	oyIDeOprZsUA6pgzfMtd2V1DiEkRGkU8kBq5bozhsyKsznI3r3pH4pCV0rHHFpNS2siZI6vIFSR
	W2RZgL0xHPCdgn4ZqdNxB+qPcg7h+i/dXT0pTpPVsVo0jbv5dLkKOkuK/NTpjzJttXV3pozl6cg
	SuPg2h9Djl6kFhQtzOsB2wXRVnzFAz/dCVsE5bUF5egtok9M7TIKOL3Sp2TUb4YQjpFQCpa1n2d
	07yoTMyfhpNXx5L1YlbVGpNELw/0bs1Lr1C5PxqmvPydDa9a/sE4WTN2l2pFMKKtb+HquYLtj99
	KEnhFnr1zC5/AqhVLMxQj/AW9JpiMUwZo8aTv7yH3+2DAdV/MLbxOo6Zz9wtC+msPWT7SYD0PEv
	Zo5saCumkyZTtwLLgVkWUNtnwUs0OqVpEIzN+9/LzqimMVpCQ4qD/uPU++cr63uRH0csCzq/rXG
	WPWQYxHryTwz/jKwpm9mmyT9
X-Received: by 2002:a05:600c:3b83:b0:4b7:6b96:e431 with SMTP id 5b1f17b1804b1-4bb88822242mr502582645e9.28.1795710708243;
        Thu, 26 Nov 2026 08:31:48 -0800 (PST)
Received: from infinity ([2001:b07:5d26:7a6a:365a:60ff:fe0d:cfc6])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb853a9846sm721964995e9.11.2026.11.26.08.31.46
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 26 Nov 2026 08:31:47 -0800 (PST)
From: koraynilay <koray.fra@gmail.com>
To: Namjae Jeon <linkinjeon@kernel.org>,
	Hyunchul Lee <hyc.lee@gmail.com>,
	Eric Biggers <ebiggers@kernel.org>,
	"Theodore Y . Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
	Alexander Aring <alex.aring@gmail.com>,
	"Darrick J . Wong" <djwong@kernel.org>,
	Andrey Albershteyn <aalbersh@kernel.org>,
	Amir Goldstein <amir73il@gmail.com>,
	=?UTF-8?q?Pali=20Roh=C3=A1r?= <pali@kernel.org>,
	Lauri Gates <lauri.gates@gmail.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dave Chinner <dgc@kernel.org>,
	linux-btrfs@vger.kernel.org,
	linux-xfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	ntfs@lists.linux.dev,
	linux-nfs@vger.kernel.org,
	linux-api@vger.kernel.org,
	koraynilay <koray.fra@gmail.com>
Subject: [PATCH v2 2/4] fscrypt: update fscrypt_prepare_setflags() to use xflags
Date: Thu, 26 Nov 2026 17:31:12 +0100
Message-ID: <20261126163114.403846-3-koray.fra@gmail.com>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261126163114.403846-1-koray.fra@gmail.com>
References: <20261126163114.403846-1-koray.fra@gmail.com>
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

Update fscrypt_prepare_setflags() to use FS_XFLAG_* xflags instead of
legacy FS_*_FL flags.

Signed-off-by: koraynilay <koray.fra@gmail.com>
---
 fs/crypto/hooks.c       | 10 +++++-----
 fs/file_attr.c          |  2 +-
 include/linux/fscrypt.h |  6 +++---
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/crypto/hooks.c b/fs/crypto/hooks.c
index 149498bdab94..52d6a33fc9e9 100644
--- a/fs/crypto/hooks.c
+++ b/fs/crypto/hooks.c
@@ -182,10 +182,10 @@ int __fscrypt_prepare_setattr(struct dentry *dentry, struct iattr *attr)
 EXPORT_SYMBOL_GPL(__fscrypt_prepare_setattr);
 
 /**
- * fscrypt_prepare_setflags() - prepare to change flags with FS_IOC_SETFLAGS
+ * fscrypt_prepare_setflags() - prepare to change xflags
  * @inode: the inode on which flags are being changed
- * @oldflags: the old flags
- * @flags: the new flags
+ * @oldxflags: the old xflags
+ * @xflags: the new xflags
  *
  * The caller should be holding i_rwsem for write.
  *
@@ -193,7 +193,7 @@ EXPORT_SYMBOL_GPL(__fscrypt_prepare_setattr);
  *	   another error occurs.
  */
 int fscrypt_prepare_setflags(struct inode *inode,
-			     unsigned int oldflags, unsigned int flags)
+			     unsigned int oldxflags, unsigned int xflags)
 {
 	struct fscrypt_inode_info *ci;
 	struct fscrypt_master_key *mk;
@@ -204,7 +204,7 @@ int fscrypt_prepare_setflags(struct inode *inode,
 	 * derive the secret key needed for the dirhash.  This is only possible
 	 * if the directory uses a v2 encryption policy.
 	 */
-	if (IS_ENCRYPTED(inode) && (flags & ~oldflags & FS_CASEFOLD_FL)) {
+	if (IS_ENCRYPTED(inode) && (xflags & ~oldxflags & FS_XFLAG_CASEFOLD)) {
 		err = fscrypt_require_key(inode);
 		if (err)
 			return err;
diff --git a/fs/file_attr.c b/fs/file_attr.c
index 40d6518f1d8e..1687891c526c 100644
--- a/fs/file_attr.c
+++ b/fs/file_attr.c
@@ -195,7 +195,7 @@ static int fileattr_set_prepare(struct inode *inode,
 	    !capable(CAP_LINUX_IMMUTABLE))
 		return -EPERM;
 
-	err = fscrypt_prepare_setflags(inode, old_ma->flags, fa->flags);
+	err = fscrypt_prepare_setflags(inode, old_ma->fsx_xflags, fa->fsx_xflags);
 	if (err)
 		return err;
 
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index 28f2108e29f3..68d0983385d0 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -461,7 +461,7 @@ int fscrypt_prepare_lookup_partial(struct inode *dir, struct dentry *dentry);
 int __fscrypt_prepare_readdir(struct inode *dir);
 int __fscrypt_prepare_setattr(struct dentry *dentry, struct iattr *attr);
 int fscrypt_prepare_setflags(struct inode *inode,
-			     unsigned int oldflags, unsigned int flags);
+			     unsigned int oldxflags, unsigned int xflags);
 int fscrypt_prepare_symlink(struct inode *dir, const char *target,
 			    unsigned int len, unsigned int max_len,
 			    struct fscrypt_str *disk_link);
@@ -784,8 +784,8 @@ static inline int __fscrypt_prepare_setattr(struct dentry *dentry,
 }
 
 static inline int fscrypt_prepare_setflags(struct inode *inode,
-					   unsigned int oldflags,
-					   unsigned int flags)
+					   unsigned int oldxflags,
+					   unsigned int xflags)
 {
 	return 0;
 }
-- 
2.56.0

