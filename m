Received: from fhigh-b5-smtp.messagingengine.com (fhigh-b5-smtp.messagingengine.com [202.12.124.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0F35254705B;
	Sat, 26 Sep 2026 00:11:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790381492; cv=none; b=jiMwDiz7TqlXR9djzD8okwwufWweDpb4/kIPwPO7emlj3DBNJkvUlQUFtxKUVwm+sxjwQ0n4zDW/TF/Tl7+gsoCG/FpR5Lf6iw29bl052BQ1M7XkRDh6fUimniMRFG46PFUgBwBOtM5oAZLjOnZ6FL43sFbcipMe4cTxb2n/qc0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790381492; c=relaxed/simple;
	bh=L99XUiH7ovVdCLdUyoRy4oxxMu4O4CiZw/A4qvDl1D0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=pDsJEy7RFc+RnBSzu6/yiLXWJNOAV7qcRikFgArI196nlstRViAvQj8KPDSUXoBmfWnoOmgNboEb1YDcTSZRg7H0yj7mj2hmDsT4fFQyZ9gKYwbNgYvikb5RBC9xhpDLKSETZWUr4OXKfwzRAZMC6vX/s7xFFSRJnctzgl95MRM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=V3TZ2tFc; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=dB4R5ZOp; arc=none smtp.client-ip=202.12.124.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="V3TZ2tFc";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="dB4R5ZOp"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 1A12C7A00D7;
	Fri, 25 Sep 2026 20:11:30 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Fri, 25 Sep 2026 20:11:30 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1790381489;
	 x=1790467889; bh=2w0jpfTjR8/j3Lp/A/H/qrO3aOog+29Mn3JJ/0x93gk=; b=
	V3TZ2tFc8mjNjzeItWIhP0tRshKWP/K8sg3flgmQ0G8fdFhxrnddO1sBvN/MITir
	HWbib/gDTNFM1q6ANU2/AzCslW5jtoNcqxM/Kn745HEg539Cu/OKia1UhjHZy6DT
	GgNmh2qFr3BL3dMA8AqQpMYrBn25yhWlB3tmuIjagMMEWxxpN0IvAPzXfNawfxTD
	uBTOgs2ITgAi7IJP949lQomOfwi2qQNqpRmOeuAwa9N2of8qXZ1fW8e2ObGp+yax
	6CRLBV6eJH5c4It92w11/+yIhf3iD63gyEAObtFd5Pb6MD+KcVgKj/9WN3jHIPyU
	RHW2YQwiGbzFUCMeNZWbPg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1790381489; x=1790467889; bh=2
	w0jpfTjR8/j3Lp/A/H/qrO3aOog+29Mn3JJ/0x93gk=; b=dB4R5ZOprg2mnzkot
	B9D7CcjQ4SKL9BfhDWxS03u8p+NSBAxcBhqo1UFyvCicgjP2mL7sJ/h5/9QrZV0L
	BKXTB69HpSdPmUlk9iMkX0gRVuTa8+BlVeQf8dA5y8HkV3QUahq879P01p7QjM3W
	Gnyz1P2Rc7Lmn3O+9cJJfrRmqD4cru1wiynVYRXK5qXdYC3+E7pvY/PcJq1BZPe5
	nGNlfFI2duXnbNtLlsfi5ZFP13xwn4X0LZyrWQORvKZlerhyppJHl2aTcd++tS4Y
	oV+dlrLX0dbQdwcmyrvXFbO4ro2W4QyYQ12qrcEeFIdUoyQCUS//0DCU9Nyq7Goh
	UpX2g==
X-ME-Sender: <xms:sQ23aq-_vk9aWfz3NZDEttXLk0Rr3jft6Jnxfcyinu-tmVYeSUE33A>
    <xme:sQ23atS3dv7JviqsA8OCRpDu7ar0o2cd1Pks-A1OA2yjy5GuHytHqbLciN9Q4xGm7
    MAKRplqC-crNd1eXGlrYh5O6GgOf1VhTCHDduxT9NBBpfIzLUM>
X-ME-Received: <xmr:sQ23ajqSQtih8BAIvVD1Q3scE-Iz74wa23FgVeQkwgeFttTKRDcTbIBJo1ecBzwRWXBflCBD3HHxvaSnmgJ6E0l3x9MOiZE>
X-ME-Proxy-Cause: dmFkZTGWxL+qwdF+6ogkc37vJ94kB80sV7VXoJ8roDlzdBJWE/FvVbq7zIGeI/14s3bjfY
    PZ63hMXDtCn28O+OsBFVT8Lm8Zqg7CpGHhkVez6qq0BomB3jToNE7dTj9ZUZXLbdXqCRYT
    DQaUnAQkugRydtr+1K+LLGaVyXqEJqmPa7NLlhJXRvqrixtMbIXVrBRTexUskOKQtuRA44
    Up2nmNI5eILZfOJCe/8SNctZVcbRibXRhcczp/dwJDzqO6+PMGUNmmXjrYgGfRN5KIV4OC
    4pq2wbc3NCSm+p5BY9gayIyR/lwnX56zYlaZqUUUbPohaMarmwAFqylfe2foCywilnorJv
    cRT0tVNgRUiEi37M9DUuxnc32GpesbR9m4UcnPM1DnYti2O/jwRSRAmPWSSY/QNvf4ouqd
    jlAqhDZdw+6a4gNS7JiZKGP5oCslGwjzBx1rzvSm13ka5viRXXORdbi2PZ+6tH+Xz+YFd0
    /PilsUx15rAYcO9+/I4p+qUPYgOQXArpVcbgmNLY0EH3zZ8IF8HsfCVOVI/21JwDxTVoox
    r4U9W8/LfTxanG5PzX6zeuItS45I+xxt2L2EfT6X48SSOoFAyiWEtklrt7seseg7hnqxeY
    NQvnWGuLjAO3x//TluJTwNQKXbnrxwxUCpPkB+FuxaWV6tR0ZLHeYOEFpr+g
X-ME-Proxy: <xmx:sQ23aikUvQo9aPqcETQp4b_dcWRHRiPQGr_X3AxRPAA--QdMydBn7w>
    <xmx:sQ23akeb6hcWgqCo8vWMgzC6fYk9fs2lN8oTDMKbz3pOWrhKHyzqjA>
    <xmx:sQ23amqde7-aoZF-NM5TXn_saZwN68YiPT-luuiPyD6CGhOFL1jM1g>
    <xmx:sQ23amM-zmlauZUJ5jPCaPjhsH-72jgyIV1-_4_mGnDOyZo02Jpmug>
    <xmx:sQ23as0em-UjPY2ppQ8g_SXVGSplW5zdF-kvFogzMdW0hAdfU83FZteE>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 25 Sep 2026 20:11:27 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH 7/9] nfs: Use d_alloc_trylock() in nfs_prime_dcache()
Date: Sat, 26 Sep 2026 10:01:24 +1000
Message-ID: <20260926001011.401824-8-neilb@ownmail.net>
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

NFS uses the results of readdir to prime the dcache.  Using
d_alloc_parallel() can block if there is a concurrent lookup.  Blocking
in that case is pointless as the lookup will add info to the dcache and
there is no value in the readdir waiting to see if it should add the
info too.

Also this call to d_alloc_parallel() is made while the parent
directory is locked.  A proposed change to locking will lock the parent
later, after d_alloc_parallel().  This means it won't be safe to wait in
d_alloc_parallel() while holding the directory lock.

So change to use d_alloc_trylock(), which removes the need for
calculating the hash or doing a preliminary lookup.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 8650ca2b6fc0..b54ae3baed46 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -749,15 +749,12 @@ void nfs_prime_dcache(struct dentry *parent, struct nfs_entry *entry,
 		if (filename.len == 2 && filename.name[1] == '.')
 			return;
 	}
-	filename.hash = full_name_hash(parent, filename.name, filename.len);
 
-	dentry = d_lookup(parent, &filename);
 again:
-	if (!dentry) {
-		dentry = d_alloc_parallel(parent, &filename);
-		if (IS_ERR(dentry))
-			return;
-	}
+	dentry = d_alloc_trylock(parent, &filename);
+	if (IS_ERR(dentry))
+		return;
+
 	if (!d_in_lookup(dentry)) {
 		/* Is there a mountpoint here? If so, just exit */
 		if (!nfs_fsid_equal(&NFS_SB(dentry->d_sb)->fsid,
-- 
2.50.0.107.gf914562f5916.dirty

