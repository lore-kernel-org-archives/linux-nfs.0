Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.48
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794765844;
	b=Slm1dl6uWmPMKe9B4qj0Zy1LfNtuTwDFHmqHuNhZVhlUGjtBVy9HxdPbLhawIGyi8Goq
	 TM84ivKObDA3EVrwf+f0uvXUkcV7wMo6mCB33s3DW6SkbpbjmOEuNsd9knrzU9nIxYjsP
	 ZOVfpBEDciCEL1MTgpgCS6EysdRRRiBxZMuLZcOq3tJpjxj7ggzRwEibbrsDn3EsCIXyJ
	 C8rPFgs4O6Rq3/HtJnk5jlY/5n3JN2iXPkinF9e1ZldrIt7OSHgFviOdA6mEOns00auSr
	 TIfFSwEfcnk/EgLRH9FWhu2rWs5mnAxrWqrRJBvPPir7wgOjwwc/E3Ba8vKoPZY9W1g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794765844;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=WZMCtFvfAg1vYqohiGdP4/WJByQardm3oeHLornlvD0=;
	b=H7UIZ1mLVXjy9dy1sC4lhVpku13XWbPTQAnTD1vnooirU883uwYd15CpbjqShdOS7Fg7
	 uOwUN0YFXdtOzx89oDlFC7iAhAON9CL3M9HwY7m/8iljXb0oiZyV5mVj8Bgqn5ysdE9lm
	 wihAL6y8nlbrLSkY/Bg2vdovVVzpjeeMbHdQuP/qyYneii2vL4hN3IdJ3kV7U/e+L1b67
	 q92u5RN6h0OfcvOiMfjDxekM41imvKbLoeFYQDsr1OP612wuuZmMiLTmHoOUyEytGgf2F
	 kV2bxPJcthjli4z0ho1+k9FxXZKwieTO3EnCvzTU8FY0XmzoBqg83wNIkH07JnLyQyg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=Y9i5SdEj;
	arc=none smtp.remote-ip=209.85.128.48
Received: from mail-wm1-f48.google.com (mail-wm1-f48.google.com [209.85.128.48])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6727E606A881
	for <linux-nfs@vger.kernel.org>; Sun, 15 Nov 2026 18:04:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 6727E606A881
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=Y9i5SdEj
Received: by mail-wm1-f48.google.com with SMTP id 5b1f17b1804b1-4a1b07c3c5fso30889005e9.1
        for <linux-nfs@vger.kernel.org>; Sun, 15 Nov 2026 10:04:02 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794765841; x=1795370641; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=WZMCtFvfAg1vYqohiGdP4/WJByQardm3oeHLornlvD0=;
        b=Y9i5SdEjHJqfgpGdwwvH18HT/U2ZCE9Ztzu9lBc7uNC7HslQd+YYHyfE4gd4JJBGZZ
         b7jnqWJjatVz/vcnWRpsFMcrX2wyk9xBokJY7U256d/MLss9fz3rQ94Oy6rh5lHlnNlI
         1RxHR9Av8yiB6KC3gO+YaziUEYLD0N7SRIg15kV+wclYUezdx66anlforVrri9d9CsMj
         SCC0b7CnycKnm/1FOWeiJ1gifv0UlhDvKLOrOpsZwLok96k/uhviBSlmvMGV5/DDzZfy
         MT7UpB05w1WtVpwrXubZOuU+JM4omun7B31maO6rnrghD0ItLCLYnSd2Fo8oasJEbk+H
         /5NA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794765841; x=1795370641;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=WZMCtFvfAg1vYqohiGdP4/WJByQardm3oeHLornlvD0=;
        b=EQuU2az6I5bMb7PKGFhSEJpJwJ8EfOffQjtrkxxU7ZPKFq+b+8Ix9iStYYxWMHmcru
         2rGYXNTC13O1nm+eKUTJcnKnE74/zdGEByi31hPA3a6bWLGlr5L+oEl5cA8x3jl9s/Gd
         3s98I083pCY7KBNRHH10qdE+8VhfjMPefq6/X6ZqYMR4LYUjiihY6F1mbsQi2qr9llos
         gL/p/a/Tov+OgY1E3hyxwN/0uv+v0Gd/UPzINJT1fvJ+HKRKPdiBthpv5rVjv13c1uop
         xahd3tebt9w81v0Tz1aj+HRgQZGsNRJnEGBrFYZy7tUDwD75R1TPRSUJcxwG3tIW/WEI
         P0aw==
