Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.53
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795710708;
	b=y6hc4XSrIkJlq8VcEPAawS48JdYSMaOPfl6bjpCh9Z1EzIYvSmDSSNwZRAxkfNj2o6Hx
	 ZBsC7ojtRpI9GXDeEZhA6d2qIBxnnQFkxRFDuhJfOoeZHm2N28snmwBwn4mcdqqDh/g7J
	 fYQJMOpX6hXyqqO+/fc3fVwe19yL5NxoqvKy1Y5PqaPVO7uHs8pCTu0BVzn9jFMVtQ3Hs
	 jhwriYP1oVFprevCgf3V+JJuyGRAZLJYvrLxL9+sGj850Rg9n3aYfKML6d0Cy+CaLyh8q
	 jbbc6mKRgf6rlGGqDlRpHu6JaSfMXwdX2sqarnt2k0kikZFS+MB1EtcWhyf8O+ptyTw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795710708;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=mfpEhfbyhPi8fEOS+N1QHzNJFz4cU/NZgKWTwuKYJ+M=;
	b=MH57qC7//LLLBsC3cklBESSumMTeHAQA8fp922vzlYtK7YRZfMbi/FsK77ScypNLj/R8
	 nXE4kOqwFbx/VD8PNxDE5Rl30GlVZkiUhTHC2bOTv1OAuupLf8zLiYa6TfzsqNpbVWrDA
	 3hlFk+J/R7J9hBkg6m+lkWghTvvcLCZi5Ytp3CvAi5XPpT1661wkN47brGwgnF7fcMGuc
	 V/Dcg6XELMYI7rTOqHzgSzX5BGyIcWw4tFKUciLn4m4R+l06u0HRJ5swKAic0g6KwCyQY
	 lNPpDhEOrCStM/s9RgvqKyFUbp0IBCYdQRZLAn5GBnM6zGWiT1Y2jakyMZh5udtGE0w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=xc+MkwdP;
	arc=none smtp.remote-ip=209.85.128.53
Received: from mail-wm1-f53.google.com (mail-wm1-f53.google.com [209.85.128.53])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4897F606A338
	for <linux-nfs@vger.kernel.org>; Thu, 26 Nov 2026 16:31:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4897F606A338
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=xc+MkwdP
Received: by mail-wm1-f53.google.com with SMTP id 5b1f17b1804b1-49d05d51553so51219905e9.2
        for <linux-nfs@vger.kernel.org>; Thu, 26 Nov 2026 08:31:48 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795710707; x=1796315507; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=mfpEhfbyhPi8fEOS+N1QHzNJFz4cU/NZgKWTwuKYJ+M=;
        b=xc+MkwdP2qSHhRJs8tqp0gJVAbhLaJGgxK7Lgcrjfgi+poNIcrpekreyQIw8Wa2ubw
         JTYEYjzBQHqXA+RCGlkMim5rWjlpg2Rc8MJ45f9iuFGrYnTeolSe9vBS2bLSeX5T5fZf
         SZX2nx4eSzWBYUFb1yi9O/TFdM/MA3MAnAw6/ApHrCpLQQihkBD0TTWOQKPnQ28uZTYE
         XpRkIhDzQqfntphSLOtItZuJswRxPc5PSDPlBmuNOaDHAcf8EMQ3hdeMUxJAM4CSuDyL
         mqwH8JHptswvYdfZEoqv6ChJC6m67PYPkI1mpROJ+wyATfnVNkfzJA1ri8ZRyz6/FKyk
         ZCyg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795710707; x=1796315507;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=mfpEhfbyhPi8fEOS+N1QHzNJFz4cU/NZgKWTwuKYJ+M=;
        b=HM4O5l0jv//fpKgBhKOlDy2vyWOKbxSMEwJ6leKDce/b3p3F22hp7f6wFX8KJhyWI8
         RcVDtIpjNH/Qh/9TcJ9xpwkSujsNr9XYnpy+9fOIqPNBv1I/ZjvC1PLWo84ZXE7/lKwH
         s8paci931+yJBe0YymbXds9eLa0G+kyLV6nPqbbP3aPN0ULsF9AJCaRSIycvZc2NaS1n
         VMaLiKn0lBVSU6MK3JkXrRDaos57Hi+OmnuJTrhwDaw1pn/JI4xzp/LTaTzURJwjGYpe
         K9vr9ywbNRyIVc8GB6czUugUrck7Vrcfrjyx2K1zyY/FcXEaXTACDs8neorQQdzYjlJ0
         En1Q==
X-Forwarded-Encrypted: i=1; AL+hErFjkrydz6lAxNIPlMHRcCHgqYHsDC/6VyWbM7JLPfommdkqumWD2YBvGK/SlX0zsa/0mQS8ympRIgQ=@vger.kernel.org
X-Gm-Message-State: APuU4Z8wo+zuH1pCyXPpLLrVqAQkeUXePN2r2kXxIRMEBRgVVsVHJEvf
	MhZm+aevhr/whTdcpEyNkTOIc6IpLjdrY3MmsigsHY7vbQR+ebftfpRE
X-Gm-Gg: AZFdTZeO3SlMBmEHy8kPtgDpKTICfI9OtPAxMOG7U1sGRd1M8iyZGRFgWbB8GDpw/o5
	k0MULNMJFMWh4wCP9V4xnpe3tObGVzyT/EXgSm2tiUay05neqolx8lMQYrahhVCPF8L3wYgNJPA
	kFY61IxokpZlh9smebisAF11hb0XDqwO7szrFyz7tI3O9SkQX9CuY6fGrCLuonPPbGP3bQQbsAD
	WxVHoEnvXYKXh6FGweo3EPu09erePP3ZRj0d8D7WHM/7IYpCAT53E5WJ/mYus0Nsg8WsQdDOdO+
	53EffPQ0YraM6t7XGgX3HSGjyypEltCDHrhUia2tgo0RLtZJrMv1cXGADatGetGUgAyQyH01L4O
	xKGC+c7pxdKHnof6JfOjp7eoYxJjj7xxQj66FKpTtuSXeWobHsQK3ol7FjFU3L6nOXdq1frGUqq
	d4vtOWJpIVPH0PlY7AEV7bTHuYR+eGA17ih73kDNJofwG0voV052fRn0HVahI4tdzqyr1ixlZDh
	Hf2BDzPadDrtMNW72Yt8zVqHIYHks4Hm6gcp7a/gO0wdqm1nNPSe5AQxLBjzz9Ke/0NADpsbKRz
	fFO0x04bNWJ2XymkGp7qd0B2
X-Received: by 2002:a05:600c:4e0c:b0:4bb:875b:f23f with SMTP id 5b1f17b1804b1-4bb88827f0bmr416764955e9.33.1795710706373;
        Thu, 26 Nov 2026 08:31:46 -0800 (PST)
Received: from infinity ([2001:b07:5d26:7a6a:365a:60ff:fe0d:cfc6])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb853a9846sm721964995e9.11.2026.11.26.08.31.44
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 26 Nov 2026 08:31:45 -0800 (PST)
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
Subject: [PATCH v2 1/4] vfs: use goto out on error in vfs_fileattr_set()
Date: Thu, 26 Nov 2026 17:31:11 +0100
Message-ID: <20261126163114.403846-2-koray.fra@gmail.com>
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

Switch from using if (!err) { ... } to the cleaner if (err) goto out;
in the main body of vfs_fileattr_set().

Signed-off-by: koraynilay <koray.fra@gmail.com>
Reviewed-by: Andrey Albershteyn <aalbersh@kernel.org>
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

