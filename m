Received: from fhigh-b5-smtp.messagingengine.com (fhigh-b5-smtp.messagingengine.com [202.12.124.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7FC311A2C04;
	Sat, 26 Sep 2026 00:11:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790381502; cv=none; b=RmTMGEOaI7iofFYQU8P69f6AbWwPC1aaMdW4N8j+555vWM1S9ZeFd2H7QLmoZ8pJgmytJuPYdyRWxjKyczUQn+/QLiaPGILqei5tzbPRyTjqDQ1aa9XVZHFQR3AWO96NKdTQE4BbtyZ9h2G0VX6tMtBwUMXhOWALd7V5a3jRbjQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790381502; c=relaxed/simple;
	bh=WdxqYmBzZ6kdwMtQ+NHPMJ/NM69S5iVaaJ+croqWJtw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=I4yxW2dcugx9piZUv4+BVEm9J9UWMJfuW5JHHfntefnoy3H28SUuG8C65lQT3OyL1oJnN0eUqnLvKHY4ofBZXscG3ynnxD3Rxja7ayPFZk0ZhAlnPZTfNVRltEGqmhMfebjlQUDPhTaupMg5jZBSvsXQ8N/lVInrztbc0np2TP4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=jtDUL3r6; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=xWH6yLRQ; arc=none smtp.client-ip=202.12.124.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="jtDUL3r6";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="xWH6yLRQ"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfhigh.stl.internal (Postfix) with ESMTP id CF3F27A00A7;
	Fri, 25 Sep 2026 20:11:40 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Fri, 25 Sep 2026 20:11:41 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1790381500;
	 x=1790467900; bh=zv6iRblgD9uTVKOWe5EPmZ9usJsI+AGb0INDth0Pgv4=; b=
	jtDUL3r6IDnguR7MJBkaALE2rfzMwijNRMr8zw/ddfo/pfrpxHERTc18mFEUACiW
	yebXPfvDhalnORDKOhYOVUpq0OARCiHlK8+mAfYAh/YBrKgrSkiI1qZcyhljN2Dx
	u8gpTIPDRps5MGbuYx5Cc280PThF1X6QpZiJXxN0WOn7YY064crPT8B/bwpHA9nV
	2RsJJZvrrIYaevwKxTRngmxXt0Ugr/Gb2685wLnzjM3cdxKjAnFqozclipniv97w
	vh69z3ouTjGVJYQbKIm8sLeXpRhTJOZOuaTAgs+iJGrCnOUMV5Y8BoMVodV3o5nV
	KhysJrnVnyAGQ2Jncg/Rlg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1790381500; x=1790467900; bh=z
	v6iRblgD9uTVKOWe5EPmZ9usJsI+AGb0INDth0Pgv4=; b=xWH6yLRQ9m1DOCRCw
	/iv5EZfZhduyuUlRuwIlj94NcUvyAKGcrRSRoHYgVJsC9Ei7SQW9P7cbbA+7SIHh
	KtA9D0TxmMOKjF0lAzjPsF6bV1jkhLiPYi2W4X6WFHMSyAbBsoDsSXwD3VWvqRZS
	Zze8+nCL2gkP1IlRMEhLHosGLRPIcz5AO5ETGsObvQsOWV3nn1Iu7790mGPoUkI2
	hffLfnM0e5qZYbtXpjbwAPJu9jeLeEA7t5FucKU6JaH/f/4kWG/8R6Q79eMaKk33
	PhqI9ujvwKDqxNOZAJF/0YDnttodKohvLvwRNU/EfKown9Dw/Vdy/ditQ+trte7V
	vHzVA==
X-ME-Sender: <xms:vA23aiHerCvYFB36fS6R9pktH_4xZnMtj4eGluJGe5NQETpUuaczaw>
    <xme:vA23al4aTH9H2spPRtpsog9fPGcqMkKEdXxC129y_AAeChrUsxMDrA4wY00vjCDUB
    nRxnhuB5N93nMrXo0zyYOtJYopRMgy5fSjEysKUkFTcMP2fmHI>
X-ME-Received: <xmr:vA23avyC3ew6klv3OTg2ioBSn4s8GfnQl7RwebI-p48pfBZ9ikPPV8y1qtZ6Xo7JdCqrA5PMqZ80b3B5xY5YbxjuCdd-RDk>
X-ME-Proxy-Cause: dmFkZTGM0ugnSXn6DL1OW0CeLj5v0nK6023RIIllNb7waCK/mhoAShU4kPP/cBOuN9EJEq
    RbggTiaZ+cC3APa7hYSauWhh2cebO4bU/IMo/94JaXWh8pF2N01W8SDZPDEMv2NwdIl03r
    nUnGoc2MRuB8ydZBp3/C1UE1NN69DPwMDtKYVTTux5an3jDeBSJ3tDMF3G6rMYzb/sNNAG
    CVBaTN1jpH6ce+aq+2YYu18UlOBvRr22sXl5PrZhIkyJ9pgY4pP/+kOrWF0gnR4ivhDy56
    WmnKB9eCjmMQDSSxeRW5PbgfhYVPR2UXtHnlwpkeoNRf+kYpnFKzkYxodKaRIN0SosiUax
    YQRYNsqaprkblTUkB64lOjxK5KseUKLvU991hTNnj5F02wCYtzuWM24c82yLaPlFWtPdpt
    OrQQ2j0A5MTdQOmmrXOtvx4EXDcDs7p22YBs/eWbrCWJP6rUxf2rSQ1EAatQzlevad+b3A
    lNTT/muA/s8T2vrBPF9IAkfMCFE2edRAoteq2bcVDNdrJ1ofiysXVckHGYTjcCXbqRHsqd
    6HstaX9HcGt30oU3Z1QGpEVc8wvVLYuhBRgfMMqZX9+Gf3O1aTQOKphvbv4CuxFZV0gl2i
    Q6aT+IT/+/fWfGTy0OctsHcVXqYGRapF1sQORdtQDtm3u1tV47LJFYinpDBw
X-ME-Proxy: <xmx:vA23asPi2zPADGrkkTzkDlzGe6zr1rPVJdEgp7GjifDui_K_rPoNJw>
    <xmx:vA23atnunklmbz-Pk3c4lgMIdCqVQI3w4Q8PT0TYzWzEFu9gGvMmwg>
    <xmx:vA23apRe8JIf56ms7VMoZoXEZ_7kTbd7Xmbym47Cb4l-vgS3JUfWyw>
    <xmx:vA23akU5yNazh1y5Pps1skF0jrB01Ncx_GgXgditIkZjRq3_VGXqUg>
    <xmx:vA23aj__IcBFXrSPUdbNNIDsfPkbfXQccxDeDWaIbkGioCqhjuB_XZcS>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 25 Sep 2026 20:11:38 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH 9/9] nfs: use d_duplicate()
Date: Sat, 26 Sep 2026 10:01:26 +1000
Message-ID: <20260926001011.401824-10-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260926001011.401824-1-neilb@ownmail.net>
References: <20260926001011.401824-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

As preparation for d_alloc_parallel() being allowed without the
directory locked, use d_duplicate() to duplicate a dentry for silly
rename.

This results in an in-lookup name, so d_lookup_done() must be called.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index b54ae3baed46..6a6ace0460bf 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2801,11 +2801,9 @@ int nfs_rename(struct mnt_idmap *idmap, struct inode *old_dir,
 			spin_unlock(&new_dentry->d_lock);
 
 			/* copy the target dentry's name */
-			dentry = d_alloc(new_dentry->d_parent,
-					 &new_dentry->d_name);
+			dentry = d_duplicate(new_dentry);
 			if (!dentry)
 				goto out;
-
 			/* silly-rename the existing target ... */
 			err = nfs_sillyrename(new_dir, new_dentry);
 			if (err)
@@ -2870,8 +2868,10 @@ int nfs_rename(struct mnt_idmap *idmap, struct inode *old_dir,
 		nfs_dentry_handle_enoent(old_dentry);
 
 	/* new dentry created? */
-	if (dentry)
+	if (dentry) {
+		d_lookup_done(dentry);
 		dput(dentry);
+	}
 	return error;
 }
 EXPORT_SYMBOL_GPL(nfs_rename);
-- 
2.50.0.107.gf914562f5916.dirty

