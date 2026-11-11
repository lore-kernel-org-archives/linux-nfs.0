Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.170
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794383322;
	b=0neailIHjVADAzjPUQODsgAivgpIIYoVqRO7WaKt2vYtsc7ZBOm9dY0TBZNw5jG+oa+i
	 bPWKLUpbMyb4NwYPC8qF/kk5BZw9WAs5VH7TsU3a75NJeBwJpunfCazlgQVodxwmZOuFd
	 Mw0LbDeMW+vciGhXz/SO73KOx0/UO50NZm408s39Qp6m3O7Txy+t2M/DYitRewPFLQMkK
	 zTiVQiQ3LEdUTb/MgdijFjI55j/FCf5s0hQcMNvz1F9a1laxtacVzI1VohFJoxJBrEScY
	 Lv6uxXmmuKg4JNpze01TqZWaUusfI0W3o4V4FV5PiLnU+Oqf+ke3J1eXq9s3gNS1eGA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794383322;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=KmH4ZXitu/F5zLcyKAJJuc2GxRLS44lxp/qvIGKdIQs=;
	b=UnFtnrth/2OAuP/ZRNv7JsDABEIwGltqQDLOoaRdieDg8ufVop+Li/CsmwGEYn1xRmK5
	 I/NOVTf0bewMNXXjbLGSx8Kywi0/exwj5LNwf5VmHUiLfanqB/8wihjRUokQhIfSjgq1d
	 mjFsY4+mcbPXW/LEySlvPwzf2HLLozu6xSGtLGqGdWV3m2Op5tLs1oiN25khO/8BZQeEs
	 aher7ASD//I1uKDcl28/SPM/h8oyT+DiIFiMDMQaUTOlLR2HMQpwRyML6TaL2+MOiO4G4
	 ZIGLOXtsJ/ccP6dNBfUJXyjIgAVJyK5/DJ06KNVQiO4iUUU9mjwhug/pGo8Jg4Ru8fw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=iLe2eJFf;
	arc=none smtp.remote-ip=74.125.82.170
Received: from mail-dy1-f170.google.com (mail-dy1-f170.google.com [74.125.82.170])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 16BA6606A31C
	for <linux-nfs@vger.kernel.org>; Wed, 11 Nov 2026 07:48:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 16BA6606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=iLe2eJFf
Received: by mail-dy1-f170.google.com with SMTP id 5a478bee46e88-3645f0f3fcdso5949658eec.0
        for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 23:48:41 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794383321; x=1794988121; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=KmH4ZXitu/F5zLcyKAJJuc2GxRLS44lxp/qvIGKdIQs=;
        b=iLe2eJFfKAcFCdWrwD05o+538qgEn4Wi7msKHKTQhjfH+ddAg00tMoDW93HTHjh2EV
         0Nn8yDtKnO6s8BACiq9sJ5b/O9ET7Axn9Z6mGHrconoSjUS22IZi6jcIQst+dNfr0qcS
         Z0IWIMZRLd1dqCqNs9cJMwettXn+oqS3bGDTm0uWUVqk2OwjtPnw4qyikZhPF4MgF7FV
         1Ncz7nbFzs+QmXVkL7EMg/4SoaKqopb9jWZfZ+xy6mPsBfWXYOpKCCYGRlsYaN9KXHoo
         mkHce4cpfJX+D72MW+9oCpghH38MKL9mOI8QWxp12J5mfY0zkkrI/63gtHyMVwh2G5pX
         28tg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794383321; x=1794988121;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=KmH4ZXitu/F5zLcyKAJJuc2GxRLS44lxp/qvIGKdIQs=;
        b=z9vU9KchUVVpF5pk+SP6HBVoGYGCMWBzODQyVQ9NCzwcLgKo6knil3mXG48SH94Mx3
         9nnyCjp5QzgVFo7g9qJ0as8k6vOsup9lIcnS2bDq/bMZ/czFfQbpAO2WdOZU4pYx765Q
         wWJt504gOsR+x6vXJN9+paIPgKrL0I0WvEnkjTc46ve8gSspmnPFV7qwpAw9qhqFyo6u
         aOoUN5noliDTG/5gwFOl5B0gDQ+Bkupv+oqyb1Pg78jh0CrqaTs1X3gP4IMKMHpPrgYo
         l1FoNavKrYjKXgVf2SDZca6XAosRCpIDAtzF28MU9wca4Jr5hCccV5/7jac6aLBhV3sy
         /ahQ==
X-Forwarded-Encrypted: i=1; AL+hErHHFowf4n0+mR7Ejrz6hxOY5bCegkPD9fenWDGyluHDVVb5WzUSS+8vW6JinJXLdLlGf8MejQyt0g4=@vger.kernel.org
X-Gm-Message-State: APuU4Z9GqA/dizVLl5KTDXlDna9XDUKm5X5wsiup+K2O+VR566BvJDrp
	/rZykDIiiBut3JZXzovItlc9Z5ZTI0o8MGM2NDOYf4cc6NOpPS2d5Azk
