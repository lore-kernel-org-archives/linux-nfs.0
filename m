Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.159
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793160668;
	b=rzvgEe/I7GQ1IkI7rg4bMnZ0nn/uD6M9Nq1Shf8qc5TgnrsOPn8KsMEeRcF7FWRAM9XI
	 sX/fahWHUhUrzlT4X6ztfvNVvXzUPkvjaUQLoUtIJH7QE+g5MTNueoQ9Me9pESuZjJL9e
	 ZYUhGPBWVdjiKHehB6GJ54oEwm1jkdz9d+AaD57kcOO/MjGBWptCCCSpFByYwWeAybrIG
	 feSyV1yzdrs+zXCfqFvZhHle6SLUKCDXhSsxhPa3azhtaG6jwBN4UeDJeiZ4rqybu/dT4
	 H/MB1EM8n+KYXRMPf8qrYT95dZIgG8EPxgvQ1l0MQhDetCKOkJOOI8l7yBITTkAt9Jg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793160668;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:Reply-To:MIME-Version:Content-Transfer-Encoding;
	bh=EQnjUrQSl14oS6ZmsfBbQKCwiQOmsREnTdDTSG7I2HE=;
	b=2YYKqZDXLlis1dtIfiQW2+Jp8AznV1o8ipyPZYtG+ZC6OM6ikV6O71sGrgpOgcoCt8r1
	 ri7ldCfHWLHrN0+VqcfunXcoFKIm0ltKkeVgsJR4rniGawqEh69WupYjGv1Zpz1/VDOnv
	 0mDiBcGN0rPFCc07sHd5tWnh+PkfvnacIOlQseuNA2+5oOu/42vt1469+mMqc+XcOLebZ
	 ouz2/HtsGVkggDyV7Kov81lbDMKFOCi3Vm3hMgOSe1Zm5TL6VbBhLhShMvtd60lV768Wd
	 xG03fU/N1BAXRxkpihPYHSO0M6xS6fZ35WCs5mY3QI/cNc0YVsTl878Od8uIksk+l3g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=Il70pkvB;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=TriIszj+;
	arc=none smtp.remote-ip=202.12.124.159
Received: from fhigh-b8-smtp.messagingengine.com (fhigh-b8-smtp.messagingengine.com [202.12.124.159])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 20716606A320
	for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2026 04:11:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 20716606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=Il70pkvB;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=TriIszj+
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 273537A0209
	for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2026 00:11:07 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-01.internal (MEProxy); Wed, 28 Oct 2026 00:11:07 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1793160666;
	 x=1793247066; bh=EQnjUrQSl14oS6ZmsfBbQKCwiQOmsREnTdDTSG7I2HE=; b=
	Il70pkvBei3Nar1oBldM7XXmlRZWuY7YVovYmIRjm5u5bk3/EvyfsV1A5rV2HCAL
	4x2WsuZDhCTliDFy6/Qqbb5FrU6IsF+4cyBWz6bd58i5CQz8gqZzVUMoVX1dpC2I
	Td9JXMVOyZj1K076m9Wc4yaeYoYONuthL1+f9s5jABazSXyC9J7jR4G3KtdV0p7H
	VcBNYmG2HRPQDUR4r+uNrVfiXNsawDIbPpfGKUzMrrz3OPm5IVNNeAc95UilpAMz
	+GMzYCPHxqp9jB3JKViQ+J63MvjT2K4tIp3edeaBWnRs+zyF8aXfigG9BWmTbVy8
	9HaB+5RZJQ2HhFquXIpOUw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1793160666; x=1793247066; bh=E
	QnjUrQSl14oS6ZmsfBbQKCwiQOmsREnTdDTSG7I2HE=; b=TriIszj+nFz1zSCaJ
	eODOospopUmjBkMLc7ljxjqj+dQukE2ERQfpy1c/fg9nF8wR89ZyE/5bsgL6JVaw
	QFKwmWl0/cXswxvj1F7kj6HbILDahMEE08kmRzQCLMa0jKzT6BORrwJKcS9rIwcg
	nY68fXpND9FNL7WYGUUWFR/2/BD7uLiaY5KnU8czBT3yZGPOAQxwnAe2l56zjNfY
	1veepdSPjGesN3VQI90VoLvl3DOzf9zdPUT4GNNfyBcAqGL/cjEfviSu06LGnpgp
	4DNe3QzDbZp9qpiRaVzBJRIJ1C+oAdbjiTLorXeOOTa8QOpxldzi4z3EItBPQYGn
	FSxgA==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1793160666; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm2:rsa-sha256:Vso684qrZMXXGUxTb2XK8Iw7cx4ZQY5Bu2dtk3hgjQzOfql
	btfN8lFaU6PpRUwjH3alz6FyEQU6O0jzrcKB9ynUHroXMcVK6H0CFBKIfcHlx1Yn
	wAcYaeG0+LIMHfhw/x7F6alfZcFdudJ5Q5MMPJ0/dy3gXYHF4mynsamNnP2+Y53q
	Am1IY4SmyjST+TLN7fAlLHgSh/b7WgtmcbUBwdsCKv+Wt0xqVmK2Gd/shFQkTZ/H
	gq469oVOgcTdLMpO27xyKwqHnqsDKa6NAtcGN8xrB2q2uJbRuJj9g9wY+4OXOVHR
	SLcKITIZHwkujOw9oh+KMjDU/KKwlqhn8vgKgZg==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=mi-m=1; hc=12;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,reply-to,subject,
	to;
