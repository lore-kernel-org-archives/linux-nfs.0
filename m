Received: from fout-a2-smtp.messagingengine.com (fout-a2-smtp.messagingengine.com [103.168.172.145])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0D12E3BBFD3
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 09:30:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.145
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784280629; cv=none; b=JpqASGdMNRcJpglayNFOwN20ruLZmkuaaiZnvAuGhFDu5cJxvSfZ8QvIXLAOv3eNwzd4GcRLgiZYbMajQ7vGFw/r3ZT/kV6I8GGxd30oAJmHiwCkddaRRFz4py9lNHkYc72Ip2as+zXDSNqT3SQ3t7kZ4hPu+G0rpvcvlWnyE5o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784280629; c=relaxed/simple;
	bh=PyNTXAqkMZFwpANOBSr1RUp1a7dd8JLhQn9VYVDThaw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=h1c0N0RW9y5uL8N2gqRNefgF7bo7WMyFQ8yx/bUd5SdcGmcBQAKfZfYVauWH53n4eiVasNwjSiFveX7xM65P79StkreaI5eoLwKvgqtDVPnMVTBruoPp4MvOENfZJUp/8gSaO+lcY2++Hq23ClN9rGZZPHpB2sturqYBPADzYg4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=ccxM83KB; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=qoAIxDfx; arc=none smtp.client-ip=103.168.172.145
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="ccxM83KB";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="qoAIxDfx"
Received: from phl-compute-11.internal (phl-compute-11.internal [10.202.2.51])
	by mailfout.phl.internal (Postfix) with ESMTP id 25DBCEC0101;
	Fri, 17 Jul 2026 05:30:27 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-11.internal (MEProxy); Fri, 17 Jul 2026 05:30:27 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784280627;
	 x=1784367027; bh=/q8p7xveHHjAYHH7V0rqJ3PT/1fW6FbQzSkwmEojazU=; b=
	ccxM83KBJEyZwMF/yANqSBjVAOxrLhdoQ6gP33A0b9sy1ZdeT+OrIavP6k1fICi4
	85dsmBqKFDi4T9VRiYsUYjRQOGauNldZ/nKbA1FAc0S62OkT6lXJ1q3Ct92KlbS9
	iayeM5JQCp3AJDIMCKRTgkpMcONZ8qNtfDe/bPO7k/800VEqB1+jD0Eoyrru0i0N
	2S8PN3KmP4/UjDN7iS28Klr+GpGICl4PtmREG3FPrKThnQeT7AFA+XxxDpK1tuam
	mp+Oixs5lxXWzRQU6QUuDeoiy6wDOKIj+A1tSS68d79h9poTtmLCg5KvfyVbE/3g
	qsbkGJkWeAyAZlqR6cMwcw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784280627; x=1784367027; bh=/
	q8p7xveHHjAYHH7V0rqJ3PT/1fW6FbQzSkwmEojazU=; b=qoAIxDfxJ9r2dOZEF
	cL0iFp50fILOtegHzxgsFp9iCVVBTUzA4FanvwVJIxpTIQB1LNakX8F2ehFO5BB3
	BjC7/bKictrpugkGJ4ps7/0DD5nxnn8qH+NPjtF/7Srz2uccacBQFoKd+OXQr0bS
	CVcVL2Dx+iSPWF36kd9J9VLdzXlh6zfaJPgoSNT/XctCa0XLIyGrUMEJGKSctvoy
	saDLKzPdG29IgaUMS46WQPHhSN2z/FYJu324tlTs8l7ERTIdh5dNQODg1ASKKMh8
	sUGReW/aqQMp2Gg318/1APWxsIMxFIt80sfvP3B26Fxq2mzgwfzEDLq+kFaHfG/r
	TzGtg==
X-ME-Sender: <xms:MvZZaiUxNLREruo-POQCItv5SEsfQbmOvwxDPCsV-I7uraTXYzw7_A>
    <xme:MvZZaiRs7fkfY5uAidyCqozx6JZaHcdTxh16HRDGthJ75behwFTvv_Sn9nuLdmGn3
    tnZU-1W4TGKhnFioEhS0OqUrgMXu5XWp56UYxI2tci380A>
