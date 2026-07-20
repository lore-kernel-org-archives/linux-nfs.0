Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 48AF2429CCA
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 14:14:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784556886; cv=none; b=F7fPWx4bHCXsiPZCIE1WyBNsyCuVOGhI+M0umxdvM6g3l2QFBEq9UOzvzFzHcXareMSJk89IHuHe/LN7LkbhUmnejqjXSkIuUVUrp/jH+EZRIOi4Zp2+elHbxtQcP2D2M5rwZfIFdiddFRDmGBDcoXqfq4E3JHr8uTJdOtD2f9E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784556886; c=relaxed/simple;
	bh=00AqXzYmzJwQdaMMFy09CoP+/hwZ1d+GqM8KbEOl0j4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=GS4b1yu6tY1wMFRMchYGgbJWYT9HFBQ6R4IhsrYdZbg/Tre4Y3/VAQHUDDeLtPrqZiWAIf7ETeRNSTYTenI1QUsSEMZ7Ev13CVOVcP90dO+dG48mTUnPPMtxXjyD1wZLti4J6Qi6g/1E4nsFpM5mtEmQwG9NcqvfcvmuLrWw7ww=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=n7xlJolq; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="n7xlJolq"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A8D3A1F000E9;
	Mon, 20 Jul 2026 14:14:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784556885;
	bh=bRpMRpqpGR54qmeFRctcDHMrh7v7oYapJKCOQVdaIMU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=n7xlJolqvT2dFnUEb43uStiArsV3tRJyu9FyW5k/orzodP7cMc34/4tLeAWVwRirw
	 8BmuUJMbsmeRix6Uaui6lGTo32G4lnx6xtOrEFFyPRDzD1uAVfLGtVUEzESqYl+OYv
	 SoAvzazlssBDuEV5E1trjYe4CjA7rb61nA0pIernGLLFXmADmwhzmyPSZxZ/3zQ4zo
	 y7/6fim0HMAPqpzc4BtYJgic5c7ajNnBFbM/GA/EEK/U+YReDgZLuBDAHGtA2Vs2IH
	 pWMQ2cYmwpqGOr4ymixGsp4RyWZ3QLGbGBUunE2FVczRK5s9B39Y4gM2tyvlZ362lI
	 a1pNvC7/5aNGw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/3] lockd: Switch linux/nfs.h to linux/nfs_fh.h
Date: Mon, 20 Jul 2026 10:14:41 -0400
Message-ID: <20260720141442.783935-3-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260720141442.783935-1-cel@kernel.org>
References: <20260720141442.783935-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

lockd references "struct nfs_fh" but none of the other definitions
in linux/nfs.h. That header also pulls in cred.h, several sunrpc
headers, and uapi/linux/nfs.h, none of which lockd needs. A new
linux/nfs_fh.h provides "struct nfs_fh" and its helpers without the
rest of that surface.

Switch lockd's xdr.h to linux/nfs_fh.h, and drop the now-redundant
linux/nfs.h includes from svc.c and trace.h.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/lockd/svc.c   | 1 -
 fs/lockd/trace.h | 1 -
 fs/lockd/xdr.h   | 2 +-
 3 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index ee90e743064a..f0e1a58c9106 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -36,7 +36,6 @@
 #include <net/ip.h>
 #include <net/addrconf.h>
 #include <net/ipv6.h>
-#include <linux/nfs.h>
 
 #include "lockd.h"
 #include "netns.h"
diff --git a/fs/lockd/trace.h b/fs/lockd/trace.h
index a11d04e8c835..1f79955ea0f5 100644
--- a/fs/lockd/trace.h
+++ b/fs/lockd/trace.h
@@ -7,7 +7,6 @@
 
 #include <linux/tracepoint.h>
 #include <linux/crc32.h>
-#include <linux/nfs.h>
 
 #include "lockd.h"
 
diff --git a/fs/lockd/xdr.h b/fs/lockd/xdr.h
index a1126cca98c6..56b9796aa39d 100644
--- a/fs/lockd/xdr.h
+++ b/fs/lockd/xdr.h
@@ -10,7 +10,7 @@
 
 #include <linux/fs.h>
 #include <linux/filelock.h>
-#include <linux/nfs.h>
+#include <linux/nfs_fh.h>
 #include <linux/sunrpc/xdr.h>
 
 #define SM_MAXSTRLEN		1024
-- 
2.54.0

