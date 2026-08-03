Received: from flow-b6-smtp.messagingengine.com (flow-b6-smtp.messagingengine.com [202.12.124.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 070142EAB6F;
	Mon,  3 Aug 2026 01:38:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.141
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785721101; cv=none; b=NK8g6IjRn7yG6A7Xxq8SnS/N94YA8pUmMg6Q2UdgiSGrEZuTYUyC7sdyFek8PQP1yIyNQ1KeOTS04UryUkY5dY5avbwPafT3+J86stU9ZCAjlMjdvIy7+zn9ConlPRQantKLGGIrxBzfKaUTVAxsDdFiCaBSyT5aEsQriM3bzBQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785721101; c=relaxed/simple;
	bh=2cufU8yvi9RClrUlLLXvb9cfqVLrKy+3OTzuskkAQBk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=b9dJQs340V78B07/1oMO5dajKZnxiK5CEgkEvnU4mtMQ80zxduGm4QbNb+PZOdvj/gFmHIAJmmErgw6SXVAs1BJu9LcafX1rdS7rzA/cyVqfb5pM0gjHsHEsMG6RfKKMjLtaJgaX4rAXh/a7mz4oRftxC2ZjdxLEYt3MeUTAQnA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=ST9djPHD; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=N24QlYEm; arc=none smtp.client-ip=202.12.124.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="ST9djPHD";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="N24QlYEm"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailflow.stl.internal (Postfix) with ESMTP id 037421300107;
	Sun,  2 Aug 2026 21:38:18 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Sun, 02 Aug 2026 21:38:19 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1785721098;
	 x=1785728298; bh=wCundvHl8EUp99cshH7SIKdPk3plPH4lsyT7KtputbA=; b=
	ST9djPHDzh8eHNLZ+kmtRf5xz2AM1vTFMmigPkYOo5c3+y6Lm8OVxUf0BQaNSC9t
	j+t/zoIEP7NtF5zcEJfONCxmvylyXBL8fC9scxMoABsjCPTgkEI8FSNNgUe8xVvz
	1MDmxkyeN9kIAy1t8NHhpwkEhyK17qMc085TyhHjdpRGs/EJ7JLzQYHfe5xQVyRD
	rseY+fQs+gp7X++zXwjMPg4wUiSh/GcShds/jMnyKHhPCGER75ZIhXDRIo647YIw
	jXTWQkBFobis26Tth0EyHFDuCu0uxhgbaZmKS/d0uUA70TcgE9a7wNIbvKS0Qm5b
	Hc5YjXzSRGS+2flL5iq6MA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1785721098; x=1785728298; bh=w
	CundvHl8EUp99cshH7SIKdPk3plPH4lsyT7KtputbA=; b=N24QlYEmtl04bNLDq
	Szzi8Ev1eSo9hWQSnBguudAKJhG/CHvPi9Jl/tdj3vFt43MXOK2QcjHC79GmvHwa
	soGJGMKubTaVRaENetIwEYC/lAUlInp5RQrcFQ7ToKNAnwS90blUB3UQxISMH8Q5
	5H4NuWbRsC6NSqWh6UekdRbkxRjUWNfB6t7pFgPrw72Sye0GbH5jEHilfvvVd69l
	ro8QFXY0NXSbPwcWBInT5cWxNgEo9VqS/8QiJ5RQJqz57A03yg8sludrluK7t5O7
	d0yD5xZhbmwkewa2RCutYxoG/vcmnY6+KGVYOLnzvi45Ac2mRXXgi58LrituzRSC
	a9nWQ==
X-ME-Sender: <xms:CvFvau5bXBvbqYdm42Kgz2Y_s_y8MR6zk8cTFc2qiRWJYBe7Ep-RGA>
    <xme:CvFvai4JLzZB41y2loGLveh1OSS7nSSW0fleBzOWMLed7oR2p-Y7vrMfbIE7BnRKr
    SFBTyIy69qT_T-nIbx00ShfSS3d7PiN9dgkrnXrPjxKWl3SsU8>
X-ME-Received: <xmr:CvFvakGPdn3KQYMX6I93M2TAWt40_O8_UFpS_NwaFcY1e9eo-oAu_97-znCePNb2u2owIrHDFdMVSDbDSDkbHXDTM0Z_yok>
X-ME-Proxy-Cause: dmFkZTFswjlVGtOMO0DJ/yAygp0kikcHV2WSXHSGnlIkcuf0k9rLUdswY4SNsXMvUWMhfJ
    kpfPtsQuVQ8vSHADhVm4IRY0nolbqOkRQBDAEaT6PViWtUiGaZ1RuyP3TKdnsto1GxdvO6
    EDjVnoxMaix/qwxYa/EnmBrWSMWR71Xsepg0lYJWsNgdazP7uMjE+vSD+hiwoRYUCYwqMd
    8UCnzcTzoJOqEB2P0a4xlmt6Vi448YXJsDRRsyN3s901toR6OrLn7/rtKpBURTUpkDqxh0
    ISJdNDy7NZx3er7DV1F6c9yJO9k8PkZEqBrF2awe8iwc4c7xBw+lDoz5IzuZ4fXetXOOZs
    fOOcpgH4bfLIMB6lfSWNYIEXPzN2voLEMVehyX/DBMYrFJBkeAsJY/hM3y3eq4V24EeHfE
    mSreAumr4Wl3f6zX+Z1SnyoR2GJjoTdHJASploR208WaujK1nAz1Z8ykDjFNbN8teGTF1D
    VX/KnV+gmbkkC5nvswMjFrPvGIA8EJkBEPbBrWEANDVPQx1MC/3YY8s/WN1nW7LEzTBoLp
    qOFUMHxKw22AgN8XVYyGmwOdhcxMJQLdvKNDZ0d6mxd3UE4n8sg0uKKTaqFubCLu0ntHPY
    SseGkI2vaFs8rHQhv5xfYt8E/hbrB9AhfzEH5rnEbpthsGN+kHhlhNPtYPIg
X-ME-Proxy: <xmx:CvFvaox2ZF2foI9Bih_Cx86yMp4-flvcalpPaWKrdpEmJYGhg6h2LA>
    <xmx:CvFvas1nSQd2Upc7efiKMyrDcO6IiK-BI_RxjQwqbeZmNBNd9ONlEQ>
    <xmx:CvFvajOPId1Z5dTfBWuaC_YKgV9gx6cVbcWtFq7WQKztEhQPhnXF4Q>
    <xmx:CvFvagsXQLPwnAbzhHV_ugX7KxhEIJSs6UILRsPva0LcS9E2_pHjJw>
    <xmx:CvFvamJ-lGr7tlE3OvySjSFp0o_SktIx_sw385sh0b4wsSofxS-nYgyU>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 2 Aug 2026 21:38:11 -0400 (EDT)
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
Subject: [PATCH v1 07/12] libfs: allow scan_positives() to be called without a cursor.
Date: Mon,  3 Aug 2026 11:21:16 +1000
Message-ID: <20260803012648.2195405-8-neilb@ownmail.net>
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

Rather than taking parent from cursor, pass it in explicitly.  And only
cond_sched() if a cursor is available.  This will allow scan_positives()
to be used in place of find_positive_dentry().

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/libfs.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/libfs.c b/fs/libfs.c
index c2369ea9196f..260f56863742 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -104,11 +104,12 @@ EXPORT_SYMBOL(dcache_dir_close);
  * found, dentry is grabbed and returned to caller.
  * If no such element exists, NULL is returned.
  */
-static struct dentry *scan_positives(struct dentry *cursor,
+static struct dentry *scan_positives(struct dentry *dentry,
+				     struct dentry *cursor,
 				     struct dentry *last,
 				     loff_t count)
 {
-	struct dentry *dentry = cursor->d_parent, *found = NULL;
+	struct dentry *found = NULL;
 	struct dentry *d = last;
 
 	d_for_each_positive_child_continue(d, dentry) {
@@ -121,7 +122,7 @@ static struct dentry *scan_positives(struct dentry *cursor,
 				break;
 			count = 1;
 		}
-		if (need_resched()) {
+		if (cursor && need_resched()) {
 			if (!hlist_unhashed(&cursor->d_sib))
 				__hlist_del(&cursor->d_sib);
 			hlist_add_behind(&cursor->d_sib, &d->d_sib);
@@ -156,7 +157,7 @@ loff_t dcache_dir_lseek(struct file *file, loff_t offset, int whence)
 		inode_lock_shared(dentry->d_inode);
 
 		if (offset > 2)
-			to = scan_positives(cursor, NULL, offset - 2);
+			to = scan_positives(dentry, cursor, NULL, offset - 2);
 		spin_lock(&dentry->d_lock);
 		hlist_del_init(&cursor->d_sib);
 		if (to)
@@ -190,7 +191,7 @@ int dcache_readdir(struct file *file, struct dir_context *ctx)
 	if (ctx->pos > 2)
 		next = dget(cursor);
 
-	while ((next = scan_positives(cursor, next, 1)) != NULL) {
+	while ((next = scan_positives(dentry, cursor, next, 1)) != NULL) {
 		if (!dir_emit(ctx, next->d_name.name, next->d_name.len,
 			      d_inode(next)->i_ino,
 			      fs_umode_to_dtype(d_inode(next)->i_mode)))
-- 
2.50.0.107.gf914562f5916.dirty