X-ME-Received: <xmr:MvZZagO-Mutkma1jK34tlFOu7iPqfMZfaPb7Ivm_AbfUUSQIZJCQH_hWup8i6NIhQi8c-eibEvjlwiTLwy1j9E3EA-9Z40w>
X-ME-Proxy-Cause: dmFkZTEX57Ex8LbShfUXWkvJih4a1baE9EfQ6TgUPnJ0DaKnRO3Du70CAhhY681g13Zhbl
    7+6gjM4A0f7dNvQc03aRIz3FZBRqrxctlwbzsG3ndQuoUarocORY0qObpi2VHZQgoKrsuo
    Pz8T2Hzo9NtU7WBXPVmdapAMdiqKaX+pxxqioqIbP8tlHObQF+a7Mp8hX7zOHvDB6EOMWg
    1sbeLGfkgUP3SWNtJdyCx4zo2FvbCdw3kEs1ZvMn58hsAfPpvA+oTbrgQ0oPjv71NDjjPy
    WnL4ClTcOz8/DrmfPbmbnRXwAb95LZ30NPNsYA/6r5bUfJzKa9KuHLiAmSCPierLaaggBT
    Iujct/pxCsV3gAuc3KUUT0RNryz9vG5bp/2SODoUFKKbSWvTPMM9pEt53lbBbOH7+zdNSk
    D2yPCGEgwHUkMK1xgPOMgGDwJR8N7aAnV46lvWnp5aGGYllcAHIqiUKl1gZriDGkz0Uhr1
    egdTEY7tR0j9WUB3otdXTWVBkCMj2a9As5la880q3ze1OL0krhbwEGKrutU5E3iE6zIGut
    qWxkPJi0/6z/MD+amvKohJ4VEjdChnhiV8md+bjp1ExXinTOWHQHNuhSnG9IlfiC5TYvng
    K76V9W+uWSHHRdUWupO8VhlE3i5eWjF9TswMReI2N+02BkUjoOWTcAhs19jQ
X-ME-Proxy: <xmx:MvZZagQJA2RNuBxdHX4m-3YdSgAImmvuPgggCzELENo3faxs36Jhpg>
    <xmx:MvZZaug9in3UKKGRC-6XTbjA8p1BfVQeGikeriKAFYd_YOslRkrhpg>
    <xmx:MvZZap_qinhRH0TKFVMk2A7uqXM9TfHjtW4_kmm-2JAIS51KvbkfIQ>
    <xmx:MvZZalE2jVzVh_nzwGWOwgZxM_lu6B0-BIOipGcMvo63jkKWL0054A>
    <xmx:M_ZZanf0PRs61w5sp7K7TIYjdihBnEqNUP4gD5Y8EekuFOvHEAChVzZi>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 05:30:24 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 03/18] nfsd: correctly handle CREATE of mounted-on files
Date: Fri, 17 Jul 2026 19:27:51 +1000
Message-ID: <20260717093001.1972119-4-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260717093001.1972119-1-neilb@ownmail.net>
References: <20260717093001.1972119-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

Linux allows a file (non-directory) to be mounted on a file.  nfsd
mostly supports this if the crossmnt option is in effect.  However if
CREATE is used on an existing mounted-on file, the filehandle for the
underlying file is returns.  The client will then continue to use that
filehandle.

So
  cat /mnt/file
will show the contents of the mounted file as expected, but if
the dcache is flushed with "drop_caches" or similar, then
  >> /mnt/file
  cat /mnt/file
will show the mounted-on file.

For exclusive or checked creates this is not a problem as the creation
will fail no matter which file is seen. For unchecked creates we need to
see if the name is in the dcache, and if it is mounted.  If so, we
simply provide that filehandle, possibly truncating.

