Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794653313;
	b=gHImyo9oe41TSTmstu3+In0PeAnTw2GbvGWrajcUdsbbaL8YROx8FHC+ogf+Nj5nee9g
	 eHiBxLkHxoqulZopE9FDO3YiuIJ4oY4tvbZABCLGaJ7aUbWfZG748eBxlqdjuhk2eSK5E
	 0rdjrBpK+7Xl8voIac5HoQ8XOcvPtFUaPmeMHIN6iM9zm7HqtM3uLbzjQKrq+NBsI1GeE
	 CEM+FrD7nXZ7RHZiL2E/Wc0K6E0c+5kZItAv1HcuvjyDA4WAJrU5GREFN90uUvM3AZNXV
	 pl7cj9AYodupDbrhjKz1sZcZ6d5AsOudA4OmL6XzsFsufXI9ihQ/bpHHtC2CwxiTHBg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794653313;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=vlnGjiz0WitO6a++5wfKz3FIFE4QfP7og6wENObjkjQ=;
	b=z9Zyg1hraQkR4V8epnKq9TcTioD8q95lQ0Jj47tJ+j0RytC7Wxh89LBghNGcjm6mU/03
	 WqHV+J06FVW6pD0lTKpE7wCRROiNByL1IP4ueotT8vmIiMt5OMQpv2Ubaij92i8mWOZ8E
	 8QNUIkCdCBHtDrL66uDI8WvqKbQMNuF+QRT1nBolkw1wN51UU51V1VatEK7JyX4qUfC+V
	 UbhP+rTejxoD3d6fEKpAnFy51S5evuJ3C9TQDqEEYe3b5Jjl5ygonYZ6HvTkWh+Zz2YEI
	 hsI9cRxPfwI2Prc0Ln4rHSb9gCNnzh8BW6faG/w+XEMvoKKfMszQHD/U+skNwRs542Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YAmKiFKv;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 86E14606B4B3;
	Sat, 14 Nov 2026 10:48:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YAmKiFKv
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A92A31F000C5;
	Sat, 14 Nov 2026 10:48:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794653313;
	bh=vlnGjiz0WitO6a++5wfKz3FIFE4QfP7og6wENObjkjQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=YAmKiFKvxF2dqJ70rHRHIFzWFOSENglPJ7iVVtlJMeJPizgjDyjwhj1/ROXABd4Et
	 bS2LB9Ar8T/0BNx16VCKlFg2fabI/kYgKN6KizzxYI5hiXrnQTHWsqMD/vVhp0iJw6
	 BSh3zGBgjYZNG2gGvg840yNfMmHJsvEL8e0NiGtV60KvyTSoQnhMOfIvmGvHR/12L1
	 6O92HQnZ5CbQImtytcFhNmkbwvgKXh/wZFcE7DrlN8z5jJwVu0pRBV+DH48kGKy4a6
	 uhb9TA2ol473UTjKLxFsdZUDTZPbBtK2UOzRFmB4BQI/sDP67dC+HHuUTOorpen3/E
	 JmS8GlEYJRJ6Q==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 11:47:19 +0100
Subject: [PATCH 12/12] nfsd: take freeze protection for the truncate on
 open
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
Message-Id: <20261114-work-fs-frozen_writes-v1-12-f5ae61c898b1@kernel.org>
References: <20261114-work-fs-frozen_writes-v1-0-f5ae61c898b1@kernel.org>
In-Reply-To: <20261114-work-fs-frozen_writes-v1-0-f5ae61c898b1@kernel.org>
To: Jan Kara <jack@suse.cz>
Cc: Shakeel Butt <shakeel.butt@linux.dev>, 
 Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, 
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, 
 io-uring@vger.kernel.org, Christoph Hellwig <hch@lst.de>, 
 linux-block@vger.kernel.org, linux-nvme@lists.infradead.org, 
 linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, 
 linux-unionfs@vger.kernel.org, bpf@vger.kernel.org, 
 linux-nfs@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>, stable@vger.kernel.org
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1520; i=brauner@kernel.org;
 h=from:subject:message-id; bh=d7TUoTxYNm2vxq8SD7MXgIqBY32W95I8i/PEQ3ekloQ=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9sPFiW6704Ye5dNmFuomL3BbsvtPb+kPxGdPsVa67P
 7o82+3+p6OUhUGMi0FWTJHFod0kXG45T8Vmo0wNmDmsTCBDGLg4BWAi174z/LMOSc6Mqtz59FDO
 3c8h5icXPbZ7tY73LsfkZuud07ee1rvEyPBrFbv4LU3zRP5kzytbKn/yzmRlu/9aLmLORO6HIS/
 6wlgB
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

An OPEN that truncates an existing file ends up in nfsd4_truncate()
which calls nfsd_setattr() on the already verified file handle. For a
verified file handle nfsd_setattr() leaves fh_want_write() to the
caller but nfsd4_truncate() never takes it, and do_lookup_open() has
dropped its own write access by then. So a freeze of the exported
filesystem that lands in between lets the truncate modify a frozen
filesystem.

Take write access around nfsd_setattr() like nfsd4_setattr() does.

Fixes: 9f67f189939e ("nfsd: notify_change needs elevated write count")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/nfsd/nfs4state.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1de6c6d757c3e..e561903b9180f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -6681,11 +6681,19 @@ nfsd4_truncate(struct svc_rqst *rqstp, struct svc_fh *fh,
 	struct nfsd_attrs attrs = {
 		.na_iattr	= &iattr,
 	};
+	__be32 status;
+	int err;
+
 	if (!open->op_truncate)
 		return 0;
 	if (!(open->op_share_access & NFS4_SHARE_ACCESS_WRITE))
 		return nfserr_inval;
-	return nfsd_setattr(rqstp, fh, &attrs, NULL);
+	err = fh_want_write(fh);
+	if (err)
+		return nfserrno(err);
+	status = nfsd_setattr(rqstp, fh, &attrs, NULL);
+	fh_drop_write(fh);
+	return status;
 }
 
 static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,

-- 
2.53.0

