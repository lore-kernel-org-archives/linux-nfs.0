Received: from fout-b8-smtp.messagingengine.com (fout-b8-smtp.messagingengine.com [202.12.124.151])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4863039B94D;
	Tue, 29 Sep 2026 02:27:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.151
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790648823; cv=none; b=akibrL3GoAoDxBMf9m0eYIqD1oHQIB/wPpWLeODgPmJQSZaCXcebKmKEiHS1Cdxs+W93gEEBcC/Ir1g02OY7pkRC8opVyUo5D9h6bJFLFhH7lH95Xo6o60Psw1oyJbqU2gP2fTSy/Ikk4NjPkopqaSLNPMUW3zs2DtWIIdOu2nM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790648823; c=relaxed/simple;
	bh=M/R7HWPQLvKoRQBOeEC9AkPKk/1Sdx9y6nEEikLX04w=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=S6SOuiXjSecVPTv+YE9msg7ZNaaQ30UugOAPkzWBWIZ04dhaQ75wCopWaOI4C3h74xBNzpMpLl030Hsdq9tlIywdKeFBiqWPi8hesrBRQvnbaCOXZaHsnNUqRl6qp+zeRJMActP+1V7xi14ArAzOwcFRORAdqjmhTbLe7Kok0Q8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=WX6Lit+n; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=vPFsRm6N; arc=none smtp.client-ip=202.12.124.151
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="WX6Lit+n";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="vPFsRm6N"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfout.stl.internal (Postfix) with ESMTP id 374C51D0012E;
	Mon, 28 Sep 2026 22:27:01 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-02.internal (MEProxy); Mon, 28 Sep 2026 22:27:01 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1790648821;
	 x=1790735221; bh=NROzVZDIwIyaq3HElGvYEx1925arTOmvDNFZwWa3ycE=; b=
	WX6Lit+nmVtZwZvYdV5cLQfwOO8gEH4gItrvwC67n4gIUass2jEjjGQg4W9aKkNp
	PiWJjlDs+jFZc+RpWwWX+U351vsdLj1nYd0tYQn87PvG0FRbEWOYKWUAF7ww6gxi
	RCf5SeWno7+MHrXQAwTkJdTX4kSTCtBdLUjsOc8RO6DS1uXcRD0W4ndqa4qIpNGN
	3N3mlLJVcuXv0GfoEuThfELJSV2F01pDerAUNz8wKwG333D3zqMrZO5KWballzjB
	YYI06M7TM6MVM9HpprKkURCqnS0enn1vsfJQsP9sgB48E5sX+L/XHadwIkAX9c+V
	fjvnjtwEGrrOmxn/VcRcCg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1790648821; x=1790735221; bh=N
	ROzVZDIwIyaq3HElGvYEx1925arTOmvDNFZwWa3ycE=; b=vPFsRm6NgjTCAOcvE
	2OqTxj2/Dw+9XZwTI6FqUf4BeRO9q/+6j7PTh0ifqDBiqPjkJm2KmiKzl/Pt7c9y
	cKJUD+I9pziyaRCI0UDJYFp8uS/avzXOFHjWD+0Ka7c28x78EiRnmFDXqHmi0I2k
	mtNjmqZ4TDp7o6YtiV9vHxoDQr8ce109urmAZkD727vRdk5CnOX0IRnZ1fHOLzy6
	/ngHqKteTGGRvW4DIfccmb4qiyTJSbVYxYCvo3IY3yw0ZqBzWmH5OX187637auNa
	SUdpOD8RGDSraGVNoxuRDFpJZRisuk3If0Hdw+OafyF32hLlSixValRCQMGFNIDB
	oTV8w==
X-ME-Sender: <xms:9CG7atlAlX1YqEZsimbcP96PIohjqTAPPZlpljbdQhPHswEHmY7qjg>
    <xme:9CG7ar6TULfEcztImDx1Anv5TmXRpLJLYr03xxSXBB6Ib5eDox_wbG2MQfDapVopE
    D8SDbpcSoJsNCCNsak2fdqs9vdZggG-a3JUtp6cm0m6dbANfaU>
