Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793651916;
	b=vxmG0B15rny67IUYHz/rMeQaIYPJeSOyfRKoonqEoo2OXFDD2wN3QY0SSQyBrmqbnV7b
	 4hEpgj5SP0+wumh6jZHfc3g48sdkF8q1u20QUxOfcyWIZkuBUkRAnzqpxsapqT/0U00GI
	 X1mXqXPffAUjD6yi1XBP+ZBndcvpGxIJLuAUHvB0Ya1s5NM6FWjgvr4LWiqgwdludYhkU
	 m/H81/Mn8nx2F4AXNgkuZ6xuxKoVasXIUEaXKyalWTBY+1xpQAnSaq0dWjsIrHXG7XhI8
	 oJF6Jkd5IaqHIQeD1PmDhHtipCTEkgXNSYjl5zLgH4+ubcZOkeX0VWQgOWXEx4Q2w5w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793651916;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=kew4vr9D/lX65hyEZonw0fC/8LUorIYJxt0gwq9n5sA=;
	b=apNu6+dz/Fwm5RtNowrKlIUqb1SmOxJyuiwv1X9KzMtTAUrxzWLDkkuyUmZlCCgqTqQZ
	 m5sT/apXznnc/nXfH+Igw8BxIG/UAWH6/QMpOAMkhZxzEOUcaeFix3+7FryGgxOHtXwZG
	 ++zkmylyjupmJPkH2+Zkv5fVbb6qLRJys2R1W4QTL9bqPM3u0FEe+wRjECJZpYTCQoTte
	 IuZqhBmBgvs7wqcErgS3dMww4cCglvDLjxvi4heUy2TiQ8PvoPhJKlpke4qTvmDomDrAh
	 KWSPi8njmTl75dWkMT706TejYOoWma1DJNbnuNnOkWq/jD0c+Dnu8/+l5ImAm4J6p/A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PNjcQpXo;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ADE1B606A32F;
	Mon,  2 Nov 2026 20:38:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PNjcQpXo
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C000D1F00A23;
	Mon,  2 Nov 2026 20:38:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793651915;
	bh=kew4vr9D/lX65hyEZonw0fC/8LUorIYJxt0gwq9n5sA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=PNjcQpXo4zGa6xw4YW89dxi/9i8qq/lUFN2rkb2+oNb0lZ5r4gROeOvxhpfTXXDIi
	 X+u5QEfjeBxybClG9H+CSRy1GmYY2OPn/96Nk3OCZ7BwB4Rs3buw7GNEqaOuT8Vj2C
	 nuIXGHkHg6KyntbyJZpEUI7r8YNDDPu3AVyaoBETtckA0BfpnvPYwubrWbxRlFK0m6
	 rt+DBmiNIX8k6EWzK8Qfh9uVE/nC+nMtGHQCxdo4A5slwOMF0vWFwftXoAnGXQJIKa
	 6U8hiCzOUx0uGKiZ02my588/OUMLGko2He3R5qTT3qpO3zo1xRpkXKF+jK00CCFv/v
	 IGE6COx3ucL/g==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 02 Nov 2026 15:38:09 -0500
Subject: [PATCH 1/2] nfsd: Report vetted delegated timestamps in GETATTR
 replies
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
Message-Id: <20261102-deleg-cb-getattr-times-v1-1-ca0326d88623@kernel.org>
References: <20261102-deleg-cb-getattr-times-v1-0-ca0326d88623@kernel.org>
In-Reply-To: <20261102-deleg-cb-getattr-times-v1-0-ca0326d88623@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1486; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=63CvdnJ3D30Wf4u4qYlU9zOOUTNaBtg7jPVJhlMIX/w=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq6PTJInT/j9YFcdhkwdvoNvc68oFFR0c6iLctA
 OmKTkuw0kmJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCauj0yQAKCRAADmhBGVaC
 FVODEADORVYgbMP583uAHhqM/u5JZE/BlCk8KpDEoOEZck7fzsHJEMDxKD1IRX2misAKiKb+1Ge
 OEic3UHgxS07TrileSMqdS1wXXyifnZIP/SBwo3slxo7sH2nXAC0DVlyVt2s6low3znjKjdSd9u
 +b77unCDjVc+cLSFMTTmh7uQGZ/Hyk0LXMEcLe34fi0dyVdd699JF0JYXL02o4T5I8Q+HwRCjWd
 FXzYi8FKFPHI31L4qx0RA8ploDvjIsWMA74axjTkSeZOhtkWaY22BDyeS1bnmx+7I1xbUqkcbUL
 qcFmTnxPLemf0+PuddwNjWKiSC0fIBrl0j+sw7MQOFLFarZzB6x7P6aHXBxrYqajhsPKO8pRxMj
 OrUt6kRYaAdJdSuKK5NuSxctCP9MTRTHu6UFexFlT/znFVfi2xS9FtOYnKTz2AJZ3ulujgw/FYp
 Ge656fVhNeQhQxSY2bAGY0Kv5mZBiKzBnVYnDkk2CN+O1RhVzjt/1kV7jidfk+WA2f9cq88+PaC
 vDnXHCWLgaYY4e+dXsdCO2/OUOO/YwnVrdmgW/8bsdxBcogYiDJf1gBhQlzeAyW5aNl45p+4Wwc
 V1FgakL+uGAc+yA7I44tTxV5s4PFHRf1ZzsrW3sgl1rsda44/Q00zhQLorOKPasJ3StBdGM1oGH
 oy+V97Ldoo+QDPA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

When a CB_GETATTR reply shows the file modified, nfsd4_encode_fattr4()
overrides atime and mtime with the raw time_deleg_access and
time_deleg_modify values from the reply. cb_getattr_update_times() has
already vetted those values per RFC 9754 section 5 and written the
result to the inode, so the override undoes that vetting:

- a time older than at delegation grant, which the server ignores, is
  still reported to the querying client
- a time in the future is reported unclamped

vfs_getattr() runs after the update and already returns the vetted
times. Drop the override.

Fixes: 6ae30d6eb26b ("nfsd: add support for delegated timestamps")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4xdr.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 90b44163f886..434b6cfc5741 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4098,14 +4098,8 @@ nfsd4_encode_fattr4(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 		if (ncf->ncf_file_modified) {
 			++ncf->ncf_initial_cinfo;
 			args.stat.size = ncf->ncf_cur_fsize;
-			if (!timespec64_is_epoch(&ncf->ncf_cb_mtime))
-				args.stat.mtime = ncf->ncf_cb_mtime;
 		}
 		args.change_attr = ncf->ncf_initial_cinfo;
-
-		if (!timespec64_is_epoch(&ncf->ncf_cb_atime))
-			args.stat.atime = ncf->ncf_cb_atime;
-
 		nfs4_put_stid(&dp->dl_stid);
 	} else {
 		args.change_attr = nfsd4_change_attribute(&args.stat);

-- 
2.56.0

