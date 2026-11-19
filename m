Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.218.70
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795116196;
	b=F0LoO8NMQHrx1nYLk+930jl+uO9jTV86RN1rxdhsiNyTIuFtWlMV3xX/61yYQq9tgB0Q
	 xY4DpTAlXBpBujPROZ7GoyCzYe1MGkYKJlbky13NTwnJWZU7aThC/+wtxaJUVPU7LTq2r
	 K2KWyJeKxu175FxnoAVDZxcJTR9in2BdiJISv+9841ho4g5Jmo4cPPYPMnjr1ba2gLTdt
	 Mc81bBz0towKq+WrSVKiDwgJVKHUxaWgglcivDdFi53EKBXEshwn+tk511O1/T13GYkfZ
	 24cLzzjc+zb3SipqtmIeyiJsVUPMQX2TqV5PI2tMTdRUhyZttiPuleZSsSM9W7O/eMg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795116196;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:In-Reply-To:
	 Mime-Version:References:X-Mailer:Message-ID:Subject:From:To:Cc:
	 Content-Type;
	bh=iB7uS9rNzMUxVP6IABsn6P+/g0oB4DwnWOOQRoeg9fM=;
	b=DRjc8DMa/UszTjEjcrQkUyWDgUM8vN64b/DmgAXKzAfvdQAzyW3MK3gRQpKUi83L5Dnk
	 bCDDnDakdV0+4EvfGBcNeVYKtNtrLNz4PEi3aR0lj4nj3Ac8Cgs3G+wilpQhrmFa8137i
	 qKJ2C5fpnhcMfsFV/el2c7Kmn9vykE+vvF4iwXAP5n1/llIgvPmQabBBsmPdM9SDXNYV9
	 Y2Thc9wcOM2un5PMb+aMfUhbxEvhGJXY90nYSBqXInNcVps5LL7ekvdC7w48d2GBbz6Rr
	 qauX4NU9NkJYEwMfybyGaxUvgTvMo7f2ib6zcs+YTj+QmStvkuQ06a2uawaMQbOv91g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--dmnk.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b="WiPMiav/";
	arc=none smtp.remote-ip=209.85.218.70
Received: from mail-ej1-f70.google.com (mail-ej1-f70.google.com [209.85.218.70])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8E7F8606A337
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 19:23:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8E7F8606A337
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--dmnk.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=WiPMiav/
Received: by mail-ej1-f70.google.com with SMTP id a640c23a62f3a-c50549f6cf1so9074766b.3
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 11:23:16 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1795116195; x=1795720995; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=iB7uS9rNzMUxVP6IABsn6P+/g0oB4DwnWOOQRoeg9fM=;
        b=WiPMiav/DFba3jhOffEk7iCJjNHHI3HaGlH6rW/CFy0x9i1TYN56ACpiw4ZhFt2uIZ
         qH2ww7OiLAtz/wjpK2rLSbOMiiwjIo/uJdmLUWOaTJ5J9qYS6nA+i2cO7NE0fTJ652vw
         SLdGakiivxs7AUfR/fy25HqS4womznQxUhaCd2kD0zbsc8kffRqiTB/7WMH8vF1uiPpe
         Y6pBUdrjFGjANX3QRQwQXDNnhWYB6AoH8B4iDfn9VmuS6HNUUdHALEdrKg5ecccG3q9g
         i+ldi0hbGMxSeL96u11Peokty8hPnoe9neE6DL/RdJW5axurubHAGo3CTc9V8yTHiXj0
         t84Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795116195; x=1795720995;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=iB7uS9rNzMUxVP6IABsn6P+/g0oB4DwnWOOQRoeg9fM=;
        b=xIPHA8LjxCys+Ff7sJxLPLUr5JVWhF7p3GBm1UeHv2KLjor0uQ7WtFMGeKF3ESRhUh
         UTj7BZR8NNJOJI3dTLwbpv5YPjVNgjwSXozZJnVNwWQF55COwaa60DCoYu2XTjtza0TV
         i8csljZeYT/IErP1toGll3UgGfQ5ZuiIaL4Kzf0xe1QN+cED3Bf32rQ0HUPrUOrf1nBa
         SRQ9dU5ZyFO2PzZNc5At3szwL0Ajktgm49zafsRkVA/XwYF37SDvxE7y4D0icHTb+VWX
         dlfH6Kc+jtPcc2ubGbXCuJGCUB71GUd17ZuUfqqgS4sZfdB5co6GSPaU53m2K+2bhzHY
         17gw==
X-Forwarded-Encrypted: i=1; AL+hErHpRLnBNZjtlz/PTK4rc+fV3snJOx0Z2Mh38n0rDeWlOjUaVfnfR4Pml1+07NJ7//J3QSJxLPSK68k=@vger.kernel.org
X-Gm-Message-State: APuU4Z+QZAHm8vyBOmf4jT9RMbtKApTgONhOkqA+WmxoZ8i+EmHxhlAv
	pDcmMaKfeEvQVPtt7e++4NmVPYwBLXIXUIvPDKVpsmaWLU8knb8snbtHt69HRz30od4ZZ80wRw=
	=
X-Received: from ejcfw45.prod.google.com ([2002:a17:907:502d:b0:c50:519f:c790])
 (user=dmnk job=prod-delivery.src-stubby-dispatcher) by 2002:a17:907:9408:b0:c49:8f1e:af0a
 with SMTP id a640c23a62f3a-c513a52bef3mr107772066b.7.1795116194626; Thu, 19
 Nov 2026 11:23:14 -0800 (PST)
