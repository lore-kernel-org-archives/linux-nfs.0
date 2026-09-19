Received: from fhigh-b5-smtp.messagingengine.com (fhigh-b5-smtp.messagingengine.com [202.12.124.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8E47B29408;
	Sat, 19 Sep 2026 02:26:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789784817; cv=none; b=RPE36z3dlZEF2cdhJd+pxJZQGEhDLz2O2QkRuuga1nr+bEC4aZzgWv3eFqZYYaothBNllSOFEq4JxwMLOuRxy6vOh0zlPxqH68VE3WsmQKqSa0X9OkV+1uBrte1LNmw2KK+qNcb9O+0Es5xY/1RaiwBvkFebrJcqAbfSbBMRpqM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789784817; c=relaxed/simple;
	bh=vn17zVxHjCDf01gjr8gu4eZfUkO7VpbSrlgfS+h9PU4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=FLJf4ESn4OoIb9/BB1vJmzc0y+C/bcit3Zqsk0XHf5Yii3ce70/CSXEDEzb5O86CmrqRBEFOiJHP78QeghF1Y/sl2oxk4rnzmFsZYAZWAsjb0iQtwCmk6NnQFZIRHqOAZQ0EH0vUxhtWFJ2buJ0Yp5bY6fbCmUXyUnRXfUweX68=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=VuFzwl5u; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=VV/ti+b7; arc=none smtp.client-ip=202.12.124.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="VuFzwl5u";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="VV/ti+b7"
Received: from phl-compute-08.internal (phl-compute-08.internal [10.202.2.48])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 986E97A0108;
	Fri, 18 Sep 2026 22:26:55 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-08.internal (MEProxy); Fri, 18 Sep 2026 22:26:56 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1789784815;
	 x=1789871215; bh=IgH4lm8uOrokKOmBvOD8T1q7ZWk96X4o3lWYpINK4Ps=; b=
	VuFzwl5uHt3tvl67JCNx29udkMDxIJ2uxSJjjDKCdWjyZb8fgHbCpZVyHWCGHpcW
	OldT0md4qKtpZiWMXVViIXjeSISB1lWT9XYSX8qEDKVtJWWW7AXk0386QXfvzB8Q
	nSDpJf9cqYIXZE2DdShTP5ykFeN5n30v/D1X55H8IxWrw4mUf+i4CeQa/yzdA6R6
	6VNPzZ0TKZI1OK38PrRz4aZMG8JROjBYyVPmO2TxJq6g2BRklwWoHXHsq30jPj3D
	OsS86VauXV6u2N3V+1bKz+cqBikTLzue2l+m7LfVcbnOoVcdiLKsL1/zvEe+iOP4
	5V3VZGeCtGUrfwbqXKjF+g==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1789784815; x=1789871215; bh=I
	gH4lm8uOrokKOmBvOD8T1q7ZWk96X4o3lWYpINK4Ps=; b=VV/ti+b7JjKfCivzj
	/6TffQr8ugKvbVPgB0cJsVXoVvZi7Yir5y3zbfLbQ/R8n3Jo8lV11vQkVlSUmvdX
	kSec5tV2fRJraGwT+/ltvYug/p2TkCfjX8Y7AaalvSvSbPQu/vIv4dBOHeIcwP2K
	yjuHbcs9VhdIYO3xuUKSfKVmUhvw8Js1zCr6RDiy7tBv6MkhENDuManSQtaSo/sj
	lMYt3pN1+QC86gAALhV6gYeimz55hgeqKvHRcWNHAwPPeqQfPFIVdinqAfvn6FuW
	hhd5iOjcwbbdLfs0Nv6a99CSWNwOpQbU2RhIfBLbJ1GZuhe92oUINGml65TAgYPc
	J+UIA==
X-ME-Sender: <xms:7_Ktar_Uuii6H5JgcC4s4vDrFuSgJAj77OwiueRC05aejYXHbYLfFQ>
    <xme:7_Ktagg9fnMfbZwD6-fmz6z4Whbvu6aSaU3-_Bjen35woZQB_ED5mF9BogBLdxugT
    7RtN8rJ8JtQO-qxvm8mEv1LDGUk2u8c3q0WG6afuSDIYlbClwU>
X-ME-Received: <xmr:7_KtaqXdxmhvyO4Uy7JnKzbsWES-dyWMwi9EobN27JzcZqze4Pn7TSqRbOzNW_BbD0lW2j_pgu9vg9OFngzO8LEjD1U0XXk>
X-ME-Proxy-Cause: dmFkZTGgqDvHUiFoelb3szb25Xc5WIL1X0CmKVd0SSFttbFGm3ZS4/WbThw2/23Wv0kT2L
    zTiD3f7/mbRn4xQkog4u9WXAUu/Z8xbLL7habzJ5iT0L9pvsBxuMoK5k8M+5CBBhCA34Md
    HPlNAQAuPUTpsFoyG9EfHruislsqzF/ELe8vhu1WoHNTpMpKsXLXUP8fPb+iJDnGZK+wxX
    pyu1Y8XGp2Ez4Y8aWvA0+LsWIM5P5beRGa1K+yf2x8AAFZFB+FqQNejpWDyXiPsbkOSKyy
    pf6WO9eid06RPw0E0qVieiQBSzbPbVfHpbR/XZ98dIIyde1pgFtUnUmkW5DtGlTWNRmktE
    VMotPuxaactwgHgO/mct7vbxA+cm0jdYrSNhSlR5sswIqVL88aJFwYMPeADs+aj8gqv7Zp
    6UtlPk/o5Ho7DYiFznEokSy1plh7fgh9yYPZGEMD7xgL6mjQ5wpzsVsUYtZdsieZBrAETh
    baDO55s2JXOmhP64fa9qL9Sgcn12rfO8cLi0dVPJzgjQ4KbCcr24JHJ2ZIfRcN1sUp3Fhx
    gJxF538kH/V55KZUZv+wMRJrMAyBgMmiUI5xLNt2pVp7f8l0ngtESDYNH40bjrHDbTMcbU
    ajWni0Zl6j5bquqJ1mdeFfeWUaL3/UZYX96rvdqvoCAjTG6QrgfwsPkAArGQ
X-ME-Proxy: <xmx:7_KtasuhGU0NeBLzLZq5mir2LWZ7DCZueFe_mioghqtGXabJPuS0XQ>
    <xmx:7_Ktaj_tJbeCMaqQa2AEiNkt7HeoU9PqBOI3J5JEUnPCgYnkecYIZg>
    <xmx:7_Ktaks7hqxclE7WylZZJnExq33SGKAtZib8jDGAP12zTes1812N4Q>
    <xmx:7_Ktah5o_dyz1bDWAYlAWe2W1PD1y3_n89IPWvVQcoPjwIpickkGLw>
    <xmx:7_KtarbJ9-0c92fi6ia4wRmnFZ7Yka8jm59DM28y9oMLlK56mxk3l3kc>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 18 Sep 2026 22:26:49 -0400 (EDT)
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
Subject: [PATCH v2 13/14] nfsd: change nfsd_check_obj_isreg() to use nfs error codes.
Date: Sat, 19 Sep 2026 12:06:17 +1000
Message-ID: <20260919022441.3305170-14-neilb@ownmail.net>
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

There is no longer any value in having nfsd_check_obj_isreg() return
over-loaded error codes which are converted to nfs error codes.
So revert to directly returning the required nfs error code.

Also take the opportunity to avoid dereferencing the inode and determine
the type directly from the dentry.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 50baf125d5f9..40bd1179bf60 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -223,17 +223,15 @@ do_open_permission(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfs
 	return fh_verify(rqstp, current_fh, S_IFREG, accmode);
 }
 
-static int nfsd_check_obj_isreg(struct dentry *child)
+static __be32 nfsd_check_obj_isreg(struct dentry *child)
 {
-	umode_t mode = d_inode(child)->i_mode;
-
-	if (S_ISREG(mode))
+	if (d_is_reg(child))
 		return 0;
-	if (S_ISDIR(mode))
-		return -EISDIR;
-	if (S_ISLNK(mode))
-		return -ELOOP;
-	return -EFTYPE;
+	if (d_is_dir(child))
+		return nfserr_isdir;
+	if (d_is_symlink(child))
+		return nfserr_symlink;
+	return nfserr_wrong_type;
 }
 
 static void nfsd4_set_open_owner_reply_cache(struct nfsd4_compound_state *cstate, struct nfsd4_open *open, struct svc_fh *resfh)
@@ -565,7 +563,7 @@ do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, stru
 	}
 	if (status)
 		goto out;
-	status = nfserrno(nfsd_check_obj_isreg((*resfh)->fh_dentry));
+	status = nfsd_check_obj_isreg((*resfh)->fh_dentry);
 	if (status)
 		goto out;
 
-- 
2.50.0.107.gf914562f5916.dirty

