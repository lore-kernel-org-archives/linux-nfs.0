Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793696652;
	b=VSBR19mXiiPacf+YYIG9KA2aqmf9Hy2VoUKIr9AB+wKnxyZNgk9itTR84JszTpqBr3yX
	 ctXVQIaoMdK+Ys3v6EsitFZ92ZQEw8DQ2NVcrR5nrlNAKYQZ2TcQjWQPuyG0wQckVBhme
	 1Z/2nZF9vMXCpOrw2PLKJN1fwfD4iNfGUUHD65RrsLe6gfLCZxRMnMz953EGviekhgYZ4
	 qYg33P70Mh7oTdT0KHE3kmJ0lTacmXUVK8OwJHcKGbyyh3SuVT7jOuNmnXfVXr0+EpNkQ
	 lPGVrA0eTVAu03gssn9GK2inJtlUkzMc9hMB5Kiz/sfsHG+GcSfBH5AHrrfYz9oC3mw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793696652;
	h=Received:DKIM-Signature:Received:From:Date:Subject:MIME-Version:
	 Content-Type:Message-Id:X-B4-Tracking:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To:Content-Transfer-Encoding;
	bh=mnb0Wt+uJpkafFJvG4fZXvQtXwaLW2sFanFoZ+MVdLs=;
	b=PMPtEPQZsp7RukCmP+9YZLNumlx2LkRU/1HNcTTxeMfKMe+JB9yWnjf+wn4Yd6xZVOa1
	 3LfbQ88GaQx2b1UVTN7qSMuA6R9FOQ824hefvjWh3Mnue5Uk9Y+hdBGhdZbATj3wXsIoC
	 eYE0AKIQhgWQv5Jh+Fj7alX52ZU0y0SzRYYZQih5v/TW8VB5julIJognS7YRvxrpjycLX
	 hLqCe666dXHwGrVw3e0Ix1ZpwhGejD61v421PcVfozPsSIQnFkYDoDK9roSBW7qVMXI6J
	 eREGa+/iYRL+6NWNj0seyHSewV89BKIOKKfH9Kh7U8cLXrbU1N3O+m7KihfYlEAUmRg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="WK/TWXwy";
	arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9975E606A324
	for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2026 09:04:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WK/TWXwy
Authentication-Results: smtp.kernel.org; arc=none smtp.remote-ip=100.80.115.77
ARC-Seal: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256; cv=none;
	t=1793696652;
	b=EWruJX8MDCI6O4u1/UwemDbHiJUsqXoOGUuBmgTRn48nDXSEbz0kTej9dJItEmhl/K79
	 JyWBoG78yYqZTVLzA6iictvdiXcyQLsONKFCc4FSx70BzviNEJWlj0uh6D//CP3mZimkq
	 M0qBOCklPK3rGU84Gg+nZ+DdgrauDOfV+/iMLjpILRwRLIBnscK5gMeQxMU1mZkBXZ0lK
	 dQ7gsxxqaPNbuufFV2USgZDP/XgNBj/U/U+lkL8eyv1u5/Pz8XjyaK+PhLg4T4ZKP9tdb
	 pp1taAT8NaAFCG9+U5v3SGEXvxNVrkKlLbydyd220zkzR6v9nI1dRfk1IzsIXIChE8g==
ARC-Message-Signature: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256;
	c=relaxed/relaxed; t=1793696652;
	h=DKIM-Signature:Received:From:Date:Subject:MIME-Version:Content-Type:
	 Message-Id:X-B4-Tracking:To:Cc:X-Mailer:X-Developer-Signature:
	 X-Developer-Key:X-Endpoint-Received:X-Original-From:Reply-To:
	 Content-Transfer-Encoding;
	bh=mnb0Wt+uJpkafFJvG4fZXvQtXwaLW2sFanFoZ+MVdLs=;
	b=qNMqCDhKkm56xUfnACR31utWTd9CJLfUDAmtQuky4dLJCNQgS/9HNNJt4iSGQyfve3N/
	 GPApn2V6776vLdNb210kOzrQHXWYOSe0yt5KkCalCkhyzWjB8hU5VZiuqad0bfyswlRgr
	 CTxSD6zLUpaACxMKQurIH5/3eaZKNjlEspizQ7xke45bUb4S3ae/0WCuQ4Dml2HSeuAqu
	 4KPHw9gwQCf8lzl9uBU6yG4jOUodkm1MiDTF0mJLebwor21YogtijKOm0/hjQdO2L81H3
	 301pwPNV/5ue4D5rOT/lIGdSXFw4SnoLL5csqua6+J1IYHArYxL54l6na8J3v2EXCzA==
ARC-Authentication-Results: i=1; smtp.kernel.org; 
	arc=none smtp.remote-ip=100.80.115.77
Received: from lkml.kernel.org (nexus.subspace.kernel.org [100.80.115.77])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.kernel.org (Postfix) with ESMTPS id BCF1D1F000C1;
	Tue,  3 Nov 2026 09:04:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793696652;
	bh=mnb0Wt+uJpkafFJvG4fZXvQtXwaLW2sFanFoZ+MVdLs=;
	h=From:Date:Subject:To:Cc:Reply-To;
	b=WK/TWXwyI1vULJvV3d3pptxBQy0Qpdz2pkN8rJjrYZoGU/TPZM/eYEH3P4Ima0QYQ
	 SnbWJVj7X5wnuKRd9PfOel25I/a+JxmsElEdo2dKlYN1e6/3cRHydbs3faMg0Y5ise
	 Pgz/Bk6MWpTtqEqk2f2mHcP+EGIU99S4WyVwflXm71KLjH85h2X2hRFF0YUcwTGZyq
	 73cNs/TtZzmjIUQuyPbDgsLiZoUpI4oiIjFa+a2LZCbRSBelR0knhXtIQYF+Jmqj6d
	 9pqJ6XkxpsjuL2FESIHS+B/Vs9xAOOA5RlnPMW9ChbculEJV8jbVVoC/cDO18WEoiK
	 LQ1eIGwO0XFkg==
