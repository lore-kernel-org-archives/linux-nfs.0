Received: from fout-a7-smtp.messagingengine.com (fout-a7-smtp.messagingengine.com [103.168.172.150])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 026074CCDCB
	for <linux-nfs@vger.kernel.org>; Wed,  2 Sep 2026 02:30:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.150
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788316231; cv=none; b=M1bAQDN/tIFmpDPlTayFO5RL8gRTOuc2eZsBPEfo19uNUHLPTNPuKL36CRTQOKGPLrkZ/aYRWzhYTh3YGmnJTU1QScjXd1rl/I+oGok/CCmZnNVgaxOQOI68fEn7D0KIX4LcD+SgqphKNNaA2WL8fgjjx3tlB12/CeTcrlAZ4Ps=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788316231; c=relaxed/simple;
	bh=muOREQ+5A+ilMynZ+u+oeab9qjVmEm2Vsu24kjnDrFs=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:Date:Message-id; b=O5Ss5juyyxsBqoENZl8ID7QxD8ix9L72h8au19ZBl41anZnwCJPWy5duVDoAF7FJbZiWA2z7YuHtoIQQwC9685qB4DtaWndQ62x+hIHZ2qEBJzvKMHblhgL2eOOkF8UMaUN9VG5Cajy8X8TBF/TQFk5oFREtikXhUEKHFcm9dgU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Sgu0/8ze; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=VT1uUdSG; arc=none smtp.client-ip=103.168.172.150
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Sgu0/8ze";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="VT1uUdSG"
Received: from phl-compute-08.internal (phl-compute-08.internal [10.202.2.48])
	by mailfout.phl.internal (Postfix) with ESMTP id 08CC0EC020B;
	Tue,  1 Sep 2026 22:30:29 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-08.internal (MEProxy); Tue, 01 Sep 2026 22:30:29 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:message-id:mime-version:reply-to
	:reply-to:subject:subject:to:to; s=fm3; t=1788316229; x=
	1788402629; bh=uiYDHT0Gqvo9azmP6+UdAMWS9V0Exa1/ScLBMczyAuM=; b=S
	gu0/8zeFbjZ9Zh1Cv2Bw4wOtqC+TmwoCWdlLsWpem//KYO0IVtYOTyylUjdD/dsX
	24S0BBvlIrNwtSoxMGltZHEY2gorjOhvByBCePXCddi800x5zb7txBen839i9f9C
	CBba9D/Dlm5sz3BCwPRCv6UUD059gPtY50Ec4xC+25EyOWElImIxMdMho5AwtM88
	ANlgeZPvQUbOYO16XhntExvtQNKB1fRgmKgt3wQwenaw1ScJOmrBdlgpfVq/RuV6
	Bm5U9746j845yvOLAAoaZ5mSOQyS8KyZgISKVdDoT8UvuKNpFyEQddk2kHNHfE7n
	obNV6YpF6mMJ0bq/EZ0yg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:message-id:mime-version:reply-to:reply-to
	:subject:subject:to:to:x-me-proxy:x-me-sender:x-me-sender
	:x-sasl-enc; s=fm3; t=1788316229; x=1788402629; bh=uiYDHT0Gqvo9a
	zmP6+UdAMWS9V0Exa1/ScLBMczyAuM=; b=VT1uUdSGb0sf52vylUforjy7JHB3h
	mOUaLJNpgdQO2fdq8A2GD9/XR/2dok+Cy0O/7gde9dCWxb6ta9mBDemJxWs385QR
	pquKFwz4RXlHjLx5l0oTxOcCFfbKlGInPFC0n3X/6dxYadsMKdAakg7NrSdAW0zM
	bM4xefAJfWwwRDhUarNWzNa5+tDRXsg8rW4LqjeK/WZvWdEY9oT7xT1e2XrMo65y
	15VJstPU44tOXr8gn3We60A79WhGISy7WtMbK6WXWxH4o9HoEgJQZhnXDtGsYZVa
	ZbpJoSPTLyGeSDXuyFVgmlDpGp7ppnwC12jvmeG27ca7I5BvMQpBXPRzA==
