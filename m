Received: from fhigh-b3-smtp.messagingengine.com (fhigh-b3-smtp.messagingengine.com [202.12.124.154])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 427DE3019C8
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 04:33:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.154
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784262832; cv=none; b=DdytHldBavnej6mE7k0LEKuSgic4ZUF9lpC3PvIGRWDVM4syh1dD0jRamfOpma0LBYuYlr9pR67MhYIbFCwkwdbg/I5sy+puOdGlTCBxyOtYRRXlFEhJCeDWc5rZzrKjsqNBGb73dL8UfeeGKiLXOfKIT8Kgg6PQQdUN35Rq+Yk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784262832; c=relaxed/simple;
	bh=x+SiEbaSOQK1Q2XS1vOljd65NgCyEZt7dIMc+5s38UQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=OU1sOgVPkTuUGv6MdCjTgrNZ5k1MMarlfmWXzxzJKa9JxRzgF3nzEjhiG+jebMS8LCocmh2KCG/gvxCSdJ3GflHUKvSJNem0KyrXkSbv/d1pS8DwYvI2KSy6fssIFUTuMMWL96f3FEZcV+wvVG/38XYKqT26Ui6mb6KHG45w1Lo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=mONci3FA; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=cYfxCuIq; arc=none smtp.client-ip=202.12.124.154
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="mONci3FA";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="cYfxCuIq"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 7665E7A0078;
	Fri, 17 Jul 2026 00:33:48 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Fri, 17 Jul 2026 00:33:48 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784262828;
	 x=1784349228; bh=SbBQK6cYjstdW/ttdwKi9dQ7z6gOS+bACEIlfxQCuiY=; b=
	mONci3FAXtHlu+m2pbwS4dqwSm2rm8jIDLet00MYAr39ob6NbKzC8HugHN5IRIOh
	xBuA7CXOX1rjXPB9ef+gOkMPQgn6aqCHW3pfRcw7eaf3j27YsK6W67D2S85zKLcr
	TzZ27Wc5jUwLRbUaF6NDE+hByEphqSpXdOV+1saGDz5UjnobT3PaqDwLO8eKDVvc
	3MnSHfgfSrzP/FmrVLcwdAkr5v3k/MStRfaOgKQwQFq3ThCXA4C3g7WhYZb+iO9K
	qT1xi5sy8tj0i7uvDSpe4NawVoVi87ic9I0e9ogNWoiZJBiK/AI2yO07YJVn2HyH
	4kMI1ja0KkIhq8TVkwBYpA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784262828; x=1784349228; bh=S
	bBQK6cYjstdW/ttdwKi9dQ7z6gOS+bACEIlfxQCuiY=; b=cYfxCuIqRb70+kKjg
	Xox7vOPLa53QwSUvEL443rWz8t9b+WMRrYi/NupTNBORXAqB1IUCkLatiDVbd1OX
	B9zQU/bZzq/KO9kbAk2uT58X70MuA02Rrxc+F2U0D8367S0CndR1pKB//K7mtKJV
	G0Ac6YV0lRpnDe8D00x7tZAdexG9wsSmA/XM5FXwWVu4sx8NNFMD/YuDSEpJx52v
	cZkYV0hEW+185qHNY8wXV8stazQvFdl4tq7C4wFRLto8ysaNUzqiHBNSyQhUKn1V
	XIbSy6aQojhJtuZ1iWutqwK0nXpYQKWiE807y8FC0tnfpbLbxeuLV8x5vqD7ire1
	+TTmA==
X-ME-Sender: <xms:rLBZaqGS9uVcUIrntRlHQ4jq7rEzwPftuFK-kEMR4Z6m9TPStOEdzw>
    <xme:rLBZavBVljP9H_qrpbJROhcJXD6nx7Nm8V_H8D1EEZHTG2pN98m-hccqazfdkZLSt
    rvxZiPpELdX6MztzX-47Ck8lRI89ING-CAs5vVycNYSx-qh>
