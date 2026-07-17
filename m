Received: from fout-b1-smtp.messagingengine.com (fout-b1-smtp.messagingengine.com [202.12.124.144])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A6E842BD033
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 04:33:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.144
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784262797; cv=none; b=VSBX8ax6OnPgFuJUrOTaUavjeXYhH1RbEFrcMzh/YtvRbb0BvsG8MtnUkYaQjhqkhLcecgz7RawxXPi3Eyr6Dm2OcWJuS1c8M6mQYlrMkzDsGIBh3WHNE0aRX1MD8DE3IoYHuZkyIQZ1IOwsGDiH5h9HzSxVOY5ng+5gUvdwr84=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784262797; c=relaxed/simple;
	bh=2m+JMtyEJSE1ZFg+Sfk3SITYOSRe1A/6Ykmty219unQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=pc8Ay3Is7mMX8pz76y5qhjGTJj5eKyXuhpXFndUrMwK+3gB0ege3tYR7XJlTiql1klzq+zXb6WEmUpSw77r+FZd7mJA0ZE2qp4/We3fiTYD2WFb5lO2DfeBOOHtT+7AthSFJjhiQ9ZOG1/ZutaCTsCmlDkufVNbIjBqNo/OgzjA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=VfBHWc/P; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=HURIxSPj; arc=none smtp.client-ip=202.12.124.144
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="VfBHWc/P";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="HURIxSPj"
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfout.stl.internal (Postfix) with ESMTP id C047D1D000C9;
	Fri, 17 Jul 2026 00:33:14 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-01.internal (MEProxy); Fri, 17 Jul 2026 00:33:14 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784262794;
	 x=1784349194; bh=awl4c3AF4FjF/O1HNQPgGsIGmb7wjykNrBLMBgNgOjk=; b=
	VfBHWc/PLFbeF44Rxi915B74UboZ0l48P5vAxctLEL+81nGk/vdQlu16MP+CtCte
	yRGp6ZZc+pa6K4T6FyL9fXLxISWNR9Ec585e0tfr8Ifpg+mmUAuaOo2lb2n+NJ5x
	2Lkq8l8cWed7UoNByKZK+IrPVvvKQijzvQhItUnIpvjUmxd/nZqPj7B84u/XTTNm
	3yUX69qBoceQYGoGr4xQXi5kf4RPYGjv0FN5uhZQ2VjgWAbFKwkvQvCiJf513Y6e
	npEn7lDOZdDMFYwOhDZqA4yKBlrooWtjyPYxjM5ql9ANviSOGVi3ulCezuHU5qQ0
	F3Z5kGdPNtlr7DVDpl9IWg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784262794; x=1784349194; bh=a
	wl4c3AF4FjF/O1HNQPgGsIGmb7wjykNrBLMBgNgOjk=; b=HURIxSPjVpXbL8ez+
	7MlH4jzqdKh6UESt1HC5UZmC61sBzIYw7QMj0JmPCrgI9STHqWKw6pvnTPCOA96M
	qJDE2vnqADuqTTgd+yIOXMZDoBAmzSdZmgwuZe15NMvBXgm/Kk8RGGl6QzB2dt6z
	hTqOAqd0NZ4pHyqCSmYj8f8T45tlF6+K1VkikrW0rpz5YQkrawoYbo8T9TPi+71E
	yRBpcxKu6tpc8SaJaqL5T87LHSklMFxaN4HENmTJWQCu5s3y639EUP9MOJB0Kc3y
	/jrkDgWjmTJib+0dolo4sZnJf5nb9JFJ/d8+JcA2M/hbGHvbMB7kZCT8mqYVVZKq
	lkT6g==
X-ME-Sender: <xms:irBZaqGV353B_szj3PpdPHr_M-FVfbATyqjQYirQ0yWIN4_ljqUbPA>
    <xme:irBZavCcfp7mi2zvKxmVkFVMYoRDcnCUvz_O9dGJ_W4ruMOp-DRRSgyC74qFsiTNB
    DotJteKt0WZwLd2nXHUMij9NzZZcx3rKM5e_bjtQ0EetwgarhY>
