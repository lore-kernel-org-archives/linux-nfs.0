Received: from fout-b3-smtp.messagingengine.com (fout-b3-smtp.messagingengine.com [202.12.124.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 00CD829408;
	Sat, 19 Sep 2026 02:27:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789784827; cv=none; b=B7e7i0isUYb4kPMRF57POtGVLK/BtNt5U3B8lFb1X31d8SXJ8Z3fMehgEX6aityX4ZOgnrGnqXp6xHR1Ox+Ctskc2TIFrQiQKV5M7h75hbFPmxc4EC9VulSUBZ4u0vY3SV4qv7muoaBrrgw5vDvtj4XJOEsEFVkMszsit4alhI0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789784827; c=relaxed/simple;
	bh=s6cayByBblZbIUGBUY15grr/HNZ4HSwkyOWYKJd+0hc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=qU453jiSQ/5aIJ+3Fpo7IDU07ImbQxr++vfXhutxnWwwQohpYZVvdYrNvNqFmqaC8iBzNUJNS/nVAGBMnt/XwHGevkeV8N0jS+nxO8n7jlNNcyQHhYSxQNyqjBzJyDjsUg3vqXevi1ZAR/BcmrwhVfTfUziid/wlbXiM/kzfvC8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=bfewcsEI; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=JgSvn6Ud; arc=none smtp.client-ip=202.12.124.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="bfewcsEI";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="JgSvn6Ud"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfout.stl.internal (Postfix) with ESMTP id D5B001D000F0;
	Fri, 18 Sep 2026 22:27:04 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Fri, 18 Sep 2026 22:27:05 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1789784824;
	 x=1789871224; bh=akLwUn1lvreeYgo58yx0OnGAqD6FE0lkcCMJqjJSHyQ=; b=
	bfewcsEIcnNsLPlh7kalv2o2/V+xdcsGXojQ6t0jQf2cnL0SlKZyRCC2FfpmmIBG
	H9GioP1Zy8pcw9fAIZkiG56WMfJMrtJsjEyv9zaFrx9S6UC7T3rCHoP+2df+NuI1
	vC8VTEP6b7ssCKg1hLKYABRf9E6KMtJKqL75YdZIU+aGV87rK9kxZhF8IkSuY0+E
	DchQNjxQnKagJknynU8GJZczsH0T0u0KBchEPKcd4P7r4G/9Wx0fJahaeSHPDPqd
	q3X6+YiBVR0j8hqyhNNWCpOlzPvN03JJW7B2aodUL+R8JeUEAvIaS7awkR3NmRPW
	Y34gqan57VXZb1qfElnFWg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1789784824; x=1789871224; bh=a
	kLwUn1lvreeYgo58yx0OnGAqD6FE0lkcCMJqjJSHyQ=; b=JgSvn6Udt0ZFSFx1U
	F4+xjWYa2Ggo3p+dx+BxVFWvN89rt8uhjoMLhikUmbe6SKcYqwUSs5MnmVipmyDx
	iTqORkbBQPlLBaff6WxYJtOwekR+ufXHgbFQXn3jjU7CLqyI/VUjVZNHS48kefM5
	CzA26nN9SkaVoK5tCNS5IPl/fsQbNQ7cN/+hD5XXErVh/kr7yt1Lu1Zxf//rAYxd
	Q3HLLnbR+NypDXX1Nz6M/eMG6LTD7d1lYFB1ZFdrH4ESETirca4CBb3M7ZRox0FQ
	E8waxtV3kNBjiQguGGmflIrYXpKE3v/QP3OJ1sR7Nnukf9UQGYo+dMo0w5HFDAHj
	wc3Vw==
X-ME-Sender: <xms:-PKtagXJ7Mtw_K6xHaCFTFQQw6jReEHdjIDunwlZi9kAQagXLoYZvA>
    <xme:-PKtatYiwrXDvB2bXGPy-EZTHVDv3FB_fyXWeydEd_bkJRj9Gf2lGu-MTgO6_DR8R
    M9BlUFi3K5e8bAvbb-5vmuFGobSA68wWegcSkSoIQbtlr1J>
X-ME-Received: <xmr:-PKtalvKDh6cO1wbb7NK2ySJP6NjV1bMYyndn78Zi5MerfL7v0uQdAvUdYQGxPMwbwtrDB-N1IvQd-nggrK1r3DlYgDtOuo>
X-ME-Proxy-Cause: dmFkZTGgqDvHUiFoelb3szb25Xc5WIL1X0CmKVd0SSFttbFGm3ZS4/WbThw2/23Wv0kT2L
    zTiD3f7/mbRn4xQkog4u9WXAUu/Z8xbLL7habzJ5iT0L9pvsBxuMoK5k8M+5CBBhCA34Md
    HPlNAQAuPUTpsFoyG9EfHruislsqzF/ELe8vhu1WoHNTpMpKsXLXUP8fPb+iJDnGZK+wxX
    pyu1Y8XGp2Ez4Y8aWvA0+LsWIM5P5beRGa1K+yf2x8AAFZFB+FqQNejpWDyXiPsbkOSKyy
    pf6WO9eid06RPw0E0qVieiQBSzbPbVfHpbR/XZ98dIIyde1pgFtUnUmkW5DtGlTWNRmkEj
    377G7CM3GpxmXSNvMi+MPW2aEgby5zH2/1Do6FlWCyen6Exv4DxYCE4xkLL+N71nymIowO
    LQbw7XMRj6Aj+q5xxndpZRqcCEI9+BWqeMNpwzih2rrAvrgBVFaN5IOQ4szAS6Ymy+7ZO/
    gVZJKUAMeQDjZCn5OqDEcaELhvBpC7YlnyySMcpxZnmZMSj302XUJy3Ivhjd6Z+dcTkPtL
    fpiZYIo2CEpWqHWfPGPyIOSgkNnl8sUfmBHExqN4gutq5Gez5f8naeViXgk+nJa/G3C9jO
    LA2CswWqZSp25q5zrRzqHydQzjvDTTIymnCMg8ivZVGwqIQlD6L5/TEC0qow
X-ME-Proxy: <xmx:-PKtaknvLCdCS97AJAHuSA4StIgQjUd05FAMiem2CRtO8biPeEyaNQ>
    <xmx:-PKtauUfJZ2AN9Xds8r_ECye6hS-MMxznRVISl9PzgnSRPzC7RxWIA>
    <xmx:-PKtavnvt4YL-5QYEO00uOfTHuJ7llq-twaGuQzdnwPp_ZnUwZV4vQ>
    <xmx:-PKtajSq4-BNs1t41vbFIf3FeLuk0PJNHwvuxXzNmDp34LCvyhQY-w>
    <xmx:-PKtajw1FgHnwTTTEAPcoZItoe0WGoPep6i7GlDA3Si_JsItHAn516xp>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 18 Sep 2026 22:26:58 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Jori Koolstra <jkoolstra@xs4all.nl>,
	Mateusz Guzik <mjguzik@gmail.com>,
	Dorjoy Chowdhury <dorjoychy111@gmail.com>
Cc: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Andreas Gruenbacher <agruenba@redhat.com>,
	gfs2@lists.linux.dev,
	Ilya Dryomov <idryomov@gmail.com>,
	Alex Markuze <amarkuze@redhat.com>,
	Viacheslav Dubeyko <slava@dubeyko.com>,
	ceph-devel@vger.kernel.org,
	Paulo Alcantara <pc@manguebit.org>,
	Namjae Jeon <linkinjeon@kernel.org>,
	linux-cifs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH v2 14/14] nfsd: use vfs_lookup_open() for non-creating open requests too.
Date: Sat, 19 Sep 2026 12:06:18 +1000
Message-ID: <20260919022441.3305170-15-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260919022441.3305170-1-neilb@ownmail.net>
References: <20260919022441.3305170-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

Now that we have vfs_lookup_open() for open requests which create, we
can use it for non-creating requests too as vfs_lookup_open() is already
able to do that.  nfsd4_create_file() is renamed to nfsd4_open_file()
and enhanced to not always create, and is then used for all OPEN
requests.

The resulting simplification allows fh_fill_pre_attrs_unlocked() to be
moved into nfsd4_open_file() so it is closer to fh_fill_post_attrs() and
fh_fill_post_noop() calls.

As ->op_createmode isn't defined when op_create is zero, we need a
local createmode which is -1 (illegal value) when op_create is zero.

The non-create path now doesn't use nfsd_lookup().  As mount-point
crossing, including check_nfsd_access(), is already included for existing
names, this does not lose us anything.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 115 +++++++++++++++++++++++----------------------
 1 file changed, 60 insertions(+), 55 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 40bd1179bf60..6be6ca473586 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -249,28 +249,30 @@ static inline bool nfsd4_create_is_exclusive(int createmode)
 }
 
 /*
- * Implement NFSv4's unchecked, guarded, and exclusive create
- * semantics for regular files. Open state for this new file is
- * subsequently fabricated in nfsd4_process_open2().
+ * Implement NFSv4's open semantics for regular files, both creating
+ * (unchecked, guarded, and exclusive) and non-creating.  The "struct file"
+ * is openned here, and other open state for is subsequently fabricated in
+ * nfsd4_process_open2().
  *
  * Upon return, caller must release @fhp and @resfhp.
  */
 static __be32
-nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
-		  struct svc_fh *resfhp, struct nfsd4_open *open)
+nfsd4_open_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
+		struct svc_fh *resfhp, struct nfsd4_open *open)
 {
 	struct iattr *iap = &open->op_iattr;
 	struct nfsd_attrs attrs = {
 		.na_iattr	= iap,
 		.na_seclabel	= &open->op_label,
 	};
-	int oflags = O_CREAT | O_LARGEFILE | O_NONBLOCK;
+	int oflags = O_LARGEFILE | O_NONBLOCK;
 	struct dentry *child = ERR_PTR(-EINVAL);
 	struct path parent = {
 		.mnt = fhp->fh_export->ex_path.mnt,
 		.dentry = fhp->fh_dentry,
 	};
 	__u32 v_mtime, v_atime;
+	int createmode;
 	__be32 status, create_status;
 	struct svc_export *exp;
 	int want_write_err;
@@ -284,7 +286,27 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (status != nfs_ok)
 		return status;
 
-	if (open->op_createmode == NFS4_CREATE_UNCHECKED) {
+	status = fh_fill_pre_attrs_unlocked(fhp);
+	if (status)
+		return status;
+
+	if (open->op_create) {
+		createmode = open->op_createmode;
+
+		create_status = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
+		if (create_status == nfs_ok)
+			oflags |= O_CREAT;
+	} else {
+		/*
+		 * The only difference between no-create and CREATE_UNCHECKED
+		 * is the presence of O_CREAT.  In all other ways we can treat
+		 * them the same.
+		 */
+		createmode = NFS4_CREATE_UNCHECKED;
+		create_status = nfs_ok;
+	}
+
+	if (createmode == NFS4_CREATE_UNCHECKED) {
 		/*
 		 * If name is already in dcache we need to check for mountpoints
 		 */
@@ -305,7 +327,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	 * For the EXCLUSIVE modes we do our own uniqueness tests
 	 * so don't want O_EXCL.
 	 */
-	if (open->op_createmode == NFS4_CREATE_GUARDED)
+	if (createmode == NFS4_CREATE_GUARDED)
 		oflags |= O_EXCL;
 
 	switch (open->op_share_access & NFS4_SHARE_ACCESS_BOTH) {
@@ -337,7 +359,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	v_mtime = 0;
 	v_atime = 0;
-	if (nfsd4_create_is_exclusive(open->op_createmode)) {
+	if (nfsd4_create_is_exclusive(createmode)) {
 		u32 *verifier = (u32 *)open->op_verf.data;
 
 		/*
@@ -359,11 +381,6 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		iap->ia_atime.tv_nsec = 0;
 	}
 
-	create_status = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
-	if (create_status)
-		/* Might still succeed if no create is needed */
-		oflags &= ~O_CREAT;
-
 	open->op_filp = vfs_lookup_open(&parent,
 					&QSTR_LEN(open->op_fname,
 						  open->op_fnamelen),
@@ -372,7 +389,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (IS_ERR(open->op_filp)) {
 		int hosterr = PTR_ERR(open->op_filp);
 
-		if (open->op_createmode != NFS4_CREATE_UNCHECKED) {
+		if (createmode != NFS4_CREATE_UNCHECKED) {
 			switch (hosterr) {
 			case -EISDIR:
 			case -ELOOP:
@@ -395,14 +412,14 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		goto out;
 
 	if (!open->op_created &&
-	    nfsd4_create_is_exclusive(open->op_createmode) &&
+	    nfsd4_create_is_exclusive(createmode) &&
 	    inode_get_mtime_sec(d_inode(child)) == v_mtime &&
 	    inode_get_atime_sec(d_inode(child)) == v_atime &&
 	    d_inode(child)->i_size == 0)
 		open->op_created = true;
 
 	if (!open->op_created) {
-		if (open->op_createmode != NFS4_CREATE_UNCHECKED) {
+		if (createmode != NFS4_CREATE_UNCHECKED) {
 			status = nfserr_exist;
 			goto out;
 		}
@@ -521,46 +538,34 @@ do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, stru
 	fh_init(*resfh, NFS4_FHSIZE);
 	open->op_truncate = false;
 
-	status = fh_fill_pre_attrs_unlocked(current_fh);
-	if (status)
-		goto out;
-	if (open->op_create) {
-		/* FIXME: check session persistence and pnfs flags.
-		 * The nfsv4.1 spec requires the following semantics:
-		 *
-		 * Persistent   | pNFS   | Server REQUIRED | Client Allowed
-		 * Reply Cache  | server |                 |
-		 * -------------+--------+-----------------+--------------------
-		 * no           | no     | EXCLUSIVE4_1    | EXCLUSIVE4_1
-		 *              |        |                 | (SHOULD)
-		 *              |        | and EXCLUSIVE4  | or EXCLUSIVE4
-		 *              |        |                 | (SHOULD NOT)
-		 * no           | yes    | EXCLUSIVE4_1    | EXCLUSIVE4_1
-		 * yes          | no     | GUARDED4        | GUARDED4
-		 * yes          | yes    | GUARDED4        | GUARDED4
-		 */
+	/* FIXME: check session persistence and pnfs flags.
+	 * The nfsv4.1 spec requires the following semantics:
+	 *
+	 * Persistent   | pNFS   | Server REQUIRED | Client Allowed
+	 * Reply Cache  | server |                 |
+	 * -------------+--------+-----------------+--------------------
+	 * no           | no     | EXCLUSIVE4_1    | EXCLUSIVE4_1
+	 *              |        |                 | (SHOULD)
+	 *              |        | and EXCLUSIVE4  | or EXCLUSIVE4
+	 *              |        |                 | (SHOULD NOT)
+	 * no           | yes    | EXCLUSIVE4_1    | EXCLUSIVE4_1
+	 * yes          | no     | GUARDED4        | GUARDED4
+	 * yes          | yes    | GUARDED4        | GUARDED4
+	 */
 
-		current->fs->umask = open->op_umask;
-		status = nfsd4_create_file(rqstp, current_fh, *resfh, open);
-		current->fs->umask = 0;
+	current->fs->umask = open->op_umask;
+	status = nfsd4_open_file(rqstp, current_fh, *resfh, open);
+	current->fs->umask = 0;
 
-		/*
-		 * Following rfc 3530 14.2.16, and rfc 5661 18.16.4
-		 * use the returned bitmask to indicate which attributes
-		 * we used to store the verifier:
-		 */
-		if (nfsd4_create_is_exclusive(open->op_createmode) && status == 0)
-			open->op_bmval[1] |= (FATTR4_WORD1_TIME_ACCESS |
-						FATTR4_WORD1_TIME_MODIFY);
-	} else {
-		status = nfsd_lookup(rqstp, current_fh,
-				     open->op_fname, open->op_fnamelen, *resfh);
-		/*
-		 * NFSv4 protocol requires change attributes even though
-		 * no change happened.
-		 */
-		fh_fill_post_noop(current_fh);
-	}
+	/*
+	 * Following rfc 3530 14.2.16, and rfc 5661 18.16.4
+	 * use the returned bitmask to indicate which attributes
+	 * we used to store the verifier:
+	 */
+	if (open->op_create &&
+	    nfsd4_create_is_exclusive(open->op_createmode) && status == 0)
+		open->op_bmval[1] |= (FATTR4_WORD1_TIME_ACCESS |
+				      FATTR4_WORD1_TIME_MODIFY);
 	if (status)
 		goto out;
 	status = nfsd_check_obj_isreg((*resfh)->fh_dentry);
-- 
2.50.0.107.gf914562f5916.dirty

