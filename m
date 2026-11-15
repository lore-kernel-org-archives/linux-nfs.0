Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.43
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794765848;
	b=OinSgEloSsS85hikTvBqOtSht6nmxuNl8/D6ZpDpELk8b4+qcz+KIXp8EF453wcQVdLV
	 /r9oPziADduv4IUKom44gqtuUKMWy5WRMfmPul+bK4xXwerDKM9L3YiZDP2PkfI/a5vEF
	 uqgCXfarqevkgLj5HIRsW+9n0wOS2TfXMCsHiLstaYVOhBIlWr16x9cnAtzWNioHKf1NA
	 QxULuvQyoougb8ReeZ/BNxh+yEFQzKu2Cbfi3fKmKFXqBfBSnT3C76l9g/0PTJz3j3f4R
	 Dk/4bYo813CGvXvqUkqOipjFfsCXSfRiy4DcV29vCZDpspaLaJ87ATbJL5v16wiMmUA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794765848;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=2ER6/NO7zpzo2Xjo4XaIJ1M2igxcKQmZBMoJ1KN6Ri4=;
	b=ZddykzAeL92Ikdu+GR/YAZkQOJ44wXfG/JcN2FfFTZGerkmw9VFtt3nProbVwqh71sOX
	 js8Fo2Uag+uUi+iEU99szNQn60DPScDYTbJP/URXYHhxFUIM8QUgoJ628lKq5jjuAEIn7
	 aibvcnHaDWpygVx3KZo+vVhGI/kBQOlJYaBBle42c0sbRc1GbopEjvlJtc4UkD3MYBIih
	 f0NY639TFvc6QUxsC0tz+/QvGoXjp74aECUIWI64uL39QEd2GqlcJK0BuXAgcbwqNUsbK
	 aUdiHnvMS8DRJGvadkaPCG3gvh9PHwEQ1FAi8WyuVlNB1k3x7mUTOviEV46Vq+1mmZQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=DaS9K5UI;
	arc=none smtp.remote-ip=209.85.221.43
Received: from mail-wr1-f43.google.com (mail-wr1-f43.google.com [209.85.221.43])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B884C60A2620
	for <linux-nfs@vger.kernel.org>; Sun, 15 Nov 2026 18:04:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B884C60A2620
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=DaS9K5UI
Received: by mail-wr1-f43.google.com with SMTP id ffacd0b85a97d-491971ac844so2446065f8f.2
        for <linux-nfs@vger.kernel.org>; Sun, 15 Nov 2026 10:04:07 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794765846; x=1795370646; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=2ER6/NO7zpzo2Xjo4XaIJ1M2igxcKQmZBMoJ1KN6Ri4=;
        b=DaS9K5UI5vQ6cDAdOmD7Qt3vqAgjmmAL4TB7Qob7Ng6lFn86kSu0BmRP5k0gSrPuzh
         AT8oBolUXoZcsBs5Is3ZCZ1j+CoUO4AunmNzyKR8loHZYVnNt778jycfOpIPt7Uh1pH6
         u3pf5xD9Q7+GgA5uziBNNrwaX6hOcWbglNJ+6upcxAua3CvwaNDG2ypPTlu9IUXH/qs8
         STMRY09KkjIKkcMndQZ9bo8+h0BzzdH2NS486mWjKnNoAtq1VanBD5+yuk3zIGmO8Fjh
         f/Z5bO08dOxs1qXW64JZbnwNHneAHab7ml/o6RGA5F2zOt/0d4xpWgMDucuXBXmHYpof
         ZXXg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794765846; x=1795370646;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=2ER6/NO7zpzo2Xjo4XaIJ1M2igxcKQmZBMoJ1KN6Ri4=;
        b=UC3fo5+25/tQMvO5YwnauPtAJZOpyXSxUW8dShRR2nTZKOIb1nMJSSrNHfG9Wsz9pQ
         4rYqDbEsHP7ZIPd9boXjOs6+7iHVVENSAfjUCQzav1oSG6L+MHGpVYL9h4X32WVdgtYV
         wMTCv+EyDyeHukenCkZnNp5FrNnKeLY9JkNTBmWidCXg9CxwSaq1UpczxEJLh82z9OEC
         ZtE9zQ5Z8bdOL0iHKbEIlyCdfeHJ4sscyF7PWM470Kl1msn+6mZpTgN8rPf8LH/OJlHi
         dVb76fJk84lLdb03PR9c7n3PoKBNH1PJZp1paez+/JOa9yrVGFbvUF6Mom+qL327Plud
         CgvQ==
