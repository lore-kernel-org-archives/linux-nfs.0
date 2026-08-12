Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 823DD4582F5
	for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2026 14:24:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786544681; cv=none; b=VEjEQduiPtctj37lUaDSoWDseArMASuvew9Q1l6dPd6+ndRgnmbgOeu99NDdlWGA1LTFTAwBK2byHfEpN7sqOLm7nVtn2pdEGPk8MinTEleJvG++8qieAJEViaK/4D3CozP5sb4eLw9iIu8nNe7BUS8GajnAUOjX0C5d5c+Y6+g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786544681; c=relaxed/simple;
	bh=pmDFNvIv79ZHAOoqvi/n3KxMp8tTsFvsYrTL05jH/T8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=uZ5nX8VdPV2L6wvbpGnOxx+QH1ZOBVL8tiUZwh7pZ1dW9Z3bDgig3tpRFOGnDJZaM+v/BxR+GiAMwVvC+lHHx3PYHRSxbijF4x4HOlfwwKRyiq4RJsxJkpcliMRgnub5izTCEXzujEW+MOG5tJNhJb5H8ApUKyb+pIkX5OF76LU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=e02LQywL; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="e02LQywL"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9E8811F000E9;
	Wed, 12 Aug 2026 14:24:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786544680;
	bh=cySeI26D1Y/fX9SUsmXebyU5nIwjBp/9r71ZKuA9SaA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=e02LQywLsRCz74lF/zCIWcFiYQYL5ii9J6GWsRoSKnjLEfumUYMzcGhyz313iT7Da
	 3fyfxi0a6VrVo8tDy1k0R5bpQMBHASnhxOWzfq+OMj7CtrYxhXMxuAOJ6WYdm8akoW
	 80rdmty97SmmwE0DxJyHunNUqpAf0pUNZJD3KAoVm2PfGFyfZOFDPsL+K7VJFUA4aJ
	 4lHd1RzZDvXPjcyB8+hcRpZxrL8ciEPjLYz/xhutQlBKDZNKT1pZiDoLoHqzczd1s1
	 Eg/cNVn/zw2cQ3Y3iqG3UBB4PLU+9oCvlf0mW5hernSpn6LbCyX+4bc5tiRwWx1yDm
	 trurmugk9V2pg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 3/3] NFSD: Remove xdr-related headers from fs/nfsd/vfs.c
Date: Wed, 12 Aug 2026 10:24:36 -0400
Message-ID: <20260812142436.35042-4-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260812142436.35042-1-cel@kernel.org>
References: <20260812142436.35042-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Clean up: Nothing in fs/nfsd/vfs.c references an NFSv3 XDR definition.
The preceding patch moved the last NFSv4 reference, a struct
nfsd4_compoundres dereference that recovered a pair of file handles for
a tracepoint, into fs/nfsd/nfs4proc.c. Remove both includes so that the
VFS layer no longer names on-the-wire types.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/vfs.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 27683f48360f..f9131827d391 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -34,12 +34,9 @@
 #include <linux/sunrpc/xdr.h>
 #include <linux/fileattr.h>
 
-#include "xdr3.h"
-
 #ifdef CONFIG_NFSD_V4
 #include "acl.h"
 #include "idmap.h"
-#include "xdr4.h"
 #endif /* CONFIG_NFSD_V4 */
 
 #include "nfsd.h"
-- 
2.54.0