Received: from nexus.subspace.kernel.org (localhost [IPv6:::1])
	by lkml.kernel.org (Postfix) with ESMTP id 223A24684E;
	Tue,  3 Nov 2026 09:04:11 +0000 (UTC)
From: Daejun Park via B4 Relay <devnull+daejun7.park.samsung.com@kernel.org>
Date: Tue, 03 Nov 2026 18:04:11 +0900
Subject: [PATCH] pnfs/blocklayout: commit the layout before reading through
 the MDS
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
Message-Id: <20261103-nfs-bl-mdsread-v1-1-9b29915bbab7@samsung.com>
X-B4-Tracking: v=1; b=H4sIAIqj6WoC/x3MQQqAIBBA0avErBvIFKGuEi1MxxooCwcikO6et
 HyL/wsIZSaBsSmQ6WbhM1WotgG/ubQScqiGvuut6rTCFAWXHY8gmVxAbWyM3tDgvIEaXZkiP/9
 wmt/3A3KBvq9gAAAA
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, 
 Benjamin Coddington <ben.coddington@hammerspace.com>, 
 linux-nfs@vger.kernel.org, Daejun Park <daejun7.park@samsung.com>
X-Mailer: b4 0.13.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1793696650; l=2270;
 i=daejun7.park@samsung.com; s=20261006; h=from:subject:message-id;
 bh=WBV4O1aChXYgb5EMs6LEz+MGYblqNH73Uzx1H9P7xWs=;
 b=MfOWEb1eb+VnNW12yPE3M4dqZNyh7pwb45bt0Tbf86q39cKdg2S+NZ4FsUiHDlZ0zrjhbvIRm
 JJF8zzlKF16ACuVyqEup9uFBlYAWL+E7gv125j6CewpSudPQzDX6EXv
X-Developer-Key: i=daejun7.park@samsung.com; a=ed25519;
 pk=4yUfDqGRZTIj0Ik43z1GoMZRWCNm/rgX6uJuM9dtNIg=
X-Endpoint-Received: by B4 Relay for daejun7.park@samsung.com/20261006 with
 auth_id=1122
X-Original-From: Daejun Park <daejun7.park@samsung.com>
Reply-To: daejun7.park@samsung.com
Content-Transfer-Encoding: 7bit

From: Daejun Park <daejun7.park@samsung.com>

bl_pg_init_read() sends some reads to the MDS, such as unaligned
O_DIRECT reads. The MDS need not see layout writes before LAYOUTCOMMIT
(RFC 8881, section 12.5.4). With Linux nfsd on XFS, such a read after
an O_DIRECT write into a hole returns zeroes.

Send a synchronous LAYOUTCOMMIT first. An asynchronous one could be
overtaken by the READ. If the LAYOUTCOMMIT returns an error, fail the
read.

Fixes: f742dc4a3258 ("pnfsblock: fix non-aligned DIO read")
Signed-off-by: Daejun Park <daejun7.park@samsung.com>
---
Tested with Linux nfsd on XFS, unaligned O_DIRECT reads only. The read
after the write returned zeroes in 5 of 5 runs before and the data
after. generic/013, 091 and 263 pass.

A failed LAYOUTCOMMIT now fails the read instead of a later fsync.

"pnfs/blocklayout: don't let a READ layout hide written extents" fixes
the same zeroes for reads through a READ layout.
---
 fs/nfs/blocklayout/blocklayout.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index b7a3211c58..54825aaad3 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -839,12 +839,16 @@ is_aligned_req(struct nfs_pageio_descriptor *pgio,
 static void
 bl_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 {
+	int err;
+
 	if (!is_aligned_req(pgio, req, SECTOR_SIZE, false)) {
 		nfs_pageio_reset_read_mds(pgio);
-		return;
+		goto out_commit;
 	}
 
 	pnfs_generic_pg_init_read(pgio, req);
+	if (pgio->pg_error < 0)
+		return;
 
 	if (pgio->pg_lseg &&
 		test_bit(NFS_LSEG_UNAVAILABLE, &pgio->pg_lseg->pls_flags)) {
@@ -853,6 +857,13 @@ bl_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 		pnfs_set_lo_fail(pgio->pg_lseg);
 		nfs_pageio_reset_read_mds(pgio);
 	}
+	if (pgio->pg_lseg)
+		return;
+out_commit:
+	/* The MDS may not see layout writes until LAYOUTCOMMIT. */
+	err = pnfs_layoutcommit_inode(pgio->pg_inode, true);
+	if (err < 0)
+		pgio->pg_error = err;
 }
 
 /*

---
base-commit: eea3fef32a9cf36abcb5975a5a594e4135a6b026
change-id: 20261031-nfs-bl-mdsread-346ffc4e9ac4

Best regards,
-- 
Daejun Park <daejun7.park@samsung.com>


