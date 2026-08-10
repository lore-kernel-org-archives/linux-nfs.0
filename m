Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DD8D93EDE60
	for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2026 14:19:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786371543; cv=none; b=HVAml+EH7z2cU4aJK1TDKUw/U6FKyYHpxAJ7DoOskVlVrpPjKJnY2OiZiSTpF4IO+xn6zK527ju8kgP/rA6auYAeHQntnDDOYoYWwnMHtQLsyRNpzKFBgEsi9LCFGN9PORaaWj4VJUHKLd9ZPucGx2at/IblXgKc2px+9gcSpPY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786371543; c=relaxed/simple;
	bh=oxpmCUrUcFYdhmTWqWznpqAtpVbPPpUZHPOMpWOwbto=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=kNEbctTjZpRtawcFBZTGnxIu1OUBvwa2zYCgDET9dH4dZ1wb5lwDw7Y+QysisulOaSnjDpYMwau2P9gSpJ58b6l84XpGWIIzDxjgaSzOsGD3q0JSWeEdPq/xYXFv1sv6LlhnhjbpRavsT+lmtSJtxBA6Dz0OFor1V7bNipBCmHM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=X+MfxEV0; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="X+MfxEV0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AD5681F000E9;
	Mon, 10 Aug 2026 14:19:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786371542;
	bh=k4i3kiHQkh2rVqaYFlK99GsHPokmdbcOEBs74Kh+ckM=;
	h=From:To:Cc:Subject:Date;
	b=X+MfxEV0xiQs78ei2VN7oaDCiOVkEr/+7GRRLzZCTVWNyzAp5wtMo3kfOb61CgUub
	 BRkGfClv7q5foXBfUFBymcT9AVUSplVLvd6Cwa1GPvzYZe9oEShfjHgMYTF6WW2H8g
	 PAmZ0hk7LBcgY7wTC4Qs9zP5yNIfNAWUeT/XJnVPf+LW4CGEVBXZnXHFjcSK0OGWcn
	 F0rRWJ5NmNGNLauaQKhIuctp1TPvrjCg9+PgdpXW7EMK9fhHqY+dpi+GwPWv11buQa
	 Od/juxe8R/DUgL4J3mZc+KPl5ljwGb2+hOXyJv7OkTRQ1pS+09C21ExdUDiw18itdL
	 MEM7HHm2vNROA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 1/2] NFSD: Replace NFS3_ACCESS_FULL in nfsd4_access()
Date: Mon, 10 Aug 2026 10:18:59 -0400
Message-ID: <20260810141900.33846-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Clean up: Remove an NFSv3 constant (NFS3_ACCESS_FULL) used inside an
NFSv4 code path.

After this patch is applied, the nfs3.h header is no longer an
implicit dependency of nfs4proc.c for this value. The definition
itself stays in nfs3.h to avoid a kernel-user space API regression.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4proc.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 03c32db618cd..a2bea8947ef5 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -842,7 +842,9 @@ nfsd4_access(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfsd4_access *access = &u->access;
 	u32 access_full;
 
-	access_full = NFS3_ACCESS_FULL;
+	access_full = NFS4_ACCESS_READ | NFS4_ACCESS_LOOKUP |
+		      NFS4_ACCESS_MODIFY | NFS4_ACCESS_EXTEND |
+		      NFS4_ACCESS_DELETE | NFS4_ACCESS_EXECUTE;
 	if (cstate->minorversion >= 2)
 		access_full |= NFS4_ACCESS_XALIST | NFS4_ACCESS_XAREAD |
 			       NFS4_ACCESS_XAWRITE;
-- 
2.54.0

