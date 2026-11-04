Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793793377;
	b=pa4vMwl/twrNiMLk5jdvPsl+KJcoe91/i9iWKLG9wAhv1pO7hneg5hInZIwTyAi3babl
	 LsHOfp0qTtsMEk4Q2o/NgkmJNUofKjNGbuy3duUKZtgXuV9cJ28F0zm/ClkFCLw5bgm2x
	 0aXHH5tZhE4rUGEKgyIu0tc6aIW/3jz1p/uLBezX6LhSholqzAcqDntM1exaHUJnLDDoN
	 Qy6k41ZqE8SNRLL7EKQdcZJTQX1RZgUn9IyPiaTTiKEU7rfKq7tnNT7K/vw0GBp0Z9Pa5
	 6VhKk0+Sugb2l9+1jr4e1q07y9CtuK3FAyQCYFG8M0kdW7tWe1+IuYWq7azivxhuagA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793793377;
	h=Received:DKIM-Signature:Received:From:Date:Subject:MIME-Version:
	 Content-Type:Message-Id:References:In-Reply-To:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To:Content-Transfer-Encoding;
	bh=cwjArDsmrlzxv8HclYxai8UlPwGNSEHt8ZvB0WFdLkU=;
	b=eAp1+kFNq0lkgfW6fMiM0mspPb+Fe69cFm1DaWtOq0aM7QhYshrSmtqhS5Oo484H6VKB
	 +wkti5V1ybX0vpptMWivpiPs0GlEWD9Y4WkYDKcawzdgFkg6Ed4aSH40EWSdybM4SNu3V
	 AdGt6O4y0lRLG8Z4imswfKwHKJJ3bI7TvPmbdLgwIorABaTU5kNPRH3PKtnQCLCBBUWKg
	 iE9CA7Ty85eCh9xiYnAFrSddLWEUKI94TRzF8WJR0GSozm3eZOI+RtYWw8r3WzU1DKGPS
	 aHVjBg4DAT9YZpxTmb+FcVr36Mg5DOCirjkwlFSsX89qi5+MHEXamw5vMzty3kMW11g==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PVO3m4Gn;
	arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 92965606A32C;
	Wed,  4 Nov 2026 11:56:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PVO3m4Gn
Authentication-Results: smtp.kernel.org; arc=none smtp.remote-ip=100.80.115.77
ARC-Seal: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256; cv=none;
	t=1793793377;
	b=VD5GQDPlK2icfAgsZtg2FZ0e1M7kKxaarJEvI2Bdz6qXiLx/SKytZUEIPSkfBO7ct1qg
	 EXphj666H07v/va/IWxhQueOedhtZp56txl7p5nDUCJxcKyzNxwJV5h4/OOMrcptsqe5U
	 vmMmI/kd42EThvOVCo0xvChsYXh71LiX1m9B15aiOQmr7GBZ4oKAS/Cs51TfWDQFoTxLh
	 80wookEj87+mcS3sjg97hJlj22HcxmpOin+mdFCARlCN8P0INQozzUFlLPC5mlQUTDIEK
	 fsp+enMyOWObQWnWbkvpdly1Bt/GQkdD9rsSTtTX6quKsHjHt704pmJGLsTmicdHbmA==
ARC-Message-Signature: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256;
	c=relaxed/relaxed; t=1793793377;
	h=DKIM-Signature:Received:From:Date:Subject:MIME-Version:Content-Type:
	 Message-Id:References:In-Reply-To:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To:Content-Transfer-Encoding;
	bh=cwjArDsmrlzxv8HclYxai8UlPwGNSEHt8ZvB0WFdLkU=;
	b=Y3TGVEJqPSPUdNtzep/svxzBDc+5gvhiUwmqB1e59m7iy7ZJx0vFPZYhbfdq4NM719VF
	 8ZNEDcJa4p9CNViHLBNKxXoSPadgme7hveNfsqnTIlsgnuv+58EelVcCUxxkkNFpp5gcA
	 k/8JGOONYhcv0qicdqcWTfd786qdC1Fnb7rydloTHjVq9i2SLrha1xgyo6xZj25+Dzytd
	 b9G4ioMcYPFkDJbyvng3S7FEIYBrv9umao0o1TUrrfMyr4ZaP4ubjz4bK+Xh6b+RKpuHU
	 SOO1EKkabH9EeB4VxM4Ai87CixjCbLa5FdMSnjLOkl9KtM4oIVjQdr69J5Xt/KFXR3g==
