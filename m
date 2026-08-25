Received: from flow-b8-smtp.messagingengine.com (flow-b8-smtp.messagingengine.com [202.12.124.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 068A348EBF7;
	Tue, 25 Aug 2026 22:16:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787696209; cv=none; b=NW+aOc/reCzSJ655iJdHqXio0XYFjhfUjolwkgKLjeti2nxqtE4Bza0a0rqIxO3L7R1FzRSwTqPbqFijEijkoHPaVFaAHcTJFxUejvVhv0XVOQINtz8HD+1N7PxI+shKn4+hUsJxphZJEJOnxpUTxsGiTidoq8b5Cdn8u4emEfc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787696209; c=relaxed/simple;
	bh=ZE2AWEM7O60kQNA58ZkvgPkhSH4ss7eUl3SaCWj191U=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Yg+pJb6lFL+aBwKq70hIwdWJzUYNwRocDrHVdADZZxMkgaUy3OAjjKNtatere4Fe7fGGCS/rxDu1uf43h93mFBHTNCwLDRUlLJ5dj059TyLCe2y/Lbc1iwdbfLKCfmEiNh9N1qLmLmdFuAOJo59i0zko/bVi3CvcHkwpS774UJg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Z6c/HUN3; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=VR2GjH5L; arc=none smtp.client-ip=202.12.124.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Z6c/HUN3";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="VR2GjH5L"
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailflow.stl.internal (Postfix) with ESMTP id 020711300291;
	Tue, 25 Aug 2026 18:16:46 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-03.internal (MEProxy); Tue, 25 Aug 2026 18:16:47 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1787696206;
	 x=1787703406; bh=MTJXqUkyboP6nT1GdTre2i6fxL2R8FyE2y1tAnQFr54=; b=
	Z6c/HUN3MCtEQq0acidtkPkLV30vLvd4jBO02+/YjdUWIsWEw8qNcTl7qM/rEuRJ
	rnN7tjnDmGnyQIH/JRC9a3QECWKREJldBnithAGLgNrIikkdrE7rpBUFAeTfmAmq
	xM8eHNmyq/7H+bXjn+KlU3UkeiONjet6LHPYw91CnwgK+2UkiE0qBLbkIQ/dHsT/
	ht786Ntm5H/5vxLBJjmav9EjJRwidcLZbm5W5GvmYKPDc33Dw/IONCqYmqvgvlSQ
	jJZjcIXyzloG0ZvRU2HjfA8nwVHa5tTzyxdAqI/XkYuqqHBIzzgKM7M+wQ7137lw
	wRerkaqMMMqJm1q4DtpCaw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1787696206; x=1787703406; bh=M
	TJXqUkyboP6nT1GdTre2i6fxL2R8FyE2y1tAnQFr54=; b=VR2GjH5LGvdhouzrq
	wy4L44fFfLE1BCTj6MQLcBW3oNJ45Dr5oKLl0OAyiNlaNdbIJN+yFY4FgPZAjJHP
	6r2F7FqOQ3wEvQ6itU4yMujeb6+/tpzyAnN7iwJhHX46FBo0TryXsugzOZfqs7CB
	9opPgntc3s02iLnVb2vHXLYb3oxOXDY9VGEu9yS5T+htPqqZyUMBR1nVohRr79bb
	Qibl5X3Zjb4VLSXC6HuaJv7ZDMJzLHzr50kY5nuHXTN2fONAZmRYZBvtb1oc19hx
	L88pD2YDot+C1AuNo4gm1hpiwSaOmfCKa6+DGbnSEXDEXwvoTTL7DQoM6Sn8mqS9
	IZ9aQ==
X-ME-Sender: <xms:ThSOalAV74YK9oFipX_K00qYrJNR-JUn7_SrVRbykHBklK37xZsEtg>
    <xme:ThSOaugDjri72XR-UdUwkF1ZggEF3A2wVYKQ3gnGh97MoHeGXiU4EUL1gOMyC0L6-
    _FPXYRRLJ8sciZ460BvUs4gMuVTA_XfrcLy-LgQm03v7yrNYtY>
X-ME-Received: <xmr:ThSOanNsosTKHFOlvZGn9MQ-b8wJLbax6JLEHVEmdb080KYdsSSGIsFUbrQ-dlGZmc7OvjTuqm7kzGZhdHE6FEAxChjm0Iw>
X-ME-Proxy-Cause: dmFkZTEp9gD1tNJOvQDhtypWMDariy1lQZzyPCbTbVWnxI6bdpy2XSc1MIE8cjy3IG5prk
    7eXXKQ1+AzawqwVafFnkSQVq3nCftIMNELyf+GmUuKYTB18VwsCSA8x1h9bnf7yYLuIe9s
    5/khboCUq8wQeamlgoG70tpcU6O9vPbdw1ApHAaCVlIPXTbjfAhkfSz569KefjxusIkwqg
    JSlqRrJD0X07dcItAiTmSeecqH/sccyG90oRqGAhsyPnna+gbbNa6u+OTNC0+oiLPN9Hl5
    FMsl0L+8C6nVE/5D5EiMbFYLm13buMsfddxLmGjqhI2v2n1p1xvAzA+rwFt4OQHM6ek8HP
    PCcHqnbTXpPt/gDr285uSlpzxdQTDEuS3eYGrcqGdpn+PwsNXF4hRi6KKVkbXv3Pt42sbt
    IcBiUnmINFi/rO2wuq63WwlDrZfcsmr9ehSpH+6v+Bu0gqKXERn3g41yy2BxVDrdI0ItvU
    rHvt/SoeZ00W9Kv849lHsg4LIVWdthkLDmIBaafbrX7w1Y3aB9/AOt3Ey1yy61Sev3pb/C
    8wnML5IrFWWvqJiHpnR4skRF+HTN1yl9/Ui7zIuw8OtZrVot3+fMFyMhnfnpa2LUWp4ZDd
    kk5OT7+iDPcWQ5osFrqgdJN9Ts9GQOlZHp3VOzB0FTCliNbc147p/kyE6MiQ
X-ME-Proxy: <xmx:ThSOataQ5Fm-mls-xdCyb-YyfQ9B8CxyYmzJCGshy-98T-MojTCcjA>
    <xmx:ThSOak8Vqwkgp3IdqMZ3mdX3XzvhE_d-SOm4vEGhvJ-ee2KxcMHkZQ>
    <xmx:ThSOao07c1L88bKf6vTVQoL8OG4xWJi89UzmFIpTr4V3PemeiMjcrw>
    <xmx:ThSOal1V1_Y-WN2GgSmi6Gda9EagQGWm7JQSwZSDADEemjA3yOc-Xw>
    <xmx:ThSOat6YpLIZrEkjaHa_yPMfkCguwEfa0kHxiuIKAsXTffCExiFcK9JF>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 25 Aug 2026 18:16:40 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Ian Kent <raven@themaw.net>,
	Chuck Lever <cel@kernel.org>,
	Jake Edge <jake@lwn.net>,
	Ilya Dryomov <idryomov@gmail.com>,
	Alex Markuze <amarkuze@redhat.com>,
	Viacheslav Dubeyko <slava@dubeyko.com>,
	Jan Harkes <jaharkes@cs.cmu.edu>,
	coda@cs.cmu.edu,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Jan Kara <jack@suse.cz>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Amir Goldstein <amir73il@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Miklos Szeredi <mszeredi@redhat.com>
Cc: autofs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	ceph-devel@vger.kernel.org,
	codalist@coda.cs.cmu.edu,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH v3 07/11] fsnotify: don't hold i_lock while walking d_children in  fsnotify_set_children_dentry_flags()
Date: Wed, 26 Aug 2026 08:06:24 +1000
Message-ID: <20260825221459.966875-8-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260825221459.966875-1-neilb@ownmail.net>
References: <20260825221459.966875-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

Rather than hold i_lock across a d_children walk, dget() a reference to
the dentry and drop the i_lock before the walk.  This is easily done
with d_find_alias().

This requires that we dput() which can sleep.  Now that no locks are
held across calls to fsnotify_set_children_dentry_flags(), this is safe.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/notify/fsnotify.c | 33 +++++++++++++++++----------------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/fs/notify/fsnotify.c b/fs/notify/fsnotify.c
index 90a2121fc54a..4a383d4d8a7b 100644
--- a/fs/notify/fsnotify.c
+++ b/fs/notify/fsnotify.c
@@ -71,27 +71,28 @@ void fsnotify_sb_free(struct super_block *sb)
  */
 void fsnotify_set_children_dentry_flags(struct inode *inode)
 {
-	struct dentry *alias;
+	struct dentry *alias, *child;
 
 	if (!S_ISDIR(inode->i_mode))
 		return;
 
-	spin_lock(&inode->i_lock);
-	/* run all of the dentries associated with this inode.  Since this is a
-	 * directory, there damn well better only be one item on this list */
-	for_each_alias(alias, inode) {
-		struct dentry *child;
-
-		/* run all of the children of the original inode and fix their
-		 * d_flags to indicate parental interest (their parent is the
-		 * original inode) */
-		d_for_each_positive_child(child, alias) {
-			spin_lock_nested(&child->d_lock, DENTRY_D_LOCK_NESTED);
-			child->d_flags |= DCACHE_FSNOTIFY_PARENT_WATCHED;
-			spin_unlock(&child->d_lock);
-		}
+	/* Find the dentry for inode - there can only be one */
+	alias = d_find_alias(inode);
+
+	if (!alias)
+		return;
+
+	/*
+	 * run all of the children of the original inode and fix their
+	 * d_flags to indicate parental interest (their parent is the
+	 * original inode)
+	 */
+	d_for_each_positive_child(child, alias) {
+		spin_lock_nested(&child->d_lock, DENTRY_D_LOCK_NESTED);
+		child->d_flags |= DCACHE_FSNOTIFY_PARENT_WATCHED;
+		spin_unlock(&child->d_lock);
 	}
-	spin_unlock(&inode->i_lock);
+	dput(alias);
 }
 
 /*
-- 
2.50.0.107.gf914562f5916.dirty

