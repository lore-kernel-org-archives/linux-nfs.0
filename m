Received: from flow-a8-smtp.messagingengine.com (flow-a8-smtp.messagingengine.com [103.168.172.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AD9F22E8DEC;
	Sat, 15 Aug 2026 04:29:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786768188; cv=none; b=Q83uHbparg13Ra0I5N3YLeNd7lNDZwuPWManSYZyK1WuVCPMBvnRUkB0PJXwJlnnQEqxEUYSWpnS2IHR/MiHS85AzinPBBwLUXil13YtkgIhC+rN+HRccvC/t5J4t5UyWh/CFGaYtyhWGhnUY0uk+zyH9EVJfzbHYQK8xxrAA74=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786768188; c=relaxed/simple;
	bh=EZGnXuikWmFjT40ONNIsrdGsW79YaEfq6MXY9Qq7SaM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=CYwAHfgh0ZVTBZX50znySP0GjQ3mbb+Y2rMQXbGYJp4LwFXqYNyW/hCJRWNcLtBhGFh0FjwW7brAYmcT6Twqch6wJBH80UBVjMYVxx4YzdOWmPsN5JiLzxm7+rfPCzFLEV5IE8a1Esari9JxMhQXWTCNEJtWpmY+fcVrYU9dpQM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=LMeHqGrG; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=XCqhSiPE; arc=none smtp.client-ip=103.168.172.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="LMeHqGrG";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="XCqhSiPE"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailflow.phl.internal (Postfix) with ESMTP id E9FF713803F8;
	Sat, 15 Aug 2026 00:29:45 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-06.internal (MEProxy); Sat, 15 Aug 2026 00:29:45 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1786768185;
	 x=1786775385; bh=V15p7YB1wxkGPcoPidTUC9Y0oWBoIwi0W1mfdrFuHck=; b=
	LMeHqGrGTjpjg317G/5toOtGJUn411/cAslSJIP2/3meBmitcbUMeHVDrB9+24Y2
	mR+c+CsEocyVI46IR+nsqY9if0XMVWf4ueNBZQY0do9LDrY0vsbZEi/VNUAwghDY
	B39HuDD0bJmZ3EMLgJ7GUJZ9XEdA5a5HrJBXdhlheh9fB1fzDqnVQVlycInvP3AR
	s9z2q2By40CwWRS2sh/lMYHfe3ua7IuaY1MXLX754jKYfObQ97Ikocfh5uOKIVDj
	aYaZ4EtthdiZSkhL+m+3dw3sIVSqRRv9v0rpuEQGbXvuXXf/s1JSGQTt6Gnln76k
	ffDjIajhZIkDtfRFNbbEWQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1786768185; x=1786775385; bh=V
	15p7YB1wxkGPcoPidTUC9Y0oWBoIwi0W1mfdrFuHck=; b=XCqhSiPEE8zxpXhEi
	25mPzVa3HlHSQJNBe0Rh27aDSU9B/zMyhG4ppSHMa3IUPLnVfFQkdJdsBPanfLkF
	M8E7rrS6F4eAWQsRI5PxEzTn5kYDRQVYAw7qrl6buzJbvenTYpuTUAupEMZgRCRV
	dIErpKJpGH65cIorCGdXzjvt5SVqP4zi6xXdn8585Tz+dkCyKbRr0vPQpraBqS+m
	7AmlcV6e604VlnASF3gNzX7i8ejpSMmGOvp//P19ffTzonGWX4LhcgCihnRhFsd4
	4KDC0oNbUQxMYXXf7l4m2L3xhy+6mGPqDEcV3UEbJI/8nw6KA6qu6hRKnOPbqO4J
	NUNbw==
X-ME-Sender: <xms:Oet_ak_plaSC3pUU-5qs171cF0llANfIS38vLdf0RJWr5QnT_f2PSQ>
    <xme:Oet_ak6jDSkYDpKVqWT8j1Zzz-_yeJ15UQI7dQxgIS7zPe2KUzW8EZy5rK46_5H3p
    1TXbaykYcpLpH9AP5dTfDfc2Z4x7rMQH_Tczyt9alL5e_ySJw>
X-ME-Received: <xmr:Oet_ahWut-oyhjcw-zOsQHK8LKL9fnM39Sgd1-vB0shhlP3rJ_79MRvxu2Oce-Wj0MfCGeddO4KB95hDzlnVr462uDrwk3Y>
X-ME-Proxy-Cause: dmFkZTE47D4+VfwQFQzr11DJvQLYIXqMi0hZV0dErVHB+rL0DNVNd8lKaFjc/DBGC/9Z+e
    1XqqSxG1COnVE2p0h+gE+3sT3WHc2s4pfHSbkJDPkdz9l078ivxoBUX7LaQuIqMUvNfdCK
    OTO6fH4CbhonnMAQrCy6mAjkD3yfDfiioSRLElGFQqu4IKzk74/3+ETPYsMsadCTSlIE72
    pFesoG42fVWkR1DR5x8Czt3y4MWTPZ7Vk8PZOOBmt7LfMXAwJXwlpNe3RczRrG53IXGKeB
    lZ2vtwNbgIUpnHC00hTYciEg8pKF9qQ82JcZyji4nf8ZRkE3Cre+0W/dXUWlpbwnOwzilo
    oGgS/Vr84mqDIFHdcOGo8SGnshn8wyVFzanBYe1PRk47FC4N2o3JW6XIwaqDE8BgOOY8hS
    ZY4XQtz8qfO7mITcXHWiBRdPCBerznxyx7JT+vqjedup7QsMUu24nJ3n3+WbEvZNPt7skY
    lErRt8RgYRoV6vSZIRB8SZh6PaNwpLdoHw0uT2gkFzUrZYaFqppyP7VMNOiL5kxqYEnQDE
    UoDDsfsp8CwAfIW1f9XmaWwh9Ob9Djh08hg/L14OltoBjEDfkJmtTjw9q1hYoHBSw0z1ZV
    3dpebE0dqj9iApNXewSxkbl8DJtBX7P4TOtRLnaEGdQkMw7vyDJPDKXehzOQ
X-ME-Proxy: <xmx:Oet_aiIj6fcFOK2rKYj2Q8WEh8pL2k5OJSa1zKQffi1CsHb3qDNLhw>
    <xmx:Oet_amSwzjvvFWRZ0Fmr7h9GWM8S8N9W3wYGMvBGRfTzneA2S9e8_A>
    <xmx:Oet_aug-9aXaZHWIdB1KvwRzjqXCrXeEOyabMWXiHjHYFrDZ0Hs9mw>
    <xmx:Oet_agvULMF0cKMAaMRDMoqHVQ8QZKSRv6ual9Q0QwgpJjdXdQakNg>
    <xmx:Oet_ao9g366j2nb4Tn-hz5JpJQ8THgdrXTfx5TqVr3vckyB7b-IQ3hIA>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sat,
 15 Aug 2026 00:29:40 -0400 (EDT)
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
Subject: [PATCH v2 10/18] libfs: allow scan_positives() to be called without a cursor.
Date: Sat, 15 Aug 2026 14:21:27 +1000
Message-ID: <20260815042707.2535717-11-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260815042707.2535717-1-neilb@ownmail.net>
References: <20260815042707.2535717-1-neilb@ownmail.net>
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
index 398fae675207..21abe0074c77 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -107,11 +107,12 @@ EXPORT_SYMBOL(dcache_dir_close);
  * (i.e. last->d_sib is unhashed) then it is treated like
  * the last element of the list and %NULL is returned.
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
@@ -124,7 +125,7 @@ static struct dentry *scan_positives(struct dentry *cursor,
 				break;
 			count = 1;
 		}
-		if (need_resched()) {
+		if (cursor && need_resched()) {
 			hlist_move_behind(&cursor->d_sib, &d->d_sib);
 			d = cursor;
 			spin_unlock(&dentry->d_lock);
@@ -157,7 +158,7 @@ loff_t dcache_dir_lseek(struct file *file, loff_t offset, int whence)
 		inode_lock_shared(dentry->d_inode);
 
 		if (offset > 2)
-			to = scan_positives(cursor, NULL, offset - 2);
+			to = scan_positives(dentry, cursor, NULL, offset - 2);
 		spin_lock(&dentry->d_lock);
 		if (to)
 			hlist_move_behind(&cursor->d_sib, &to->d_sib);
@@ -192,7 +193,7 @@ int dcache_readdir(struct file *file, struct dir_context *ctx)
 	if (ctx->pos > 2)
 		next = dget(cursor);
 
-	while ((next = scan_positives(cursor, next, 1)) != NULL) {
+	while ((next = scan_positives(dentry, cursor, next, 1)) != NULL) {
 		if (!dir_emit(ctx, next->d_name.name, next->d_name.len,
 			      d_inode(next)->i_ino,
 			      fs_umode_to_dtype(d_inode(next)->i_mode)))
-- 
2.50.0.107.gf914562f5916.dirty

