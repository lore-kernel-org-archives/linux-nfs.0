Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EED0C337688
	for <linux-nfs@vger.kernel.org>; Tue, 28 Jul 2026 16:59:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785257957; cv=none; b=FZ3Z64sEQTV1Ml+8tU5nCLQ/LW5Uud2174BxI0xCHXtD8kMMfrJSoBVCTASfTUFifssySPKsMAo9lly+lgygvBT0LepAy7FuNMTz8t4d5XCrVEzdFxRyM7hrBMbuUuHa0tfYpuxbkfx3xCvmO8nMTdHdG4C/idiN24EDalKoxAQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785257957; c=relaxed/simple;
	bh=btf5/jyp1ea5UmbSS/9VqqxRx0CZ05PW8+eS3ow5DOM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=DkyDpKkDjv1yNoxpcVblX6Uos4hJTuMUNgre2yCjC3nxejTt3Jw6q0O1/DWA3ZRuBQ/GM0U5h1jVAZGLp4xzh5d2lN2QFb8jTyIruse+o4gW9jPWSImrlOwL1M8HvLo2tZ3ZeZuJgtq2a4amBFeSGyDOKrvtI3/m22aInZducCA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=PzCv56X/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="PzCv56X/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6F8C51F00A3D;
	Tue, 28 Jul 2026 16:59:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785257955;
	bh=+q0hcPGaoQHtZ/qb+abFqypwRoKLjoranxuRlqLWt2E=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=PzCv56X/zEEFfRwQcPARmQ8eKXnBcIpxWCK77RkWRrAt46rrwAI07LYdadSlX56lb
	 lo5pPn38fsEIYsEVa+aysK6PnsvlSMJLRWa+i1OjGoVzQ+monZ+jlBvOZAXWCuqoAt
	 xRnrC29Bv1VrayhgX1jCBSvhChm/pFTqM/ssPX0PXkPHg+j1WMhyzcCfV3r2KyBFoQ
	 x8x9snKibj5l9adxQ/4gtILpKgwsVqFOVkcGqxAcLcmQ5g0vv59OlDacPJ+YvLmyiP
	 XTHjW83VoKOKYNChwZ1C9/Pr3Ev3Q/KJ4Mrby+/IH0GEofdGkABQee0Ws3zsnRRt2H
	 hkfihHr2KGYeg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 2/5] nfs_common: Remove "#include <linux/nfs.h>" from linux/nfslocalio.h
Date: Tue, 28 Jul 2026 12:59:08 -0400
Message-ID: <20260728165911.462534-3-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260728165911.462534-1-cel@kernel.org>
References: <20260728165911.462534-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Clean up: linux/nfslocalio.h pulls in linux/nfs.h only for the
definition of struct nfs_fh, which now lives in linux/nfs_fh.h.

Replace linux/nfs.h with linux/nfs_fh.h so that nfslocalio.h no longer
carries uapi/linux/nfs.h into its consumers.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/nfslocalio.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/nfslocalio.h b/include/linux/nfslocalio.h
index d2b39e6e6c6a..8ce4d978a636 100644
--- a/include/linux/nfslocalio.h
+++ b/include/linux/nfslocalio.h
@@ -13,7 +13,8 @@
 #include <linux/uuid.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svcauth.h>
-#include <linux/nfs.h>
+#include <linux/nfs_fh.h>
+
 #include <net/net_namespace.h>
 
 /*
-- 
2.54.0

