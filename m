Received: from flow-b6-smtp.messagingengine.com (flow-b6-smtp.messagingengine.com [202.12.124.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AC9572E6CAB;
	Mon,  3 Aug 2026 01:37:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.141
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785721068; cv=none; b=jATcI7crWonVvfrGprkV2cuy2VeKCCpiRSqgumpzmYfOs2AaBnTFXTCB1IpXTRmr/JLyVnceXXXBHuMqM8bAmbkmgutZhfI/wata1KPhOol5C0B8SZs7rlbB5by66hMLqJQgECgYP83Rd/7QWESQs2D2wxnVN6NSnaoyzSsjWOw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785721068; c=relaxed/simple;
	bh=rSU6UbsrTcyt3N112Q3EtPGvjxX0a0TDtw8hgko0YDw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=fNvmjaV4zOt4FW9TjojvcnNQ0eVMIpx5rBL2P9aIc/dL4vcqbVzpx4x1fcbSdlQiwO9soX9PrAbseKLWjLJuzJeX7w7eyiWnysVbC1yFLVW9idAWLqMNeuzH2jmIbEqq/5AMDz6IxJ+raQzhqI+Qt6CG3sEiu3Tzs3bxQv0HNgY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=QM459I+X; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=V8CQvIIv; arc=none smtp.client-ip=202.12.124.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="QM459I+X";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="V8CQvIIv"
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailflow.stl.internal (Postfix) with ESMTP id 83B2C13000FC;
	Sun,  2 Aug 2026 21:37:45 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-03.internal (MEProxy); Sun, 02 Aug 2026 21:37:46 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1785721065;
	 x=1785728265; bh=afxw517QIyxjWvT6uJJLabhwFNdUnkpoqoM+3My1Tus=; b=
	QM459I+XDejUzxea0p/QVfF2/YDkhyvXZYOXiOhfyU0lLBm+MVHygDGdlczO7sQB
	xGQmT7KwdW0piNEXzxVRlvBUNzMvoYyHxSx0CF04XDs70UHLjU1+4eGxR3Tu4gtc
	3AbU9oVir5ZBmLLIK2m1yEB0vxQT3ft2gWdhCpMlFoSWF6sqdGZdEBat6FsWTtlq
	RlRr+0zD32dPdIByulliHxDgbbyRllVNqLHxJAcWi6TrSsMlaG/jTNWUlh23erBg
	/AAW1W4dWqhLGQihsQ1cmZWmKHpspqnpa3PBTC0UtEl2oteZdXuqeukl8PSnijDJ
	o4lZvPf7rQ5Mmx4e0uGtsw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1785721065; x=1785728265; bh=a
	fxw517QIyxjWvT6uJJLabhwFNdUnkpoqoM+3My1Tus=; b=V8CQvIIvPp8DBMFKx
	6k/fMNzUZF73VqbuQqjbu5cNvcSuTg9oadaBIfBhhFjD9/8ZWiQXGlotHaUD1PcL
	3r5MauFTXBG9qpqyTNpAh+v+VJ9B/9sGxPDZ45LdUBI7xtUQr75EMB/B5diKZ8ca
	ShXHb1bnf63cDb43nIlmTpX59xwGyM6dGQjf8VaBpXkmqXfqJc0Mvl5Pc2O1aNHZ
	YlnAX5T+aM8ZmiSFi0uhMZ2/8FCh5G9SNAA37BVTrUcsvbgN2PRnkX3MBPK14j3F
	KnV7L6gn2lmweGsiTJe5XMU89yZDGvsHYly7BnnKTX4sJloeb60VuqqdWa3Tds87
	700Jw==
X-ME-Sender: <xms:6fBvagulP4rx8D2nlhCbldh_P2Bb_YlAdPR0cxqd8GWBbbbVRm8Ldw>
    <xme:6fBvalp6TYrsC37uJgzwxlqM1qBdHEQ77-25xo8-LCk4KIJDquN83iZJtnY83gQVw
    SoMl-KlUsmZ1afWnGy4OWGiY-xM0R4Ylb6aMG9wSkUXbcR4JJU>
X-ME-Received: <xmr:6fBvajEGK1WC4ZGpwFNoAsHVLBvmcWUKO86dO0lj46s5iqdop616eQrOLjvcObzbdGjTwSP2YbuE60rQPTI5x0gn_j-GS20>
X-ME-Proxy-Cause: dmFkZTFswjlVGtOMO0DJ/yAygp0kikcHV2WSXHSGnlIkcuf0k9rLUdswY4SNsXMvUWMhfJ
    kpfPtsQuVQ8vSHADhVm4IRY0nolbqOkRQBDAEaT6PViWtUiGaZ1RuyP3TKdnsto1GxdvO6
    EDjVnoxMaix/qwxYa/EnmBrWSMWR71Xsepg0lYJWsNgdazP7uMjE+vSD+hiwoRYUCYwqMd
    8UCnzcTzoJOqEB2P0a4xlmt6Vi448YXJsDRRsyN3s901toR6OrLn7/rtKpBURTUpkDqxh0
    ISJdNDy7NZx3er7DV1F6c9yJO9k8PkZEqBrF2awe8iwc4c7xBw+lDoz5IzuZ4fXetXOOIf
    p3XSqG6UtFEs/BmMHkY3CQfXIvgzw8oapoHNClzH0uYron6Vd63SEIhb8HzP165rHbrwzn
    kbT2arbSvF+izWEpASygMM17t9hzCbLozecAqfY42LcHUEtXV2+3EedS3fhSEUefNmAVat
    doeVB8roamWdmH4qhmn6CoykF7m6+Rc5fE2dfnY+sufLLM+1mea+NWTB0uPW7auy8n63nK
    GpqR8jx6I3iWlTzYcEoAo5PSX0v8AZ3WAOBqGhaf62Mx2rPEJir73bxffr9SMBkdigumGV
    S98iIp1gH0kX4Vd5JzGBOafOlDfpV+okzj8jajlIfQM8so5MjpOcInCEbreg
X-ME-Proxy: <xmx:6fBvag7P_m2vtq9EpNVTDmxq0ObadYf9HiFYnq-OpvjzVdrbzWZZQQ>
    <xmx:6fBvauDrDiFdtVohLYZNDR75n-mSsaIcp3-ArHaBvUNmdc5djKSbcw>
    <xmx:6fBvarT6D1YOlYrVtXRrjPR80SKfPhN6dSF32HdGZeLCutFOZ7zmog>
    <xmx:6fBvaucRWMkvLzGgBND_DZiFdxfuL-5WUUe_VC1s7oeGLgaZc5KrrQ>
    <xmx:6fBvahsH8uHOyaLKTLozm6XxzkXYnvwlGNANIL3jf-Saw8zBhtK1yxx->
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 2 Aug 2026 21:37:37 -0400 (EDT)
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
Subject: [PATCH v1 04/12] fsnotify: reduce i_lock hold time in fsnotify_set_children_dentry_flags()
Date: Mon,  3 Aug 2026 11:21:13 +1000
Message-ID: <20260803012648.2195405-5-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260803012648.2195405-1-neilb@ownmail.net>
References: <20260803012648.2195405-1-neilb@ownmail.net>
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
the dentry and drop the i_lock before the walk.

This requires that we dput() which can sleep.  Now that no locks are
held across calls to fsnotify_set_children_dentry_flags(), this is safe.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/notify/fsnotify.c | 35 ++++++++++++++++++++---------------
 1 file changed, 20 insertions(+), 15 deletions(-)

diff --git a/fs/notify/fsnotify.c b/fs/notify/fsnotify.c
index 90a2121fc54a..aa94c0fa7686 100644
--- a/fs/notify/fsnotify.c
+++ b/fs/notify/fsnotify.c
@@ -71,27 +71,32 @@ void fsnotify_sb_free(struct super_block *sb)
  */
 void fsnotify_set_children_dentry_flags(struct inode *inode)
 {
-	struct dentry *alias;
+	struct dentry *alias, *child;
 
 	if (!S_ISDIR(inode->i_mode))
 		return;
 
 	spin_lock(&inode->i_lock);
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
-	}
+	/* Find the dentry for inode - there can only be one */
+	for_each_alias(alias, inode)
+		break;
+	dget(alias);
 	spin_unlock(&inode->i_lock);
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
+	}
+	dput(alias);
 }
 
 /*
-- 
2.50.0.107.gf914562f5916.dirty

