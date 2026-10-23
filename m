Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.155
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792720419;
	b=Kj4xyHdGBi4A+RY7bvH2tyBw2BWBnZbItVN0nGyzUaopimo59m0v0WdUCpVgYy0Mep2v
	 KTrN9Lagi/o4WuRIUunZoTyrfQEIyD6Ls/TyDLmDUfuM5pqKh8eckxhuN1FT+mR3JzCS0
	 SBOPWIbA8lotnTiaGqMayH4Ubi18D/NY457Pqsst5GXxmO2uUOxduujgMWbYAD0cSJx97
	 au9c9Re6UI+LNa/JQX2jtlRAF3ZZYjcS5xHMiJK0/U+cjudejE7L8B7JO3/0PgcIVCY3x
	 AoOb0/NnhU46eQVwWof7VWNHzT373H9rTP2JSZGk297BmujfVCgD66BWYUqN/+hhdqA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792720419;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:Reply-To:MIME-Version:Content-Transfer-Encoding;
	bh=p+/tqKxvTgf1l3vFJoMmNf3gpsdrBdx9RA5sR0kyGwA=;
	b=RMUFZ0sle70Jv+oVW3bkdKnxZeXV7Wg3tViLZrQGN7mPM5qdQpuS13GbxYrxdt4sAR/z
	 i7VWMhYBtqyAcR9Ai8cHxKPUAoq1R+mZhJkNuQn2o7RGh3ogt4amLD45tYeWrwXXfq/CJ
	 chLRdR64Xym2AQPX6+LdSktHZSYyNhPWFJboNyjhV72ajudhFssOeBQClHIt9pdYAm1D7
	 lVSldlyMDo4z3eXfXwJel4yExw06mgyTXiLZSkYiDAdFApdjJDWFLlnsSzagtheegO8nf
	 5pTQdwv7yookwnO4q8n5huo8y6zTUEv8A6uDBaf6SbkkeNJucHm9oghHtI2SrWpaZYw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b="j9KlM/Co";
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=sqq9SSKX;
	arc=none smtp.remote-ip=202.12.124.155
Received: from fhigh-b4-smtp.messagingengine.com (fhigh-b4-smtp.messagingengine.com [202.12.124.155])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0EFBC606A319
	for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 01:53:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0EFBC606A319
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=j9KlM/Co;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=sqq9SSKX
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 73E737A0186
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 21:53:38 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-05.internal (MEProxy); Thu, 22 Oct 2026 21:53:38 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1792720418;
	 x=1792806818; bh=p+/tqKxvTgf1l3vFJoMmNf3gpsdrBdx9RA5sR0kyGwA=; b=
	j9KlM/CoZ8yp60MWUp+1Oe1kw5BzTRVYRpESYdAwGNRBIVgbBt6NBPqqy8JLk+ZK
	rgKIgUOPn0k6xK5d88FLoQ0rxD9tIirS4dzqBMLXB9Z3c51D64bbShoaQHxlLE8Q
	qHlhieQcNTEsVNO0iNrY25WpLx2+UptaB03eLMrV8MqPwzpnuOU3nXMsGKuG84cg
	H4r57+ys/Hkh8f9x3/aOsy0+kRiApaXoqLWY1w5P/iVwqc2jEM3ury2taYmo3h+E
	K/T/uXUu6KB22pVr8MNXuStaH2YykPc175yLZwM3PvNuBIZLUPV92efm/CyW0E5v
	RpCEvUXZFkJi0WOpr+R19w==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1792720418; x=1792806818; bh=p
	+/tqKxvTgf1l3vFJoMmNf3gpsdrBdx9RA5sR0kyGwA=; b=sqq9SSKX0uDCSFYrl
	XJrKP1Ut0jgKbwNhW4+iqrhx6n4zUEfHswWy/EtwD7IM3Q338p4KTmKQw4qysw4G
	XROovFtULf2h0D2iQGb9iTkqeQ9Qq7xHuTUpaEO5+PVxR9Ju8GOiWCQGpXaEZqw1
	abVa7YSytw123pSlDtNJRQOqLpadCHY/LWXc+Nu09hiGNxZrwMi/BEawjXWsnZAK
	T9+6HCkr0F2BTfrJ0bHwePcbumodBmzE9QmYJRNPI9wBWLA4pJaMTUgXN3PDYMx4
	JrpM/Mk5Cx7HVQ0a+fyGs15Th7eJQQOibN88VX7xEz8YiU3hiNCUvXR+MRwLu4Vx
	4lYbg==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1792720418; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm2:rsa-sha256:Ed8xfydnPSnpRWe5bfoNuIONEnbs+bHvfDVl/5xLgCcOt74
	4mIY2a6oQJVCghS+v2hGMxeBT/0vzvM1fh6JIdQBH/OmhBUNMfelEhRLvldkNFha
	QVM1D9k3AVz1Kstn0yzhZqE0rrFL+PLE6I/ip0aMcts+eqs8U4rK9RdvTowkwHJ/
	tMvx8bDf2GhTySY722v8QRw0ZxBI+xCA0vV4jsv6/ja1wByVqOlYLL1u3OECI5AJ
	tZiz0DGKEq0e1XWNTK5eVX9egjYTqFbQdNpCZyHbnSQobRxaLgaNnS9T1MgkzMFd
	XVyqCYjsEyabnioJCkYHrx9Ju5yJvx/Ld0otJiA==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=mi-m=1; hc=12;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,reply-to,subject,
	to;