X-Forwarded-Encrypted: i=1; AL+hErFNXUmckhRWIHiATgUbHEhovDmM4spqrh8WtTztj7uKccrplpdTA46FagHkvuys7D7L1BVo4LH245Q=@vger.kernel.org
X-Gm-Message-State: APuU4Z+ejq/s2Jz1dFhANoCxBAjTT4e3larpoQ+yYEGyU8A2BAF4sXcT
	vY3x+yTsD/8TqrobbGEq0uXDjz055X35d4IWZDhmXq7J+fxfmRjMRKjQ
X-Gm-Gg: AYBFou04GQGs9H6rTCX+kw0mPnZu+SSlpa+TIY6b3CDZcNT+e6eQg4spybdoxjwgH8l
	Tl/Cj7ie5b6kYPFhrc4XQfj7RwU1NDjbSYXHHgBNmd3wxtPafQ7TlNY32H66WaBrwcYyfBnz6nu
	R52ZiYZL4+xn2nXD5IggCgcsIwoycV1I5kUyetVQRdxkBP0d4hKJ2PFEVL/sACfKTkCVYafPdAi
	tC0VBwNYXN2lbMWVwGlxhijSh+gYbhkkgt+FqZKYwO3eyZvQwy6cDEonhA1/few0z936mpjNn2e
	JB2p42cIAmzm5W63Rp4b2udb7px4nnfFH6dqZUKh6sfre3/DZpJguvxerSp5hjrRUaSe1Ak6ArG
	mbtb9Lxtpkz67xPgkO0sZXsUXQ/CRhofyQ7x2/0fNbKJuBd/TFWPY17FaNHJIsyXjqMtmqt+CqK
	TW9WdTjdzRouUE7KLakIdstjdEfjJ30tGzI36RCMFftcMgajnra1a30BXXXccvpxohnbBiSNWMe
	7wf0K27I4imcc6HiLXa7gfnb1wRH+Y047AjKXtZNfPzuD7JicEHBMiZ1TXY8gAsg16VbbbBbFUT
	WZ0CKRztIxMcs0CX3Z4v7GrA
X-Received: by 2002:a5d:5d88:0:b0:48b:1296:52ec with SMTP id ffacd0b85a97d-49c70ed8eaamr19692466f8f.18.1794765845937;
        Sun, 15 Nov 2026 10:04:05 -0800 (PST)
Received: from infinity ([2001:b07:5d26:7a6a:365a:60ff:fe0d:cfc6])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-49c60f8c248sm17980448f8f.58.2026.11.15.10.04.03
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 15 Nov 2026 10:04:05 -0800 (PST)
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
Subject: [RFC PATCH v4 03/10] ntfs3: make crtime user-settable using ptime
Date: Sun, 15 Nov 2026 19:03:36 +0100
Message-ID: <20261115180343.576773-4-koray.fra@gmail.com>
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

Since NTFS supports user-settable file creation timestamps, map
provenance time (ptime) to NTFS file creation time (crtime) by using the
newly introduced ptime API (in commit "vfs: add provenance time
(ptime)").

To do this, update ntfs_fileattr_[gs]et(), ntfs_getattr() and make it
persist to disk in ni_write_inode().

The timestamp is now retrievable by using file_getattr() or statx(), and
is settable by using file_setattr() with the FS_XFLAG_PTIME flag.

Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.4.7
Signed-off-by: koraynilay <koray.fra@gmail.com>
---
 fs/ntfs3/file.c    | 20 ++++++++++++++++++--
 fs/ntfs3/frecord.c |  8 +++++++-
 2 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/fs/ntfs3/file.c b/fs/ntfs3/file.c
index 6c84a3e1c7fe..1a9301006154 100644
--- a/fs/ntfs3/file.c
+++ b/fs/ntfs3/file.c
@@ -90,6 +90,8 @@ static int ntfs_ioctl_fitrim(struct ntfs_sb_info *sbi, unsigned long arg)
 	return 0;
 }
 
