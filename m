Received: from fhigh-b5-smtp.messagingengine.com (fhigh-b5-smtp.messagingengine.com [202.12.124.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B731129408;
	Sat, 19 Sep 2026 02:26:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789784800; cv=none; b=S32m1EfEkZUYL7/vWDd4Dqe5uHi5b9H+/c3/DmB8/Sm/HvFKnp+yvnEIOXABxou3jSIt+WQkisRr5EwFfpet79NhaaPHoemjJuLRvTSLRRFpdliVnzDthDVy5iGwQfudSmalFLkvFM5Dmnhb91QGf4YHD8LOdRKVEsY7Q9Vndw4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789784800; c=relaxed/simple;
	bh=YmC59NAUC7/uUbhj1BJ/zSEWfT+TfTXDmuq1GQDsb0o=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=R1PqLum7dUvVlHbWQSRqi+MLg5fqB7U3gjSDp7aQuwrZQW7OvkKgQiKn4dtcnxiLRrhMRNvVuNCt8j4lnDnNBYATdgLaJlnECowJ696Kg3ulFEUpvvzhV+h9kh5961bHV0mTncbOSTKJaFouOkfWnMJuJArijUC98zmGpw+fo3Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=W8654+RX; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=fbcBSW67; arc=none smtp.client-ip=202.12.124.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="W8654+RX";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="fbcBSW67"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfhigh.stl.internal (Postfix) with ESMTP id C55CF7A0111;
	Fri, 18 Sep 2026 22:26:37 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-06.internal (MEProxy); Fri, 18 Sep 2026 22:26:38 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1789784797;
	 x=1789871197; bh=Bfas5eoj6gTl6gT4OiBpfvkBBi/UOvEDd8xjCDdIVxw=; b=
	W8654+RXA4fm8Eg3wfnhxF/nda66MLqYnWwxSy/2BZNq5sYKJt6fNror0pY7GiqN
	5NkCrsFFI0QZmu/YB9h2Wp7hMaZUhdkPGNWnoAszgvrx1xyyANCL0WEUwgYzP9MN
	LWlLhvre8Q4wk7xW/0wYA4DSlDX57t+s9R5BfhhFasL9OtaHTfB35xZKRv8biJ8Z
	UarJa2u/t4LjbJZemCJncW2g1/9E9vUjE9ttCVlUIFeGsidNc9KEu8SVBzJyM2DS
	TSZnpInyTdoIg27MMx3drZeogjtCheVj/NiW0a4MRWyVFlATnTojn+DPCpmHXTng
	yrJHIa3H4UiA24V48ay3kA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1789784797; x=1789871197; bh=B
	fas5eoj6gTl6gT4OiBpfvkBBi/UOvEDd8xjCDdIVxw=; b=fbcBSW674z5RO9z/J
	Ut4mw6Rpan6nJ04tUzj5jpH2qxaYNcVoP/VhKa+ylOk5PPa6uG1y/ZtpKzFeyk33
	CtR1haqm/3kF9R5KSeyVjx0pkzp73QonvxOaIQ+pyhYyIyN5Vgf/F7ozQow14iEk
	aulXuTxQES/B0PYBrLmr8nzgh16uva7vAZJgr3a2XIWwnETF34rw2e1FwY+RKUBL
	OR0vM+/zS0KAct7A7PNY5HDmaYZoG8Hw3oH7wNIc8wfhdelMzfg8wzU/fDZuH9Kq
	gMlQUFCf24TJ7p3dH1FFI2ZHTSr9az/sndJ7uFGvZCZF00NQ73gR4DhbP0hc4Zer
	p58QA==
X-ME-Sender: <xms:3fKtaj6ZC4I6VIt5LBnt5YsA34IoZ7CH0nZZ-I6L5MWd1D_zfCWdDw>
    <xme:3fKtapSn1J0YrA_AjzOKGp2UtmYrVKP-czE-7HUlkGJG6EIPEfufZxpqaGR7a4LUw
    vS-CaZ8KBjGLMxLkWWI2vAxj90ADPLdZb7JHV1Jk9liZpdxeUE>
X-ME-Received: <xmr:3fKtarlfRJXCZZSOlcD8l3DCFzDyOH83nVNV0-49V6W8yYfhHgMlyJ9dTMjuAujOkzXu4DpXLeCtLmCo0T-VMGYNBNGmc8E>
X-ME-Proxy-Cause: dmFkZTGgqDvHUiFoelb3szb25Xc5WIL1X0CmKVd0SSFttbFGm3ZS4/WbThw2/23Wv0kT2L
    zTiD3f7/mbRn4xQkog4u9WXAUu/Z8xbLL7habzJ5iT0L9pvsBxuMoK5k8M+5CBBhCA34Md
    HPlNAQAuPUTpsFoyG9EfHruislsqzF/ELe8vhu1WoHNTpMpKsXLXUP8fPb+iJDnGZK+wxX
    pyu1Y8XGp2Ez4Y8aWvA0+LsWIM5P5beRGa1K+yf2x8AAFZFB+FqQNejpWDyXiPsbkOSKyy
    pf6WO9eid06RPw0E0qVieiQBSzbPbVfHpbR/XZ98dIIyde1pgFtUnUmkW5DtGlTWNRmkO1
    tW0GGVDTRwtKBGFoRS1xsMA/6OFLzDhXTgNuEBQ6mFI6B7/GkoSuSzhSHTUZFjwXh+zdwQ
    GNr5BGvh17pfQzyjnss8bxp3/hzn1x5YvfMI+T2IJxlq5rpmidlT21yZxiZ9hA12xTkwIy
    1GjY05xvJ6fLHn6p1RSsgHpCAGb5k00zMdVflsRKvc0Yi7VcjaJkuYjqEQFHO+1taOCVrC
    EVHMwxDTXvo47rtz92PsUP/oFsDw+MmygYU+aZJVPwyAKHx1xgk3BoSg8anEW/sN+3HwxR
    ZfDnskicWx6bcn4lZkpJSdJ3NOSjSbFszG0ACb+AhmWppG9+rTkubX8Int/w
X-ME-Proxy: <xmx:3fKtagKpekYeXXK7Rt0OF5vH5JR9x5GWt7Ah57WGHI3VCjhsgLwuJA>
    <xmx:3fKtamTGGFsiKhwYgNlJcxQQjmG0_xo_LmphoQzUHOb08l2FXu3wBg>
    <xmx:3fKtamT4tVIz0yYHOLjvqEQeTsTFclqKQCK1EP76izYAi7RqQzMhow>
    <xmx:3fKtagw4-q4t5-GVOIpClZT4Dfq1zXIyJgGC6qqb3NMBvkEos1d5oQ>
    <xmx:3fKtagtbATJRduzyGLstjy689tGFQ1ZkFaliPViHLYN4peOPsWH3oWqX>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 18 Sep 2026 22:26:31 -0400 (EDT)
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
Subject: [PATCH v2 11/14] nfsd: check for mountpoints after non-creating open.
Date: Sat, 19 Sep 2026 12:06:15 +1000
Message-ID: <20260919022441.3305170-12-neilb@ownmail.net>
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

A file can be a mountpoint for nfsd purposes when it isn't in the
dcache.  This happens when it is a junction (nfsd4_is_junction()).
So when we open a file and find that it already existed though
not in the dcache, we have to check if it is a mountpoint (or junction)
and potentially follow the junction.

So move the mountpoint crossing code in nfsd4_create_file() to a new
label at the end of the function and goto there both when an in-dcache
lookup finds an existing file, and when vfs_lookup_open() finds an
existing file.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 41 ++++++++++++++++++++++++++---------------
 1 file changed, 26 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 6e443503d0b7..3d37754f787b 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -320,6 +320,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	};
 	__u32 v_mtime, v_atime;
 	__be32 status, create_status;
+	struct svc_export *exp;
 	int want_write_err;
 
 	if (name_is_dot_dotdot(open->op_fname, open->op_fnamelen))
@@ -339,21 +340,8 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 						    open->op_fnamelen),
 					  parent.dentry);
 		if (child && !IS_ERR(child) && d_is_reg(child) &&
-		    unlikely(nfsd_mountpoint(child, fhp->fh_export))) {
-			struct svc_export *exp = exp_get(fhp->fh_export);
-
-			status = nfsd_cross_mnt(rqstp, &child, &exp);
-			if (status == nfs_ok)
-				status = fh_compose(resfhp, exp,
-						    child, fhp);
-			fh_fill_post_noop(fhp);
-			open->op_truncate =
-				(iap->ia_valid & ATTR_SIZE) &&
-				!iap->ia_size;
-			dput(child);
-			exp_put(exp);
-			return status;
-		}
+		    unlikely(nfsd_mountpoint(child, fhp->fh_export)))
+			goto do_cross_mnt;
 		if (!IS_ERR(child))
 			dput(child);
 	}
@@ -466,6 +454,14 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			status = nfserr_exist;
 			goto out;
 		}
+		/* We opened an existing file, it might be a junction. */
+		if (unlikely(nfsd_mountpoint(child, fhp->fh_export) == 1)) {
+			dget(child);
+			nfsd_filp_close(open->op_filp);
+			open->op_filp = NULL;
+			goto do_cross_mnt;
+		}
+
 		/* NFSv4 protocol requires change attributes
 		 * even though no change happened.
 		 */
@@ -511,6 +507,21 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 out:
 	nfsd_attrs_free(&attrs);
 	return status;
+
+do_cross_mnt:
+	exp = exp_get(fhp->fh_export);
+
+	status = nfsd_cross_mnt(rqstp, &child, &exp);
+	if (status == nfs_ok)
+		status = fh_compose(resfhp, exp,
+				    child, fhp);
+	fh_fill_post_noop(fhp);
+	open->op_truncate =
+		(iap->ia_valid & ATTR_SIZE) &&
+		!iap->ia_size;
+	dput(child);
+	exp_put(exp);
+	goto out;
 }
 
 /**
-- 
2.50.0.107.gf914562f5916.dirty

