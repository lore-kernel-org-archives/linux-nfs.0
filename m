Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 850D840B397
	for <linux-nfs@vger.kernel.org>; Mon, 27 Jul 2026 13:04:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785157454; cv=none; b=cVORTtwZpvvWVlo4CAw9gWY7rWsO7fBK8vgZx+pyN9FOmoinjN9ukA2CfNtBLSQorRxqh08fhUjKP8eff6kxFC/Jb1tGKLC5TYP5k5AI7gxnOBUQHQBoWp2lrq6j9mf5duMJ2itpy5wXkORAplH8+Nk9u1xlcPD9Jrdsf115SAg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785157454; c=relaxed/simple;
	bh=0OMXLGr75rV2gj/2dQ5U5tVfpzd/Xd/cL9L0F7eOkO8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=XCIDXMNamws5vZOAFujr8gG8Kppwf7GS9Bttd8lqSpwyGitsnCZDzeqKrN1nPJo0VyWWfGlchCCbdj4NIpmkZ9K6LXxwkdaOap2591qTHM5XoLrjheCQdqdns5Vc1A7buuQJmdGeryHCO1oaBBigMaWUW5uILoK55A+qpY1yX5g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LW2CJj7z; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LW2CJj7z"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9E9271F00A3E;
	Mon, 27 Jul 2026 13:04:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785157453;
	bh=GxB5w0WEG/CalsLk7Dd6qPYCUrbXo7h9U4mjrd7c+tQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=LW2CJj7z8ioY0vG2AtsSQmQ2r7x7kRKHyswNbfp9woEUahRVczT427NflvxcZa9EC
	 Q/bXU+SJGLt7I+hXffk8+qJairx1wmoIIziaCCgPpeIQYSXJC1JKN1Z1B/RU2WqeK6
	 WuABSG6KRnZ7hZTBMeAOoSkXUvmkeUn8mauV1IkQB+r3N0NFF+TOtxDBerQaOXOAtU
	 Jh+XxKw+DieCvd4deaTbA51jH0y+35fjmytbDuwxWeYKbArO6aRqbvyjmp3L6wITPY
	 X9uGotNI37pJiYmXkFLxxy2yugM+mL9/KnPfFK7/KLQdFGXuaqUe9kl3U/dZSqH5su
	 EvmpFV4YRNVcg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/3] NFSD: Move the RPC program definition for LOCALIO
Date: Mon, 27 Jul 2026 09:04:08 -0400
Message-ID: <20260727130410.14887-2-cel@kernel.org>
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

Clean up: The definitions for the LOCALIO program are not needed by
most files that include linux/nfs.h. Following the convention used
by most other in-kernel RPC program implementations, relocate the
LOCALIO program definitions to a localio-specific header.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/nfs.h        | 7 -------
 include/linux/nfslocalio.h | 8 ++++++++
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/linux/nfs.h b/include/linux/nfs.h
index 0e2b210c103b..8c2818db43c5 100644
--- a/include/linux/nfs.h
+++ b/include/linux/nfs.h
@@ -15,11 +15,4 @@
 
 #include <uapi/linux/nfs.h>
 
-/* The LOCALIO program is entirely private to Linux and is
- * NOT part of the uapi.
- */
-#define NFS_LOCALIO_PROGRAM		400122
-#define LOCALIOPROC_NULL		0
-#define LOCALIOPROC_UUID_IS_LOCAL	1
-
 #endif /* _LINUX_NFS_H */
diff --git a/include/linux/nfslocalio.h b/include/linux/nfslocalio.h
index 3d91043254e6..d2b39e6e6c6a 100644
--- a/include/linux/nfslocalio.h
+++ b/include/linux/nfslocalio.h
@@ -16,6 +16,14 @@
 #include <linux/nfs.h>
 #include <net/net_namespace.h>
 
+/*
+ * The LOCALIO program is entirely private to Linux and is NOT part of
+ * the uapi.
+ */
+#define NFS_LOCALIO_PROGRAM		400122
+#define LOCALIOPROC_NULL		0
+#define LOCALIOPROC_UUID_IS_LOCAL	1
+
 struct nfs_client;
 struct nfs_file_localio;
 
-- 
2.54.0

