Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795113241;
	b=OB2sfpT07TLp+l4W99/PROttRM/HJk2d3iXktqYHObse4H1MbZJ9u90Qu0f06K6xAHv6
	 ljl/QeBllw4a5JXRJGckel2R2OVPbB3kK+86wMBF44wOieRhA2YqJSIQnyp3ONclrNj/S
	 Bxo9hP8G2Q5FOgrj+/5EJClTKpz6iswojbSnVKUAlFfvuT0DE3n9prTdk1ZUKfsOSJtLo
	 Sh3CXxT+iETsOJJLClUzBMMK2fPVneU76okyosFrDn/F++7nPja02ZuGiGgLLlsG7fpqu
	 LNrEWPy56wJjDscBpMfQNHy/kMt+AH9Hk6lSQBP2QdBAe4ivbuAVtE/dV//ap5+JT5w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795113241;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=p+iyWmMjHBwobSSgRlSljCsB6hXrJK7vTvqyqX3bMVg=;
	b=Hi2lE7Stctk5CRgkC802ONajvdXGj7qvB2D4WgpxqFM+zjK98FLc1VHU+867COSGpUpT
	 Qg4rLgyaSwZXD5qOF+DwAY4KmqnLNssapPyqh0gw6j5sT8DEOBq9/vCE1JBmJvNHVYpAH
	 S/dKJEoq/OS4qUH+M+P68IFjKkzwI0zUtvcN60XGzzPIrHIbcxIMf7NqVyNDPU3NOurbw
	 aCf9y95+oHp4UZB0P4eHUXMVBDZNI18e5JEDLpz/EuFNgiIgiXQCk7frY6pdwJy2f6+Ym
	 nlwmV9SsyxZyqZ5P4Kh5/3st873VPFV9M3bgyBFmrIgI9wbPtZQohn+UtzNxpJjQ8kg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VjdU33aq;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9A9E1606A336
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 18:34:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VjdU33aq
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 27C211F000C4;
	Thu, 19 Nov 2026 18:34:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795113241;
	bh=p+iyWmMjHBwobSSgRlSljCsB6hXrJK7vTvqyqX3bMVg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=VjdU33aqip7fzcR/HKi2Eu+Mdkm5YMzzVU4mRqZA9xoiQ8Uf7iBxaGf/rw1oQlx1l
	 N1JPiFXAbf7zDfBgSa0p37CRkqwIB5JhoutjOKGkiyeDOYpWVYd+TLSgxmeQpBPbJg
	 U09+y/xpG82xHllAFwaIwzdonbY/5R1Nk1HN85TB0xYWhS0mRlgZDFkR10hNYF7vUg
	 xlgsNXEKYgALVRrF/IeTV2ni/AS/Lr2Dh0lvq6csatxtWaTL3/+6Guy9iz9SlwGaJc
	 j1Pa6kw9mjcK+LqPOsEkeilDtAgKkOrK8SQ05/7uElUiP4pLe2gYSpMx8CMWw5Pqs4
	 QrUMi6LdeCi8A==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 19 Nov 2026 13:33:52 -0500
Subject: [PATCH 2/4] NFSD: Allocate the layoutupdate extent array with
 kvzalloc_objs()
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261119-blocklayout-decode-stream-v1-2-d71322f42c28@kernel.org>
References: <20261119-blocklayout-decode-stream-v1-0-d71322f42c28@kernel.org>
In-Reply-To: <20261119-blocklayout-decode-stream-v1-0-d71322f42c28@kernel.org>
To: Chuck Lever <cel@kernel.org>, Christoph Hellwig <hch@lst.de>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Sergey Bashirov <sergeybashirov@gmail.com>, 
 Konstantin Evtushenko <koevtushenko@yandex.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2582; i=cel@kernel.org;
 h=from:subject:message-id; bh=ilRGmqbUhyjMgPHg3fGYlh5LyiqjVM7pCMtgyR75V6o=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq/0EXjK3w8FbJsLkmugTZTx8oT24ck+XV+Bh0E
 4mpkKchfAOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCav9BFwAKCRAzarMzb2Z/
 lwcgD/4ruzrfOq7kjtZFbthkSZOQQNFSK4brgYrDi/LUsTIzx0Mt2fEtFPCUz0GBXk1OToYJY67
 paQzJirvG6sBzW9hdj2cMU6G/rLtoUWX3RDEmlVDbQl+FGCFQwDMqhGvvhZICccPdvMDPwyVjFT
 jyU21ACDho0D/9LulJwdOSNlX3EDu7M91DMUF2pbq07xt9tllquvJsl19FtFfucxKtCkpaeDAyS
 1KoYnHvy4Ucn4zo5NzcU6orXejZMPkAeTcHSliZ7h6hIx51SwJyz7uJ70zNjgUsahxh/UnvuXNP
 UgpUytoRWlegHuDwu2IJHGLjd4I60Xq63bgFGjk21Ei+jK774pWLSMaHVPR6q2Gle/H+fXenjcQ
 wvnoKcFFGPInxy/FoQ43B3Yt7CXVeVS+BSizUHkNxILhw6NErJ2yNlTSSnypJxYgPGsLEVIs83x
 r6zu4rJRhVRRyySAW9WxDFiRrVsNaSAC8L59ppsXIdqaV6DE5+0lM9zJGQeVT9sOMsS6qHOdHp/
 EPjCHxuLgd62NR1B3RJqnzjBihgOteMfrP2SiNfFCuel7qXrJZqBkMd6FyMjm67uFkhBa01LfvA
 f5QZB2CgnboG9HgpBwPJFOI0vhRb2Vdhzl9r+vqaguTon70+fTBV3i81uYSgxdLSDvfyPsqmzyO
 i8zacaIbOI/UlaA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The block and SCSI layoutupdate decoders allocate one struct iomap
