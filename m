Received: from fout-b8-smtp.messagingengine.com (fout-b8-smtp.messagingengine.com [202.12.124.151])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E72C72D1913;
	Tue, 29 Sep 2026 02:26:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.151
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790648812; cv=none; b=Jre2rOHtvj1P8vv5EBybovr9hxtyK+rS7dwPv5PRadf/2PRI1Ai6pdd3sx8yEKK0HhrKOhCetVmb+VpeOsjsKnCmZX7MubtiONOsBL1piZycvgEekwd9mb51O7SmEF6jsEnL3XS14Sp5Aiu7ruE1+FIj8u1LMqUwBNVcEdsmVvg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790648812; c=relaxed/simple;
	bh=NOnSRp2kxnyMnxqkm1ceapCrGoAaaoR7EzrcZwGTh3U=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=TZx9RcFT4xZocjaAGDtu0gt2Mb2Rk+XRl9+ZkS4Ab5yC1rFCBqlH3RnsPGRElmAMq+5euc4O4YJQHZLJ+SORvCI2kJxt01ZONefD5IZPjgpY1cZWxJWcvCSGagPOK7QK9A6YMzgH5oEy8ShccUlfsR8enMpRuIScnU7TYlfkfgw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=LitlcS8G; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=aNCk9scU; arc=none smtp.client-ip=202.12.124.151
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="LitlcS8G";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="aNCk9scU"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfout.stl.internal (Postfix) with ESMTP id E9B7D1D0012B;
	Mon, 28 Sep 2026 22:26:49 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-06.internal (MEProxy); Mon, 28 Sep 2026 22:26:50 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1790648809;
	 x=1790735209; bh=ANQObL1xB5sA0p/hT8By1Wk381VxDj1iYlQc1jcd2cQ=; b=
	LitlcS8GAxf0osXvoz6/HMYM5xqjMukrYAdDEZavsokL+7J908RByOF7a514c2JW
	h+g3D6a+O3UQlBz8pQcJ5GGsz3xPFjsstdYgQg7Ivb4EQmOY8Okahp43nVpPhUWD
	kXITqdXaXRIqlhVfhev/mpBDBC+e2vbLqV0KqEuGr7vRutoKeztfy3R+vnXt2j6K
	7TefcW46jTWU+w3RE9pngl2no7z1cmd7wK81GdAZBtpPpDr2rPjsQuxlx4KzYwa5
	j6pVvgHLKO8yJ0Bb0V4tl1H9t2+BfUbXgfhBhsSSSOydI8awmk6WPETbjM6LiOHZ
	eRdgEahYXn7unlDZ0j5huA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1790648809; x=1790735209; bh=A
	NQObL1xB5sA0p/hT8By1Wk381VxDj1iYlQc1jcd2cQ=; b=aNCk9scUV9l4Yzbuh
	D0YorcjCQfE1XnQfSZntpH9d6icEfjDD8t2klX6yMfzk1oEwoT0GgU1vQgAEE4Ps
	3NN6AxupRZ2W7dQm7vb6zvRimo/fZgUz9hewdqOc7i/Jl9M8VXKeYlrxX9m2FQsk
	dPPyrdjs5grQQ2wrMH6tAozofSAU9Swq7XgzbnqKkRUze4o2th6b5cnu9gNCbuj1
	ADl2mUlcFOTLPazl8klbwc631Fg40x/g5VwhGz+3H4kNmSq3ykzSx3v+2MJHVawL
	g3o1fDIiuFw0/iRYcQ71oBkCRP/z8hiocGnefiSLgOsnOjoaM0PWNE7EcGSJjndp
	QqDNg==
X-ME-Sender: <xms:6SG7asK4Ct_f8SC0BUxz83ff7PecONiUuTwJIMf31TJ2TcrEaNR0OQ>
    <xme:6SG7avP321iTgn6TFxGoXyhdXBsaUnPcXPAb94FEZt91haOmkIKCHBeu8lxCUmIHA
    gB2qIWbMcRwhPNcRldbHNcb_Ht-Eb0o1oe7s529a0TENTtR4Tg>