Date: Thu, 19 Nov 2026 20:23:11 +0100
In-Reply-To: <20261119192311.2684978-1-dmnk@google.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
References: <20261119192311.2684978-1-dmnk@google.com>
X-Mailer: git-send-email 2.56.1.809.ga0b61035b5-goog
Message-ID: <20261119192311.2684978-2-dmnk@google.com>
Subject: [PATCH 2/2] nfsd: enforce cross-export and may_linkat() checks in nfsd_link()
From: Dominik Maier <dmnk@google.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
	Christian Brauner <brauner@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Jan Kara <jack@suse.cz>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	dmnk+artist@google.com, Dominik Maier <dmnk@google.com>
Content-Type: text/plain; charset="UTF-8"

nfsd_link() verifies NFSD_MAY_CREATE on the destination directory
filehandle (ffhp) and NFSD_MAY_NOP on the source filehandle (tfhp)
before calling vfs_link() directly, omitting two checks enforced
elsewhere:

1. Unlike nfsd_rename(), nfsd_link() does not verify that the source and
   destination filehandles belong to the same export path. In addition,
   because tfhp is verified second with NFSD_MAY_NOP, if two distinct
   svc_export entries share ex_path with different read-only or UID
   squashing options, fh_verify(tfhp, NFSD_MAY_NOP) skips exp_rdonly()
   and leaves current_cred() set to tfhp->fh_export's credentials.
2. Unlike filename_linkat(), nfsd_link() does not call may_linkat()
   before vfs_link(), allowing remote NFSv3 and NFSv4 clients to bypass
   fs.protected_hardlinks restrictions and hardlink non-owned restricted
   files.

Require ffhp->fh_export->ex_path and tfhp->fh_export->ex_path to match
(returning nfserr_xdev on mismatch, matching nfsd_rename()). When
ffhp->fh_export and tfhp->fh_export differ on the same ex_path, reject
read-only source exports via exp_rdonly() with nfserr_rofs and restore
ffhp->fh_export credentials via nfsd_setuser(). Finally, check
may_linkat() before proceeding with the link, mapping -EOVERFLOW on
unmapped inode IDs to nfserr_perm to match vfs_link().

This issue was discovered by an AI-assisted code review tool (ARTIST)
and validated in QEMU against an unmodified v7.4-rc3 kernel without
kernel modifications or error injection. A standalone reproducer is
available on request. The fix was build-tested with KCFLAGS=-Werror and
checked with checkpatch.pl --strict.

Fixes: 800179c9b8a1 ("fs: add link restrictions")
Cc: stable@vger.kernel.org
Signed-off-by: Dominik Maier <dmnk@google.com>
---
 fs/nfsd/vfs.c | 34 +++++++++++++++++++++++++++++-----
 1 file changed, 29 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 56c49b5..0c4e052 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -45,6 +45,7 @@
 #include "netns.h"
 #include "stats.h"
 #include "vfs.h"
+#include "auth.h"
 #include "filecache.h"
 #include "trace.h"
 
@@ -1993,6 +1994,11 @@ nfsd_symlink(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	return err;
 }
 
+static int exp_rdonly(struct svc_cred *cred, struct svc_export *exp)
+{
+	return nfsexp_flags(cred, exp) & NFSEXP_READONLY;
+}
+
 /**
  * nfsd_link - create a link
  * @rqstp: RPC transaction context
@@ -2011,6 +2017,7 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
 {
 	struct dentry	*ddir, *dnew, *dold;
 	struct inode	*dirp;
+	struct path	old_path;
 	int		type;
 	__be32		err;
 	int		host_err;
@@ -2032,6 +2039,28 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
 	err = nfserr_exist;
 	if (name_is_dot_dotdot(name, len))
 		goto out;
+	err = nfserr_xdev;
+	if (!path_equal(&ffhp->fh_export->ex_path, &tfhp->fh_export->ex_path))
+		goto out;
+	if (ffhp->fh_export != tfhp->fh_export) {
+		if (exp_rdonly(&rqstp->rq_cred, tfhp->fh_export)) {
+			err = nfserr_rofs;
+			goto out;
+		}
+		host_err = nfsd_setuser(&rqstp->rq_cred, ffhp->fh_export);
+		if (host_err) {
+			err = nfserrno(host_err);
+			goto out;
+		}
+	}
+
+	old_path.mnt = tfhp->fh_export->ex_path.mnt;
+	old_path.dentry = tfhp->fh_dentry;
+	host_err = may_linkat(&nop_mnt_idmap, &old_path);
+	if (host_err) {
+		err = host_err == -EOVERFLOW ? nfserr_perm : nfserrno(host_err);
+		goto out;
+	}
 
 	err = nfs_ok;
 	type = d_inode(tfhp->fh_dentry)->i_mode & S_IFMT;
@@ -2592,11 +2621,6 @@ nfsd_statfs(struct svc_rqst *rqstp, struct svc_fh *fhp, struct kstatfs *stat, in
 	return err;
 }
 
-static int exp_rdonly(struct svc_cred *cred, struct svc_export *exp)
-{
-	return nfsexp_flags(cred, exp) & NFSEXP_READONLY;
-}
-
 #ifdef CONFIG_NFSD_V4
 /*
  * Helper function to translate error numbers. In the case of xattr operations,
-- 
2.56.1.750.gf70dc682cf-goog