X-Forwarded-Encrypted: i=1; AL+hErHGw8ZuNaH4kNy4g8R1Wp4llQ49JrWdAaAuCLDP40ReBFwLlGFQeC6wuqn6N0TXWSq6UfxhFNu64Y0=@vger.kernel.org
X-Gm-Message-State: APuU4Z+c/AAXr32nMvDW994Rq4OnE+A5Epk2cScaBpkiudLVL5UItjtF
	bejvA+3LEZJLbakmiz8XiErh1YWeDy7un5RlosMUb2HTMLSDN6qflVJm
X-Gm-Gg: AYBFou36lSyNZyU6UmR3eFHYKDqYN5LikzIN5uRQEASuJT4U7xcpjtgPLlzJdsYUHIe
	4xmBTYHERsQtq4xyesqPwhtvU7ar7kGljSBumnTkA1W/ZS9VCJjOuXMvoJsF3LDbxfxT17fQ/a0
	vAsW5LsUvp6EcC2JnrejDsyzq78fKYZfIOQSZk0KOhDZ6I2/lrgxckz11DBK73bBKg4evUUGZbz
	utP9HKDHz+zh7RCq9KDTQAnXeeEaVKjDGdQ+tsIKDbU0o2r+eqhQV33MirVNLkp5Jm65pYzwb/u
	NpV/mSNgzugPQFfXf13D3ml/Ui7E/II0KP8UV5eCgNT6YcxY160d4CnP2Yzr47o1vvfEpGHF3jF
	pich8Am0QsZdYNjQYK/JxhHDB8EA58VE6nvtOm2YHvMj+XxSXaAmU1FmEbF0dF9/eB3sKUwOLfX
	NXs57RP18anqKR7AK0+VLogNUG0oXiSVw8nAQijeMKXq5YQqBJszE8yTnBMRjD/QOaI+j0nvKy3
	F1tVb0DaOBkp+Zz9VUth6uI7SSxuTnD4HvKlB/zesTW/vSl4Gjh/ZDLEYN4NIWtuzxZputLSSoG
	GDgpJk8MyxmqgDJnB4ixEA2iMg==
X-Received: by 2002:a05:600c:4e0d:b0:4bb:69b2:d3df with SMTP id 5b1f17b1804b1-4bb69b2d82fmr54499615e9.25.1794765841177;
        Sun, 15 Nov 2026 10:04:01 -0800 (PST)
Received: from infinity ([2001:b07:5d26:7a6a:365a:60ff:fe0d:cfc6])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-49c60f8c248sm17980448f8f.58.2026.11.15.10.03.59
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 15 Nov 2026 10:04:00 -0800 (PST)
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
Subject: [RFC PATCH v4 01/10] vfs: add provenance time (ptime)
Date: Sun, 15 Nov 2026 19:03:34 +0100
Message-ID: <20261115180343.576773-2-koray.fra@gmail.com>
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

Add provenance time (ptime), indicating the time when a file or
directory was created. This is user-settable via file_setattr() and
retrievable via statx(2) (using STATX_PTIME) or file_getattr().

The semantics of when to preserve this new timestamp are the same as
mtime, the idea being that there is a correspondence like this:

ctime <-> btime
mtime <-> ptime

so every operation (copying, moving, ...) that currently preserves mtime
should also preserve ptime.

