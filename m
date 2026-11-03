Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.208.41
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793669570;
	b=UKz2jp3ZIm/pFHZHBSBrfnXur5MA/h5AdCdBaxPiZNuRiFXttgV2KhpHDUX/XiZ18lww
	 8QTWYdm/ZZjr5efPGox8kM17iBg+00+e8a4MF12cKhvd/6i6b584IxGtWrrKTYJgD/slB
	 nuQIEg94Y2a41uc5qM20HkCGVgsaftJGN00yxc7rcIhRv5RKCdKFMLZaz2xhyhDKl8cuD
	 UZk4HdnDGvcEjzadh66C0WiRhWdcR/u1ZCsCjreDSflQsTvW16pJTzDJgnZTuJfKTTbKT
	 TwBekb7osQX4yqs+aFbFJSi/q6ZStioaGAflIH6/4O3FLdGsKdVDBn8LWlDC5kwflHA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793669570;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=jX3IkR+2sL10OzJeXBMlegpXQtT3gERG6oDD2hz/J6E=;
	b=tAQmojnndLJwQbA16+gow5LVDdUdKwqfB3zQLpqVkKOa3+vU2JobsQWM5faVF0bJmLzo
	 ZOI8rlE3/lMq2H811xyJkqQaTlrohMPqeogJQyPOV9CV0w7hw/kLAYyzgJeAbR3uhroH3
	 rzMsi64jM/FJFETz/Eo4N6wSU01HA33Cqqw70bOhIkCD0nsW3N8WjWUM5A2pxxGkQZPf/
	 yQndzBpAVkz6Ip5+SOx9GR/0oXP0PnKmUdC+tD1RhucbLkaNrQxLLE0ibCVlAUfMPgaQ6
	 /undMb0JspHjFs06tv1UMj2socK6D6e17tdTxLyiA7JmVv5TEKD9P5D5WuRO1uQUBLA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=ZzCIWKHm;
	arc=none smtp.remote-ip=209.85.208.41
Received: from mail-ed1-f41.google.com (mail-ed1-f41.google.com [209.85.208.41])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BB885606A324
	for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2026 01:32:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BB885606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=ZzCIWKHm
Received: by mail-ed1-f41.google.com with SMTP id 4fb4d7f45d1cf-6b1a86c0316so5017330a12.0
        for <linux-nfs@vger.kernel.org>; Mon, 02 Nov 2026 17:32:49 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1793669568; x=1794274368; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=jX3IkR+2sL10OzJeXBMlegpXQtT3gERG6oDD2hz/J6E=;
        b=ZzCIWKHmSqATzHz+kF2jVZKxhuOAWUrOfZWCTzvERIPDSleJlFoF+hz+BFYt4kGbgW
         CVqDEg2DDzqphtNrz04Yge5N5KiP9lIu/ZOzPSvg2MXNNWTau2EKR3Dyf3HJglbhxHv8
         rVsBI4UTY5AJtIRUkjJ9G83XhYPV08hIP0wFg39zOmiOYx6HPbxmvovRBGyrk/8++CsD
         yzNxyJEyJtabA9t1U2P+FISohfGELD4I/w4YzUEj4ntzslL2pw00EeNmbXkN6CGaCaBz
         TaKfyRuMYRsJWV5yWYnqESNX5kXnINPNoF9jz5sLLZCqWe8XbKWRVdPqScnLmg/5+26E
         0I+w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793669568; x=1794274368;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=jX3IkR+2sL10OzJeXBMlegpXQtT3gERG6oDD2hz/J6E=;
        b=GyoyEwOniRqZ6uZNjl4j700bqKdbHOhAvPBieCNDjLfQtslg+Sw+xe4mUN9np7qTLe
         gp0TBsxWmbnCLAyB+UcqIkjUV+vJE1W/MCcJY5945zpsDLglBrzl2BFhAKz8EfYfn6HU
         TxoxovW43okSEEd3e9aODecMqFonmRORZjRSCgPknxqxy1tCup7oIO/TmPFAx0pQ/9Tg
         MBEvE7h1lqUvS6apfgm6zE398/DxGkMBR5mTA4bhiXWSXY2NvgIdq5my8EW5yP8+NXxV
         dT7EQHJLIbIseasT6p8L7AmtE0f2JAkBtH6iBiaBE1ZJ4etc/ic/BPSeeN3fYrCLAGzy
         XpQg==
X-Gm-Message-State: APuU4Z/u9gzkwBYrkwr7JYwLRVfy4SkxxQncn5eM8/SiVk/FdZcsCiiY
	a44zfdxsl0sOZGcgyCSE5Dow6WBxqk+bKh8UPm5LtqYk3KHbGxy+0AhfnuXqD/3flHY=
