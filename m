Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.167.175
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297409;
	b=hxuNFRbAcGU6GmXSHSo+OtkICbcELJE8ixymDlJcbxygnwvsr9+Ftb7DqRdfVE9+S8NX
	 06JdfRDbIeRWw1z94I5cdo3GFU3BzJkNmBOrOEVHit/ffA76GO7MPiZmh6tbLqS2HTnEy
	 1LBJAkN0FgKMrxzaCyCvD62/Ao9xBz+3F5vUPSib9JTkxHSpJuF+QZN6VHwyZS4usNvE7
	 3vor5L/oH0u4OrOlP5B853MYJaEGEVBa7TLzwkp7zHg/TGVyme91lQs14oSx8/EhpqedJ
	 FkwUOuX8G5BVC2Y7OtfIDj7TBeGozObCgIEDdkPyjp+VaHG8MEzwLId8f2yD+3Mi3Zg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297409;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=rH9CbGqODly4QJymlyl4BG0aA7nsrIIcMmK3tybqsts=;
	b=ch5d9/BXEUM3EOej/noUmimnOfGvy5Idz8xakhVpSCz0LXrAR9X4lVHfQy0icgyg/38F
	 XrM+z2xvi7QwxHfZWM1kNUItaB7ubjbWJr2kjpbI0k/MMQC3QND+1N0oYPsWaS+IdHk+U
	 mGPIQwJFkR/1jQZARPP/wQabpp9PeA3JO/eREO8FBLqldXrluFiIii+TDAegcKEZR84Wy
	 5q34JRj/77O1kn00qbfDXzNmbIBi8LX+aZZgM67fkbxHApM4ekRkShZ2rzJPCXf4ngKAT
	 aATwxeA35C3resf9sxFf80vVHSYc8Ydi5Ht2i6Ui1+VF9Lmu54+lz/ebM0DrHhwxbxA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=jiIoUki4;
	arc=none smtp.remote-ip=209.85.167.175
Received: from mail-oi1-f175.google.com (mail-oi1-f175.google.com [209.85.167.175])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0994C60A6F78
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:10:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0994C60A6F78
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=jiIoUki4
Received: by mail-oi1-f175.google.com with SMTP id 5614622812f47-54cd7de2d42so1543627b6e.0
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 11:10:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793297408; x=1793902208; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=rH9CbGqODly4QJymlyl4BG0aA7nsrIIcMmK3tybqsts=;
        b=jiIoUki4j4MwfBdQRja9mQm5YbKyR2UfdgEDEpBelWc7CL+KZVxs8YGe3V4thSYnTf
         4Q+6PlYwf8H0dxXpIZVkw0gqDbX1JjegbhGQsrf0o123qkP9aVQ+RgM9z+sgWLRegzAy
         mXzOKWzYxxn3T25pHgaOYoGMT14v36G/tEp03Ighzjd8v+4bIIhikIk6gOb+8BzUxOip
         IeVfFmYJIsZi4z1gBG6/k7WKvjJtJAehF2bUmKLJyCjPLaBWNFrYAiaSo9l0uVlFKgw0
         Pm1MqLT15sII2XEXTBrAYgBpCOqBlXifLBnUsRmeBl6T25KGkyrt9j3xpkOIqf7olmiN
         p8xw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793297408; x=1793902208;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=rH9CbGqODly4QJymlyl4BG0aA7nsrIIcMmK3tybqsts=;
        b=Lu1MFJGmX4xkrnU92hEzvslRYYSwzOqS1G2W7hYE9bo/mLoirRgZPxIW9tpUVIg7bF
         mK9QWc7bYm3ba0JELK6bg0kACPXyYtNHXgrINDqUqBTRrh6JrbihY6FpVG6sXqTiSnJX
         H93Tn8T7rIiqb3NBoSin7ONCa0MYzvASXadj6rXGX9I4ZVgs0b6trZQqaSJdgDl5a9Tr
         D7EQcIYdP9O3QZDxOsD61Srmkd4kUxATmmTvF2Z02xhs7S2FjOgMjibCsieAv1L7QYL0
         4focCVJnujp5XS1zNOyiLXi2fM2eoGb2lOJn0uHlc+V1GEZdHimcz8fyRTpElfxo2Tec
         8UwQ==
X-Forwarded-Encrypted: i=1; AKwUvBxmZeX4cy46uasGijlWJcwbw4bd/T92JeG2GQ0mu/aBkb4aaFhckRM5+GBC7vX/unQoudw9MXEXl9Q=@vger.kernel.org
X-Gm-Message-State: AFq9FYJ2iwGmmVpkgmCBNXnpBZT+6mKDtct9SqR19xFIhPigkdO/pLhy
	0STKS2rYbGCk8Orce8+8XHmAPs9sACz3a6qRjWMYqCrrKvuTVJOAk8Dfv+DR2jgNkxo=
