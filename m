Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793793378;
	b=HJ08J3RLv8oix2Iwgs9aizhKeF6lqTe7NCrXehKjf1Ep6OLkijjiEkiXQPZ99pwnmuWV
	 Blz0cigj+MceaM1OeMyphfGgcRjgCBPN0UlyK7PzLnFPmySU4iSoPvRPWvOa5rJ3i4crQ
	 j2VfIErXnMSG93FFDUezxjJ2e3OkvQbZIxhcM2lXpNAilRcq5ABQqBbSHQCoJiS7PiFe+
	 IQ5ATaaQrf4gTdDxGKUCV3Bz6JARH5/9gKRnxqs2zcUUWDMeOG+Ux3zyTZYSYG4dltwbI
	 Orhc2qF6ClQJoXuUjNIouIkKLtH+bOOLgeLxM7DmjP3O+7cdcgoGoKmozfX84SqzXbw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793793378;
	h=Received:DKIM-Signature:Received:From:Date:Subject:MIME-Version:
	 Content-Type:Message-Id:References:In-Reply-To:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To:Content-Transfer-Encoding;
	bh=22hsY3mSlPmFJL5zvtz3fqQcrSsDAItDsPdBqGXiKRk=;
	b=mSgYNP7d5G32vx47CKCVUJ2cRz/gvnZ+nZWr8ETxVyjZzmAj/XYnzpnCivGRs44F0v5b
	 aa/9oolPKA9PDWGPGq0o352Dd55K4ivJ3tYqb73iha+QLMjmIw/sDx6g+DabS4gBqWljQ
	 8X+b/Yl5QPujXgIdAlB9m5M6DAmAc8y0bHNum+2N+qnH3rV+gaAFlfQsdF2dVN4bpdjrU
	 8DOcPnfRh8OcmvRVfszAn1T2G26I3HsPG+a4lDPzDh9Eyw0+Ik3e95rf89GIcbDGx3QIW
	 jXjW+8U9YZ3aP0z1WfHGiuunu/TKuuG42iWvBtUIvhH7W0RhXtXwB6cva8JWWXTh6Og==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KkVDl1GA;
	arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B8D1F606A32E;
	Wed,  4 Nov 2026 11:56:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KkVDl1GA
Authentication-Results: smtp.kernel.org; arc=none smtp.remote-ip=100.80.115.77
ARC-Seal: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256; cv=none;
	t=1793793377;
	b=ZqXDA5Ytc0+JruPm/CzL2pzYlqkw7xevCfy9tCyewbPOA0GSMHBtsT/jEbon8gMhRvuG
	 oigvWREpwtcUdkWs1sYjI7FyAV8Ee7vXjyCE3Fg0mXhiDRGBI9HE1hStoLSMeiDU6JtO3
	 W0dRAifnulGgQjzcBXA9p/hj0jh2yOEINFsQjSvVIfApJ5N6II6brgoILnL9cLIHLKGJ2
	 gZ5kqkjSI0x7oMvjpDqa2hXM1Q3svlB5SZDG+GkN2zM7y5sZ32cbjsuBb/KOnOuOsDN+t
	 xpLFX/28V5a6nv/yhzPJpkuYg47+HjvZ8EKTmEsQ4znXwpwBxmLYw2y1yUD8fyk0SHg==
ARC-Message-Signature: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256;
	c=relaxed/relaxed; t=1793793377;
	h=DKIM-Signature:Received:From:Date:Subject:MIME-Version:Content-Type:
	 Message-Id:References:In-Reply-To:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To:Content-Transfer-Encoding;
	bh=22hsY3mSlPmFJL5zvtz3fqQcrSsDAItDsPdBqGXiKRk=;
	b=WdhMrJF93iy+e7Ur6IiOr24sE0EIUpYpNU/Ov9H4G47NWQWwfF2kOKqAANYAIUoXbb+y
	 AUImwztrU5Y35Czjkq+jRKLFNijV4pl5YB/XcJiCPpG9cSfjXYHKfIXPk8w0go3Q8ZZgH
	 1pwAJeJFIxekXSQccppbM+7vAHHyC1jf8kN76+ANqFLI5D0M52kuSItUlGcGXHESFH8Sa
	 oVjwUolz6Bdu1r0/82X+gWmgTiqKiwyVYS8mx8HP5FTGSGeokWjuyKWQ2B5pOR43nAUkn
	 kf6aDTdfTKR7xf87vA+mLCNp4xbHFYR5SYYeE5g0ylPxZe86rYo5vfN0P5EliVeYZ7g==
