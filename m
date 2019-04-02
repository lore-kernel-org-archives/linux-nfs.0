Return-Path: <SRS0=y3t/=SE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B906BC4360F
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:46:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7DFEB207E0
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:46:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HVJk3UwI"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726625AbfDBXqY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 19:46:24 -0400
Received: from mail-pg1-f196.google.com ([209.85.215.196]:44460 "EHLO
        mail-pg1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726624AbfDBXqY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Apr 2019 19:46:24 -0400
Received: by mail-pg1-f196.google.com with SMTP id i2so7315022pgj.11
        for <linux-nfs@vger.kernel.org>; Tue, 02 Apr 2019 16:46:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=C/kjrU89XM3AiZr8cj7Jt3GkMQIe3SV2VIvM3zC645g=;
        b=HVJk3UwIx8reG0gDU363tKm55uP369u3UgE5b48r8V+vd9EyqdnGL+TG2FWpqW1brC
         RsT0A/Tx4bJErwawXcRExLonT0a+O+5nPW2cu90HOVSZqbh6/FskepGHzKR22gZJ7Evh
         43StHqJOyXfgnOaNwNfYHT5s78mWDUGNxHF84TS5jF731xIqeAlkZj2vVO7G07c+ijJx
         l3K3WwhdnCzFMoldr3adQHDyqtPgbnOWWongzrdXr9CDhNtqZxOussdor4k6Cw0FIdMS
         3w+rtLGcMNIvWVf3F460tH+RG0rPCWdqF+Gq2Ecdeyo1GVzVSF1EJYpjQy+q6pHEz06t
         uXVw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=C/kjrU89XM3AiZr8cj7Jt3GkMQIe3SV2VIvM3zC645g=;
        b=iUc70JcjwJ1CB5AZRvDP1dHHMXa30XKqaz7IzETjNQmaifOeFV2BnFi3vI3ukq1QzD
         diq+U6wmijwpfjv4VH+0RouaLk6XbCfe3+fUNLkDkazJaWXkLOL8xFjOwz6MYTV5+KFF
         bjWHKuS8/yD8un+IpSYe2vPECAq8zaGiP8jHzJbByFZm/Pht/j8zdHtOjFvbCMcp1Pjk
         g2GgNx5DIuljiwx+41k4j3DVsTcekqIR0oPAWy40WQW9La09dg/MbrM8XDm3XGDFYps9
         GkkoYezwggpZVxNoomcDGllU1HXGThSZIGUtIg8pNyygL5IBN8KHKClpYmudUyZXEcHZ
         0gsw==
X-Gm-Message-State: APjAAAWA2DOoBrwf/Lq7UXGFjN8WMK/Dvm9OkIwsh7qkGZUlDDwDum/g
        Jpu7gXukUykgLOXR1EpWcw==
X-Google-Smtp-Source: APXvYqxF7oSzB8L7UaItVPq2lwVhu9Danaoo3EaDfhIV1qJrKyJH4t0YcFo5vaEKetlMigg0do4xrA==
X-Received: by 2002:aa7:8c86:: with SMTP id p6mr9239243pfd.37.1554248783475;
        Tue, 02 Apr 2019 16:46:23 -0700 (PDT)
Received: from localhost.localdomain (63-235-104-78.dia.static.qwest.net. [63.235.104.78])
        by smtp.gmail.com with ESMTPSA id y12sm38011643pgq.64.2019.04.02.16.46.22
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Apr 2019 16:46:22 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] nfsd: knfsd must use the container user namespace
Date:   Tue,  2 Apr 2019 16:44:11 -0700
Message-Id: <20190402234411.28204-6-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190402234411.28204-5-trond.myklebust@hammerspace.com>
References: <20190402234411.28204-1-trond.myklebust@hammerspace.com>
 <20190402234411.28204-2-trond.myklebust@hammerspace.com>
 <20190402234411.28204-3-trond.myklebust@hammerspace.com>
 <20190402234411.28204-4-trond.myklebust@hammerspace.com>
 <20190402234411.28204-5-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Convert knfsd to use the user namespace of the container that started