X-Gm-Gg: AYBFou1oWSVk1V7/vCvyYK4eALFrxn1jmC29BczYScX3VqOsbDsa3SVEHAo5Wp9NRmO
	GZXR9CuglepjVm4GBQcmlwT4VqkTfNy6bSjjeo6Si8i1O701lqrnmlTUSBJdYBqOVASCecKx6js
	o8X23jkZ0tDIE+6vwvqiFfpE/PRh58NtIzxhZbkY+VJSg4bFISujZ1tPdDczfI2ObozdOJ3RY0I
	I35Z7/ii5JjV9ERQLKpQ9H/17Uh51HwrVRAdfRUUquObVs7gMRoue0s99iDNoOvJvEuO1y8oeNh
	DjEVL4RS9bQj0qcIrG8mn+MaqDD2mKaHPodl7GbchDUzybLZpoviQc1j9eqeQuGYEg15aOvtbQB
	/5td6ymQZdX9u98xpSEP0l9wbuFPgaCQNutKx70n9uVxy3JZXWoRnwlKdbXbG4gDrW3M/zm/Gsz
	BCJTw8mCG3re5g+/rddZR40PnfJFDEXWsRwS2CQRwJFpbMWXeWQ5Ya4dRTn665+01ZIr/en3gPo
	TFxcl0ussymGZe4fzVlMgayi4AMibQDZ24MPtWXVQrok2UTWZn5OPmwy0/LHw3kz/NHr8o2q4/X
	oCafW1KcQXx6xlmM7+faIx0k8OWHU97ZvQX61ZDYEe/Ol4CwdYFa8YdvejPzArAAEN4=
X-Received: by 2002:a05:7300:d18f:b0:366:703c:5ef8 with SMTP id 5a478bee46e88-376850cefb9mr2028290eec.7.1794383321067;
        Tue, 10 Nov 2026 23:48:41 -0800 (PST)
Received: from osman.mioffice.cn ([43.224.245.178])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-3752060c4b6sm13675956eec.15.2026.11.10.23.48.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 10 Nov 2026 23:48:40 -0800 (PST)
From: Zhan Xusheng <zhanxusheng1024@gmail.com>
To: cel@kernel.org,
	jlayton@kernel.org
Cc: neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	zhanxusheng@xiaomi.com
Subject: [PATCH v2] nfsd: don't block on a file lease while holding the parent lock
Date: Wed, 11 Nov 2026 15:48:35 +0800
Message-ID: <20261111074835.599584-1-zhanxusheng1024@gmail.com>
X-Mailer: git-send-email 2.43.0
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

From: Zhan Xusheng <zhanxusheng@xiaomi.com>

Since commit 2a60db3525d4 ("nfsd: (almost) always open file in
nfsd4_create_file()"), an NFSv4 OPEN with create that finds an
existing file opens it with dentry_open() while start_creating()
still holds the parent directory lock. The open flags lack
O_NONBLOCK, so break_lease() in do_dentry_open() blocks. Before that
commit the file was opened later by __nfsd_open(), which breaks
leases with O_NONBLOCK, and the client retried on NFS4ERR_DELAY.

A lease on the file now stalls an nfsd thread for up to
lease-break-time with the directory locked, and other creates,
unlinks and renames in that directory wait for it.

To reproduce, set fs.lease-break-time=15, take F_SETLEASE F_WRLCK on
/srv/g from a local process and keep it, and run "echo x >> /mnt/g"
on an NFSv4.2 mount of /srv from localhost. The nfsd thread blocks
in break_lease() for 15s, and "touch /srv/other" on the server takes
13s.

Pass O_NONBLOCK so that break_lease() returns -EWOULDBLOCK and the
client gets NFS4ERR_DELAY again.

Guarded creates and exclusive creates with a different verifier
fail with NFS4ERR_EXIST on an existing file and have no use for the
open. Skip it for them, as nfsd did before that commit, so that they
don't break the lease and, with O_NONBLOCK, don't return
NFS4ERR_DELAY instead of NFS4ERR_EXIST.

Fixes: 2a60db3525d4 ("nfsd: (almost) always open file in nfsd4_create_file()")
Signed-off-by: Zhan Xusheng <zhanxusheng@xiaomi.com>
---
v2: also skip the open for guarded and non-matching exclusive
creates (sashiko, via Jeff). The other part of that report, the open
running before the permission check, is older than this patch and is
not changed here.

QEMU guest on b3dfbde62cf1, a local write lease held on f:

                  touch in f's dir while    open(O_CREAT|O_EXCL)
                  "echo x >> f" waits       of f
  b3dfbde62cf1    13.0s                     EEXIST after 15.3s
  + v1            20ms                      EEXIST after 26.5s
  + v2            10ms                      EEXIST after 2ms

v1: https://lore.kernel.org/all/20261110080038.232210-1-zhanxusheng1024@gmail.com/

 fs/nfsd/nfs4proc.c | 43 ++++++++++++++++++++++++++++++-------------
 1 file changed, 30 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 3a82af381a8d..f19bd69d66f4 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -250,10 +250,21 @@ static inline bool nfsd4_create_is_exclusive(int createmode)
 		createmode == NFS4_CREATE_EXCLUSIVE4_1;
 }
 