ARC-Authentication-Results: i=1; smtp.kernel.org; 
	arc=none smtp.remote-ip=100.80.115.77
Received: from lkml.kernel.org (nexus.subspace.kernel.org [100.80.115.77])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.kernel.org (Postfix) with ESMTPS id 4630C1F0093A;
	Wed,  4 Nov 2026 11:56:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793793377;
	bh=22hsY3mSlPmFJL5zvtz3fqQcrSsDAItDsPdBqGXiKRk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:Reply-To;
	b=KkVDl1GAKw0B9iNSHmTVJu7yt6rwyil+K22E+HDGROdR2GRYVwisJyW3jiCAijSlJ
	 YR2iujFfq6MZ5FoasscSXm10Gvs2aMvVP3HlvQhORZaXiFtyC8HKPPi4w1iWeQq5mr
	 JQ63QHT5Y/bp1ObF5gsJlO8dWoNCfQ1/sP/X3vNe+PCR92+DkfEcE/C5Z6MA2oOJ2o
	 aHEkVDVhs4U4tCgVTk5W0Z0IJi1BNpyhP9d9Q7fJCPn9m/KnO1jAf/Si7V72xQXypJ
	 LBe2E8lS3tdZ2KLUYJXEavOaXoI8khIflhkSZqX9cv0EbGJXDpSrEaBu/Koqi/OLm9
	 1LYK1HA4FXoOQ==
Received: from nexus.subspace.kernel.org (localhost [IPv6:::1])
	by lkml.kernel.org (Postfix) with ESMTP id BB72E46E06;
	Wed,  4 Nov 2026 11:56:15 +0000 (UTC)
From: orkunsari via B4 Relay <devnull+sariorkunemin.gmail.com@kernel.org>
Date: Wed, 04 Nov 2026 14:56:16 +0300
Subject: [PATCH 2/2] nfsd: check access to the export being entered when
 crossing mounts
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
Message-Id: <20261104-nfsd-cross-mnt-v1-2-5ec5fca0a553@gmail.com>
References: <20261104-nfsd-cross-mnt-v1-0-5ec5fca0a553@gmail.com>
In-Reply-To: <20261104-nfsd-cross-mnt-v1-0-5ec5fca0a553@gmail.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 orkunsari <sariorkunemin@gmail.com>
X-Mailer: b4 0.16.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1793793374; l=4976;
 i=sariorkunemin@gmail.com; s=20261103; h=from:subject:message-id;
 bh=JlWr15lM/B/AmdFzx3FSapRze7rNKJEt/9Zsci6sgU0=;
 b=YJyABjfSPK9rruPjbLFt30iEZsCIOr0gOH9Qzat7to+VEsfM3NIvmIF/FHx+KujSavlypCIq2
 6fSTm6RDwq3DHf2hEVfxGKU7AhbowuxcpBT5TNqI/dWOI/wk3yKWGOv
X-Developer-Key: i=sariorkunemin@gmail.com; a=ed25519;
 pk=MJ3Y3somkGDQVAXOSR189QAqWOcfzYCRkL1cSQgJXnE=
X-Endpoint-Received: by B4 Relay for sariorkunemin@gmail.com/20261103 with
 auth_id=1408
X-Original-From: orkunsari <sariorkunemin@gmail.com>
Reply-To: sariorkunemin@gmail.com
Content-Transfer-Encoding: 7bit

From: orkunsari <sariorkunemin@gmail.com>