Also add fa_xflags_mask to struct file_attr (and equivalent
fsx_xflags_mask to struct file_kattr) to let the filesystems advertise
their support for specific xflags and users advertise what they want to
change, behaving like statx.stx_attributes_mask:
- on GET (file_getattr): each filesystem fills the mask according to
  their supported xflags, e.g. FS_XFLAG_PTIME or FS_XFLAG_COWEXTSIZE,
  and provides the values in the corresponding struct fields;
- on SET (file_setattr): userspace fills the mask according to which
  xflags it wants to change, VFS validates this and preserves xflags
  that were not specified in the mask;
- if xflags_mask == 0, use legacy full-struct replacement to keep
  compatibility with older programs.

Furthermore, in order to avoid the legacy FS_IOC_FSSETXATTR accepting
FS_XFLAG_PTIME, add an FS_FILE_ATTR_XFLAGS_MASK mask to support new
xflags and use it in fileattr_to_file_attr()/file_attr_to_fileattr() to
validate that the xflags passed in xflags and xflags_mask fields are
valid.

Finally, add the missing FS_XFLAG_PROJID flag, to allow userspace to set
the projid using file_[sg]etattr().

[ This is a re-implementation of the initial patch[1] by Sean Smith
  <defendthedisabled@gmail.com>, following the advice[2] from Darrick J.
  Wong <djwong@kernel.org> of using file_setattr() instead of updating
  utimensat() ]

[1]: https://lore.kernel.org/20260405195007.1306-2-DefendTheDisabled@gmail.com
[2]: https://lore.kernel.org/20260407014129.GC6192@frogsfrogsfrogs

Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.4.7
Signed-off-by: koraynilay <koray.fra@gmail.com>
---
 fs/file_attr.c            | 75 +++++++++++++++++++++++++++++++++++++--
 fs/stat.c                 |  2 ++
 include/linux/fileattr.h  |  6 ++++
 include/linux/stat.h      |  1 +
 include/uapi/linux/fs.h   |  9 ++++-
 include/uapi/linux/stat.h |  7 +++-
 6 files changed, 95 insertions(+), 5 deletions(-)

