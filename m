Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A3BDD4AA1C9;
	Wed,  2 Sep 2026 18:54:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788375284; cv=none; b=bHBd8Puiqi4kOfv68TMQZyALsCoI3Z7e7zurAUiVvPqxljX2QWNEGr3M2Pvp6Ym6l57zABUX1XOPnS416lVlgXHGnOYol4ZBOVZd7ClA0S5HGhfyTWnBE+Zc2KtFmNHOm5kcl+6c4YJNlxQy80fa9kb2aFMZEP6RYHkwYa2vBhk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788375284; c=relaxed/simple;
	bh=N5ee7KGNPzugi2BNjQP/0HQr9KUtY/6LU5GWKanWZPA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=kMMSKyhRnQPqKJLNrRFdiO/cnE9ClU7DQ1yJyleH2opMLLas4vtNErCtMVEa9mw71gjKBTu4lvT4JxXagGnPzGscJerVAGjK+jVo8/6vBORV/9mabdy16fTVb33PjXcXVr1HacSlrykvbm23pRFnSvfPfAqaAjYPk/t9LnH3/ig=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=O9K3zdLf; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="O9K3zdLf"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 606651F00A3D;
	Wed,  2 Sep 2026 18:54:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788375279;
	bh=x7xZ8LbQwQ3si4CNL3UMJiQVkPBI+q4WfYx464B0eMs=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=O9K3zdLfaZt3XQRDvycxiMoqheMvgYRQa6pLFZuanfVP7TIrncL6z7HDLr5ZhnRaA
	 wLgjeiMbNpTUQckduBDA6b0JYcRuAutCmGuHDlY59e1xG0BHDkBfGqz1EtDVw96Pt2
	 AufKp9miuUSZbnsDozOH2M0irETW+yUgc8KS/H/oeDP0v3HVAfVn1naRQOTZPpX1uY
	 zZkB2f3ktZQj5QDZUUcrdo9peXZhYZojZ4j2asF973U1REmB6vw0nDSuBeLI8cqlEG
	 rH0RNBef5tfcEfhm5juGp6BIWGSOInwpm1aG4SXbms/Ae47Dyzepyp89jktH0XyQkI
	 ZZao8QKGVFUrw==
From: Jeff Layton <jlayton@kernel.org>
Date: Wed, 02 Sep 2026 14:54:14 -0400
Subject: [PATCH v2 1/3] fs: stamp the current time for a stale delegated
 ctime update
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260902-delegts-v2-1-383cb289ce88@kernel.org>
References: <20260902-delegts-v2-0-383cb289ce88@kernel.org>
In-Reply-To: <20260902-delegts-v2-0-383cb289ce88@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>
Cc: Thomas Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2153; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=N5ee7KGNPzugi2BNjQP/0HQr9KUtY/6LU5GWKanWZPA=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqmHDszj9DcXjDFsTtMXtmabGNDkLD021g6MCxB
 AgdTMwa9KiJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaphw7AAKCRAADmhBGVaC
 FS+DEACuPM63Pa6/22CxbYrgNFwDDbMczouqfbcymKzKqh0luqIW2JtqUtSv6EGvxrhuDjk10Nt
 N2oqBWN+IKepLXZbCPOr4juzd2wmq27rULnKSRvA28DT3fWuGlyMK9kfKvkYKJuO10dvGQfPtyU
 aOUH8Y+0C9HJ6VtT24Rv5oACCyku7NQVEKEUanQcr0LSSrYHAcWabiUD/XXEVv8wqeYtKZHBVVy
 0rGP8TS5AVghCKwDDyUsiTZlLU4XueldZt5k41G51LW9VtIu1LlNU5oYZrpCwEYLqeGYqnv0B2i
 J4JMP7niS+ps+F55UEK+CvddSWlhb51K7jNluYPI8gQGPxLrqNJ5yqBtGIqTxiujnifAEeceY6i
 HahdiSXpwFUtiBqDietxkMZRZB8tiv2S2N9B+xqghwc5qF6xqSNDv1TQa6nxTp3DcF0FT0BG6DX
 wD/U+RYqn7Kiy1Iot60SgSU95Lnu3giMa09lNVIo3ygFtM5tPiWdc2SokRnFNnsI8rqOK4rEPHA
 iU6ujrrvT1mWkyOR2ZeCk1RJ8iUqnRQmfhNYAcJwNVvS477PlV7OYjlGWVoRc7P7+xq35XkQGqd
 uSC0UH5Gham6EUvrC/q+i8hVesDr2CcGyCllU4mRF9q1/ux4Np7kNZ1hinqytS1SPPfVxfvyPKB
 3wUfukT4HIY5+Ow==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

inode_set_ctime_deleg() drops an update that does not advance the ctime.
That is correct when a client reports a timestamp that it advanced on its
own. It is wrong when the client moves the timestamp backwards on purpose,
as utimensat() does.

Stamp the current time in that case. The ctime still never moves backwards.

Fixes: 3952f1cbcbc4 ("nfsd: fix SETATTR updates for delegated timestamps")
Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/inode.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index ba7da39be4a3..8391814a4016 100644
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
@@ -2975,9 +2981,12 @@ struct timespec64 inode_set_ctime_deleg(struct inode *inode, struct timespec64 u
 	cur_ts.tv_nsec = cur & ~I_CTIME_QUERIED;
 	cur_ts.tv_sec = inode_get_ctime_sec(inode);
 
-	/* If the update is older than the existing value, skip it. */
+	/*
+	 * The update does not advance the ctime. Stamp the current time, so
+	 * that the delegated change is still visible in the ctime.
+	 */
 	if (timespec64_compare(&update, &cur_ts) <= 0)
-		return cur_ts;
+		return inode_set_ctime_current(inode);
 
 	ktime_get_coarse_real_ts64_mg(&now);
 

-- 
2.55.0

