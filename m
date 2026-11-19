Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.69
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795116214;
	b=L5SNx4/ICz6KqCYEBu1w2ZybfhRKp7BXuHlqvKKDupTCO+ReM0TlNfilZZyhr/NqMhSJ
	 6ErnegomKXx1QuHDV5s8ZEDp1dUsnFQaZdpM2XjJdL4977cIaFqjx1yvefNHPapfwDmNm
	 z3yetyT7uzlsu/zF9/emiLrjdtt4vmE4YqtF+xFUno6gsQAFETR8PiNVAv27+1QRbaf/r
	 UsxvVTZt6P7dpVqef5KFzV2y5fT9digwDrnIejjOrWOvJlyAS9bv8pUkMfWAZsO5bfKkH
	 qIyfqpMaDk/mDKr2kszM/40Db0ElaMTLcF+ARrDd6hPb4IhvzWY9XvPhTpzXnrFQUVA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795116214;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:Mime-Version:
	 X-Mailer:Message-ID:Subject:From:To:Cc:Content-Type;
	bh=fV5gMniU7c3uA6sIEL3QHarW5z+qAZvra4n6XWyUVDk=;
	b=g2hFQy7F0jk5CRUpz43XMHPaT3+vJUqKDn3+V1GIevf+J5cAU+TNQlPudJk8/Fs0QlsJ
	 GT1xydS67SqJfGJqFdczVNY4OaCiM/wVK42/HCORtskScHzJI0NQ+TWo+xbqgB7vczdhm
	 zu60UIjkl2knRTfneA2tApaYYvGIwz7+YRFKxUl5/ka16lilYv+PsVhPzjfRKGyjt4gyT
	 9SMezzh2YAoD8GhEChC+AgA3tWZBnKLVF1rmOxsUIPyNb/KRLMNh9Emq1pzp/ersmh61k
	 WaUrWmHrNJ4Xj8cZifQwa+D0TxfAm+6RP/wmPPBHXaLCShrUptGAwz33S6EvejrPlew==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--dmnk.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=i+LcyMT2;
	arc=none smtp.remote-ip=209.85.128.69
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 55C5C606A320
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 19:23:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 55C5C606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--dmnk.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=i+LcyMT2
Received: by mail-wm1-f69.google.com with SMTP id 5b1f17b1804b1-4ba078f26f4so268005e9.2
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 11:23:34 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1795116213; x=1795721013; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:mime-version:date:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=fV5gMniU7c3uA6sIEL3QHarW5z+qAZvra4n6XWyUVDk=;
        b=i+LcyMT2q+JiLPLTXbOPkl+SId+Ek1C1OeHE4JncKEYcNkpwREFmFECpg0+4G3VdUp
         uwOH5gg6Bn0yUvFjuXcRRzW9ZBM7JoiBcMvD5Fpy4Bgny0dMaMle+JBdlw4QkQnn1bZW
         mNrrDI1vMfUXTRDXrUEBA6fr9AnLfnU/CvC5pT9bu5XH8W4bL9OuhVUtNnIP4g1N9xfI
         G+CcTFQGL751MHl44f61siaxKgsXI3GY1tR1yKswsqYYquStPElWGVM3uoTH53vByz/g
         XMPUwe8NDaGRIbks6dKNmyr3HdIpethEpvInm5n2v86xO91BLthAonksGwdGwpD2D3L8
         9nqg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795116213; x=1795721013;
        h=content-type:cc:to:from:subject:message-id:mime-version:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=fV5gMniU7c3uA6sIEL3QHarW5z+qAZvra4n6XWyUVDk=;
        b=EGV5LOYyQ/GpFHVd5z9AkOBBsjI4ruZNykRSb/hYLTbkPMizX17MvG19OTWwNx8g5z
         RM+pc4vNRGscOylOr1Eq07JM8HZk24HhmYdwiZ8Iz7EAG0R7hBMBn3RRXNVsCA5FfYbO
         OzlZpkOCdjtQcvqS2+0kOydoy7TxzrVuQkiFuyZkTe9SA6IYWktGCvB8sE9dJbSJ6AWn
         WmNDLvf7O0chZE7Cq0NAdjPFnubZxkzmMgbNvhN+70mDx+qYYqEkpSpp4xuhXUvVmLeF
         d3+5uI14Ax8IsuWoECIPQ0P3+U26JaW9O0EchYqBUh55Hbh3OWqTCsKjAP4rqoKZnNHg
         n/Fg==
X-Forwarded-Encrypted: i=1; AL+hErFhUtumpUwT32GAijVOPQZ3r4o6sHAGbal0qI4v44nAe/v50anMlnE+KKLjGkPOFWe+0m9Ea/zlwIE=@vger.kernel.org
X-Gm-Message-State: APuU4Z9Mx+fhnswEZqcfGyQek3EW5PTwaly2mqu7XeTsHrJ16N2WgIVl
	TN1SCCnc66mgW2Jhqj9K3qfdCzQDmmd5EJdzEfg/DG8DeMLSEHtKKnCqoxRowekd5BN6mQ5fUA=
	=