+/* Does @child carry the verifier of an earlier exclusive create? */
+static bool nfsd4_create_verf_matches(struct dentry *child, const u32 *verf)
+{
+	struct inode *inode = d_inode(child);
+
+	return inode_get_mtime_sec(inode) == verf[0] &&
+	       inode_get_atime_sec(inode) == verf[1] &&
+	       inode->i_size == 0;
+}
+
 static struct file *do_lookup_open(struct path *parent,
 				   struct qstr *name,
 				   unsigned int oflags,
-				   umode_t mode)
+				   umode_t mode,
+				   const u32 *verf)
 {
 	struct file *filp = NULL;
 	struct path path;
@@ -277,8 +288,16 @@ static struct file *do_lookup_open(struct path *parent,
 		 */
 		int err = nfsd_check_obj_isreg(child);
 
+		/*
+		 * Guarded creates and exclusive creates with another
+		 * verifier fail with EEXIST. Don't open the file for them,
+		 * that would only break a lease.
+		 */
 		if (err)
 			filp = ERR_PTR(err);
+		else if ((oflags & O_EXCL) ||
+			 (verf && !nfsd4_create_verf_matches(child, verf)))
+			filp = ERR_PTR(-EEXIST);
 		else
 			filp = dentry_open(&path, oflags, current_cred());
 	} else if (!(oflags & O_CREAT)) {
@@ -312,13 +331,13 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		.na_iattr	= iap,
 		.na_seclabel	= &open->op_label,
 	};
-	int oflags = O_CREAT | O_LARGEFILE;
+	int oflags = O_CREAT | O_LARGEFILE | O_NONBLOCK;
 	struct dentry *child = ERR_PTR(-EINVAL);
 	struct path parent = {
 		.mnt = fhp->fh_export->ex_path.mnt,
 		.dentry = fhp->fh_dentry,
 	};
-	__u32 v_mtime, v_atime;
+	u32 verf[2] = {};
 	__be32 status, create_status;
 	int want_write_err;
 
@@ -395,8 +414,6 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		attrs.na_pacl = posix_acl_dup(open->op_pacl);
 	}
 
-	v_mtime = 0;
-	v_atime = 0;
 	if (nfsd4_create_is_exclusive(open->op_createmode)) {
 		u32 *verifier = (u32 *)open->op_verf.data;
 
@@ -408,13 +425,13 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		 * verifier, then do_open_lookup() will also need to be
 		 * fixed accordingly.
 		 */
-		v_mtime = verifier[0] & 0x7fffffff;
-		v_atime = verifier[1] & 0x7fffffff;
+		verf[0] = verifier[0] & 0x7fffffff;
+		verf[1] = verifier[1] & 0x7fffffff;
 
 		iap->ia_valid |= ATTR_MTIME | ATTR_ATIME |
 				 ATTR_MTIME_SET|ATTR_ATIME_SET;
-		iap->ia_mtime.tv_sec = v_mtime;
-		iap->ia_atime.tv_sec = v_atime;
+		iap->ia_mtime.tv_sec = verf[0];
+		iap->ia_atime.tv_sec = verf[1];
 		iap->ia_mtime.tv_nsec = 0;
 		iap->ia_atime.tv_nsec = 0;
 	}
@@ -428,7 +445,9 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				       &QSTR_LEN(open->op_fname,
 						 open->op_fnamelen),
 				       oflags,
-				       open->op_iattr.ia_mode);
+				       open->op_iattr.ia_mode,
+				       nfsd4_create_is_exclusive(open->op_createmode) ?
+				       verf : NULL);
 	if (IS_ERR(open->op_filp)) {
 		int hosterr = PTR_ERR(open->op_filp);
 
@@ -456,9 +475,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	if (!open->op_created &&
 	    nfsd4_create_is_exclusive(open->op_createmode) &&
-	    inode_get_mtime_sec(d_inode(child)) == v_mtime &&
-	    inode_get_atime_sec(d_inode(child)) == v_atime &&
-	    d_inode(child)->i_size == 0)
+	    nfsd4_create_verf_matches(child, verf))
 		open->op_created = true;
 
 	if (!open->op_created) {
-- 
2.43.0

