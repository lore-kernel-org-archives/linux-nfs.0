Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795438761;
	b=bmk05kCg49Ie/coRpL/AGlkgJLfZaZoeDA1bE/XXissdaJWuQwNnAy/dUKC/x6vzmDUf
	 YWfwXu25HqHp5vozxIruLJowwK23v4FaZDsCNcw92JkC31ZFF9LCx/98HG23JeN/jx5QM
	 ZZtuLFWKS1w5KZOVH96qLOaCy1iW7/KtB7fHQcz3Y09cfOTWAQDJtuF7QA46LP3IXxIOB
	 qaP1SQSiIAZ46Vkc3Hbb4sio4pe8/MZfpZtf3UVAxDQwL88pAqmWRenvLh4n9JH7U1afA
	 akryiLS2JyY86XWupgyXT1cA2X0cQPU5HCZhv6T6TMYNjjI18CZsyUn56/riYl+6KhA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795438761;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=gEWQnguPB7hMdARfJ31ISn8RsG2f0AX2Jn3S+xqhW8w=;
	b=TW2cptaG2mISn/9ulXzXCTbcYGfM0qQGqWqeGpIMu/eZWn1es3Vy3ktTBPwvFEDNKgeA
	 RED/vOcEosrBkHeRzOZz/8Dbfk+dl5miPjMcIsYOCnwvTPRGhvvxtcHK49G5sHOopjSMs
	 92A3ggG3iTmxCeitcLCRaQOTNIf1gn5h7kO3a7tnBbX7dWoaZWM1vQpV2InKR5hPng5vw
	 tGWUX7UKPH43XKUXrXpgGLNcqhiFobJWUvgHe86ftAXI1sxrQGvADDa22HNtoJJYB2g8l
	 cRRTyRgCqm7ZY4Ecf3j+V6jXHI8MrhSEJOybxGx79zxRzOQ0hu9NctNa2Ol2OTJlyOw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hkaipYgG;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 61B58606A321;
	Mon, 23 Nov 2026 12:59:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hkaipYgG
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4D4A31F000D1;
	Mon, 23 Nov 2026 12:59:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795438761;
	bh=gEWQnguPB7hMdARfJ31ISn8RsG2f0AX2Jn3S+xqhW8w=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hkaipYgG2YTQpKjQgqh0ngFfPCpySP8SskZdYMMhATS91RsLzDWGm/UFwunfJ36P3
	 2iMHbXPUNZh0TS73gVR3kSt5BhqD9jkXnBiIDaAHrV8QJcxGk2sIhenFnWWStJqyXY
	 b/xiKnlYBKjRVJYHVs/SBLRp/vwKEbFhw+9Qr2JE9PJRuWql0pPQVivzf+0cPBHZA8
	 sut4Gk0PC35mBsFQf7aImkfSQpOrogprIfs//wakmA6+3JxlHHQWylw0t6nm80eIcS
	 VsziaJdw0QZT6vhadi3HWUMpE2i4nKdhRqMzL84LC/0q+oz3BB0Yu9jCn9OyUgB54u
	 PuDomONGd2VNA==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 23 Nov 2026 04:59:04 -0800
Subject: [PATCH v2 01/11] nfsd: don't hold inode_lock while waiting for a
 delegation in nfsd_setattr()
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
Message-Id: <20261123-delegts-fixes-v2-1-960ce0fb2fed@kernel.org>
References: <20261123-delegts-fixes-v2-0-960ce0fb2fed@kernel.org>
In-Reply-To: <20261123-delegts-fixes-v2-0-960ce0fb2fed@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: =?utf-8?q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=4815; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=gfHLApKVxnVRAVhXAlVUqlmSc1b8cj0Xz02L3tCImHo=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrBDikjIqcBpUUvxaMz8LFt8Dn5TSB7EUB/o89k
 ++W+xLZIT+JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawQ4pAAKCRAADmhBGVaC
 FQhBD/4llLbbl62CxAGV3lAPgQORjW3AbIB59GsEjFLFsIQ0O6O1Ca5IMh5+6FRBMXWnNTij1VE
 SDTJrNSVxgWy2gLCr+8I159KQek66weNj2+vPiGAyvCza+7OU0NtS9mcdtCfcvMXouXknV1Wlw2
 EVBrQ86uTMwtNHZLJGzi0BumvNx6+RQfw3R4dG5LYxKGgzk12cm1nwT1O00Bp9RNXgEm7uVi5wB
 Udr9mumj/Xz8CZZkBFuMZxCAhiGqpEV6GhimqyN0pXVOgeLw0PCMw8RtyU7R3BsV5rm3gs6XuVq
 0FGyisY/EncyAuE8sLTKyF5bxbLhvLBGpANBorcqMsZ05vm6Up/UhUoNRY1URIlFPDmbURr56pB
 PdpebDTyW74sboBpuSAnGobsOWx6+BweBff91mdUQ92ir5V89mUN+oIrId2pE1GuY3x4AEOkwY0
 i5ylw/9+M9QnfZ3NkDRA4M1dQYaaSi3K7vw4rxce5gR7A+BkeENBxjV1JlTU0aIJ65trEwUSpgr
 qNW/Y2Rj0z+yQV/N+hdwzHAbNKKLtHHWjTYyAYizwEwnpNozZJMUMVbhqXxFm8xAuhe8GQ+tmXU
 fmSe/4OwXAJfoq1ATKC6Chq/QGmhT5lt8O5aFPMEJkjvw2OFXsLdk+nWjwADEGEz2NR1/c+0AIH
 xFHuOf6iv9Dxf8w==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

