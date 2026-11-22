Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.54
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795306157;
	b=FtXvNZw2FG37TOLRwnSX+LxWylYF94eO4KA0T8qsMT55yT1Axxo0/FVgyJ3bUtm0v5qN
	 8NVxvxz7GNErMpjn3NNhU8fuhwqPUYvIe8EkUm0bn4d9gdKEm9asv+C+v66/nxnkfXjZx
	 QicrNOq29R/2rHdHkHGBeVs2z0KE9aFWZL+mNHjQWuqZMlllXwDMiqtvSo/zK6GY/tkRY
	 yzFufi9gVhxJp7bO5xV7n7aTKj6iQX/0jg4H8NbIlbUk8RbfqY4nAmYSkLWM4NyzpJRiG
	 oE1pGmp9X1EXKcBJutVic1uoRb7gzP7B6UBdyFRXO3VuYt+d77DJBwo8amN0aIk31WQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795306157;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=I3/a3+7dsQvjvECUWVZ/SwOHlfbc32z4n2+Zae+M7DI=;
	b=Xjk4TFKxsb0CS+qzxp3kE5wrEvapXj4oIgiuR5rWLLd4gfagfTJYeZo8n/8BhAaTLurO
	 QN6J1d483IVJqwIYsTS52oVqqhpziRDx994PByMflSAbpT4wjfaM72GyeF97qtnZ3Zrdw
	 RDqTO1+Cc0iYxBevV4AoH5nrvh0mcsm2AAi4ZR1bmgK6IQuJXLW98G3CRINcKfSo5Ue1+
	 KsKS7pLH1r2phD/ViTZiLbJyUYRqcaazDSJNkPZWvQGSLkW8Xmti9kWjG3mXAqLCQJelN
	 cUcpI4aG+0yzPg937AoTU8tVVCft97V0iiC4JDNtmRX6nWjZzKO6VUvODDS53LnqS+g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=pxx4MEVM;
	arc=none smtp.remote-ip=209.85.221.54
Received: from mail-wr1-f54.google.com (mail-wr1-f54.google.com [209.85.221.54])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 553E0606A681
	for <linux-nfs@vger.kernel.org>; Sun, 22 Nov 2026 00:09:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 553E0606A681
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=pxx4MEVM
Received: by mail-wr1-f54.google.com with SMTP id ffacd0b85a97d-48e46e449e8so1396173f8f.3
        for <linux-nfs@vger.kernel.org>; Sat, 21 Nov 2026 16:09:16 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795306155; x=1795910955; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=I3/a3+7dsQvjvECUWVZ/SwOHlfbc32z4n2+Zae+M7DI=;
        b=pxx4MEVM3F9ewoA+cmrYZ5iJ7GG66cT5YEMw/9bSw+32AQdbNaeyaZM+3JoC/dwApz
         UTXTyt2hP1yxywMm4hNVJePOeGz0MGnOqeDT59BoZmGM0iHtv3qvQDqcKJ75ZctYftXA
         kPEmslanb0UMiXCiyaAj65FLQcg9cH55lzNF2rhCJTB0VVD4RlJR8bfx34szlVVEKDaC
         /SQf4GCr0GacL1gTvq3QehD9mb/pXaJT0DU0oIq9fiin+wEYVcS/rJt2xmbLSEz1RYGY
         zZWz6FecCb/clp9mCPrinCaau+nYvOhVOjDICs76X+KNwZWPsk1GaY5WrM54lZtPqKFa
         teuQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795306155; x=1795910955;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=I3/a3+7dsQvjvECUWVZ/SwOHlfbc32z4n2+Zae+M7DI=;
        b=q7TaE8p43R2kHFt0G3I3snEFVI0eJWMRAdCi9YDjQu38nP1Y9NXCWWdjmTWJoNpiT6
         yk5Od0YKZHmrlnSjbIziCYahAy5KsIfHupu3ZjABhNvtx/tx9DolsDw4dFvqBzrJNjSI
         zjgVUIqQvsxkRh566yq84xmIiWqm3+w3Z0x96uhcOmInelYLDB0NbcUydagH6gFRoJNi
         p1THHwRCv2EbkCH06nJdt4H28y/YhvdyioFzPqX9OpFLuSuEJV0OzDgy6H/JErPs2ADz
         SYeou8cpMf8RCdnRdJsAZ2rPqGswmiGQTGSw5ldwoIcqT7Un1Tnp9L4xZfQLfLdqtz/X
         D7xw==
X-Forwarded-Encrypted: i=1; AL+hErFjPbrsTPjt6Kb8Nn4uYn7qq41gjJ7NJP6S6Koh3syYjKAFZwIC6kZRK9FI4x4S/Fe1CsOhHITXIOU=@vger.kernel.org
X-Gm-Message-State: APuU4Z+DMOSMIZI3jMTvydpmQdcxLxkmJJKyuJPACxukDZPctC43Abhz
	LMBTjGyTQ8p/2WDOo6yt3f8lIrjqqvGmxSIrzMtsKE8dCV5dVHs+hpg/
