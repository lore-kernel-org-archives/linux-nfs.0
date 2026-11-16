Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827115;
	b=W9tvUjdxxBsy3QJI+sM7/XOv8thoIybyA+3zzhpf7xtTUvyBmt9luskbh6utLXaGKDbM
	 Q7jzydzhoYGCgUGt/D9wHBkzK9+ZLW423EWk1DSFcbDSLiSHEJ93RCd72vFXLGHpIPObv
	 rJ/0SiVnNN8pHuHHS9sGxuc1VgESmUP3cCCAlK6yORP2JvB0DbDB8bs71+/I9REBMagD9
	 RYXf0uEzqCuOyqgWNzQVFbovwbJQ95JP/e+URnXRYs8glK8H5Pon6KOwNN2Hb1Pr6sEH8
	 Vf+Wf5Y2EUGH4OWhQl822EdGHQcHKCQvgxh4Y5xGxWR1f5ciWLYSfDbukpIkEo6mrDg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827115;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=i8O0jdpykiNB8SwGgODz3acyFz22/17AhWFONkzhh/g=;
	b=0JoPkU/jL2hxqNTApBpcF7jiUrhhUi2NZFZBvHU3ASROUFBQUOJEMtlMq2/dIGm25WMx
	 LRRDJrn23GrV9cDAQatd0GzUaupo3sDw3A8C/gQZ/RxbNlV1+LRL6yIbeSznDbcy4a62p
	 fmV41ONLvefcnOaoxifQdgMSVFRJkmKZesmmWi5bS9nskXSnHZgYCDciWiOGc36h4kUZ9
	 MNEkJGZSlVaM8BQCAiohAFLA3DZQr2yxrDOLtdcH2xKxJ0ntI8C9C7b9lkjpdKlNE2Vjj
	 yXirVbZBa78mdwJONWYO43L03xDQki7BR+QvoLXXjiW1Saw2ovGxDVG6mPMZAIMtK4A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EUBzj8rd;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 603CD606A333;
	Mon, 16 Nov 2026 11:05:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EUBzj8rd
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 01F871F0181F;
	Mon, 16 Nov 2026 11:05:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827115;
	bh=i8O0jdpykiNB8SwGgODz3acyFz22/17AhWFONkzhh/g=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=EUBzj8rdNpxkagJSBg7wcf9wBRgmeYEHqgbMlEejIEvBFFBhnNYMUGGEHzxWMg0hZ
	 LyIBdubhmLQQF5f1+O8j7EHv+97DTc5JxXnBnnDbdRTkvNp7b6kCE2QlqKyr030qtf
	 ZQT0wfryidm3UcE4gPDS2XMHCUh9EnruAWBkQAHUEDYuvOvRBYzB7T6Be0mHdHhMK+
	 c5sNBl+ZGGpXlDSc6q3HMSHIgO8Duicz2lNKPHnUpz7zS5POXtG36hs2JFLFBaUAlL
	 qXU6IIaD/vqpkaktX5aVAaqYMeiv3ooKezFeHOWYRfp4nGGvwdNfxQAPXaxhd260nv
	 kahpjT8C0w64Q==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:03:52 +0100
Subject: [PATCH v2 12/17] ovl: take freeze protection when storing the uuid
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261116-work-fs-frozen_writes-v2-12-ecc4a2aac40e@kernel.org>
References: <20261116-work-fs-frozen_writes-v2-0-ecc4a2aac40e@kernel.org>
In-Reply-To: <20261116-work-fs-frozen_writes-v2-0-ecc4a2aac40e@kernel.org>
To: Jan Kara <jack@suse.cz>
Cc: Shakeel Butt <shakeel.butt@linux.dev>, 
 Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, 
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, 
 io-uring@vger.kernel.org, Christoph Hellwig <hch@lst.de>, 
 linux-block@vger.kernel.org, linux-nvme@lists.infradead.org, 
 linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, 
 linux-unionfs@vger.kernel.org, bpf@vger.kernel.org, 
 linux-nfs@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>, stable@vger.kernel.org, 
 Amir Goldstein <amir73il@gmail.com>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1319; i=brauner@kernel.org;
 h=from:subject:message-id; bh=iEqLSnloc6x/kvA8qf87o60wvCftihDv39CzS/x68mo=;
 b=kA0DAAoWkcYbwGV43KIByyZiAGr64yvIYGRKYpcyDI7foAEx48sCbXXrr2tiH4XzGg+SJ4/Ha
 Ih1BAAWCgAdFiEEQIc0Vx6nDHizMmkokcYbwGV43KIFAmr64ysACgkQkcYbwGV43KKg3gEAj87k
 b/pDhchb2tEdJEkXgBi6fLBU6mCmFqJ5E75UmgEBANAEc8kQgCTSmcKpnwq1Bk35rMwZLkityEE
 R25Yx9RUO
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

ovl_init_uuid_xattr() stores the persistent uuid in an xattr on the
upper root. That happens after ovl_make_workdir() dropped its write
access to the upper mount and before ovl_get_indexdir() takes it
again. So a freeze of the upper filesystem that lands in between lets
the mount modify a frozen filesystem.

Take write access to the upper mount around the xattr update.

Fixes: d9544c1b0d9e ("ovl: store persistent uuid/fsid with uuid=on")
Cc: stable@vger.kernel.org
Reviewed-by: Amir Goldstein <amir73il@gmail.com>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/overlayfs/util.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/overlayfs/util.c b/fs/overlayfs/util.c
index 521717209b2e4..67aa7b71e9c83 100644
--- a/fs/overlayfs/util.c
+++ b/fs/overlayfs/util.c
@@ -829,8 +829,12 @@ bool ovl_init_uuid_xattr(struct super_block *sb, struct ovl_fs *ofs,
 
 	/* Try to store persistent uuid */
 	set = true;
-	res = ovl_setxattr(ofs, upperpath->dentry, OVL_XATTR_UUID, uuid.b,
-			   UUID_SIZE);
+	res = mnt_want_write(ovl_upper_mnt(ofs));
+	if (!res) {
+		res = ovl_setxattr(ofs, upperpath->dentry, OVL_XATTR_UUID,
+				   uuid.b, UUID_SIZE);
+		mnt_drop_write(ovl_upper_mnt(ofs));
+	}
 	if (res)
 		goto fail;
 

-- 
2.53.0