X-ME-Sender: <xms:RIqXajAsHJUUCN2-SCcCdhk3kHXPSJCddhs-aHQ5qlAE2eqoxiIwRg>
    <xme:RIqXagixIIyx1mGhtNlWGXdWvQDrHTGXPgVvWibYPiV0TLVV0t31En5OdsItEi5bb
    199W_belxOMcq0T07mE9erEUL5Gt4OyskC97VF1kLgc1NJrWME>
X-ME-Received: <xmr:RIqXajmeQppXMl7pWWbsAUFRKvsP0p2oi3Edj-TDOiW5MyAVLHmbAOx20n9qWjitcXLeGbgiMd0gPMUaSAI-gBQKd6O3unw>
X-ME-Proxy-Cause: dmFkZTEOH6bpbVKuWc3BreFUInpiM+mNaeT2ZppVElD59HjaIrEpJRAn+Zw1v9MycYV8lf
    IxT9TWq1hvQ8AoKmHt/65UIQAh7WX4nu4TePq5xeVNaWiTeZOfyLVv2eqaA7ciEImM6Mjm
    t50L0oa8LwX1ZQQucZxZyoUSdefAdzylC+rI5nTJYrrcvv9shHmSndA/Ce7rboPTF4edzu
    AWw9eLEaqnwYSkWWaFl9UxwlLT/hzLIQt4NUe4H6tjqPsOVosFPxyHh8J81FUbnpbKfnfN
    lC6twX01lYTMR4aeRIFKO8bBNpdJkJr62FdMCpC2sfH7ZJ1ISkTuRdUxU9417yBem5eLBg
    I6YDd0zs6HpoIpU3oSjF0ZenuTYZfVjjtLFyPmFLje1KpTcsq+2llL5pvNnyjUSrjtq6ow
    hg+qlmpUtBWQC49o/z7ObuzcRsSWWa74zlPtuDP7Js/ln5do1ey6Xl7Ja0k4QG+5QMf+iu
    5xyCCMZIQMPbmsBfvbcuXAPMznAf5uRcqFEsl/E/OJFhST0zlZEikfcxXqVcYzQHRJ6K5R
    ZlavfcN9sRKeLMAck7Mc6n4b5xs0Am29E4juBQzSsGtOL7H/Tl9tXXruwjytGNjaXdarav
    1Ux3lq5xeKBGp1ALYTiIvwMDKlbvW4HmiNaIMgeLFnyEZrPXag5KCtln+9fA
X-ME-Proxy: <xmx:RIqXakqiMKxboaPHjXXNCMcp1QrleWf-9DsaMjdcpScNN2qbqNBA1w>
    <xmx:RIqXakHL_HfTPMBb3s28PuukeBKHan2kOzX3JaQGwZLi3dhd384WSA>
    <xmx:RIqXaow-wUFa3z_WvBRUC5_PK0xlfmZzA4Uj8T3v4IezbT7nYbFrGg>
    <xmx:RIqXahp9dDZCEagtyS-0GBLFsAQFOe4kUOuVwtbwGHRmKhZdiBPTLA>
    <xmx:RYqXaitIWir92nYIxUAOMz_Y5i4y3Ssq3uE2abgwmPzVonF3v71KKWOK>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 1 Sep 2026 22:30:27 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>, Jeff Layton <jlayton@kernel.org>
Cc: Christian Brauner <brauner@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: switch nfsd4_open() to use vfs_lookup_open()
Date: Wed, 02 Sep 2026 12:30:23 +1000
Message-id: <178831622346.3510150.10735958308429473076@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>


From: NeilBrown <neil@brown.name>

The functionality that was recently gathered into do_lookup_open() is
now available from the vfs as vfs_lookup_open().

This implementation shares more code with syscall open paths and so uses
some filesystem interfaces slightly more correctly.  It also takes the
responsibility for locking out of nfsd so that planned changes can
happen entirely in VFS code.

One difference is that do_lookup_open() would use nfsd_check_obj_isreg()
to get an error when the name exists but is not a regular file.
vfs_lookup_open() uses slightly different error code, particularly
returning -ENODEV when a device-special file is found.  So we need
to map that error to -EFTYPE.

Unfortunately vfs_lookup_open() doesn't allow O_LARGEFILE so we need
to patch it to avoid a warning.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/namei.c         |  2 +-
 fs/nfsd/nfs4proc.c | 66 ++++++++++------------------------------------
 2 files changed, 15 insertions(+), 53 deletions(-)