This probably has always existed since before the git history.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs3proc.c | 19 ++++++++++++++++++-
 fs/nfsd/nfs4proc.c | 27 +++++++++++++++++++++++++++
 fs/nfsd/nfsproc.c  | 17 ++++++++++++++++-
 3 files changed, 61 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index bbaef884f893..61272a6d2211 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -282,6 +282,7 @@ nfsd3_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	struct nfsd_attrs attrs = {
 		.na_iattr	= iap,
 	};
+	struct svc_export *exp;
 	__u32 v_mtime, v_atime;
 	struct inode *inode;
 	__be32 status;
@@ -320,7 +321,23 @@ nfsd3_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			goto out;
 	}
 
-	status = fh_compose(resfhp, fhp->fh_export, child, fhp);
+	exp = exp_get(fhp->fh_export);
+	if (argp->createmode == NFS3_CREATE_UNCHECKED) {
+		/*
+		 * If name is already in dcache we need to check for mountpoints
+		 */
+		if (d_is_reg(child) &&
+		    unlikely(nfsd_mountpoint(child, exp))) {
+			status = nfsd_cross_mnt(rqstp, &child, &exp);
+			if (status != nfs_ok) {
+				exp_put(exp);
+				goto out;
+			}
+		}
+	}
+
+	status = fh_compose(resfhp, exp, child, fhp);
+	exp_put(exp);
 	if (status != nfs_ok)
 		goto out;
 
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 0317ff3f1c39..a13dc1756b1b 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -271,6 +271,33 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	parent = fhp->fh_dentry;
 	inode = d_inode(parent);
 
+	if (open->op_createmode == NFS4_CREATE_UNCHECKED) {
+		/*
+		 * If name is already in dcache we need to check for mountpoints
+		 */
+		child = try_lookup_noperm(&QSTR_LEN(open->op_fname,
+						    open->op_fnamelen),
+					  parent);
+		if (child && !IS_ERR(child) && d_is_reg(child) &&
+		    unlikely(nfsd_mountpoint(child, fhp->fh_export))) {
+			struct svc_export *exp = exp_get(fhp->fh_export);
+			status = nfsd_cross_mnt(rqstp, &child, &exp);
+			if (status == nfs_ok)
+				status = fh_compose(resfhp, exp,
+						    child, fhp);
+			if (status == nfs_ok)
+				status = fh_fill_both_attrs(fhp);
+			open->op_truncate =
+				(iap->ia_valid & ATTR_SIZE) &&
+				!iap->ia_size;
+			dput(child);
+			exp_put(exp);
+			return status;
+		}
+		if (!IS_ERR(child))
+			dput(child);
+	}
+
 	host_err = fh_want_write(fhp);
 	if (host_err)
 		return nfserrno(host_err);
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index f60043632575..20fe4411f666 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -291,6 +291,7 @@ nfsd_proc_create(struct svc_rqst *rqstp)
 	struct nfsd_attrs attrs = {
 		.na_iattr	= attr,
 	};
+	struct svc_export *exp;
 	struct inode	*inode;
 	struct dentry	*dchild;
 	int		type, mode;
@@ -319,8 +320,22 @@ nfsd_proc_create(struct svc_rqst *rqstp)
 		resp->status = nfserrno(PTR_ERR(dchild));
 		goto out_write;
 	}
+	/*
+	 * If name exists we need to check for mountpoints
+	 */
+	exp = exp_get(dirfhp->fh_export);
+	if (d_is_reg(dchild) &&
+	    unlikely(nfsd_mountpoint(dchild, exp))) {
+		resp->status = nfsd_cross_mnt(rqstp, &dchild, &exp);
+		if (resp->status != nfs_ok) {
+			exp_put(exp);
+			goto out_unlock;
+		}
+	}
+
 	fh_init(newfhp, NFS_FHSIZE);
-	resp->status = fh_compose(newfhp, dirfhp->fh_export, dchild, dirfhp);
+	resp->status = fh_compose(newfhp, exp, dchild, dirfhp);
+	exp_put(exp);
 	if (!resp->status && d_really_is_negative(dchild))
 		resp->status = nfserr_noent;
 	if (resp->status) {
-- 
2.50.0.107.gf914562f5916.dirty