Message-Instance: m=1; h=sha256:n79bcikYfmAn95WvQU8TgveyNApKazCXHbqP3ehAhiU=:i0ihEzBwkHZYIFPIGvcwCqTjGwUIFSs6F4q1ZDqg0+Q=;
X-ME-Sender: <xms:Ir7aagYING_JOR08wkrcSoTExVT5PSIYyu4RoXjP_OyIPUiWnh0c8g>
    <xme:Ir7aaufPWeID-LUNrAvUU7uGbtvp8QBHlhQH6b2bceRXi4boxJ-eUPRsX8D1doHUU
    PJFIarsdhAHBAh9P5xtyo78GyX62uly_gO8B6zIFrEEIqvvSg>
X-ME-Received: <xmr:Ir7aalnnGGiDj6M167dCVhB_khJUzl_jA0gJyTcTF8OkEdWbtCRZ-b-xWL6L6y9VXx5tspL4OFn0TllWtkszFfBh7UKVI7c>
X-ME-Proxy-Cause: dmFkZTExLsW4SpLCAv0tdT8e4ZPZyVz4IupNhJEO2SD3abqv0hzNCt0wHCU9mnuewgcb3C
    8m9r5e3YKSPGnPB5PYtZBGCtADj2rC8TRrl1Bc3fUQAcoD/QlA9OXRwyejoKLjNMy4BgBR
    4LbEnQXkypLxZ3m4X/K/R9IRkdumNmSBKPe/sfK+vfZjOaMBax2CiZaO2EgzLsHG6TJvVg
    RpN12/waUzArwE0mLwMuNeArpooRt4XVRLhGwsa86uWcBuDyb7Qho3ZSdk2rEHCSbKf9p0
    4ukEKjRnVkvK5y+ofxTRlX1T622kiTdxG1JD6FQoOO8gRlRh/mERVb6ZQ5j3LkSoNAI4gv
    O+xW6DG7omVt1JEfqqihvjTldDIraq3fq90WTRZA2GrttEUgIXbI3VgvdRCCz1qcfQnzwI
    rCeRzyiGqjutgITjb7g0xwfp/u+kmCVx6yDiid2rx3a5WMmdd2P02q+lchdkvN9yjhJ9/c
    bzCzom1fWsTKMy6VyfCQcQdIVBXmgWeMs7WsIiejV9q8868Qh+13bMBs6W+OmDkgl7Bgfb
    ijvsT9LGDIL/IiZrNNdCm3belr1BmyBwVglSvx+9ansheblzOC8X4gv1MhwGyJtx0QmmvN
    4CFwAXH+JcfspmY/sRhKTKKcBWIz/aCYJuWvVAR6xjpEpJ02bN1w1C9tfOAg
X-ME-Proxy: <xmx:Ir7aam3ugv8UMxiC_vFnXcnR7rxms745TvQSH8BhKbIHIEoc3UxZBA>
    <xmx:Ir7aamfbMVMS_D0pitQ6UYVZy0sCGqBwAnekGNMHYSllNCyKpCzjhQ>
    <xmx:Ir7aaoYFv47EQ_KdWBDPNq2Uhq8biegLH4c3v60ESV_KpVxKlXBlcQ>
    <xmx:Ir7aajGATjspP7u9_OI61zqQHI5n_B3tf-E20HHZacNf9cQTnLLwuA>
    <xmx:Ir7aalQv4Xr6eHx_W4b1z8NnD997D3iXXXDREzag7ufVmekFxiymmenY>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Thu,
 22 Oct 2026 21:53:35 -0400 (EDT)
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
Subject: [PATCH v3 6/9] nfs: don't d_drop() before d_splice_alias() in atomic_create.
Date: Fri, 23 Oct 2026 12:50:16 +1100
Message-ID: <20261023015239.2163480-7-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20261023015239.2163480-1-neilb@ownmail.net>
References: <20261023015239.2163480-1-neilb@ownmail.net>
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
index aaad823370e2..8a98247b6b2d 100644
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

