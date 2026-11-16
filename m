Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827123;
	b=NGsGeDPwGA2sNn906cFZcVdLl+0SZsvBpOhAudKXzzjsjSIJNyBed4brND//YCvVX/Gs
	 QwvFCS0CZIkPG71k+2ZjpizsitjEJAFUzGNsVQwF2SIRzfQka2sHWDB35BOhBUelHuJUC
	 oA8BzMeBuZ813HjVw8Hn2AcARo7ZYAZ9pNtn8CgxMi4MjlXibF3W8CNjaAffBVNtG5K35
	 dMrS2fU0msDpHQSOG7Y8Dqd/5cGJi5A3dPtx+XTTlcMJRIJ8/xrJKb3d2pMnO27A8OFSN
	 s3vQhmy/ZaKSuVbifuuWnN5Tlwv2cJQtZnwT1c7i450uKnxTyy3rmougMjuAtWitVDg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827123;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=vlnGjiz0WitO6a++5wfKz3FIFE4QfP7og6wENObjkjQ=;
	b=SCd/TYkKe6CiNr1h/lpUg/SKtpUUQKnptq6CM1LiEerQ8c1rGk2cCnNveiu/Tq4I0fpO
	 gXuy5OrlvXa2PChKwTMO8PUcs6b1r86M3fCnw9jXGkXafopGm4kd7xQylan8wCQJB3vzG
	 kgrgaRlxnAhtDuSBjmKk6bAMqCEGMUzpGri/OA4mSu3/9cYkzvnA9lXUob1v+PQcwvFqe
	 aDZK5NhnqrjTC9Sc1jEtLrmDvBBnJyHylK100XhZuXHlti9/Iq2RJb8bEnEEB3JW5UUsC
	 jOYO+WViwnG/uJxO3GYYtccAZ0pln1ZnynnNgOB7S5JaL6XUQJ21VT2C54tL0tsXL8Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Kdh28b2u;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6715F606FEAE;
	Mon, 16 Nov 2026 11:05:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Kdh28b2u
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9EE001F000C8;
	Mon, 16 Nov 2026 11:05:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827123;
	bh=vlnGjiz0WitO6a++5wfKz3FIFE4QfP7og6wENObjkjQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Kdh28b2udiuoZvahWOKbTcq54DCpt3h5t8ExLilpPqtyX/5WyAekxbdCf/uw1aLh3
	 wrX+xVfd2cjX8BV0FYMz7vvaNw27klurDso8/rw1E0ggPWg6QrVEmm9yJ0pYFXPcfo
	 K2SfE3aFRJ92HhK5tgSGO8OQLAJb7JhNrIH2vit46k/PsSeLT8faE0iaLdMmev7cJU
	 8edF6r1Ip6VgOtMTcN+XEsv+eU5Us3+rEe/9ECrna83dAmIpG1u5yr25pXNKcuNNhR
	 aFlVE5w4qWjyarF1BzBUiUZTIW71T5/AuGEsXI+SeWkvtl/xNDHqoQx9chli0UScfs
	 X+HqfAVBrQ8sA==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:03:54 +0100
Subject: [PATCH v2 14/17] nfsd: take freeze protection for the truncate on
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
Message-Id: <20261116-work-fs-frozen_writes-v2-14-ecc4a2aac40e@kernel.org>
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
 "Christian Brauner (Amutable)" <brauner@kernel.org>, stable@vger.kernel.org
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1520; i=brauner@kernel.org;
 h=from:subject:message-id; bh=d7TUoTxYNm2vxq8SD7MXgIqBY32W95I8i/PEQ3ekloQ=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9eqzLaBI1W2q3a8PtvT8mzXTnPWq88hIj18m7QfuuX
 JD9qJjT0lHKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAnCTuRj+GfNo88tZ/T5sOHOf
 pYBAXehqIVP1HbG7zDzPm+85w7PjDMNfQU3mM4GXo3Tan//9eZKXqWKzSeLR0KkhFU+8D538deQ
 CBwA=
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

