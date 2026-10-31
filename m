Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=51.159.188.251
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793466821;
	b=3zbw6UdZa4FgB3Qy3DsufmqULx4iMJf9BG7zVAhqYsVdL1zQ+WEJORHr3nuqLOOkAJkN
	 UPlrtRUXDFKgEy6/7ZVgQAf9NrLEMtViPZG0VpSwVBrqsVd4V1Es9Vb+6hFOIbF8VgEpp
	 JMt+BGZKaiRAd3W2TJSNuYeBuL/ztyI78ww50caGNqASb6PCN6YudA6ecpQktyPmOjO35
	 2bkmdqwMpUzZlP6YI7o0zRstaTDFZL93u0n3LsWRrGrDLZsJk3d+UcK8ZTy6ifIzwrM76
	 iSXSzEyPwpz/nCI3mvUDLGuaXEP2XusxPqVvUVAD0NyW9EVZTDEOSaTHg6qgnhWl5tw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793466821;
	h=DMARC-Filter:DKIM-Signature:Received:From:To:Cc:Subject:Date:
	 Message-ID:X-Mailer:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:X-AntiAbuse:X-AntiAbuse:X-AntiAbuse:
	 X-AntiAbuse:X-AntiAbuse:X-Get-Message-Sender-Via:
	 X-Authenticated-Sender:X-Source:X-Source-Args:X-Source-Dir;
	bh=39qI15/gvYYxuDuo0yqQ2O0uqVDWTO8RyTVe8eRnfmQ=;
	b=BT/obBtvkHDbG+P4QcxKzlYyRjhQJU/ztkxZSRPVI9lDY5OmRaiFJHxo9liSwkmFWjxl
	 SaSOjT+2jOj9R3Tv8a+3gMaqMsEcxjHiYYKESJwGjeI/ZGIHgjs64A5E8aNM/EEEPX/f2
	 wbeCGVVgLHXPVEIIEzyxNWjbSnPdVKzYGtIjpw/3FU4leY8G3xEX4QIPsC28PzTjfpJju
	 64QlSDy6vAvs+z9kX7q08YCw2JSIecY8YhB74lGm7MSZhOB1/RURUj8tSvPci3FqGDUsE
	 DnbTbQ4lLlUi5kFGyAaBg+QlTjdIkQGzSWtjakD80eLjNaZGDYRipuJaZZKgzl2E9Tw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=oss.cyber.gouv.fr;
	spf=pass smtp.mailfrom=oss.cyber.gouv.fr;
	dkim=pass header.d=oss.cyber.gouv.fr header.i=@oss.cyber.gouv.fr header.a=rsa-sha256 header.s=default header.b=X2F7T9wx;
	arc=none smtp.remote-ip=51.159.188.251
Received: from oss.cyber.gouv.fr (oss.cyber.gouv.fr [51.159.188.251])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0DFBA606A31C;
	Sat, 31 Oct 2026 17:13:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0DFBA606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=oss.cyber.gouv.fr
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=oss.cyber.gouv.fr
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=oss.cyber.gouv.fr header.i=@oss.cyber.gouv.fr header.a=rsa-sha256 header.s=default header.b=X2F7T9wx
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=oss.cyber.gouv.fr; s=default; h=Content-Transfer-Encoding:Content-Type:
	MIME-Version:Message-ID:Date:Subject:Cc:To:From:Reply-To:Sender:Content-ID:
	Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
	:Resent-Message-ID:In-Reply-To:References;
	bh=39qI15/gvYYxuDuo0yqQ2O0uqVDWTO8RyTVe8eRnfmQ=; b=X2F7T9wxYNuG3UUoSCVrEU2qv8
	Io1MDWNWnSPnbJ8lxNGxg/7GBrMlBcKyZVnQ8snAmbmeFjuAgWoRv6XtpS723QEWQhCs7KzWIaYqZ
	6oriPhlP8saOJjXEp5U/o5TfY0k1/sPMICrWLh/ZevQi+ZVPnSV4eHduXXPqmwuvPzCBpvJR2ee6d
	AFcozUsBDSvwnGYRYOATOJ3WuxctkZ5OthT1mjlCatSuZm9kKRFMr3TDiz0P7iy26Dw/1HdhAHeCg
	n2XP47P/3Qf2meGP8Dm0cLPbCMX+sKKWcrmraQWRS2Z6n7lXQovf+vWmuv8qf88I+djxmZUkezjDu
	5v11g+PQ==;
Received: from [151.115.150.205] (port=37456 helo=gepetto..)
	by pf-012.whm.fr-par.scw.cloud with esmtpsa  (TLS1.3) tls TLS_AES_256_GCM_SHA384
	(Exim 4.100.1)
	(envelope-from <Jeremy.Jean@oss.cyber.gouv.fr>)
	id 1xNCe7-00000006Wj6-2Jt4;
	Sat, 31 Oct 2026 18:13:31 +0100
From: =?UTF-8?q?J=C3=A9r=C3=A9my=20Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=A9my=20Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>,
	stable@vger.kernel.org
Subject: [PATCH] nfsd: fix XDR tail bounds after spliced READ
Date: Sat, 31 Oct 2026 17:10:59 +0000
Message-ID: <20261031171057.1562342-3-Jeremy.Jean@oss.cyber.gouv.fr>
X-Mailer: git-send-email 2.47.3
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-AntiAbuse: This header was added to track abuse, please include it with any abuse report
X-AntiAbuse: Primary Hostname - pf-012.whm.fr-par.scw.cloud
X-AntiAbuse: Original Domain - vger.kernel.org
X-AntiAbuse: Originator/Caller UID/GID - [47 12] / [47 12]
X-AntiAbuse: Sender Address Domain - oss.cyber.gouv.fr
X-Get-Message-Sender-Via: pf-012.whm.fr-par.scw.cloud: authenticated_id: jeremy.jean@oss.cyber.gouv.fr
X-Authenticated-Sender: pf-012.whm.fr-par.scw.cloud: jeremy.jean@oss.cyber.gouv.fr
X-Source: 
X-Source-Args: 
X-Source-Dir: 

After a successful spliced READ, nfsd points the XDR tail at the
unused bytes remaining in the first response page, so that later
operation results are written into that space.
nfsd4_encode_splice_read() correctly computes how much space is left
there, but then moves xdr->end from its old value instead of using
xdr->p. This gives the tail an incorrect size limit, which can cause
an OOB write past the end of the page.

Keep the tail end at the current pointer plus the bounded remaining
space.

Fixes: 30596768b310 ("nfsd4: fix buflen calculation after read encoding")
Cc: stable@vger.kernel.org
Signed-off-by: Jérémy Jean <Jeremy.Jean@oss.cyber.gouv.fr>
---
 fs/nfsd/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 606ddcb085c0..2f92b6dfd92c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -5200,7 +5200,7 @@ static __be32 nfsd4_encode_splice_read(
 	space_left = min_t(int, (void *)xdr->end - (void *)xdr->p,
 				buf->buflen - buf->len);
 	buf->buflen = buf->len + space_left;
-	xdr->end = (__be32 *)((void *)xdr->end + space_left);
+	xdr->end = (__be32 *)((void *)xdr->p + space_left);
 
 	return nfs_ok;
 
-- 
2.47.3