X-Gm-Gg: AYBFou1nw4ot92XcSyN0YO3rJ6PZb8c8clfQFYY5Oy8JqX5v5Ek4jjMt90nm5znD0ql
	TbMlq5lhkxs7sNXQVJw9wGx/BLKEwhsVEZGZVKqD9Q8hanxaDaWT3wOF4ZwZQbsd/bPfDPbUzn1
	G1p8L5hsxTQ0DloLeO2TKycUwDonoZJT8yp2DSOs0nTSADh7310WGRfPDcP72Grh+/pzNsLqEQK
	1oksyOtquix29FzeNheaBS7dXahBOrzKvez29H+TvbI7BrVH3kLMyfbuIYlqmeMgLmxQtlF/HbS
	UgDsSbLYg4yYaPj0mjU+ZXVg9hyLlxuxEdqas1U7C6TpUx8gYdNm33IVXYr2Ot/jE5jKOX8rGuj
	/zrNyhsEhWbt0Z0WUhx5OaPdmU5sz+W4dtZCiI8xNWvnC9SDqGN9MCybhSII9xvuEc4/7hKAWfq
	bPgGkAgd7jwh3s2W7iR6pbeLuWQwHkI0FZ/LVniPyVNCV01DBSGcHryVhtc9ysKbNizZLNarqV/
	aABrt+w1ujY8Ltm0/UuhoFe3pFQs3CCMzrxOhgCQzAJj11CPmxB0V0XmciA2awHcQzK1T4QDAjd
	eD+LHfAyYdOWJMhpPy9Er2LTAknz2Fs5Y8jpcWRO6nxSNp850aFAlY6W74LoAtcV1T1DVr2V
X-Received: by 2002:a05:6808:1904:b0:4e4:627a:e0a5 with SMTP id 5614622812f47-56383e91af6mr4444175b6e.40.1793297407750;
        Thu, 29 Oct 2026 11:10:07 -0700 (PDT)
Received: from localhost (75-163-200-235.clsp.qwest.net. [75.163.200.235])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-563c654a22bsm4702434b6e.14.2026.10.29.11.10.06
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 11:10:06 -0700 (PDT)
From: Jonathan Flynn <jonathan.flynn@hammerspace.com>
To: NeilBrown <neil@brown.name>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jan Kara <jack@suse.cz>,
	Jonathan Corbet <corbet@lwn.net>,
	linux-doc@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH RFC 05/12] vfs: factor file removal into a helper, no functional change
Date: Thu, 29 Oct 2026 12:09:50 -0600
Message-ID: <20261029180957.387138-6-jonathan.flynn@hammerspace.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20261029180957.387138-1-jonathan.flynn@hammerspace.com>
References: <20261028041023.3738553-1-neilb@ownmail.net>
 <20261029180957.387138-1-jonathan.flynn@hammerspace.com>
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

Move the body of vfs_unlink() into a static helper, __vfs_unlink(),
that calls the method it is passed in place of ->unlink(), or
->unlink() when passed NULL.  vfs_unlink() becomes a wrapper that
passes NULL, so every caller behaves exactly as before; its kerneldoc,
including the requirement that the caller hold the parent directory's
lock exclusive, does not change.

This prepares for a second removal method, called with the parent
directory's lock held shared, which a following patch adds.

Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
---
 fs/namei.c | 26 ++++++++++++++++++++++++--
 1 file changed, 24 insertions(+), 2 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index ce10a408d3..1b3a605ded 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -5679,6 +5679,12 @@ SYSCALL_DEFINE1(rmdir, const char __user *, pathname)
 	return filename_rmdir(AT_FDCWD, name);
 }
 
+static int __vfs_unlink(const struct mnt_idmap *idmap, struct inode *dir,
+			struct dentry *dentry,
+			struct delegated_inode *delegated_inode,
+			int (*method)(struct inode *dir,
+				      struct dentry *dentry));
+
 /**
  * vfs_unlink - unlink a filesystem object
  * @idmap:	idmap of the mount the inode was found from
@@ -5706,6 +5712,20 @@ SYSCALL_DEFINE1(rmdir, const char __user *, pathname)
  */
 int vfs_unlink(const struct mnt_idmap *idmap, struct inode *dir,
 	       struct dentry *dentry, struct delegated_inode *delegated_inode)
+{
+	return __vfs_unlink(idmap, dir, dentry, delegated_inode, NULL);
+}
+EXPORT_SYMBOL(vfs_unlink);
+
+/*
+ * The body of vfs_unlink().  @method, if not NULL, is called in place of
+ * dir->i_op->unlink(); vfs_unlink() passes NULL.
+ */
+static int __vfs_unlink(const struct mnt_idmap *idmap, struct inode *dir,
+			struct dentry *dentry,
+			struct delegated_inode *delegated_inode,
+			int (*method)(struct inode *dir,
+				      struct dentry *dentry))
 {
 	struct inode *target = dentry->d_inode;
 	int error = may_delete_dentry(idmap, dir, dentry, false);
@@ -5730,7 +5750,10 @@ int vfs_unlink(const struct mnt_idmap *idmap, struct inode *dir,
 			error = try_break_deleg(target, 0, delegated_inode);
 			if (error)
 				goto out;
-			error = dir->i_op->unlink(dir, dentry);
+			if (method)
+				error = method(dir, dentry);
+			else
+				error = dir->i_op->unlink(dir, dentry);
 			if (!error) {
 				dont_mount(dentry);
 				detach_mounts(dentry);
@@ -5750,7 +5773,6 @@ int vfs_unlink(const struct mnt_idmap *idmap, struct inode *dir,
 
 	return error;
 }
-EXPORT_SYMBOL(vfs_unlink);
 
 /*
  * Make sure that the actual truncation of the file will occur outside its
-- 
2.43.0