ARC-Authentication-Results: i=1; smtp.kernel.org; 
	arc=none smtp.remote-ip=100.80.115.77
Received: from lkml.kernel.org (nexus.subspace.kernel.org [100.80.115.77])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.kernel.org (Postfix) with ESMTPS id 462CD1F00919;
	Wed,  4 Nov 2026 11:56:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793793377;
	bh=cwjArDsmrlzxv8HclYxai8UlPwGNSEHt8ZvB0WFdLkU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:Reply-To;
	b=PVO3m4GnkSHatao0Aqpnwb2/EsshhMl+eEVVf9r+Tld83KCOCacIKYBr4MDrFnP30
	 kzCW9/uq20P5d/X/CLcWVnm48KWNRWruVl33P8iEtFkJ1wt/cFg0jV7hZtzFcJkPSX
	 J6+EysMMIctuLHMIdz/VKQXmjycUkgHhFK6joxWWpZPnDnL63O6c9nafnEWWuTiFI8
	 yIROgpMHbHSV5MlKLzn4JHmrebmc3hibuu3xgiDMNXX6G+q+JPLjIwf7jeixhNk+UC
	 cyOualhJcs6z7kQiDnG55Xc26RPKh233hh7nPsVvp+fPR/DrlBrQ+/8LK8g0ivvMw7
	 d2tNFa0p9ubRw==
Received: from nexus.subspace.kernel.org (localhost [IPv6:::1])
	by lkml.kernel.org (Postfix) with ESMTP id A8EAD46DFB;
	Wed,  4 Nov 2026 11:56:15 +0000 (UTC)
From: orkunsari via B4 Relay <devnull+sariorkunemin.gmail.com@kernel.org>
Date: Wed, 04 Nov 2026 14:56:15 +0300
Subject: [PATCH 1/2] nfsd: unlock the locked parent after crossing a mount
 in CREATE
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
Message-Id: <20261104-nfsd-cross-mnt-v1-1-5ec5fca0a553@gmail.com>
References: <20261104-nfsd-cross-mnt-v1-0-5ec5fca0a553@gmail.com>
In-Reply-To: <20261104-nfsd-cross-mnt-v1-0-5ec5fca0a553@gmail.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 orkunsari <sariorkunemin@gmail.com>
X-Mailer: b4 0.16.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1793793374; l=4017;
 i=sariorkunemin@gmail.com; s=20261103; h=from:subject:message-id;
 bh=nmjbVfxD/SAnHRb/TsZON41UIu9qiDUdfa1MwQhC9uA=;
 b=3QjWHJ3TJ1bU3gFFVufK2ZH1N6D4mdafYiFxclfJcseLecUOAbufSi8HjsL19Ps93KTnCzYcH
 j45F3HOmc2nARigRDFO3C/M8kN8HsBk2n8X8GbHvJ3CxOqQlBGc7tl8
X-Developer-Key: i=sariorkunemin@gmail.com; a=ed25519;
 pk=MJ3Y3somkGDQVAXOSR189QAqWOcfzYCRkL1cSQgJXnE=
X-Endpoint-Received: by B4 Relay for sariorkunemin@gmail.com/20261103 with
 auth_id=1408
X-Original-From: orkunsari <sariorkunemin@gmail.com>
Reply-To: sariorkunemin@gmail.com
Content-Transfer-Encoding: 7bit

From: orkunsari <sariorkunemin@gmail.com>