diff --git a/fs/file_attr.c b/fs/file_attr.c
index 833e03810b24..12610fb6a751 100644
--- a/fs/file_attr.c
+++ b/fs/file_attr.c
@@ -102,14 +102,23 @@ EXPORT_SYMBOL(vfs_fileattr_get);
 static void fileattr_to_file_attr(const struct file_kattr *fa,
 				  struct file_attr *fattr)
 {
-	__u32 mask = FS_XFLAGS_MASK;
+	/*
+	 * fsx_xflags_mask contains only flags added after the
+	 * file_[gs]etattr() API, so we need to tell userspace the filesystem
+	 * actually supports all legacy and new advertised flags
+	 */
+	__u32 mask = (FS_XFLAGS_MASK | fa->fsx_xflags_mask) &
+		     FS_FILE_ATTR_XFLAGS_MASK;
 
 	memset(fattr, 0, sizeof(struct file_attr));
 	fattr->fa_xflags = fa->fsx_xflags & mask;
+	fattr->fa_xflags_mask = mask;
 	fattr->fa_extsize = fa->fsx_extsize;
 	fattr->fa_nextents = fa->fsx_nextents;
 	fattr->fa_projid = fa->fsx_projid;
 	fattr->fa_cowextsize = fa->fsx_cowextsize;
+	fattr->fa_ptime_sec = fa->fsx_ptime.tv_sec;
+	fattr->fa_ptime_nsec = fa->fsx_ptime.tv_nsec;
 }
 
 /**
@@ -141,15 +150,23 @@ EXPORT_SYMBOL(copy_fsxattr_to_user);
 static int file_attr_to_fileattr(const struct file_attr *fattr,
 				 struct file_kattr *fa)
 {
-	__u64 mask = FS_XFLAGS_MASK;
+	__u64 mask = fattr->fa_xflags_mask ?: FS_XFLAGS_MASK;
+
+	if (fattr->fa_xflags_mask & ~FS_FILE_ATTR_XFLAGS_MASK)
+		return -EINVAL;
 
 	if (fattr->fa_xflags & ~mask)
 		return -EINVAL;
 
 	fileattr_fill_xflags(fa, fattr->fa_xflags & ~FS_XFLAG_RDONLY_MASK);
+	fa->fsx_xflags_mask = fattr->fa_xflags_mask;
 	fa->fsx_extsize = fattr->fa_extsize;
 	fa->fsx_projid = fattr->fa_projid;
 	fa->fsx_cowextsize = fattr->fa_cowextsize;
+	if (fattr->fa_xflags_mask & FS_XFLAG_PTIME) {
+		fa->fsx_ptime.tv_sec = fattr->fa_ptime_sec;
+		fa->fsx_ptime.tv_nsec = fattr->fa_ptime_nsec;
+	}
 
 	return 0;
 }
@@ -232,6 +249,23 @@ static int fileattr_set_prepare(struct inode *inode,
 	    !S_ISREG(inode->i_mode) && !S_ISDIR(inode->i_mode))
 		return -EINVAL;
 
+	if (fa->fsx_xflags_mask & FS_XFLAG_PTIME) {
+		if (!(old_ma->fsx_xflags_mask & FS_XFLAG_PTIME))
+			return -EOPNOTSUPP;
+
+		if (!(fa->fsx_xflags & FS_XFLAG_PTIME))
+			return -EINVAL;
+
+		if ((unsigned long)fa->fsx_ptime.tv_nsec >= NSEC_PER_SEC)
+			return -EINVAL;
+
+		fa->fsx_ptime = timestamp_truncate(fa->fsx_ptime, inode);
+
+		if (!timespec64_equal(&old_ma->fsx_ptime, &fa->fsx_ptime) &&
+		    (fa->flags & old_ma->flags) & (FS_APPEND_FL | FS_IMMUTABLE_FL))
+			return -EPERM;
+	}
+
 	/*
 	 * It is only valid to set the DAX flag on regular files and
 	 * directories on filesystems.
@@ -288,13 +322,41 @@ int vfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dentry,
 	if (!err) {
 		/* initialize missing bits from old_ma */
 		if (fa->flags_valid) {
-			fa->fsx_xflags |= old_ma.fsx_xflags & ~FS_XFLAG_COMMON;
+			/* FS_IOC_SETFLAGS */
+			fa->fsx_xflags |= (old_ma.fsx_xflags & FS_XFLAGS_MASK) &
+					  ~FS_XFLAG_COMMON;
 			fa->fsx_extsize = old_ma.fsx_extsize;
 			fa->fsx_nextents = old_ma.fsx_nextents;
 			fa->fsx_projid = old_ma.fsx_projid;
 			fa->fsx_cowextsize = old_ma.fsx_cowextsize;
+			fa->fsx_ptime = old_ma.fsx_ptime;
 		} else {
+			/*
+			 * Preserve unmasked xflags when running file_setattr()
+			 * with a mask, which doesn't need a read-modify-write
+			 * so these attributes would be set to 0.
+			 *
+			 * With FS_IOC_FSSETXATTR or mask == 0 (legacy mode)
+			 * this is not needed as userspace does
+			 * read-modify-write already.
+			 */
+			if (fa->fsx_xflags_mask) {
+				fa->fsx_xflags |= old_ma.fsx_xflags &
+						  ~fa->fsx_xflags_mask;
+				fileattr_fill_xflags(fa, fa->fsx_xflags &
+						     ~FS_XFLAG_RDONLY_MASK);
+				if (!(fa->fsx_xflags_mask & FS_XFLAG_EXTSIZE))
+					fa->fsx_extsize = old_ma.fsx_extsize;
+				if (!(fa->fsx_xflags_mask & FS_XFLAG_PROJID))
+					fa->fsx_projid = old_ma.fsx_projid;
+				if (!(fa->fsx_xflags_mask & FS_XFLAG_COWEXTSIZE))
+					fa->fsx_cowextsize = old_ma.fsx_cowextsize;
+			}
 			fa->flags |= old_ma.flags & ~FS_COMMON_FL;
+
+			/* xflags not present in fsxattr */
+			if (!(fa->fsx_xflags_mask & FS_XFLAG_PTIME))
+				fa->fsx_ptime = old_ma.fsx_ptime;
 		}
 
 		err = fileattr_set_prepare(inode, &old_ma, fa);
