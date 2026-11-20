Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795192820;
	b=ds7u58IUesadjLcxMg6NlUdYhgd9TACCf867MwYjHqLh0ANabLbPkkwY8td20xXqrrPZ
	 FM3W7WNyQmcNBzWNz8Jo+8AukWEzJBWP/Y6UhffookeNEX1MLvTmH/HRKyIt/+uRRG8IV
	 IXAZpyIkoh0yUjR7b34xlceFvpnGLXL1bzXBQhFKlJb0xMyWShF/Q6/+y0P5xHFc7q5jz
	 hnnZ+V7Ifvwb5+uANOyqCkb4sp25sog1LK+rMqQPDHJfhIKvPZSZKttjezZC/KjH23Tu+
	 bgqM53caruwlClVEcqi2ixcp3J9kryWTX7AwfZ2lspJqZW4vIsRDD9sY+GABxdT+mDA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795192820;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=6lAzRxzz4ui6EShaKhfuWI+UdQvuZuX+KQhmq+S5fxg=;
	b=CH1jWyfOWaOnUnXFYKn1YSAddXeMgSLdQ88idShUugBWdJ7BT7wu4ZZmPS9nGe9M00Yj
	 VCgZD7TJR3zVkk6m5nWL4MUT8aFv8AmhLLPt2gfZkcA9EmzRG7cmvV+EsK9RJOMFVlHNj
	 jgNZWvELW1SabtCg8pvSYHM3XHBNb3XM5SdtUl6+zPcn8aX1PQEIqdjxPno95lqSnR5kP
	 NDDTh1saHP5g2Trwe+uWhgrYT82q2F2DxNoOLm6GPKRh36LU0hMk8gQ74H2+LLRW9iuVP
	 RUXgu2qwcfgy+VulfcTFwp94hkT4odBuKy+f8KyirbuqORhxft0d1nnYryOzOGsiK1g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="RY2z/gde";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 86CE160A2622;
	Fri, 20 Nov 2026 16:40:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RY2z/gde
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 25A571F000D1;
	Fri, 20 Nov 2026 16:40:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795192820;
	bh=6lAzRxzz4ui6EShaKhfuWI+UdQvuZuX+KQhmq+S5fxg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=RY2z/gdeUtX+BqMH+xSPggLOES/cicOIh2YIa2omqkY0okneD6fb2xe+Wg/71IrRi
	 ADhY2OzpxWEV+zJ/SACUgAN3ncDfVXyk+NrsgjcbztXAzOZ3XoZIgpO++auF6KvHoB
	 9jGdOXZh4EkF3mnpt0ZBuxij90AU34uweGMYuSS25qmoyruqE3vj2wxQ0RFbFh8SUF
	 SWs0Xx6AljwXTHeajDjNbismXfj9ZCh4tT76Ccy8fkmZKuLuUQFUfaKQSVaSO3aaWT
	 CANARIL4EeoyGIDn5vuvXJCg7Sti8qcORGTdm/OGp4ZFFmiP2PDN5X8TnY8Lngd8Z7
	 pNY9iOOYdwrVQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 20 Nov 2026 08:40:07 -0800