X-ME-Received: <xmr:6SG7anW8jiCPrQyOaml1-n4Tzl7f_6mH2g5bmoEFB1_NypyA0BEMRct3iBVzfFcLp1LdjyOOxT-eXk6vLlbBIliOv1tDV7Q>
X-ME-Proxy-Cause: dmFkZTGVDNnzESBYR3mA0mj4J/oiPo94sEVuvz2NPFNMdz9kYeMQUYNSOMDonD5x5v1lxt
    Y3YKxth5y+5AcelhmbqoVXV3FsLexQGqy6ySfBbZdX3XOiA0j0ixOwBQ7YQLMW11urS7Nn
    P7GcHAm+fnGGsK6eRyjpaEjaW3wGzOUhgHmF6172kXxhvNqw5t03JcHMsDIg5eCzkcfYMp
    gzeksANsqYigaEYw/3+s/BCzhblwneuYn20KFgS0pcn7Y6OCynIfFAyFrn+uVtT1eBj7is
    YWaEDBls78d1VVrgCXv67Nm8xKS7Zaj2d89K8kC6IirWCBlABYeoWupGoWlHVy0aKpr4ra
    MCuHKCIGuxk+pUdVyAeBUoLSkp62iBW9r9vU/E9CFIdQOIWzgRKlEJx7M7LkCwXcA1ka3f
    Ce5dqvAhVl6F2MeyVU8zh7uNIMAHZnqBraYo1/DcUThzLhri4YNb05g2dhjD3bIqSh0F5Z
    EUGKZaNVf2hZTAnmxc2zQfDq4dqRZz4IC+CK9QFTG6YCatXNCSqdo2480HDvhwzTn21a+h
    jKTXZmkFi5yeCZOUETrZvK/dcSGbtvxhlQqSqEGa0a+WTOCPv19BcN28o46p0jKJYSinik
    ctc3m48a6Ku59emXOEvmD/kEaZ2NsyvZFDPQrAlylZcdBrIVuCWrZZbgH5nw
X-ME-Proxy: <xmx:6SG7alnT9SR8fqERtt_L_ejiOqNeyw8uK8HPU8ADbXgwgzKbN6Vfew>
    <xmx:6SG7auNbWTCo7I7ncyikPbVxpvfALGchak5Tq1Bu9rITU3SAYeje2w>
    <xmx:6SG7alIiUDDB30JJRHT9Uo8CQR6efjKDp8qe2cyy7fz_5G1nSPLILQ>
    <xmx:6SG7ag0LB9rsOsjL575vrSqvofc7K8p8MRM-RgGwbkqz8gdYYjSuIQ>
    <xmx:6SG7amBDuJk6aNf2Ux_crd3fvZZSYjQ4NQ17MKnDtVW5S5_tj4Qw3j6l>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 28 Sep 2026 22:26:46 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2 4/9] nfs: use d_splice_alias() in nfs_link()
Date: Tue, 29 Sep 2026 12:21:14 +1000
Message-ID: <20260929022547.1428036-5-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260929022547.1428036-1-neilb@ownmail.net>
References: <20260929022547.1428036-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

When filename_linkat() calls filename_create() which ultimately
calls ->lookup, the flags LOOKUP_CREATE|LOOKUP_EXCL are passed.
nfs_lookup() treats this as an exclusive create (which it is) and
skips the ->lookup, leaving the dentry unchanged.

Currently that means nfs_link() can get a hashed dentry (if the name was
already in the cache) or an unhashed dentry (if it wasn't). As none of
d_add(), d_instantiate(), d_splice_alias() could handle both of these,
nfs_link() calls d_drop() and then d_add().

Recent changes to d_splice_alias() mean that it *can* work with either
hashed or unhashed dentries.  Future changes to locking mean that it
will be unsafe to d_drop() a dentry while an operation (in this case
"link()") is still ongoing.

So change to use d_splice_alias(), and not to d_drop() until an error is
detected (as in that case was can't be sure what is actually on the server).

Also update the comment for nfs_is_exclusive_create() to note that
link(), mkdir(), mknod(), symlink() all appear as exclusive creates.
Those other than link() already used d_splice_alias() via
nfs_add_or_obtain().

Possibly nfs_is_exclusive_create() should return true even with NFSv2
when the request isn't an open (not LOOKUP_OPEN).

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index f219cc1a5fc5..b7cb14310bcf 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1570,6 +1570,9 @@ static int nfs_check_verifier(struct inode *dir, struct dentry *dentry,
 /*
  * Use intent information to check whether or not we're going to do
  * an O_EXCL create using this path component.
+ * Note that link(), mkdir(), mknod(), symlink() all appear as
+ * exclusive creation.  Regular file creation could be distinguished
+ * with LOOKUP_OPEN.
  */
 static int nfs_is_exclusive_create(struct inode *dir, unsigned int flags)
 {
@@ -2699,14 +2702,15 @@ nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
 		old_dentry, dentry);
 
 	trace_nfs_link_enter(inode, dir, dentry);
-	d_drop(dentry);
 	if (S_ISREG(inode->i_mode))
 		nfs_sync_inode(inode);
 	error = NFS_PROTO(dir)->link(inode, dir, &dentry->d_name);
 	if (error == 0) {
 		nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 		ihold(inode);
-		d_add(dentry, inode);
+		d_splice_alias(inode, dentry);
+	} else {
+		d_drop(dentry);
 	}
 	trace_nfs_link_exit(inode, dir, dentry, error);
 	return error;
-- 
2.50.0.107.gf914562f5916.dirty