the server processes.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfsd/export.c    | 18 ++++++++++--------
 fs/nfsd/nfs3xdr.c   | 21 +++++++++++----------
 fs/nfsd/nfs4idmap.c |  8 ++++----
 fs/nfsd/nfs4xdr.c   |  5 +++--
 fs/nfsd/nfsd.h      |  7 +++++++
 fs/nfsd/nfsxdr.c    | 17 +++++++++--------
 6 files changed, 44 insertions(+), 32 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 802993d8912f..baa01956a5b3 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -570,13 +570,13 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 		err = get_int(&mesg, &an_int);
 		if (err)
 			goto out3;
-		exp.ex_anon_uid= make_kuid(&init_user_ns, an_int);
+		exp.ex_anon_uid= make_kuid(current_user_ns(), an_int);
 
 		/* anon gid */
 		err = get_int(&mesg, &an_int);
 		if (err)
 			goto out3;
-		exp.ex_anon_gid= make_kgid(&init_user_ns, an_int);
+		exp.ex_anon_gid= make_kgid(current_user_ns(), an_int);
 
 		/* fsid */
 		err = get_int(&mesg, &an_int);
@@ -1170,15 +1170,17 @@ static void show_secinfo(struct seq_file *m, struct svc_export *exp)
 static void exp_flags(struct seq_file *m, int flag, int fsid,
 		kuid_t anonu, kgid_t anong, struct nfsd4_fs_locations *fsloc)
 {
+	struct user_namespace *userns = m->file->f_cred->user_ns;
+
 	show_expflags(m, flag, NFSEXP_ALLFLAGS);
 	if (flag & NFSEXP_FSID)
 		seq_printf(m, ",fsid=%d", fsid);
-	if (!uid_eq(anonu, make_kuid(&init_user_ns, (uid_t)-2)) &&
-	    !uid_eq(anonu, make_kuid(&init_user_ns, 0x10000-2)))
-		seq_printf(m, ",anonuid=%u", from_kuid(&init_user_ns, anonu));
-	if (!gid_eq(anong, make_kgid(&init_user_ns, (gid_t)-2)) &&
-	    !gid_eq(anong, make_kgid(&init_user_ns, 0x10000-2)))
-		seq_printf(m, ",anongid=%u", from_kgid(&init_user_ns, anong));
+	if (!uid_eq(anonu, make_kuid(userns, (uid_t)-2)) &&
+	    !uid_eq(anonu, make_kuid(userns, 0x10000-2)))
+		seq_printf(m, ",anonuid=%u", from_kuid_munged(userns, anonu));
+	if (!gid_eq(anong, make_kgid(userns, (gid_t)-2)) &&
+	    !gid_eq(anong, make_kgid(userns, 0x10000-2)))
+		seq_printf(m, ",anongid=%u", from_kgid_munged(userns, anong));
 	if (fsloc && fsloc->locations_count > 0) {
 		char *loctype = (fsloc->migrated) ? "refer" : "replicas";
 		int i;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 93fea246f676..9c9d0dffbb32 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -96,7 +96,7 @@ decode_filename(__be32 *p, char **namp, unsigned int *lenp)
 }
 
 static __be32 *
-decode_sattr3(__be32 *p, struct iattr *iap)
+decode_sattr3(__be32 *p, struct iattr *iap, struct user_namespace *userns)
 {
 	u32	tmp;
 
@@ -107,12 +107,12 @@ decode_sattr3(__be32 *p, struct iattr *iap)
 		iap->ia_mode = ntohl(*p++);
 	}
 	if (*p++) {
-		iap->ia_uid = make_kuid(&init_user_ns, ntohl(*p++));
+		iap->ia_uid = make_kuid(userns, ntohl(*p++));
 		if (uid_valid(iap->ia_uid))
 			iap->ia_valid |= ATTR_UID;
 	}
 	if (*p++) {
-		iap->ia_gid = make_kgid(&init_user_ns, ntohl(*p++));
+		iap->ia_gid = make_kgid(userns, ntohl(*p++));
 		if (gid_valid(iap->ia_gid))
 			iap->ia_valid |= ATTR_GID;
 	}
@@ -165,12 +165,13 @@ static __be32 *
 encode_fattr3(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp,
 	      struct kstat *stat)
 {
+	struct user_namespace *userns = nfsd_user_namespace(rqstp);
 	struct timespec ts;
 	*p++ = htonl(nfs3_ftypes[(stat->mode & S_IFMT) >> 12]);
 	*p++ = htonl((u32) (stat->mode & S_IALLUGO));
 	*p++ = htonl((u32) stat->nlink);
-	*p++ = htonl((u32) from_kuid(&init_user_ns, stat->uid));
-	*p++ = htonl((u32) from_kgid(&init_user_ns, stat->gid));
+	*p++ = htonl((u32) from_kuid_munged(userns, stat->uid));
+	*p++ = htonl((u32) from_kgid_munged(userns, stat->gid));
 	if (S_ISLNK(stat->mode) && stat->size > NFS3_MAXPATHLEN) {
 		p = xdr_encode_hyper(p, (u64) NFS3_MAXPATHLEN);
 	} else {
@@ -325,7 +326,7 @@ nfs3svc_decode_sattrargs(struct svc_rqst *rqstp, __be32 *p)
 	p = decode_fh(p, &args->fh);
 	if (!p)
 		return 0;
-	p = decode_sattr3(p, &args->attrs);
+	p = decode_sattr3(p, &args->attrs, nfsd_user_namespace(rqstp));
 
 	if ((args->check_guard = ntohl(*p++)) != 0) { 
 		struct timespec time; 
@@ -455,7 +456,7 @@ nfs3svc_decode_createargs(struct svc_rqst *rqstp, __be32 *p)
 	switch (args->createmode = ntohl(*p++)) {
 	case NFS3_CREATE_UNCHECKED:
 	case NFS3_CREATE_GUARDED:
-		p = decode_sattr3(p, &args->attrs);
+		p = decode_sattr3(p, &args->attrs, nfsd_user_namespace(rqstp));
 		break;
 	case NFS3_CREATE_EXCLUSIVE:
 		args->verf = p;
@@ -476,7 +477,7 @@ nfs3svc_decode_mkdirargs(struct svc_rqst *rqstp, __be32 *p)
 	if (!(p = decode_fh(p, &args->fh)) ||
 	    !(p = decode_filename(p, &args->name, &args->len)))
 		return 0;
-	p = decode_sattr3(p, &args->attrs);
+	p = decode_sattr3(p, &args->attrs, nfsd_user_namespace(rqstp));
 
 	return xdr_argsize_check(rqstp, p);
 }
@@ -491,7 +492,7 @@ nfs3svc_decode_symlinkargs(struct svc_rqst *rqstp, __be32 *p)
 	if (!(p = decode_fh(p, &args->ffh)) ||
 	    !(p = decode_filename(p, &args->fname, &args->flen)))
 		return 0;
-	p = decode_sattr3(p, &args->attrs);
+	p = decode_sattr3(p, &args->attrs, nfsd_user_namespace(rqstp));
 
 	args->tlen = ntohl(*p++);
 
@@ -519,7 +520,7 @@ nfs3svc_decode_mknodargs(struct svc_rqst *rqstp, __be32 *p)
 
 	if (args->ftype == NF3BLK  || args->ftype == NF3CHR
 	 || args->ftype == NF3SOCK || args->ftype == NF3FIFO)
-		p = decode_sattr3(p, &args->attrs);
+		p = decode_sattr3(p, &args->attrs, nfsd_user_namespace(rqstp));
 
 	if (args->ftype == NF3BLK || args->ftype == NF3CHR) {
 		args->major = ntohl(*p++);
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index bf137fec33ff..2961016097ac 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -634,7 +634,7 @@ nfsd_map_name_to_uid(struct svc_rqst *rqstp, const char *name, size_t namelen,
 		return nfserr_inval;
 
 	status = do_name_to_id(rqstp, IDMAP_TYPE_USER, name, namelen, &id);
-	*uid = make_kuid(&init_user_ns, id);
+	*uid = make_kuid(nfsd_user_namespace(rqstp), id);
 	if (!uid_valid(*uid))
 		status = nfserr_badowner;
 	return status;
@@ -651,7 +651,7 @@ nfsd_map_name_to_gid(struct svc_rqst *rqstp, const char *name, size_t namelen,
 		return nfserr_inval;
 
 	status = do_name_to_id(rqstp, IDMAP_TYPE_GROUP, name, namelen, &id);
-	*gid = make_kgid(&init_user_ns, id);
+	*gid = make_kgid(nfsd_user_namespace(rqstp), id);
 	if (!gid_valid(*gid))
 		status = nfserr_badowner;
 	return status;
@@ -660,13 +660,13 @@ nfsd_map_name_to_gid(struct svc_rqst *rqstp, const char *name, size_t namelen,
 __be32 nfsd4_encode_user(struct xdr_stream *xdr, struct svc_rqst *rqstp,
 			 kuid_t uid)
 {
-	u32 id = from_kuid(&init_user_ns, uid);
+	u32 id = from_kuid_munged(nfsd_user_namespace(rqstp), uid);
 	return encode_name_from_id(xdr, rqstp, IDMAP_TYPE_USER, id);
 }
 
 __be32 nfsd4_encode_group(struct xdr_stream *xdr, struct svc_rqst *rqstp,
 			  kgid_t gid)
 {
-	u32 id = from_kgid(&init_user_ns, gid);
+	u32 id = from_kgid_munged(nfsd_user_namespace(rqstp), gid);
 	return encode_name_from_id(xdr, rqstp, IDMAP_TYPE_GROUP, id);
 }
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 3de42a729093..0a8063c94c79 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -521,6 +521,7 @@ nfsd4_decode_access(struct nfsd4_compoundargs *argp, struct nfsd4_access *access
 static __be32 nfsd4_decode_cb_sec(struct nfsd4_compoundargs *argp, struct nfsd4_cb_sec *cbs)
 {
 	DECODE_HEAD;
+	struct user_namespace *userns = nfsd_user_namespace(argp->rqstp);
 	u32 dummy, uid, gid;
 	char *machine_name;
 	int i;
@@ -563,8 +564,8 @@ static __be32 nfsd4_decode_cb_sec(struct nfsd4_compoundargs *argp, struct nfsd4_
 			dummy = be32_to_cpup(p++);
 			READ_BUF(dummy * 4);
 			if (cbs->flavor == (u32)(-1)) {
-				kuid_t kuid = make_kuid(&init_user_ns, uid);
-				kgid_t kgid = make_kgid(&init_user_ns, gid);
+				kuid_t kuid = make_kuid(userns, uid);
+				kgid_t kgid = make_kgid(userns, gid);
 				if (uid_valid(kuid) && gid_valid(kgid)) {
 					cbs->uid = kuid;
 					cbs->gid = kgid;
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index d200c8680259..24187b5dd638 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -17,6 +17,7 @@
 #include <linux/nfs3.h>
 #include <linux/nfs4.h>
 #include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/svc_xprt.h>
 #include <linux/sunrpc/msg_prot.h>
 
 #include <uapi/linux/nfsd/debug.h>
@@ -112,6 +113,12 @@ static inline int nfsd_v4client(struct svc_rqst *rq)
 {
 	return rq->rq_prog == NFS_PROGRAM && rq->rq_vers == 4;
 }
+static inline struct user_namespace *
+nfsd_user_namespace(const struct svc_rqst *rqstp)
+{
+	const struct cred *cred = rqstp->rq_xprt->xpt_cred;
+	return cred ? cred->user_ns : &init_user_ns;
+}
 
 /* 
  * NFSv4 State
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 6b2e8b73d36e..b51fe515f06f 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -71,7 +71,7 @@ decode_filename(__be32 *p, char **namp, unsigned int *lenp)
 }
 
 static __be32 *
-decode_sattr(__be32 *p, struct iattr *iap)
+decode_sattr(__be32 *p, struct iattr *iap, struct user_namespace *userns)
 {
 	u32	tmp, tmp1;
 
@@ -86,12 +86,12 @@ decode_sattr(__be32 *p, struct iattr *iap)
 		iap->ia_mode = tmp;
 	}
 	if ((tmp = ntohl(*p++)) != (u32)-1) {
-		iap->ia_uid = make_kuid(&init_user_ns, tmp);
+		iap->ia_uid = make_kuid(userns, tmp);
 		if (uid_valid(iap->ia_uid))
 			iap->ia_valid |= ATTR_UID;
 	}
 	if ((tmp = ntohl(*p++)) != (u32)-1) {
-		iap->ia_gid = make_kgid(&init_user_ns, tmp);
+		iap->ia_gid = make_kgid(userns, tmp);
 		if (gid_valid(iap->ia_gid))
 			iap->ia_valid |= ATTR_GID;
 	}
@@ -129,6 +129,7 @@ static __be32 *
 encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp,
 	     struct kstat *stat)
 {
+	struct user_namespace *userns = nfsd_user_namespace(rqstp);
 	struct dentry	*dentry = fhp->fh_dentry;
 	int type;
 	struct timespec64 time;
@@ -139,8 +140,8 @@ encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp,
 	*p++ = htonl(nfs_ftypes[type >> 12]);
 	*p++ = htonl((u32) stat->mode);
 	*p++ = htonl((u32) stat->nlink);
-	*p++ = htonl((u32) from_kuid(&init_user_ns, stat->uid));
-	*p++ = htonl((u32) from_kgid(&init_user_ns, stat->gid));
+	*p++ = htonl((u32) from_kuid_munged(userns, stat->uid));
+	*p++ = htonl((u32) from_kgid_munged(userns, stat->gid));
 
 	if (S_ISLNK(type) && stat->size > NFS_MAXPATHLEN) {
 		*p++ = htonl(NFS_MAXPATHLEN);
@@ -216,7 +217,7 @@ nfssvc_decode_sattrargs(struct svc_rqst *rqstp, __be32 *p)
 	p = decode_fh(p, &args->fh);
 	if (!p)
 		return 0;
-	p = decode_sattr(p, &args->attrs);
+	p = decode_sattr(p, &args->attrs, nfsd_user_namespace(rqstp));
 
 	return xdr_argsize_check(rqstp, p);
 }
@@ -319,7 +320,7 @@ nfssvc_decode_createargs(struct svc_rqst *rqstp, __be32 *p)
 	if (   !(p = decode_fh(p, &args->fh))
 	    || !(p = decode_filename(p, &args->name, &args->len)))
 		return 0;
-	p = decode_sattr(p, &args->attrs);
+	p = decode_sattr(p, &args->attrs, nfsd_user_namespace(rqstp));
 
 	return xdr_argsize_check(rqstp, p);
 }
@@ -398,7 +399,7 @@ nfssvc_decode_symlinkargs(struct svc_rqst *rqstp, __be32 *p)
 			return 0;
 		p += xdrlen;
 	}
-	decode_sattr(p, &args->attrs);
+	decode_sattr(p, &args->attrs, nfsd_user_namespace(rqstp));
 
 	return 1;
 }
-- 
2.20.1