Since commit f58a48389c14 ("nfsd: correctly handle CREATE of mounted-on
files"), nfsd_proc_create() and nfsd3_create_file() call
nfsd_cross_mnt() on the dentry returned by start_creating().  When the
name refers to a file that has something mounted on it,
nfsd_cross_mnt() replaces that dentry with the root of the mounted
filesystem and drops its reference to the original one.

The replacement is later passed to end_creating(), which unlocks the
d_parent of the dentry it is given.  That is the parent of the mount
source, not the directory start_creating() locked, so the directory
being created in is left locked and another directory's i_rwsem is
released without being held.

Do the crossing on a separate reference that is only used for
fh_compose(), so that the dentry returned by start_creating() is the
one passed to end_creating().  Only positive regular files are crossed,
so the later checks on the child dentry give the same result.

This was found by AI-assisted code review (Claude Code).  The fix has
been build-tested with W=1 only; no reproducer was run.

Fixes: f58a48389c14 ("nfsd: correctly handle CREATE of mounted-on files")
Signed-off-by: orkunsari <sariorkunemin@gmail.com>
---
 fs/nfsd/nfs3proc.c | 14 +++++++++++---
 fs/nfsd/nfsproc.c  | 14 +++++++++++---
 2 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 60cd01b6a3..0711e93c99 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -334,7 +334,7 @@ nfsd3_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		  struct svc_fh *resfhp, struct nfsd3_createargs *argp)
 {
 	struct iattr *iap = &argp->attrs;
-	struct dentry *parent, *child;
+	struct dentry *parent, *child, *mnt_child;
 	struct nfsd_attrs attrs = {
 		.na_iattr	= iap,
 	};
@@ -378,21 +378,29 @@ nfsd3_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	}
 
 	exp = exp_get(fhp->fh_export);
+	/*
+	 * Cross on a separate reference: child must remain the dentry
+	 * start_creating() returned so that end_creating() unlocks the
+	 * right directory.
+	 */
+	mnt_child = dget(child);
 	if (argp->createmode == NFS3_CREATE_UNCHECKED) {
 		/*
 		 * If name is already in dcache we need to check for mountpoints
 		 */
 		if (d_is_reg(child) &&
 		    unlikely(nfsd_mountpoint(child, exp))) {
-			status = nfsd_cross_mnt(rqstp, &child, &exp);
+			status = nfsd_cross_mnt(rqstp, &mnt_child, &exp);
 			if (status != nfs_ok) {
+				dput(mnt_child);
 				exp_put(exp);
 				goto out;
 			}
 		}
 	}
 
-	status = fh_compose(resfhp, exp, child, fhp);
+	status = fh_compose(resfhp, exp, mnt_child, fhp);
+	dput(mnt_child);
 	exp_put(exp);
 	if (status != nfs_ok)
 		goto out;
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 1f74008bc0..7da653bc0e 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -682,7 +682,7 @@ nfsd_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		.na_iattr	= attr,
 	};
 	struct svc_export *exp;
-	struct dentry *dchild;
+	struct dentry *dchild, *dmnt;
 	struct inode *inode;
 	int type, mode;
 	__be32 status;
@@ -709,16 +709,24 @@ nfsd_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	 * If name exists we need to check for mountpoints
 	 */
 	exp = exp_get(fhp->fh_export);
+	/*
+	 * Cross on a separate reference: dchild must remain the dentry
+	 * start_creating() returned so that end_creating() unlocks the
+	 * right directory.
+	 */
+	dmnt = dget(dchild);
 	if (d_is_reg(dchild) &&
 	    unlikely(nfsd_mountpoint(dchild, exp))) {
-		status = nfsd_cross_mnt(rqstp, &dchild, &exp);
+		status = nfsd_cross_mnt(rqstp, &dmnt, &exp);
 		if (status != nfs_ok) {
+			dput(dmnt);
 			exp_put(exp);
 			goto out;
 		}
 	}
 
-	status = fh_compose(resfhp, exp, dchild, fhp);
+	status = fh_compose(resfhp, exp, dmnt, fhp);
+	dput(dmnt);
 	exp_put(exp);
 	if (!status && d_really_is_negative(dchild))
 		status = nfserr_noent;

-- 
2.56.0