Message-Instance: m=1; h=sha256:tPBQXqqUNigMefBYUdCNb/lZzKndE0R1eRdSfg0zlIM=:a7iN5qz1jYk47n5bKVN7Y7AIaexeK8MaqyIeAdwFMnQ=;
X-ME-Sender: <xms:2nXhamcmGUjgCStPY0Pv5w3A2FGWezVE5_gIf8IkGJJrs3Wd-v2cvg>
    <xme:2nXhaudpomZZDLR6AlteheDk6ZYkD0FjRvV_dHUyyhyfc_me51XNqO0TKbMOjIAj_
    WGvr_atlV1jReEgDIxIBRLzHmHleEm-pNkjpXLz8mmwqVdyD6CJ>
X-ME-Received: <xmr:2nXhag3ljoiAGOT55XW2CFy2eTPiUZKRRpS94ipj5_qXqFytfVrCsHohSkIrSDSya1enMmthT4g1bsu6waDuaFDbBaf_QfQ>
X-ME-Proxy-Cause: dmFkZTEtaaJo3zhk6q8YHjcrAGFhzjZGx7kav9mjn36dhiCDz1sQNUcnPXqPMC3VqBUdUM
    QC/BqNrn6VDtoNvGfXsPC6PtPC8Yf5vcT7dSqr4OQVWjbDjoqPju2ao8WKvEVWn6qwQJpD
    4CN6jGUHDBUbMwADgY1eHpCxVa8gj9W+FVkilH/Bf9wmvEra1caZDRUZmQcG/Ro3xW8rsx
    nbEpGLXA1HN5mBuF45EijzjRcn/0zOhqfoHROonBfk2oQm2kGy7PxZcAZk+GCvIPn4bVTg
    3udSvT9vlUjceFzrt+IHSgKFct3qykKWsSJoK8kyGUhtj7khaHZlaj5tXb3YwgPRJ+b+e/
    OBmUuupKDLikksVyzqjA15X1zBWW/4q8dpUu/R90vOpb+sG7ojwGG9kx7zx/pDTZprgVUs
    UIMQMPSqMRr2LKPEjZG4LtVUKfMelbmt+KzzEzqBMULwzBr4fc85mvjg3/FTkplwrO5xKi
    WowPwjx9v8w8Ek1ZeGZEkHe4Y8Tb9T37ql05VJN9nGdRO3diHw84SBTMjSH83f9iAD7MU5
    baztOppT0unyoNjklvGKOodB2hLnWjaaEVQckFrNUmRwTvY9LJdchjsf382LG7RMw1+llw
    zZHr58hNRIoqRrDS4+cqURFeATXDZKwWLYoCJE8NQJFX+5kDeIMADnStXUqg
X-ME-Proxy: <xmx:2nXham8HgusKTqSQFbOsBFu9XogS7MCLn-uTyY22AhM9xOzf7Y03jA>
    <xmx:2nXhal7_KQU8_RF4ISNb9L5fiLo0EkPOETvb85JdIGhr4sGymFiCMQ>
    <xmx:2nXhauuZKZr9RCXdgSDEowt_d7CkyF34Z707ynr9yart9eGjEAls5g>
    <xmx:2nXhan3k9HoVdtQuAfrAjzD0ZRxm5iPr2sVD9JFrYEpXwEeO4HYx1Q>
    <xmx:2nXhagA3NjteQ0UjjSwWxbb0NvhCAGT0INOOeXDRAW1g_dyar15OfxFQ>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 28 Oct 2026 00:11:03 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v4 4/9] nfs: use d_splice_alias() in nfs_link()
Date: Wed, 28 Oct 2026 15:06:32 +1100
Message-ID: <20261028041023.3738553-5-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20261028041023.3738553-1-neilb@ownmail.net>
References: <20261028041023.3738553-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
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

Acked-by: Anna Schumaker <anna.schumaker@hammerspace.com>
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index cf366329666f..e4c7acaaf2ba 100644
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
@@ -2715,14 +2718,15 @@ nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
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

