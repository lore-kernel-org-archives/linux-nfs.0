Received: from fout-a2-smtp.messagingengine.com (fout-a2-smtp.messagingengine.com [103.168.172.145])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7CFFF3BE635
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 09:30:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.145
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784280660; cv=none; b=DGeWTUK8FyEu1W7gpQbOa9yBSK84A87h2wu6xjGoRh08tgE2Ena1OWoES0n6qndr/glHvkViNgZOf5RHE+xIjZk7SiScVTjfD2bFQVpLeqdrclRoXXoVJ6hzznp79G0zZIWkNDq5MWp6JJnwJPS3O4Qj1CRLQCVAHGSinJMvII4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784280660; c=relaxed/simple;
	bh=UVw52gCzKon6IbZGeD6X/feiToU4aAcqlzjlnr+cNKc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=uXJxjXi8wGwxeD0tfkjYlAomUjbFGOfD12R7nM8Z8X/DO1oV6gDHLGfC9FfThhWeeb/SexDuuM16UuI5/vZ0ok6pRK8eZjCw/B0YnndkyCFZ6+orw5o8oJ8MsmS6L2RxUUxCdRxY/DrcqZqJPQwSSNNWcQ2abX5lonNppXfueCk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=PKmW+yXH; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=VG7QtDIe; arc=none smtp.client-ip=103.168.172.145
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="PKmW+yXH";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="VG7QtDIe"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfout.phl.internal (Postfix) with ESMTP id B2415EC0101;
	Fri, 17 Jul 2026 05:30:58 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Fri, 17 Jul 2026 05:30:58 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784280658;
	 x=1784367058; bh=ADUn0PC5CG/DLUIL0eBM1CneE2bcs2zv8ljGeSAPpNQ=; b=
	PKmW+yXHVLu383uT3toRg08A6kV3DwSR6tKu9cpCBEjI5LARV64KmlMXCt+qClAP
	3EyJF+nvSYwb0SxG4jS0OoYPhD52xknFVHPkjfYm/uzg2Qdjiz7KwXDeOM3B8U9U
	G0QP8gt/bhQFOtYCFpIEpFyTixKia834KWfLuyKBeX911cX93lumRhzto9dqFrXf
	eEGJvAioP8XhnwCd6q9CBQ0LQRYUAbkTlmsKA26YIsH1gDuKVj6Bic51EJPsq+49
	NCyXYqDZyoTWL6EltvyliWSykGkxSKex9nf2yX4scx4ObnJ962snhlh5jIIF2tXk
	W6MrX4Q6gshgu24jlsdN2w==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784280658; x=1784367058; bh=A
	DUn0PC5CG/DLUIL0eBM1CneE2bcs2zv8ljGeSAPpNQ=; b=VG7QtDIeATxmO5ncg
	qFodzM78C0jxxLM00Pd6mKTtgO6Hu1R6OrNYb5aRI52bYtwth0+zi/V9V+NvmPLA
	DhJv0XF9rzycMz9OEmvy+8YmrQzoVUHycHFV2qbFSNVE6rpOfjXfELgmBmz1dIzD
	V+X5gQvth3kphgc4RugQJmZ072QU3BtlvN8j83zRZAFTLHF56vcmS06n0LQQ5e8l
	X3Hvh8aYy8HoZ4OYRkm3oas5RLQQDuKGKlDcyUUVeyNQxl4li8x0meFn2ueC/DPg
	1gkVqYTH+JH8l9Wpcx5GbkqwK50HnJz7k+5e1DX/yZAEViTVcYtDQ6q9e/YFfUS6
	0nWew==
X-ME-Sender: <xms:UvZZalFkSyPTlNlAOs8yjJM0U38OPcrtfDgV8ySAyuf0LyqnKEr17w>
    <xme:UvZZauC9V3Mc1gH44J8p05lczVZcrzNRJKkPjO6js-pdpo8ryEkyyyY4qifo7StAs
    mpIiuUT6ucueZGjxDuTWYjXxMx8c2rjd-rO_jrEHVTvjKm77A>