This patch is against nfsd-test.  I would like it to land there so it
best good nfsd testing over the coming weeks.
Thanks,
NeilBrown


diff --git a/fs/namei.c b/fs/namei.c
index d95249dd527c..85fd5e8221e2 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -4632,7 +4632,7 @@ struct file *vfs_lookup_open(struct path *parent, struc=
t qstr *last,
 	int error =3D 0;
=20
 	WARN_ONCE(mode & ~S_IALLUGO, "mode must only have permission bits");
-	WARN_ONCE(open_flag & ~(O_ACCMODE|O_CREAT|O_EXCL|O_TRUNC|__O_REGULAR),
+	WARN_ONCE(open_flag & ~(O_ACCMODE|O_CREAT|O_EXCL|O_TRUNC|__O_REGULAR|O_LARG=
EFILE),
 		  "open_flag has unsupported flags");
=20
 	mode |=3D S_IFREG;
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 33dc92d48ce0..ae70f7489d95 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -213,52 +213,6 @@ static inline bool nfsd4_create_is_exclusive(int createm=
ode)
 		createmode =3D=3D NFS4_CREATE_EXCLUSIVE4_1;
 }
=20
-static struct file *do_lookup_open(struct path *parent,
-				   struct qstr *name,
-				   unsigned int oflags,
-				   umode_t mode)
-{
-	struct file *filp =3D NULL;
-	struct path path;
-	struct dentry *child;
-	int want_write_err =3D 0;
-
-	want_write_err =3D mnt_want_write(parent->mnt);
-
-	child =3D start_creating(&nop_mnt_idmap, parent->dentry, name);
-	if (IS_ERR(child)) {
-		filp =3D ERR_CAST(child);
-		goto out;
-	}
-	path.mnt =3D parent->mnt;
-	path.dentry =3D child;
-
-	if (d_really_is_positive(child)) {
-		/*
-		 * open the file so that we consistently have a valid
-		 * op_filp and consequently a valid ->f_path.dentry.
-		 */
-		int err =3D nfsd_check_obj_isreg(child);
-
-		if (err)
-			filp =3D ERR_PTR(err);
-		else
-			filp =3D dentry_open(&path, oflags, current_cred());
-	} else if (!(oflags & O_CREAT)) {
-		filp =3D ERR_PTR(-ENOENT);
-	} else if (want_write_err) {
-		filp =3D ERR_PTR(want_write_err);
-	} else {
-		filp =3D dentry_create(&path, oflags, mode, current_cred());
-		child =3D path.dentry;
-	}
-	end_creating(child);
-out:
-	if (!want_write_err)
-		mnt_drop_write(parent->mnt);
-	return filp;
-}
-
 /*
  * Implement NFSv4's unchecked, guarded, and exclusive create
  * semantics for regular files. Open state for this new file is
@@ -390,13 +344,21 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh=
 *fhp,
 		/* Might still succeed if no create is needed */
 		oflags &=3D ~O_CREAT;
=20
-	open->op_filp =3D do_lookup_open(&parent,
-				       &QSTR_LEN(open->op_fname,
-						 open->op_fnamelen),
-				       oflags,
-				       open->op_iattr.ia_mode);
+	open->op_filp =3D vfs_lookup_open(&parent,
+					&QSTR_LEN(open->op_fname,
+						  open->op_fnamelen),
+					oflags,
+					open->op_iattr.ia_mode);
 	if (IS_ERR(open->op_filp)) {
-		status =3D nfserrno(PTR_ERR(open->op_filp));
+		int hosterr =3D PTR_ERR(open->op_filp);
+
+		/*
+		 * NFS doesn't differentiate between device files and
+		 * sock/fifo when reporting an error.
+		 */
+		if (hosterr =3D=3D -ENODEV)
+			hosterr =3D -EFTYPE;
+		status =3D nfserrno(hosterr);
 		open->op_filp =3D NULL;
 		if (status =3D=3D nfserr_noent && create_status)
 			status =3D create_status;

base-commit: f5dc2038906bb0c9627c99bea06dd7786b5ac2d1
--=20
2.50.0.107.gf914562f5916.dirty