Commit f0d6ad5a2f67 ("nfsd: move check_nfsd_access() call into
nfsd_cross_mnt()") moved the check_nfsd_access() calls from
nfsd_lookup() and the NFSv4 READDIR encoder into nfsd_cross_mnt().  The
moved call checks @exp, the export being left, which the caller has
already verified, rather than @exp2, the export being entered.  The
sec= and xprtsec= settings of a crossmnt/nohide child export are
therefore no longer applied when LOOKUP or READDIR returns its root
filehandle and attributes.  Later operations on that filehandle are
still checked by fh_verify().

The same commit also removed the check that nfsd_lookup() applied after
a ".." lookup steps up into a parent export via nfsd_lookup_parent().

Simply checking @exp2 instead is not enough: nfsd_lookup_dentry() also
serves SECINFO, which must not fail with NFS4ERR_WRONGSEC (RFC 8881,
section 2.6.3.1.1.5) and did not check the target export before.

Split the crossing into __nfsd_cross_mnt(), which checks @exp2 before
switching to it only when asked to.  nfsd_cross_mnt() keeps checking,
for READDIR and the CREATE paths, while nfsd_lookup_dentry() does not.
nfsd_lookup() checks the resulting export whenever it differs from the
directory's, which covers both mount crossings and "..", as it did
before.

This was found by AI-assisted code review (Claude Code).  The fix has
been build-tested with W=1 only; no reproducer was run.

Fixes: f0d6ad5a2f67 ("nfsd: move check_nfsd_access() call into nfsd_cross_mnt()")
Signed-off-by: orkunsari <sariorkunemin@gmail.com>
---
 fs/nfsd/vfs.c | 46 +++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 39 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 56c49b5bc5..2df2df5aaf 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -120,14 +120,16 @@ nfserrno(int errno)
 }
 
 /*
- * Called from nfsd_lookup and encode_dirent. Check if we have crossed
- * a mount point.
+ * Check if we have crossed a mount point.  If @check_access is set, the
+ * export being entered must also pass check_nfsd_access().
+ * nfsd_lookup_dentry() passes false, as it also serves SECINFO; its
+ * other users check the resulting export themselves.
  * Returns an nfs error leaving *dpp and *expp unchanged,
  *  or nfs_ok having possibly changed *dpp and *expp
  */
-__be32
-nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
-	       struct svc_export **expp)
+static __be32
+__nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
+		 struct svc_export **expp, bool check_access)
 {
 	struct svc_export *exp = *expp, *exp2 = NULL;
 	struct dentry *dentry = *dpp;
@@ -165,7 +167,8 @@ nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
 			err = 0;
 	} else if (nfsd_v4client(rqstp) ||
 		(exp->ex_flags & NFSEXP_CROSSMOUNT) || EX_NOHIDE(exp2)) {
-		nfserr = check_nfsd_access(exp, rqstp);
+		if (check_access)
+			nfserr = check_nfsd_access(exp2, rqstp);
 		if (nfserr == nfs_ok) {
 			/* successfully crossed mount point */
 			/*
@@ -189,6 +192,20 @@ nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
 	return nfserrno(err);
 }
 
+/*
+ * Called from encode_dirent and the CREATE procedures. Check if we have
+ * crossed a mount point, and if so whether the client may access the
+ * export being entered.
+ * Returns an nfs error leaving *dpp and *expp unchanged,
+ *  or nfs_ok having possibly changed *dpp and *expp
+ */
+__be32
+nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
+	       struct svc_export **expp)
+{
+	return __nfsd_cross_mnt(rqstp, dpp, expp, true);
+}
+
 static void follow_to_parent(struct path *path)
 {
 	struct dentry *dp;
@@ -284,7 +301,12 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		if (IS_ERR(dentry))
 			goto out_nfserr;
 		if (nfsd_mountpoint(dentry, exp)) {
-			__be32 nfserr = nfsd_cross_mnt(rqstp, &dentry, &exp);
+			/*
+			 * Access to the new export is checked by the caller
+			 * where needed; SECINFO must not fail with WRONGSEC.
+			 */
+			__be32 nfserr = __nfsd_cross_mnt(rqstp, &dentry, &exp,
+							 false);
 
 			if (nfserr) {
 				dput(dentry);
@@ -336,6 +358,15 @@ nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp, const char *name,
 	err = nfsd_lookup_dentry(rqstp, fhp, name, len, &exp, &dentry);
 	if (err)
 		return err;
+	/*
+	 * The lookup may have crossed into another export, either down
+	 * through a mount point or up through "..".
+	 */
+	if (exp != fhp->fh_export) {
+		err = check_nfsd_access(exp, rqstp);
+		if (err)
+			goto out;
+	}
 	/*
 	 * Note: we compose the file handle now, but as the
 	 * dentry may be negative, it may need to be updated.
@@ -344,6 +375,7 @@ nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp, const char *name,
 	if (!err && d_really_is_negative(dentry))
 		err = nfserr_noent;
 
+out:
 	dput(dentry);
 	exp_put(exp);
 	return err;

-- 
2.56.0