X-Gm-Gg: AYBFou34/1ALonvzZ2sUK5aH9VLIoQXY7dvIK3RDDJKF3yB7qA2tjz0irWA75oGzX5z
	Yu2ytaQDXpvRjzVKTghze/tBA1kvq3zyoI+4vDRe1kHOlDRzhRf2cX3/EPwT1Fl5gF9ZU0SeAnI
	+yrcKtIQDwp176Ml+InneihLLP6D3XL+Vgy+nkFmTRShrwP5jjw7NUJxCCEEUa2lYZ0InvBRTWZ
	hFz8LN2MWOsYm5+bIfA1O+g8iY28uRD10t/TLzOFWTmYPekyNUFCi+WmTBEsi/M3XgSfX1GPlPL
	3InK9R21Oyg9Pgf8/rCjmWV4pdqPLqWEbCJ0nyCfeYgABESuwn+owqNZubAoVQ8xTdLW2o+JN5R
	66AJPTZVWClcCuCDCDfV8Y62HaNPax7C5y4gaG5f1ZyUfr2cOhNi2iT8cZBj6fAsTSl3WqXWYuk
	6B81U7h9V1AXk4Y0tPPtJd0KLstl4xHjH2D9lcFnNcgQJpC7T1VB8NNCRqSoGDqwQvoWRgwvHeH
	hJ64zNpLWLhvg0hJWyrB/FUkC23qst7nxjfBmrDLn6TTwt9Y8qRiDYIJ8TIMiS6zbDpkMWLuC/1
	pZV3rUviph3KUgRbrZnI8eCw7htfqdDpmKqlSsJ/8/uQPwFFFMk2HUm6QydYsimvK59GBrvt
X-Received: by 2002:aa7:c0d7:0:b0:6b3:d0a0:39e5 with SMTP id 4fb4d7f45d1cf-6b4d438bdb7mr6016589a12.9.1793669568048;
        Mon, 02 Nov 2026 17:32:48 -0800 (PST)
Received: from localhost.localdomain (173.242.112.181.16clouds.com. [173.242.112.181])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-6b4ec91e2f2sm3776583a12.0.2026.11.02.17.32.45
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 02 Nov 2026 17:32:47 -0800 (PST)
From: VeroFess <coderzeng@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: cel@kernel.org,
	jlayton@kernel.org
Subject: [PATCH 1/3] NFSD: Check the secure-port policy when entering an export
Date: Tue,  3 Nov 2026 09:32:35 +0800
Message-ID: <20261103013237.1174538-2-coderzeng@gmail.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20261103013237.1174538-1-coderzeng@gmail.com>
References: <20261103013237.1174538-1-coderzeng@gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

LOOKUP checks the parent filehandle before crossing a mountpoint.
The crossing checks the entered export's flavor and transport policy,
but not its secure-port setting. An AUTH_SYS request from an
unreserved port can therefore enter a secure export by LOOKUP,
although PUTFH of the same filehandle returns NFS4ERR_PERM. The
requester must already hold an OPEN stateid for the file for the
demonstrated READ and CLONE paths; the reproducer obtains it from a
reserved port before sending the requests from an unreserved port.

Check the port whenever check_nfsd_access() revalidates an export.
Use the same port helper as fh_verify(), including SECINFO's flavor
bypass path. Map a port denial to NFS4ERR_ACCESS in SECINFO and
SECINFO_NO_NAME, as required for a denied name lookup.

The omission is old; it dates back at least to Linux 2.6.12.
Maintained LTS branches with this crossing path also need the check.

