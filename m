Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3A0E44756B1
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 14:00:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787061640; cv=none; b=qFidyeVZvLeeZwH4a0UOp3HYGxlo/ipVPg/t9tRRFuDb2y/pte7V+5zDvnUXLhoQjWFRO7+peSv6odDPDtWNv6k5WvLDbdZDEY9VSM9Powk1F1bGXAcRHut7GLTKkdurCSdvuOApmrn9ZUvDsEK2S4rUDsUJb9rAm58yWoVPgTg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787061640; c=relaxed/simple;
	bh=km1/OIW3iQCKSJQJrnUC4IV8gdH7oJfAy+PFB/hKOZI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=iZ5tCWWgLu7kXRq7QqjHMKzV4KisUYBmxEooGu2W8fgoC5WR6Ka4ZtJLpiXze38WtUko/gW1JkjVMpVZZWyOrfls2of1nVFlvds9Tm1+Vzwqe4pz8JIrg77LpV+pp+jfFGWoYsvs7xWLV2ORYIMltnjPjVBCeWnf6b+bctSUK0k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jPRXMfQM; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jPRXMfQM"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5A6F31F00A3A;
	Tue, 18 Aug 2026 14:00:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787061638;
	bh=7myn3eLfJfXmvBkQszx6i3XIi8mhXlToVtOIcj72YLE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=jPRXMfQM3hDOwj0bqYWSFXpwHmbfcfbC5Jasvvc8mUz7/VlgiLOw8XnUjexsAZiQr
	 GLt+fsbtmuzfTJDdJ/2VDERXluYbVbObwoMmJ7kwCj5MFh34Y2nbfD7/8mSu1Ml5xA
	 oeGe/OjMv2TdyRhekV2x/UErziBicnSQScE456F/Umrpt789NscVkZfQkzJ0rOc3fL
	 7Fc3s+pSKAaM8Z7aBI+wJ/AwOqYEoviiMTWoONY08wydcaGu3eLpb2B0SZGmJ/cGfe
	 zcdQKumerjKm3ZTeeqdlXOb+fdjnhDm08sfBItDQt0IFZuEiyhL+WaVXlbRcosUeSW
	 3lObj7oIzHc4g==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/3] NFSD: Clean up header guards in fs/nfsd/xdr.h
Date: Tue, 18 Aug 2026 10:00:35 -0400
Message-ID: <20260818140035.12740-3-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260818140035.12740-1-cel@kernel.org>
References: <20260818140035.12740-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Make the header guards less ambiguous about their provenance.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/xdr.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
index df540c940cef..52660b9f8dde 100644
--- a/fs/nfsd/xdr.h
+++ b/fs/nfsd/xdr.h
@@ -1,8 +1,8 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* XDR types for nfsd. This is mainly a typing exercise. */
 
-#ifndef LINUX_NFSD_H
-#define LINUX_NFSD_H
+#ifndef _LINUX_NFSD_XDR_H
+#define _LINUX_NFSD_XDR_H
 
 #include <linux/vfs.h>
 #include "nfsd.h"
@@ -175,4 +175,4 @@ bool svcxdr_encode_stat(struct xdr_stream *xdr, __be32 status);
 bool svcxdr_encode_fattr(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 			 const struct svc_fh *fhp, const struct kstat *stat);
 
-#endif /* LINUX_NFSD_H */
+#endif /* _LINUX_NFSD_XDR_H */
-- 
2.54.0