X-ME-Received: <xmr:UvZZag9zNoTzU7cS5l7J8k41p_wSK_m1Z81zt4j-YOkRzcj9oqGuokmNXdmQrHBA-F2nVj79e3pVIUNadV5y_JG2nWXsCEM>
X-ME-Proxy-Cause: dmFkZTFt/ltHQiQnjOnec5Xwf7HAyfv/h6swQd9Lp4S8lAVdynG6lr/bMlDadX3a6MZaNI
    xARu8dwnt5/EKu9g11Xxlo5cFffflZKrI1fbT4sSobshHOocQ5fK7d3tI7rh7yGEguG5js
    SqTubOs7Q1Ji7gqDKvmCOslN+YMh5QmMGMkgdI4Rh10FgF7mn0JKW4SNmo14KiFpivov8C
    +UzA+fJ2Fmt2HPUW8tILOaqDOjiyN/I09G9/CmpiIJyiNHUxhCdpGgyFgzGgqafrlcFmsv
    RKOGDGknxA+ctU9mmjkFL44NELF9JXjKsTr1S+qon4sfNZpuA7EeL1QNk0SIiYNxaEpgHf
    TGDTtDInjMBBhXVGQZlTaXjZ5HKK7bLPJADFoPe4/ZkbfdkL0luZLa5jauIl7XEzKzxhEB
    TkTT4h/SOlYLisE+LqtSU3uanriB2rugBHbEYMFqUx1lF0GiVdYOmQ2KA8ByUNuy2k8S2F
    aaCkZhAsMdNFni0w5ZOyaZpCxFU11mMNzr/ksA/I5ng7da9NqzmZhJmkowK/83dEztExOk
    7KcA8qsg9LA9ORHas6bIxbQdMHPMVmZ5Qib5yGqx6XLWSVkM7HA860LoiedJ4JHHZQclLX
    nKZyC40cqzSitU57zikHMJnQBWFbQu/yIJghJACEl3aRclRfGmXbTUYMWu6Q
X-ME-Proxy: <xmx:UvZZaiDnTy6IFLlQHPQ5E_YfVnXHeuBQOpMiXd1eHX2ry4vP9bYRzQ>
    <xmx:UvZZatT3obnW8yaG9__Ul6dGih_ak7WEH2kfPSAmTS0qVnkjprU4RA>
    <xmx:UvZZahscP23h-Dx_JUlQHN3eJ5NNRkmn_c57kPcq5ZCKRkSQecokjQ>
    <xmx:UvZZah2wC5ho6dqNtv8mFh_ztqF4tyMSwUBnOz2e7YSW2mRk5B0FjA>
    <xmx:UvZZaqlkTFTx4alCnAOue8v0v01iQn7mIXbzEuQwLdE1xkGFEcm613kR>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 05:30:56 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 10/18] nfsd: fh_want_write) failure need not be immediately fatal for  nfsd4_create_file()
Date: Fri, 17 Jul 2026 19:27:58 +1000
Message-ID: <20260717093001.1972119-11-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260717093001.1972119-1-neilb@ownmail.net>
References: <20260717093001.1972119-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

If nfsd4_create_file() is asked to create a file, then failure to get
write access to the mount need not be fatal if the file already exists.
So we can delay handling the error until it is known if creation was
needed, just like with the error from testing for write permission in
parent.

This is similar to want_write error handling in lookup_open() in
fs/namei.c.

Note that getting mnt write access to support O_RDWR is handled
separately in do_dentry_open(), and op_truncate is handled in
do_open_permission(), so  nfsd doesn't need to be concerned
with these.  It only needs to be concerned with creation, and setattr.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 5e56bf6e6bd9..a4838d36885b 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -262,7 +262,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	__u32 v_mtime, v_atime;
 	struct inode *inode;
 	__be32 status, create_status;
-	int host_err;
+	int want_write_err;
 
 	if (name_is_dot_dotdot(open->op_fname, open->op_fnamelen))
 		return nfserr_exist;
@@ -349,11 +349,10 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	create_status = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
 
-	host_err = fh_want_write(fhp);
-	if (host_err) {
-		status = nfserrno(host_err);
-		goto out_free;
-	}
+	want_write_err = fh_want_write(fhp);
+	if (want_write_err)
+		/* Might still succeed if no create is needed */
+		create_status = nfserrno(want_write_err);
 
 	child = start_creating(&nop_mnt_idmap, parent,
 			       &QSTR_LEN(open->op_fname, open->op_fnamelen));
@@ -424,8 +423,8 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		open->op_bmval[2] &= ~FATTR4_WORD2_POSIX_ACCESS_ACL;
 out:
 	end_creating(child);
-	fh_drop_write(fhp);
-out_free:
+	if (!want_write_err)
+		fh_drop_write(fhp);
 	nfsd_attrs_free(&attrs);
 	return status;
 }
-- 
2.50.0.107.gf914562f5916.dirty