@@ -423,6 +485,10 @@ SYSCALL_DEFINE5(file_getattr, int, dfd, const char __user *, filename,
 		return error;
 
 	fileattr_to_file_attr(&fa, &fattr);
+
+	if (usize < FILE_ATTR_SIZE_VER1)
+		fattr.fa_xflags &= ~FS_XFLAG_PTIME;
+
 	error = copy_struct_to_user(ufattr, usize, &fattr,
 				    sizeof(struct file_attr), NULL);
 
@@ -459,6 +525,9 @@ SYSCALL_DEFINE5(file_setattr, int, dfd, const char __user *, filename,
 	if (error)
 		return error;
 
+	if ((fattr.fa_xflags & FS_XFLAG_PTIME) && usize < FILE_ATTR_SIZE_VER1)
+		return -EINVAL;
+
 	error = file_attr_to_fileattr(&fattr, &fa);
 	if (error)
 		return error;
diff --git a/fs/stat.c b/fs/stat.c
index 34d786c1de3e..1e4260f55f01 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -728,6 +728,8 @@ cp_statx(const struct kstat *stat, struct statx __user *buffer)
 	tmp.stx_ctime.tv_nsec = stat->ctime.tv_nsec;
 	tmp.stx_mtime.tv_sec = stat->mtime.tv_sec;
 	tmp.stx_mtime.tv_nsec = stat->mtime.tv_nsec;
+	tmp.stx_ptime.tv_sec = stat->ptime.tv_sec;
+	tmp.stx_ptime.tv_nsec = stat->ptime.tv_nsec;
 	tmp.stx_rdev_major = MAJOR(stat->rdev);
 	tmp.stx_rdev_minor = MINOR(stat->rdev);
 	tmp.stx_dev_major = MAJOR(stat->dev);
diff --git a/include/linux/fileattr.h b/include/linux/fileattr.h
index 09e32b84e02a..42b92ccdc583 100644
--- a/include/linux/fileattr.h
+++ b/include/linux/fileattr.h
@@ -35,6 +35,10 @@
 	(FS_XFLAG_COMMON | FS_XFLAG_RDONLY_MASK | FS_XFLAG_VALUES_MASK | \
 	 FS_XFLAG_DIRONLY_MASK | FS_XFLAG_MISC_MASK)
 
+/* Flags only for fa_ fields */
+#define FS_FILE_ATTR_XFLAGS_MASK \
+	(FS_XFLAGS_MASK | FS_XFLAG_PTIME | FS_XFLAG_PROJID)
+
 /*
  * Merged interface for miscellaneous file attributes.  'flags' originates from
  * ext* and 'fsx_flags' from xfs.  There's some overlap between the two, which
@@ -45,10 +49,12 @@ struct file_kattr {
 	u32	flags;		/* flags (FS_IOC_GETFLAGS/FS_IOC_SETFLAGS) */
 	/* struct fsxattr: */
 	u32	fsx_xflags;	/* xflags field value (get/set) */
+	u32	fsx_xflags_mask; /* supported xflags (get) / flags to set (set) */
 	u32	fsx_extsize;	/* extsize field value (get/set)*/
 	u32	fsx_nextents;	/* nextents field value (get)	*/
 	u32	fsx_projid;	/* project identifier (get/set) */
 	u32	fsx_cowextsize;	/* CoW extsize field value (get/set)*/
+	struct timespec64 fsx_ptime; /* provenance (settable birth) time */
 	/* selectors: */
 	bool	flags_valid:1;
 	bool	fsx_valid:1;
diff --git a/include/linux/stat.h b/include/linux/stat.h
index 4f0a4af7a067..5384a77676f1 100644
--- a/include/linux/stat.h
+++ b/include/linux/stat.h
@@ -48,6 +48,7 @@ struct kstat {
 	struct timespec64 mtime;
 	struct timespec64 ctime;
 	struct timespec64 btime;			/* File creation time */
+	struct timespec64 ptime;	/* File provenance (user-settable creation) time */
 	u64		blocks;
 	u64		mnt_id;
 	u64		change_cookie;
diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
index a46c33692aa2..655e448cdd23 100644
--- a/include/uapi/linux/fs.h
+++ b/include/uapi/linux/fs.h
@@ -229,10 +229,14 @@ struct file_attr {
 	__u32 fa_nextents;	/* nextents field value (get)   */
 	__u32 fa_projid;	/* project identifier (get/set) */
 	__u32 fa_cowextsize;	/* CoW extsize field value (get/set) */
+	__s64 fa_ptime_sec;	/* provenance (settable birth) time (seconds) */
+	__u32 fa_ptime_nsec;	/* provenance (settable birth) time (nanoseconds) */
+	__u32 fa_xflags_mask;   /* supported xflags (get) / flags to set (set) */
 };
 
 #define FILE_ATTR_SIZE_VER0 24
-#define FILE_ATTR_SIZE_LATEST FILE_ATTR_SIZE_VER0
+#define FILE_ATTR_SIZE_VER1 40
+#define FILE_ATTR_SIZE_LATEST FILE_ATTR_SIZE_VER1
 
 /*
  * Flags for the fsx_xflags field
@@ -261,6 +265,9 @@ struct file_attr {
  */
 #define FS_XFLAG_CASEFOLD	0x00040000	/* case-insensitive lookups */
 #define FS_XFLAG_CASENONPRESERVING 0x00080000	/* case not preserved */
+
+#define FS_XFLAG_PTIME		0x00100000	/* provenance time */
+#define FS_XFLAG_PROJID		0x00200000	/* project ID */
 #define FS_XFLAG_HASATTR	0x80000000	/* no DIFLAG for this	*/
 
 /* the read-only stuff doesn't really belong here, but any other place is
diff --git a/include/uapi/linux/stat.h b/include/uapi/linux/stat.h
index 1686861aae20..f3a1013ba022 100644
--- a/include/uapi/linux/stat.h
+++ b/include/uapi/linux/stat.h
@@ -187,7 +187,11 @@ struct statx {
 	__u32	__spare2[1];
 
 	/* 0xc0 */
-	__u64	__spare3[8];	/* Spare space for future expansion */
+	/* Data provenance (creation) time */
+	struct statx_timestamp	stx_ptime;
+
+	/* 0xd0 */
+	__u64	__spare3[6];	/* Spare space for future expansion */
 
 	/* 0x100 */
 };
@@ -219,6 +223,7 @@ struct statx {
 #define STATX_SUBVOL		0x00008000U	/* Want/got stx_subvol */
 #define STATX_WRITE_ATOMIC	0x00010000U	/* Want/got atomic_write_* fields */
 #define STATX_DIO_READ_ALIGN	0x00020000U	/* Want/got dio read alignment info */
+#define STATX_PTIME		0x00040000U	/* Want/got stx_ptime */
 
 #define STATX__RESERVED		0x80000000U	/* Reserved for future struct statx expansion */
 
-- 
2.56.0