Subject: [PATCH 01/11] nfsd: don't hold inode_lock while waiting for a
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
Message-Id: <20261120-delegts-fixes-v1-1-c89b37d2d462@kernel.org>
References: <20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org>
In-Reply-To: <20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3967; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=gIkdbaQk/nZlbsQRoAuYS/418fVY5UmO9qi0DLZYBuc=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrAHfw3k+9rlrDdKIjilODyxEaKjOBGJIj+Uxkr
 Xa2+BB3r8SJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawB38AAKCRAADmhBGVaC
 FXe3EACJpD6X8361VJsIe6QSp+LpKaMkFIMDg4CWj1SsR9PEZ4cSXqJwx9f50Z53RKgQ/4SKMPq
 z6vL1hvGtSkq8u3zJnnH4NIX0VhZS2a1tntHu2TpkLrG57TtC9ZuRrWWnBxqVRBb/U3bGTpDTOM
 Dmy8YDlZ7L7NaYYp31IplkdDDJxyiWqsWIYH4mGMmoiiyvH/xAGW2k9AgTINkQecOwN7NtpBBzF
 Q1F4Vn4Qi/Vh2s7KxmxgpD5HJE73pOBASn9qQR/Q83vhIEXyXGLTzZnraft1op1y7PaiGVWsAK3
 3nIMeQGTwJxWrWyA9MX2OTY+Ppw4KUzLd6mXzglnXAyzQ9dv7I+oNe6uJF+FAVm8EbWoYQI/Etm
 G3GxvMYQCw7BHA7g2PV3Vf93ugfeFf/jMYhFd+mIOSbnPR9NT6H1NvZsgYk9eIZ+u5jhI7j/Z6u
 fRGAZqNUuyiB8qpLJGlw4t40OaZUD3DJF4dbCfMJ+LR+H9bUbdNSYkMlr+WDQEM2V6Tyr7eq9hw
 H1fRilKnhpYEsywfqE0vL1FcOh0Es3He+RPc8hDzxoUv0xVYhRqiZ+Uv8OEkRNm5EEVtXWjodxh
 yKT94HBqtCNk57wmWFKuHgPmOs8w5C8/Bh6SK+ooo/KNrddIhQ8MZSt/CJuqU84H9vX3jk7ivg8
 qqS8fWoE7QRiR7A==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

When notify_change() breaks a delegation, nfsd_setattr() waits up to
NFSD_DELEGRETURN_TIMEOUT for the holder to return it and then retries
once. It waits while still holding inode_lock, but what the holder
sends before DELEGRETURN can need that lock: WRITEs that flush its
dirty data take i_rwsem exclusively on ext4 and xfs, and a SETATTR
with delegated timestamps in the DELEGRETURN compound goes through
nfsd_setattr() itself. The wait then always times out and SETATTR
returns NFS4ERR_DELAY, after holding up the return it was waiting for.

Drop inode_lock across the wait, as callers of break_deleg_wait() do.
The file can change while the lock is dropped, so start over: check
that the truncate is allowed, take fresh pre-op attributes, and check
the guard again, so that all of them stay atomic with the attempt that
changes the inode. fh_fill_pre_attrs() does nothing once pre-op
attributes are saved, so restore fh_pre_saved to its value on entry.

If the wait times out, still try once more rather than finishing with
the attributes from before the wait. A lease that is already being
broken isn't broken again, so the retry just gets -EAGAIN.

Don't start over once the size change is done, though, as when a
filesystem returns -EAGAIN for the other attributes: the retry would
truncate again, over whatever was written while the lock was dropped,
and its new pre-op attributes would hide the truncate. Return the error
instead, as if the wait had failed.

Fixes: 34b91dda7124 ("NFSD: Make nfsd4_setattr() wait before returning NFS4ERR_DELAY")
---
 fs/nfsd/vfs.c | 42 +++++++++++++++++++++++++++---------------
 1 file changed, 27 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 6905d3285ce1..4f3e480a3981 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -550,7 +550,9 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	int		host_err = 0;
 	bool		get_write_count;
 	bool		size_change = (iap->ia_valid & ATTR_SIZE);
-	int		retries;
+	bool		pre_saved = fhp->fh_pre_saved;
+	bool		retried = false;
+	struct iattr	attrs;
 
 	trace_nfsd_vfs_setattr(rqstp, fhp, iap, guardtime);
 
@@ -612,6 +614,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		}
 	}
 
+retry:
 	inode_lock(inode);
 	if (size_change) {
 		err = nfsd_may_truncate(rqstp, fhp, iap);
@@ -631,20 +634,29 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp,
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
+	 * unsuitable for submission multiple times. Pass a copy.
+	 */
+	attrs = *iap;
+	host_err = __nfsd_setattr(dentry, &attrs);
+	/*
+	 * A delegation was broken. Give its holder a chance to return
+	 * it, without inode_lock: what it sends first, such as WRITEs
+	 * that flush its dirty data, can need the lock. The file can
+	 * change meanwhile, so start over, taking fresh pre-op
+	 * attributes and checking the guard again. That's only safe if
+	 * nothing was changed: a size change that is already done
+	 * (__nfsd_setattr() clears ATTR_SIZE) would be repeated over
+	 * whatever was written after it, so return the error then.
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