X-ME-Received: <xmr:9CG7auRzUcX3taqPMLOuqt0WLIVRi372vwwY8fHnQNC3ycYSbcdrHHyqSoG1iNZ8yyR1ePzREU_JQBixVGHurdLY7sXO5DM>
X-ME-Proxy-Cause: dmFkZTGVDNnzESBYR3mA0mj4J/oiPo94sEVuvz2NPFNMdz9kYeMQUYNSOMDonD5x5v1lxt
    Y3YKxth5y+5AcelhmbqoVXV3FsLexQGqy6ySfBbZdX3XOiA0j0ixOwBQ7YQLMW11urS7Nn
    P7GcHAm+fnGGsK6eRyjpaEjaW3wGzOUhgHmF6172kXxhvNqw5t03JcHMsDIg5eCzkcfYMp
    gzeksANsqYigaEYw/3+s/BCzhblwneuYn20KFgS0pcn7Y6OCynIfFAyFrn+uVtT1eBj7is
    YWaEDBls78d1VVrgCXv67Nm8xKS7Zaj2d89K8kC6IirWCBlABYeoWupGoWlHVy0aKpr4nR
    BrBFiwNJJTnXccWRa8Ri3yyEdc32kQgsSX6PmIdjlpKc2GKeRZQ1/8vJZ+UUEF4m8mlqYk
    jhjRT/6YvIJYBb5Eg4lzrLl3CrhlQj1L330wzcTS8hN7GcWMtG8tDysMVJQ+MSscNav5Tj
    6QPqmUe38AkROqA2X6L6u4BE8gFHkhdxTFdCNnmkRGMvhjsClFWNuzwYtsH+nnPXt2SO/c
    MuchKerW794RVpKcs78wHLoPU/od6rDTx2vELoQVP8U5e0fFM3wbgbYqoZH/8LpRFQk87I
    933qnxgfeixvgMOmmz9DSESsjuasIetZp6M2p09mSh8mJuO1s4Yh3EzSJplg
X-ME-Proxy: <xmx:9CG7apyn_5jSRrTnkHLRKtYa_rMnHMDx3dMTXaJ8mTukK9-fVSqoGg>
    <xmx:9SG7amruADUTFij4Isojtt3Vt2yPPaE9hbOiPqHYVMRcBnsRRaOW5w>
    <xmx:9SG7as3Pwt9cVMw224qlJrKpuTpP6Fnz5HLJ6lNwKy-7K544ZaXpCA>
    <xmx:9SG7amxqGy3BKab0Gh30-isxz6MvO6VLvuD4jNvNe-C62vRRNXi-Jw>
    <xmx:9SG7aisi_X2gPpQjhIUa99dByfHNi3wEGA9cuEBIn-AXWiblJc8yxmES>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 28 Sep 2026 22:26:58 -0400 (EDT)
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
Subject: [PATCH v2 6/9] nfs: don't d_drop() before d_splice_alias() in atomic_create.
Date: Tue, 29 Sep 2026 12:21:16 +1000
Message-ID: <20260929022547.1428036-7-neilb@ownmail.net>
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

When atomic_create fails with -ENOENT we currently d_drop() the dentry
and then re-add it (d_splice_alias()) with a NULL inode.
This drop-and-re-add will not work with proposed locking changes.

As d_splice_alias() now supports hashed dentries, we don't need the
d_drop() until it is determined that some other error has occurred.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index a0d22445dd06..04f6aee65446 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2180,7 +2180,6 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 		err = PTR_ERR(inode);
 		trace_nfs_atomic_open_exit(dir, ctx, open_flags, err);
 		put_nfs_open_context(ctx);
-		d_drop(dentry);
 		switch (err) {
 		case -ENOENT:
 			if (nfs_server_capable(dir, NFS_CAP_CASE_INSENSITIVE))
@@ -2189,7 +2188,7 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 				dir_verifier = nfs_save_change_attribute(dir);
 			nfs_set_verifier(dentry, dir_verifier);
 			d_splice_alias(NULL, dentry);
-			break;
+			goto out;
 		case -EISDIR:
 		case -ENOTDIR:
 			if (open_flags & __O_REGULAR) {
@@ -2205,6 +2204,7 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 		default:
 			break;
 		}
+		d_drop(dentry);
 		goto out;
 	}
 	file->f_mode |= FMODE_CAN_ODIRECT;
-- 
2.50.0.107.gf914562f5916.dirty