per extent with kzalloc_objs(). A struct iomap is larger than a
44-byte block extent or a 16-byte SCSI range, so a lou_body that
fits in the maximum request size can still need an array larger
than KMALLOC_MAX_SIZE. kmalloc() then warns that the request exceeds
KMALLOC_MAX_SIZE, and the decoder returns nfserr_delay. A client that
retries after NFS4ERR_DELAY resends a LAYOUTCOMMIT that NFSD can never
decode. Found by inspection.

The session's ca_maxrequestsize still bounds the size of the array.

Fixes: 8650b8a05850 ("nfsd: pNFS block layout driver")
Fixes: f99d4fbdae67 ("nfsd: add SCSI layout support")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/blocklayout.c    | 2 +-
 fs/nfsd/blocklayoutxdr.c | 8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
index b3bb2831cff3..06564f247795 100644
--- a/fs/nfsd/blocklayout.c
+++ b/fs/nfsd/blocklayout.c
@@ -228,7 +228,7 @@ nfsd4_block_commit_blocks(struct inode *inode, struct nfsd4_layoutcommit *lcp,
 	error = inode->i_sb->s_export_op->block_ops->commit_blocks(inode,
 			iomaps, nr_iomaps,
 			lcp->lc_size_chg ? lcp->lc_newsize : 0);
-	kfree(iomaps);
+	kvfree(iomaps);
 	return nfserrno(error);
 }
 
diff --git a/fs/nfsd/blocklayoutxdr.c b/fs/nfsd/blocklayoutxdr.c
index ea9a3f04a560..90ccc07801ca 100644
--- a/fs/nfsd/blocklayoutxdr.c
+++ b/fs/nfsd/blocklayoutxdr.c
@@ -175,7 +175,7 @@ nfsd4_block_decode_layoutupdate(struct xdr_stream *xdr, struct iomap **iomapp,
 	    nr_iomaps != len / PNFS_BLOCK_EXTENT_SIZE)
 		return nfserr_bad_xdr;
 
-	iomaps = kzalloc_objs(*iomaps, nr_iomaps);
+	iomaps = kvzalloc_objs(*iomaps, nr_iomaps);
 	if (!iomaps)
 		return nfserr_delay;
 
@@ -231,7 +231,7 @@ nfsd4_block_decode_layoutupdate(struct xdr_stream *xdr, struct iomap **iomapp,
 	*nr_iomapsp = nr_iomaps;
 	return nfs_ok;
 fail:
-	kfree(iomaps);
+	kvfree(iomaps);
 	return nfserr;
 }
 
@@ -269,7 +269,7 @@ nfsd4_scsi_decode_layoutupdate(struct xdr_stream *xdr, struct iomap **iomapp,
 	    nr_iomaps != len / PNFS_SCSI_RANGE_SIZE)
 		return nfserr_bad_xdr;
 
-	iomaps = kzalloc_objs(*iomaps, nr_iomaps);
+	iomaps = kvzalloc_objs(*iomaps, nr_iomaps);
 	if (!iomaps)
 		return nfserr_delay;
 
@@ -301,6 +301,6 @@ nfsd4_scsi_decode_layoutupdate(struct xdr_stream *xdr, struct iomap **iomapp,
 	*nr_iomapsp = nr_iomaps;
 	return nfs_ok;
 fail:
-	kfree(iomaps);
+	kvfree(iomaps);
 	return nfserr;
 }

-- 
2.56.0