Signed-off-by: VeroFess <coderzeng@gmail.com>
---
The combined fix tree was tested in an x86-64 KASAN guest. High-port
AUTH_SYS LOOKUP returned NFS4ERR_PERM, named SECINFO returned
NFS4ERR_ACCESS, and the CLONE destination was unchanged. Low-port COPY
and CLONE and high-port GSS privacy access succeeded. This patch also
built alone with W=1.

 fs/nfsd/export.c   |  8 ++++++--
 fs/nfsd/nfs4proc.c |  4 +++-
 fs/nfsd/nfsfh.c    | 26 ++++++++++++++++++++++----
 fs/nfsd/nfsfh.h    |  2 ++
 fs/nfsd/vfs.c      | 21 +++++++++++++++------
 5 files changed, 48 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index f0dd9fb..3bdc6b8 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -2077,13 +2077,17 @@ __be32 check_security_flavor(struct svc_export *exp, struct svc_rqst *rqstp,
  * @rqstp: svc_rqst attempting to access @exp.
  *
  * Return values:
- *   %nfs_ok if access is granted, or
- *   %nfserr_wrongsec if access is denied
+ *   %nfs_ok if access is granted, %nfserr_perm if the
+ *   originating port is not allowed, or %nfserr_wrongsec
+ *   if the transport or flavor is not allowed.
  */
 __be32 check_nfsd_access(struct svc_export *exp, struct svc_rqst *rqstp)
 {
 	__be32 status;
 
+	status = nfsd_check_port(rqstp, &rqstp->rq_cred, exp);
+	if (status != nfs_ok)
+		return status;
 	status = check_xprtsec_policy(exp, rqstp);
 	if (status != nfs_ok)
 		return status;
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 2c65302..43c2aa9 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1086,7 +1086,9 @@ nfsd4_link(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
  */
 static __be32 nfsd4_secinfo_status(__be32 status)
 {
-	return status == nfserr_wrongsec ? nfserr_acces : status;
+	if (status == nfserr_wrongsec || status == nfserr_perm)
+		return nfserr_acces;
+	return status;
 }
 
 static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh,
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 0939146..4b5280e 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -102,11 +102,17 @@ static bool nfsd_originating_port_ok(struct svc_rqst *rqstp,
 	return test_bit(RQ_SECURE, &rqstp->rq_flags);
 }
 
-static __be32 nfsd_setuser_and_check_port(struct svc_rqst *rqstp,
-					  struct svc_cred *cred,
-					  struct svc_export *exp)
+/**
+ * nfsd_check_port - check an export's secure-port requirement
+ * @rqstp: request being checked, or %NULL for a local caller
+ * @cred: credentials used for export option checks
+ * @exp: export being checked
+ *
+ * Return: %nfs_ok if allowed, %nfserr_perm otherwise.
+ */
+__be32 nfsd_check_port(struct svc_rqst *rqstp,
+		       struct svc_cred *cred, struct svc_export *exp)
 {
-	/* Check if the request originated from a secure port. */
 	if (rqstp && !nfsd_originating_port_ok(rqstp, cred, exp)) {
 		if (IS_ENABLED(CONFIG_SUNRPC_DEBUG)) {
 			char buf[RPC_MAX_ADDRBUFLEN];
@@ -116,6 +122,18 @@ static __be32 nfsd_setuser_and_check_port(struct svc_rqst *rqstp,
 		}
 		return nfserr_perm;
 	}
+	return nfs_ok;
+}
+
+static __be32 nfsd_setuser_and_check_port(struct svc_rqst *rqstp,
+					  struct svc_cred *cred,
+					  struct svc_export *exp)
+{
+	__be32 status;
+
+	status = nfsd_check_port(rqstp, cred, exp);
+	if (status)
+		return status;
 
 	/* Set user creds for this exportpoint */
 	return nfserrno(nfsd_setuser(cred, exp));
diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
index aa3ff30..90b6429 100644
--- a/fs/nfsd/nfsfh.h
+++ b/fs/nfsd/nfsfh.h
@@ -226,6 +226,8 @@ extern char * SVCFH_fmt(struct svc_fh *fhp);
 /*
  * Function prototypes
  */
+__be32	nfsd_check_port(struct svc_rqst *rqstp,
+			struct svc_cred *cred, struct svc_export *exp);
 __be32	fh_verify(struct svc_rqst *, struct svc_fh *, umode_t, int);
 __be32	fh_verify_local(struct net *, struct svc_cred *, struct auth_domain *,
 			struct svc_fh *, umode_t, int);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 269dc49..2775911 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -123,6 +123,19 @@ nfserrno(int errno)
 	return nfserr_io;
 }
 
+static __be32 nfsd_check_crossing_access(struct svc_rqst *rqstp,
+					 struct svc_export *exp, int access)
+{
+	__be32 status;
+
+	if (!(access & NFSD_MAY_BYPASS_FLAVOR))
+		return check_nfsd_access(exp, rqstp);
+	status = nfsd_check_port(rqstp, &rqstp->rq_cred, exp);
+	if (status)
+		return status;
+	return check_xprtsec_policy(exp, rqstp);
+}
+
 /*
  * Check if we have crossed a mount point.
  * Returns an nfs error leaving *dpp and *expp unchanged,
@@ -168,9 +181,7 @@ nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
 			err = 0;
 	} else if (nfsd_v4client(rqstp) ||
 		(exp->ex_flags & NFSEXP_CROSSMOUNT) || EX_NOHIDE(exp2)) {
-		nfserr = (access & NFSD_MAY_BYPASS_FLAVOR) ?
-			 check_xprtsec_policy(exp2, rqstp) :
-			 check_nfsd_access(exp2, rqstp);
+		nfserr = nfsd_check_crossing_access(rqstp, exp2, access);
 		if (nfserr == nfs_ok) {
 			/* successfully crossed mount point */
 			/*
@@ -222,9 +233,7 @@ static __be32 nfsd_lookup_parent(struct svc_rqst *rqstp, struct dentry *dparent,
 	} else if (IS_ERR(exp2)) {
 		nfserr = nfserrno(PTR_ERR(exp2));
 	} else {
-		nfserr = (access & NFSD_MAY_BYPASS_FLAVOR) ?
-			 check_xprtsec_policy(exp2, rqstp) :
-			 check_nfsd_access(exp2, rqstp);
+		nfserr = nfsd_check_crossing_access(rqstp, exp2, access);
 		if (nfserr != nfs_ok) {
 			exp_put(exp2);
 		} else {
-- 
2.43.0

