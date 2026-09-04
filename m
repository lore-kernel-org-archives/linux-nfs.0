Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 803FE495030;
	Fri,  4 Sep 2026 14:17:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788531467; cv=none; b=iIVuZoFTbXPV65vpSz9tcfoXPlZDl2NlhocejaqZU/NZiB6N56I/+R6RAgezJ9AVKg+yKnry6tJXQzlVFsbNPKwIWeUXwO4qR4uxfvRX3pAd+lPvU+fb4dcDa3BxTvFw/XKVwQDDi3SLzJnKkMoyncr7XLiYLehSHOdF1vT7J+M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788531467; c=relaxed/simple;
	bh=GPuj3sulN1EVqegKGOkxmLt9iqOchOeoF/C189BSDLQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Npt1jB1izvFCZxwYkmH9qc9ouC0s4JGsocRrF7Q5fHF4zsgPJshWJSjYe94qUW5vw5jc3dFngU3WSEPi6qvw1UdKKUU8pG4yqq7o8hXDjQJ9ss0gXg57WiZ867RICTOnXBPOB58pnXpDm7fwhwLq1aVBdy4r7zCRzksNLpsPvsk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=YbKVV9BS; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="YbKVV9BS"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1C00B1F00ACA;
	Fri,  4 Sep 2026 14:17:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788531465;
	bh=dzfQvEvrcjHdupca1CqJWp8dWvoMvwWFsdUd3DQS658=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=YbKVV9BS8nDsCLwuwYVbN2UtZwwZjXLhctDIaD+rVI51pLBZ/UotRb6IO9cBzVSkX
	 HwE6ZuQS5TDzzohFnyR6mflzVUelicYV3QtijBUxmRaT4LFqcT/JGQfYhrVVL0evVZ
	 EznCjYkxsH9g+3dgDlQpo6jkJ7fNtvPh5DRPE6ffVpmAzGex8+dEQwQNroJUgzv0Bf
	 zzoIweN1riletZA5M2XiKEyzwdOpzcc6j5CMSlRPTfKxVlUY57/iCiUm10i/6OXxu1
	 vcSNglYA1+HK0lxsss5mo0A6vaHM2G5jB46xIa8Nr1Zd6CMgSlFV/2iXBjxH5Z047Q
	 Gmz+PpMctEw/g==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 04 Sep 2026 10:17:32 -0400
Subject: [PATCH v3 1/3] fs: stamp the current time for a stale delegated
 ctime update
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260904-delegts-v3-1-b6062ba75f07@kernel.org>
References: <20260904-delegts-v3-0-b6062ba75f07@kernel.org>
In-Reply-To: <20260904-delegts-v3-0-b6062ba75f07@kernel.org>
To: Christian Brauner <brauner@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>
Cc: Thomas Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2831; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=GPuj3sulN1EVqegKGOkxmLt9iqOchOeoF/C189BSDLQ=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqmtMGXMNBhYUyiUAW+NXCgYGnfZMVRvnNgWj2y
 GNQcUdFiNCJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaprTBgAKCRAADmhBGVaC
 FVo+EADU6a38WWjDxoqGsoPkLgXaSVAI5RfMCUAR0F2uapbDOZs6pG3m/nMGDx1tS/QI8ysT2zp
 TP+DIDhgnEyxJnqmDLVZsHjU4ZU5UkcBzWbQY4LM/lDRsBwRkPw3MHB6NfpUaMrtAsY/Zk8SYgq
 ooZ8GXLR6K/q1QEqbQfcETzpTIdSzl36a/6hZI8TA5BcLHTkI4Un+eteWOPtTlXlpaWce+cglHY
 3VgNcOp1BeSSYFYjoLb2ktNXGGhkgltwavH0BrUCzyTKaaNNlWMrwgYrA5Pm+Lc9r2fVNHDPxsr
 Otr4PtC9KcliSFuorz/HqeMEbh5h1VifTltfQikE3lE8Ut2T00+1w5AliJ0TcptcF0Iq++9d5ZA
 aFXeUACQZyJZztuoTDqZCGVchfWKEY/0J/PYa9cYDW2FeWx3Itde5Fp8BvG2YokW4SWlW/InK5/
 dtUBkX73j9HOl156iaAn8uiO1j+4gkpcjh3NkNHJ1oaEvocEyGwtjzh0Ef6vUXjXCZLvj/6TFuD
 Gl9LloqP1Pa5UoJ9467RxOmy1ZddHJ11aWTAPNK1pRnpxQweOCpeS5lHNnoomBvr432c//vkhCG
 mUjiO+tgIL6SBgX/zYSqBXxdiKmbL8OmB0Hm5ejNU3tE6A5hOswS2gxIAgzUzAJlLux85sRfO7v
 42avkVUwBQ9fqFA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

inode_set_ctime_deleg() drops an update that does not advance the ctime.
That is correct when a client reports a timestamp that it advanced on its
own. It is wrong when the client moves the timestamp backwards on purpose,
as utimensat() does.

Stamp the current time in that case. The ctime still never moves backwards.

Fixes: 3952f1cbcbc4 ("nfsd: fix SETATTR updates for delegated timestamps")
Assisted-by: LLM
Reviewed-by: Jan Kara <jack@suse.cz>
Acked-by: Chuck Lever <cel@kernel.org>
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/inode.c | 25 ++++++++++++++++---------
 1 file changed, 16 insertions(+), 9 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index ba7da39be4a3..09eac2e0e172 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -2959,11 +2959,17 @@ EXPORT_SYMBOL(inode_set_ctime_current);
  * inode attributes, including the mtime. When updating the mtime, update
  * the ctime to a value at least equal to that.
  *
- * This can race with concurrent updates to the inode, in which
- * case the update is skipped.
+ * The ctime never moves backwards. An @update that does not advance the ctime
+ * records the current time instead, so that the delegated change is still
+ * visible in the ctime.
+ *
+ * This can still race with a concurrent update to the inode. That stamp takes
+ * precedence, and is at least as recent as the one it displaces.
  *
  * Note that this works even when multigrain timestamps are not enabled,
  * so it is used in either case.
+ *
+ * Returns the resulting ctime.
  */
 struct timespec64 inode_set_ctime_deleg(struct inode *inode, struct timespec64 update)
 {
@@ -2975,10 +2981,6 @@ struct timespec64 inode_set_ctime_deleg(struct inode *inode, struct timespec64 u
 	cur_ts.tv_nsec = cur & ~I_CTIME_QUERIED;
 	cur_ts.tv_sec = inode_get_ctime_sec(inode);
 
-	/* If the update is older than the existing value, skip it. */
-	if (timespec64_compare(&update, &cur_ts) <= 0)
-		return cur_ts;
-
 	ktime_get_coarse_real_ts64_mg(&now);
 
 	/* Clamp the update to "now" if it's in the future */
@@ -2987,9 +2989,14 @@ struct timespec64 inode_set_ctime_deleg(struct inode *inode, struct timespec64 u
 
 	update = timestamp_truncate(update, inode);
 
-	/* No need to update if the values are already the same */
-	if (timespec64_equal(&update, &cur_ts))
-		return cur_ts;
+	/*
+	 * The update does not advance the ctime. Stamp the current time, so
+	 * that the delegated change is still visible in the ctime. Compare
+	 * after clamping and truncating, since either can pull an update that
+	 * was ahead of the ctime back onto it.
+	 */
+	if (timespec64_compare(&update, &cur_ts) <= 0)
+		return inode_set_ctime_current(inode);
 
 	/*
 	 * Try to swap the nsec value into place. If it fails, that means

-- 
2.55.0

