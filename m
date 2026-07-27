Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 32CB140BCB7
	for <linux-nfs@vger.kernel.org>; Mon, 27 Jul 2026 13:04:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785157455; cv=none; b=fDPPPG78FZttQCMysOAysAlIWTcGriGKcBadlwXqsujIaOnNpyNMkhVO3sE5gItY4esleOugjScP4gQx2+/4xj6PbiBwgJeHh5uSc8/QhNBHrqnqL7js9g99zUcjM/d8BySjLtxlTcGF4FJgrzBrmOhkEB9PkpzeT5/Y213724Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785157455; c=relaxed/simple;
	bh=btf5/jyp1ea5UmbSS/9VqqxRx0CZ05PW8+eS3ow5DOM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=YLHCgIy2M6K3Ph82nLgwbIE8whFHFAQzLlXm7DiWyNI0kfj+c0xeOv5in+wnK82oREEBUzRstEBGLmh2RNnNTUmNYMdBMgt5TpSrjMoAZLJZqORmMzQf17a5GD+DVWLz/6v00Y6nqxgNlKcEYGDwAM28A7YIyjkWrxwqO3L8P2k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=d2U8bv8F; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="d2U8bv8F"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5F3B61F00A3D;
	Mon, 27 Jul 2026 13:04:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785157453;
	bh=+q0hcPGaoQHtZ/qb+abFqypwRoKLjoranxuRlqLWt2E=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=d2U8bv8F3ea7i69er46hl9EYA0qiO7rgUNPVQLNgMMJKoHBz/89upFwmt2vyhBbGb
	 tvK1hO0zZ1Mf278erfPZyGphbuVU5Ii2zvMgI47pEzTPG27cZZ+jjXPJiV8ImlsZZO
	 +rS3nfxZ9H+/FTyhKKRf3V3WpDQvCod3JVU3VM6eYMtPGstgXZDdeoxOLqpBBQJYGv
	 IJEtek8FkL+Wv4mue/9wIFEZeKFdNgJXHoeAtws9GfwR6dADC9BSC5O6gtZQnWyZzJ
	 zS6Dhy0QRGynAqM1HL+SfYO8MEu9RXd9FaQqicnFfnAMM4I9XfVMKeiBWHk2fBvxcK
	 mBEvR/LQdXD0Q==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/3] nfs_common: Remove "#include <linux/nfs.h>" from linux/nfslocalio.h
Date: Mon, 27 Jul 2026 09:04:09 -0400
Message-ID: <20260727130410.14887-3-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260727130410.14887-1-cel@kernel.org>
References: <20260727130410.14887-1-cel@kernel.org>
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