X-ME-Received: <xmr:irBZat_M61KV-yjmFb5S193Ow0wY5JA6h-4VlnDLVS1-JMDzXT-d1cfZg5biQ2Jz4oFEhPUvUxClI5TrOYCSW1elLBqRsJw>
X-ME-Proxy-Cause: dmFkZTFe1fPNt0teZMz+igsEg0Yi62Nw1HA3RWU9lajtn/KqgzCHwE0SDkRLEuN+X2bdVn
    +JxjBa/aSTWuozTeEfNHmtuHiUV9Fs0BisuGE4A6T2CuSFG0Kbv+f8y8Mx+y2wKStdSD9p
    PaPx17A/9gdYw6sCXZWoqwe8lNQRn2EzH+qt+7c1YcHbUG//gzMSJJTZ/alz3WThwvIjtT
    idS8iFF3/6rHUzD/jtcaZ1nbGsquEb2JQSEJPSew5ZS0S8U3+gbXCpYfG8PNx1QnJfm2Ft
    pgkeO93PTIHeEUjFLtz/B0GOYhyxjLHHwxBr0+PWJNH+dGjEfqQKxE8vXo/hgjfbNoODXr
    5AXnSUlxtxcL5VzOmSuQJvW/fx1L4AHcf8mNuFJJcVicf+lvZrfixUcEATF2Neee0MSAsD
    2rfJ/JGpri6ktt8ZjFqB1dhu3t0fN4w/jAqJ3sQM6KlKcsxeFBDgLZlsvC2M3ISFWbWI8H
    qATdb43QY8w8ypx3c/Pvy9tpu0FVLLtP+ijf1Rzv1hd7KkqXquLxKTy+Swt6lp9g/LC5X9
    SkDtg9N9NS1jI7MeZhcFbFiSlQ7aiwIz7lHCScpuNnwKGYSByK3AVKnWqkCrz48DHE6b2Y
    Lyw8sjxMbSkBPjo8ux3+bB44szP5o6ha1Z+6H8VTNCLjqT54x0T6UJKyRIlw
X-ME-Proxy: <xmx:irBZarAE-EvnPIT9OQhtxrI4lhB_xZUwRkHcXw_biTauU8AQl75ceA>
    <xmx:irBZaiTuhYUPWAH0t-Utm8jM1nWBtIBI6POvpCMfWE416UcE9INllQ>
    <xmx:irBZaivcWn7EUTAFw8Gda7R2dY40RpK5B5lLSz-wwvXzUOc5S6FRJw>
    <xmx:irBZau3WKr70qL_5uv8GaTV2qrXzVACVkRrz5kIV3JUccfODa9Pj_w>
    <xmx:irBZavlZPZyGzrAqwoqM71qiDHRzH7Ijfl3UCgMgW4zRyVic5haDmFC1>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 00:33:12 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v4 05/18] nfsd: move fh_want_write() after preamble in nfsd4_create_file()
Date: Fri, 17 Jul 2026 14:31:03 +1000
Message-ID: <20260717043242.1865905-6-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260717043242.1865905-1-neilb@ownmail.net>
References: <20260717043242.1865905-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

As part of separating the nfsd-specific code from the VFS interaction
code in nfsd4_create_file(), move fh_want_write() to just before we need
it.

Consequently errors in the "if" statement that this code is moved over
can now be returned immediately rather than needing to "goto out".

Also restructure that "if" statement to only test is_create_with_attrs()
once.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 31 +++++++++++++++++--------------
 1 file changed, 17 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 6e02976484d9..d5c5f440481e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -297,22 +297,18 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			dput(child);
 	}
 
-	host_err = fh_want_write(fhp);
-	if (host_err)
-		return nfserrno(host_err);
-
-	if (open->op_acl) {
+	if (!is_create_with_attrs(open)) {
+		/* No attrs to check */
+	} else if (open->op_acl) {
 		if (open->op_dpacl || open->op_pacl) {
-			status = nfserr_inval;
-			goto out;
+			/* Cannot specify both NFSv4 and Posix ACLs */
+			return nfserr_inval;
 		}
-		if (is_create_with_attrs(open)) {
-			status = nfsd4_acl_to_attr(NF4REG, open->op_acl,
+		status = nfsd4_acl_to_attr(NF4REG, open->op_acl,
 						   &attrs);
-			if (status)
-				goto out;
-		}
-	} else if (is_create_with_attrs(open)) {
+		if (status)
+			return status;
+	} else {
 		/* The dpacl and pacl will get released by nfsd_attrs_free(). */
 		attrs.na_dpacl = open->op_dpacl;
 		attrs.na_pacl = open->op_pacl;
@@ -320,6 +316,12 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		open->op_pacl = NULL;
 	}
 
+	host_err = fh_want_write(fhp);
+	if (host_err) {
+		status = nfserrno(host_err);
+		goto out_free;
+	}
+
 	child = start_creating(&nop_mnt_idmap, parent,
 			       &QSTR_LEN(open->op_fname, open->op_fnamelen));
 	if (IS_ERR(child)) {
@@ -436,8 +438,9 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		open->op_bmval[2] &= ~FATTR4_WORD2_POSIX_ACCESS_ACL;
 out:
 	end_creating(child);
-	nfsd_attrs_free(&attrs);
 	fh_drop_write(fhp);
+out_free:
+	nfsd_attrs_free(&attrs);
 	return status;
 }
 
-- 
2.50.0.107.gf914562f5916.dirty