X-Received: from wmrn31.prod.google.com ([2002:a05:600c:501f:b0:4bb:5e65:fabc])
 (user=dmnk job=prod-delivery.src-stubby-dispatcher) by 2002:a05:600c:1d8c:b0:4bb:5345:606b
 with SMTP id 5b1f17b1804b1-4bb8882358dmr11642755e9.31.1795116212707; Thu, 19
 Nov 2026 11:23:32 -0800 (PST)
Date: Thu, 19 Nov 2026 20:23:31 +0100
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
X-Mailer: git-send-email 2.56.1.809.ga0b61035b5-goog
Message-ID: <20261119192331.2695154-1-dmnk@google.com>
Subject: [PATCH] nfsd: enforce export checks in nfsd4_restorefh() and nfs4_check_file()
From: Dominik Maier <dmnk@google.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
	Tom Talpey <tom@talpey.com>, linux-nfs@vger.kernel.org, dmnk+artist@google.com, 
	Dominik Maier <dmnk@google.com>
Content-Type: text/plain; charset="UTF-8"

When an NFSv4 compound saves a filehandle from a UID-squashed export
(all_squash or root_squash), switches current_fh to an unsquashed export
via PUTFH, and then restores the saved filehandle via RESTOREFH,
nfsd4_restorefh() duplicates save_fh back into current_fh without
recomputing the worker thread's subjective credentials via
nfsd_setuser().

In addition, when nfs4_check_file() finds a cached nfsd_file on a
stateid, it calls nfsd_permission() directly instead of running
fh_verify() for fhp (unlike the uncached nfsd_file_acquire() path).
Because PUTFH and SAVEFH defer security-flavor checks via
OP_HANDLES_WRONGSEC, both post-RESTOREFH operations and cross-export
COPY/CLONE operations (via nfsd4_verify_copy()) can skip nfsd_setuser(),
check_xprtsec_policy(), check_security_flavor(), and originating-port
checks on the cached-file fast path. While nfsd4_restorefh() has omitted
credential restoration since early NFSv4 compound support,
nfs4_check_file() and commit b7342204253a ("NFSD check stateids against
copy stateids") expanded cached-stateid checks that bypass fh_verify().

Call nfsd_setuser() when restoring save_fh in nfsd4_restorefh()
(preserving deferred OP_IS_PUTFH_LIKE WRONGSEC handling) and call
fh_verify() on the cached-file branch in nfs4_check_file() to match the
uncached branch.

This issue was discovered by an AI-assisted code review tool (ARTIST)
and validated in QEMU against an unmodified v7.4-rc3 kernel without
kernel modifications or error injection. A standalone reproducer is
available on request. The fix was build-tested with KCFLAGS=-Werror and
checked with checkpatch.pl --strict.

Fixes: b7342204253a ("NFSD check stateids against copy stateids")
Cc: stable@vger.kernel.org
Signed-off-by: Dominik Maier <dmnk@google.com>
---
 fs/nfsd/nfs4proc.c  | 9 +++++++++
 fs/nfsd/nfs4state.c | 4 +---
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 3a82af3..1e7abe5 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -49,6 +49,7 @@
 #include "xdr4.h"
 #include "nfs4ctl.h"
 #include "vfs.h"
+#include "auth.h"
 #include "current_stateid.h"
 #include "netns.h"
 #include "acl.h"
@@ -847,9 +848,17 @@ static __be32
 nfsd4_restorefh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		union nfsd4_op_u *u)
 {
+	int err;
+
 	if (!cstate->save_fh.fh_dentry)
 		return nfserr_restorefh;
 
+	if (cstate->save_fh.fh_export) {
+		err = nfsd_setuser(&rqstp->rq_cred, cstate->save_fh.fh_export);
+		if (err)
+			return nfserrno(err);
+	}
+
 	fh_dup2(&cstate->current_fh, &cstate->save_fh);
 	if (HAS_CSTATE_FLAG(cstate, SAVED_STATE_ID_FLAG)) {
 		memcpy(&cstate->current_stateid, &cstate->save_stateid, sizeof(stateid_t));
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 567a856..8e5c3ca 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -8434,9 +8434,7 @@ nfs4_check_file(struct svc_rqst *rqstp, struct svc_fh *fhp, struct nfs4_stid *s,
 
 	nf = nfs4_find_file(s, flags);
 	if (nf) {
-		status = nfsd_permission(&rqstp->rq_cred,
-					 fhp->fh_export, fhp->fh_dentry,
-				acc | NFSD_MAY_OWNER_OVERRIDE);
+		status = fh_verify(rqstp, fhp, 0, acc | NFSD_MAY_OWNER_OVERRIDE);
 		if (status) {
 			nfsd_file_put(nf);
 			goto out;
-- 
2.56.1.750.gf70dc682cf-goog
