Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795549754;
	b=QdquU/NOdCSJ0U3vepYkun7d12nWmFd1akxFbzE9HtyeF1bpTDeydxqTN2r7wBXKSeN+
	 NpbwNv+Ilgfmc6lYn+jz+nMq1NKNOIPfkRm79CNC5eiLF3VTjBP9ki0ntzSttCfgrSC0l
	 VEDXbmtho41CNDJil8LRW4bPU+W9QtKeW0rNxsQl62C2LFBqt2CowgS2cluDvU80mzZGw
	 7eh6fMVaMJ2rV8it6id+Bj50yoKEgywbjy8zIuYlK3V7ApYfCI0/gCHImHR7Qi9Ug+92R
	 OEoQCFJAwg9h6fySTABRq5b0SzLBKT/3x7MTucLRe6+0bfW9L2dioOYiZWenAfEvssQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795549754;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=gEWQnguPB7hMdARfJ31ISn8RsG2f0AX2Jn3S+xqhW8w=;
	b=XBT86PgYtjLPAbl7cSQu7OSOyFvFRKsCbBU3WGUDM/8BU99J6z/SrFAgnn+Mdj0phOL8
	 Rn6V59E+aNkMZD0nexp8P2oUnctQWr8K2+b66oFc0ZgciA2upchMlcVNEVMT+xAnDa3JX
	 5wD09Qh6jhNT+QQ0XVenoLu6zBH9fXAiFpGmxhI6gpipeNkjwXE9nkAGhfMpeH6VjecUN
	 KxjvPk6sOwVTSC7pJpiiAXD7EW9Mxw3VmBxCVmZH06Wnoi++PM+YUWGBS/Y2lIGis56pv
	 UvgXofGdm09YI7YblbrIKHclv9OcPfE6QropaF9wbcjrtP8Ao6rXDMheVQ+xufuFhCQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KwmGp5sa;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C7FE9606A32D;
	Tue, 24 Nov 2026 19:49:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KwmGp5sa
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6D5C71F000CA;
	Tue, 24 Nov 2026 19:49:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795549754;
	bh=gEWQnguPB7hMdARfJ31ISn8RsG2f0AX2Jn3S+xqhW8w=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=KwmGp5saCE10U8N1P0haAJ3jXVq7rBLSqD7+rF+4YF/4pdOy0aDOPSh8ccopYtIrM
	 TrOT/Q0TP6sBzHtc8f0C9bhTrto7g+acfpef+aas8rI86dnQfsc9lThpcln5Y7NtOz
	 9D3zxqWM/j+dApzQc0La4Y3IqfeI4HezP7lwRqGvp8oagDsWqO1dkJWq9mDp2uQs8F
	 27IFxYsoQT8kTgz75Ob8odBs7dnHFZVYrJ/jXp1n+YD+5kRLZSx+8swaKzN4dhQc3N
	 DPFm8+c1aKXx2ii9mpxxcaD9P7RuLcGH+fLJHSDzlmf0CLseX3Sz9A4yqUtRNOrrNq
	 4MPRXXRD7FL5g==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 24 Nov 2026 14:48:40 -0500
Subject: [PATCH v3 01/12] nfsd: don't hold inode_lock while waiting for a
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
Message-Id: <20261124-delegts-fixes-v3-1-6fe4ba705aef@kernel.org>
References: <20261124-delegts-fixes-v3-0-6fe4ba705aef@kernel.org>
In-Reply-To: <20261124-delegts-fixes-v3-0-6fe4ba705aef@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: =?utf-8?q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=4815; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=gfHLApKVxnVRAVhXAlVUqlmSc1b8cj0Xz02L3tCImHo=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrBeo06EQ2wNt0ItnE38jQaDbrU6MKMdhTtX33A
 aB/KmtVfOCJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawXqNAAKCRAADmhBGVaC
 FdAND/9Vu+ljTZ9YjaDKauNGdddGGKUJVLMDkKxd3zE9sDmNcWwYCJWpBaqBgbDLxDZHkD2GR17
 n76cKbJsCAJUKSjlpUUQeU1D3Ktwh9KWN5bYvI2MD1PYTSmIBRvpNPqpzFXkjU70656rUZw7dt/
 EJ6FEkLsPv/xtyEbLuLYyAv7Pnrqt5uizrRgd83iJQ1eAcDRkGSrQgIhlv9gRHjgNGyQRuasXuO
 pmLAWmS8NjYMvUSNYIuMcAjzUZLdXIA1HMzYlRLgta9xYn7MrSZVVcD+MGinaPIrQbKRqQ6ZQsK
 MItXG4JLXLKmIshSX60AxsNtSV0u5RmooidxnosDUm0PTqPEr7GxsyVo0XRxYzjQP6akEBDKKm4
 eENp1zTkqsQGI89HFk2KSnaDrCxeNYHAJKBA++IfXIdpLXc67+5pq35zmCN/qntnQ4psHdZ679Z
 MMeuvK2meWU8QKvd5by1qx3DXvXfobpEQoBf1+gSu2kHUsNyG/gnSqni7CtIZ6YnOX6pk5lMSeC
 hLHXT7qkW71jAmZ0+rrPJVLdUZm3vP1bOPeqU6Ij9A8ThOkzYQeNSj8xbfNon4VSP5n4zutWE8t
 gzMuqdo2SGo+mZU+iuxs1u2dUoaFypElPQ+2UHbAN7WC0Qff+f1IzkpryHA8grSPbcq9rxxp/QK
 qbkvkxvviIQovbQ==
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