When notify_change() breaks a delegation, nfsd_setattr() waits up to
NFSD_DELEGRETURN_TIMEOUT for the holder to return the delegation and
then retries once. nfsd_setattr() waits with inode_lock still held, but
what the holder sends before DELEGRETURN can need that lock. WRITEs that
flush the holder's dirty data take i_rwsem exclusively on ext4 and xfs,
and a SETATTR with delegated timestamps in the DELEGRETURN compound goes
through nfsd_setattr() itself. The wait then always times out, and the
SETATTR fails with NFS4ERR_DELAY after stalling the DELEGRETURN that the
wait was for.

Drop inode_lock across the wait, as callers of break_deleg_wait() do.
The file can change while the lock is dropped, so start over after the
wait. Check again that the truncate is allowed, take fresh pre-op
attributes, check the guard again, and sanitize a fresh copy of the
attributes, since the setid bits that a chown must clear depend on the
current mode. Redoing these steps under the lock keeps them atomic with
the attempt that changes the inode. fh_fill_pre_attrs() does nothing
once pre-op attributes are saved, so restore fh_pre_saved to its value
on entry.

If the wait times out, still try once more rather than finishing with
the attributes from before the wait. A lease that is already being
broken isn't broken again, so the retry just gets -EAGAIN.

Don't start over once the size change is done, though, as when a
filesystem returns -EAGAIN for the other attributes after the truncate.
The retry would truncate again, over whatever was written while the lock
was dropped, and the retry's fresh pre-op attributes would hide the
first truncate. Return the error instead, as if the wait had failed.

Fixes: 34b91dda7124 ("NFSD: Make nfsd4_setattr() wait before returning NFS4ERR_DELAY")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/vfs.c | 48 +++++++++++++++++++++++++++++++-----------------
 1 file changed, 31 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index e033fbc225cf..4a5674e583cc 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -549,7 +549,9 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	int		host_err = 0;
 	bool		get_write_count;
 	bool		size_change = (iap->ia_valid & ATTR_SIZE);
-	int		retries;
+	bool		pre_saved = fhp->fh_pre_saved;
+	bool		retried = false;
+	struct iattr	attrs;
 
 	trace_nfsd_vfs_setattr(rqstp, fhp, iap, guardtime);
 
@@ -587,8 +589,6 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	dentry = fhp->fh_dentry;
 	inode = d_inode(dentry);
 
-	nfsd_sanitize_attrs(inode, iap);
-
 	/*
 	 * The size case is special, it changes the file in addition to the
 	 * attributes, and file systems don't expect it to be mixed with
@@ -611,6 +611,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		}
 	}
 
+retry:
 	inode_lock(inode);
 	if (size_change) {
 		err = nfsd_may_truncate(rqstp, fhp, iap);
@@ -630,20 +631,33 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		}
 	}
 
-	for (retries = 1;;) {
-		struct iattr attrs;
-
-		/*
-		 * notify_change() can alter its iattr argument, making
-		 * @iap unsuitable for submission multiple times. Make a
-		 * copy for every loop iteration.
-		 */
-		attrs = *iap;
-		host_err = __nfsd_setattr(dentry, &attrs);
-		if (host_err != -EAGAIN || !retries--)
-			break;
-		if (!nfsd_wait_for_delegreturn(rqstp, inode))
-			break;
+	/*
+	 * notify_change() can alter its iattr argument, making @iap
+	 * unsuitable for submission multiple times. Pass a copy,
+	 * sanitized under inode_lock, because the setid bits that a
+	 * chown must clear depend on the current mode.
+	 */
+	attrs = *iap;
+	nfsd_sanitize_attrs(inode, &attrs);
+	host_err = __nfsd_setattr(dentry, &attrs);
+	/*
+	 * A delegation was broken. Drop inode_lock while waiting for the
+	 * holder to return the delegation, since what the holder sends
+	 * first, such as WRITEs that flush the holder's dirty data, can
+	 * need the lock. The file can change meanwhile, so start over,
+	 * taking fresh pre-op attributes and checking the guard again.
+	 * Starting over is safe only if this attempt changed nothing. A
+	 * retry would repeat a size change that is already done
+	 * (__nfsd_setattr() clears ATTR_SIZE) over whatever was written
+	 * after the truncate, so return the error in that case.
+	 */
+	if (host_err == -EAGAIN && !retried &&
+	    !(size_change && !(attrs.ia_valid & ATTR_SIZE))) {
+		inode_unlock(inode);
+		retried = true;
+		nfsd_wait_for_delegreturn(rqstp, inode);
+		fhp->fh_pre_saved = pre_saved;
+		goto retry;
 	}
 	if (attr->na_seclabel && attr->na_seclabel->len)
 		attr->na_labelerr = security_inode_setsecctx(dentry,

-- 
2.56.1