X-Gm-Gg: AZFdTZf2Qy4qs0B0ViY802lOUN8DFJzpxseLs7NiGmARI7yJZ47uAfLQI1LEu+SvwAO
	CaUpClltp/xhlkP8DIjfZD9eb213UqmsWFhOs8kabsdNHQGeX7JGLaAg29j9lnTvvtvWIDkyhHV
	bOLl5UTJxWTrz05yHmSpMnVVxHNoNB/nfJbi3nbx3NeSLkWsycF4WEhySikJ4RIdrIlvqn3quEl
	j9uHGYr08VxY/Apa/iJxxE7RJIKbGaPzg5SxPrmCDnf4//3N5D0u1Qd/XvojDgIaLGmAwIeTzxR
	PGlNTAggZidshabEF7nS8DG8h1b5ows6qnSAAes4dLgT00xAe9XR3K1G6ZDpm+GH0f7ZU5G9kwu
	O/bld38xuOM31yFkcxXX2qMbeaYTBuhF97qOhbFzRTBn1UrjGfWVJJRbJemQTNh9r4RSEkpkuZo
	KDprtIZtoANGFXJ39zg8d3AIV7YDUMSeegXpI2d0L0j1ELJ76V72ptMQLkiu2LohlRyS3gQspMn
	vycVdVkrSfMd3/T31c7dbuEBwMEVzFYk9rqOQDVu4UMRSBQlIECEc/L/wNLmt2f3uU+ZUme0MxE
	6hOm7jn72zex/RDgNs85acuTcnMevCU+oCReItLQaIUSPg==
X-Received: by 2002:a5d:5f4c:0:b0:48e:5d33:da5c with SMTP id ffacd0b85a97d-4abad5aca65mr14743143f8f.1.1795306154599;
        Sat, 21 Nov 2026 16:09:14 -0800 (PST)
Received: from infinity ([2001:b07:5d26:7a6a:365a:60ff:fe0d:cfc6])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-4ab5ffcad11sm13461872f8f.0.2026.11.21.16.09.12
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 21 Nov 2026 16:09:13 -0800 (PST)
From: koraynilay <koray.fra@gmail.com>
To: Namjae Jeon <linkinjeon@kernel.org>,
	Hyunchul Lee <hyc.lee@gmail.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
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
Subject: [PATCH 1/3] vfs: use goto out on error in vfs_fileattr_set()
Date: Sun, 22 Nov 2026 01:08:54 +0100
Message-ID: <20261122000856.536902-2-koray.fra@gmail.com>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261122000856.536902-1-koray.fra@gmail.com>
References: <20261122000856.536902-1-koray.fra@gmail.com>
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

Switch from using if (!err) { ... } to the cleaner if (err) goto out;
in the main body of vfs_fileattr_set().

Signed-off-by: koraynilay <koray.fra@gmail.com>
---
 fs/file_attr.c | 45 +++++++++++++++++++++++----------------------
 1 file changed, 23 insertions(+), 22 deletions(-)

diff --git a/fs/file_attr.c b/fs/file_attr.c
index 833e03810b24..40d6518f1d8e 100644
--- a/fs/file_attr.c
+++ b/fs/file_attr.c
@@ -285,30 +285,31 @@ int vfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dentry,
 
 	inode_lock(inode);
 	err = vfs_fileattr_get(dentry, &old_ma);
-	if (!err) {
-		/* initialize missing bits from old_ma */
-		if (fa->flags_valid) {
-			fa->fsx_xflags |= old_ma.fsx_xflags & ~FS_XFLAG_COMMON;
-			fa->fsx_extsize = old_ma.fsx_extsize;
-			fa->fsx_nextents = old_ma.fsx_nextents;
-			fa->fsx_projid = old_ma.fsx_projid;
-			fa->fsx_cowextsize = old_ma.fsx_cowextsize;
-		} else {
-			fa->flags |= old_ma.flags & ~FS_COMMON_FL;
-		}
-
-		err = fileattr_set_prepare(inode, &old_ma, fa);
-		if (err)
-			goto out;
-		err = security_inode_file_setattr(dentry, fa);
-		if (err)
-			goto out;
-		err = inode->i_op->fileattr_set(idmap, dentry, fa);
-		if (err)
-			goto out;
-		fsnotify_xattr(dentry);
+	if (err)
+		goto out;
+
+	/* initialize missing bits from old_ma */
+	if (fa->flags_valid) {
+		fa->fsx_xflags |= old_ma.fsx_xflags & ~FS_XFLAG_COMMON;
+		fa->fsx_extsize = old_ma.fsx_extsize;
+		fa->fsx_nextents = old_ma.fsx_nextents;
+		fa->fsx_projid = old_ma.fsx_projid;
+		fa->fsx_cowextsize = old_ma.fsx_cowextsize;
+	} else {
+		fa->flags |= old_ma.flags & ~FS_COMMON_FL;
 	}
 
+	err = fileattr_set_prepare(inode, &old_ma, fa);
+	if (err)
+		goto out;
+	err = security_inode_file_setattr(dentry, fa);
+	if (err)
+		goto out;
+	err = inode->i_op->fileattr_set(idmap, dentry, fa);
+	if (err)
+		goto out;
+	fsnotify_xattr(dentry);
+
 out:
 	inode_unlock(inode);
 	return err;
-- 
2.56.0