X-ME-Received: <xmr:rLBZat-RO6qipuLNX1al2m23VsnvquWCoxV3yW1onh35pUvKuqOHdBIeuwW7I-Su42SczwFhF2IcSFrhPWlIgXn_nIEZszs>
X-ME-Proxy-Cause: dmFkZTFf1QU68ccbCX8W2k8Y1nGREK2lfBZ8muLx/9jWiTseOaEvZ5XgO1veuwpDDLDOh8
    GTBUmiRJRPyTQkIt2BUTpACGqxcYNQqe9Tcjx6k+JMfW40TZxrio5AhHmqjioKB7znJTir
    ATb1v/hlECnvAs6heOVcOHOlHDBfVnNe9pooX5hb/po3RqsBkktpkbuLKQfQYMMzr+JzB9
    /njxHQoF8AY+jho0jMT1tubTiNoCuayOLJLgFmAfFIsropGRO+BVYqdpkyAIA5dLkXTXCV
    Ha4vNgb6VzTYvk/ZKP8hUsX7dik9VUXtlC+e2jQNq5KVv1wL7YMoKmhY7BOqudAWlfzyEk
    OV4MhQaKmR6VYFd7rc25JOsKRDzCHuZXUCs1MwGPoqt7bdDWVj6LIHdVwS1zLuL/sJtBxa
    5eDxQs9DqODsxm68yGiA3Sa3Xsrmyk3qBCkZThpC5suQgEn0kPSgbLTxUzcc+9dl7vrUXL
    t57RBNQBWLR1ps0q8U4xAG+eONKnXcwQJqy3LodYGaSxGAyZuOVoX4CxThFbiPckgEapkn
    cktSYk63NK4UVo0DVdtN9cH+oW9iNr1tJqAkdAwr7JuZsL5mFNOZpjC0g2inui8ggQMTcs
    Izxk1PvhN0gABNkjxY2Sr7xVMyTkU2c79bX1PpByBop3ZLK2AG43KXP6Ai7A
X-ME-Proxy: <xmx:rLBZarDl7L-4-KFNHuexhPA5E7-BY-Jn4RMEtP8bbvlReWD9xxmh0w>
    <xmx:rLBZaiS771Jpw6Ng8PubCBQa5gwP_P7yqLzcJ05Qh1Px3gsakipKBg>
    <xmx:rLBZaisllf7ibqoWbBXW5yRb1ISbzX3waz_Fv0DK3bANbmctrEDMJw>
    <xmx:rLBZau3rkQAWRF6fGPm8EWHkN5xaMNLFIAH5OCepMIWHMPVZmaWhUg>
    <xmx:rLBZakOVNIhk70uA2i_XShpmng3qooKSaWXLSaSu1y9RY1JQlcEJdFNz>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 00:33:46 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v4 12/18] nfsd: reduce range of directory lock in nfsd4_create_file()
Date: Fri, 17 Jul 2026 14:31:10 +1000
Message-ID: <20260717043242.1865905-13-neilb@ownmail.net>
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

We only need to hold the lock taken by start_creating() until the create
has been attempted.  Holding for longer can serve no purpose.

The lock is currently held across the setattr call.  This might be the
intent but it serves no purpose.  Holding the lock prevents the name
from being removed or renamed, but it doesn't prevent a GETATTR or a
racing SETATTR or an OPEN.

Calling end_creating() puts the reference to 'child', but we can still
use the reference that was stored in open->op_filp.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 0b3b358679f3..c04a021d9719 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -366,7 +366,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (d_really_is_positive(child)) {
 		/*
 		 * open the file so that we consistently have a valid
-		 * op_filp.
+		 * op_filp and consequently a valid ->f_path.dentry.
 		 */
 		struct path path = {.mnt = fhp->fh_export->ex_path.mnt,
 				    .dentry = child,
@@ -400,9 +400,12 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		if (status == nfs_ok)
 			open->op_created = open->op_filp->f_mode & FMODE_CREATED;
 	}
+	end_creating(child);
 	if (status != nfs_ok)
 		goto out;
 
+	child = open->op_filp->f_path.dentry;
+
 	status = fh_compose(resfhp, fhp->fh_export, child, fhp);
 	if (status != nfs_ok)
 		goto out;
@@ -452,7 +455,6 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (attrs.na_paclerr)
 		open->op_bmval[2] &= ~FATTR4_WORD2_POSIX_ACCESS_ACL;
 out:
-	end_creating(child);
 	if (!want_write_err)
 		fh_drop_write(fhp);
 	nfsd_attrs_free(&attrs);
-- 
2.50.0.107.gf914562f5916.dirty