+#define NTFS_SUPPORTED_XFLAGS		(FS_XFLAG_PTIME)
+
 /*
  * ntfs_fileattr_get - inode_operations::fileattr_get
  */
@@ -124,6 +126,11 @@ int ntfs_fileattr_get(struct dentry *dentry, struct file_kattr *fa)
 
 	fileattr_fill_flags(fa, flags);
 
+	fa->fsx_ptime.tv_sec = ni->i_crtime.tv_sec;
+	fa->fsx_ptime.tv_nsec = ni->i_crtime.tv_nsec;
+	fa->fsx_xflags |= FS_XFLAG_PTIME;
+	fa->fsx_xflags_mask |= FS_XFLAG_PTIME;
+
 	return 0;
 }
 
@@ -142,7 +149,10 @@ int ntfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dentry,
 	if (unlikely(is_bad_ni(ni)))
 		return -EINVAL;
 
-	if (fileattr_has_fsx(fa))
+	if (fileattr_has_fsx_mask(fa, NTFS_SUPPORTED_XFLAGS))
+		return -EOPNOTSUPP;
+
+	if (fa->fsx_xflags_mask & ~NTFS_SUPPORTED_XFLAGS)
 		return -EOPNOTSUPP;
 
 	if (flags & ~(FS_IMMUTABLE_FL | FS_APPEND_FL | FS_NODUMP_FL))
@@ -154,6 +164,11 @@ int ntfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dentry,
 	if (flags & FS_APPEND_FL)
 		new_fl |= S_APPEND;
 
+	if (fa->fsx_xflags_mask & FS_XFLAG_PTIME) {
+		ni->i_crtime.tv_sec = fa->fsx_ptime.tv_sec;
+		ni->i_crtime.tv_nsec = fa->fsx_ptime.tv_nsec;
+	}
+
 	inode_set_flags(inode, new_fl, S_IMMUTABLE | S_APPEND);
 
 	/* Save nodump flag to return in ntfs_getattr. */
@@ -275,8 +290,9 @@ int ntfs_getattr(const struct mnt_idmap *idmap, const struct path *path,
 	if (unlikely(is_bad_ni(ni)))
 		return -EINVAL;
 
-	stat->result_mask |= STATX_BTIME;
+	stat->result_mask |= (STATX_BTIME | STATX_PTIME);
 	stat->btime = ni->i_crtime;
+	stat->ptime = ni->i_crtime;
 	stat->blksize = ni->mi.sbi->cluster_size; /* 512, 1K, ..., 2M */
 
 	if (inode->i_flags & S_IMMUTABLE)
diff --git a/fs/ntfs3/frecord.c b/fs/ntfs3/frecord.c
index 16ac847de48d..5e4f743a5930 100644
--- a/fs/ntfs3/frecord.c
+++ b/fs/ntfs3/frecord.c
@@ -3215,6 +3215,13 @@ int ni_write_inode(struct inode *inode, int sync, const char *hint)
 		}
 
 		/* Update the access times if they have changed. */
+		ts = ni->i_crtime;
+		dup.cr_time = kernel2nt(&ts);
+		if (std->cr_time != dup.cr_time) {
+			std->cr_time = dup.cr_time;
+			modified = true;
+		}
+
 		ts = inode_get_mtime(inode);
 		dup.m_time = kernel2nt(&ts);
 		if (std->m_time != dup.m_time) {
@@ -3250,7 +3257,6 @@ int ni_write_inode(struct inode *inode, int sync, const char *hint)
 		    (modified || (ni->ni_flags & NI_FLAG_UPDATE_PARENT))
 		    /* Avoid __wait_on_freeing_inode(inode). */
 		    && (sb->s_flags & SB_ACTIVE)) {
-			dup.cr_time = std->cr_time;
 			/* Not critical if this function fail. */
 			re_dirty = ni_update_parent(ni, &dup, sync);
 
-- 
2.56.0

