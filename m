Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 641BB57268E
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 18:22:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789064533; cv=none; b=duN6QuMnHfvc5puaCSulJCkWqrxkx3GEmnzufwdHfQTbpIDKK8f6AS0T6VTDYENIhjkPcAT6UBIvC/3pRJCnbayoSai9nBhGQFpECmTTyDRTOzVITNC4Ytj/mcSjzr4wpGu+ItWtreCeOox9/rw9Ddvk7pl4+3Hf2V4WMHt0Yhw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789064533; c=relaxed/simple;
	bh=wv2OccFFKLkXr+YGWy2rzbry5U+NwLKxDOIg6uFw+yo=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=XBCMSRVse1P60DGeaxSN5v2ffdRh+43V/woDeVHCSi9kj8vCNbyf6RSf3y8e4GnVFN2KlLpYKMv8E54cDP3c7evJGIVLLzO62gbOufAydISC/0GkIngYd3p4LucFUzFIvSjjd2r2T6cJ8IyrVzuh/hCTSWOfgMy/u/UKhnXyZd4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=A/DOHiAz; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="A/DOHiAz"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3F8E71F0089A;
	Thu, 10 Sep 2026 18:22:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789064531;
	bh=UQzN4TV7ckJxcZ7ca7fcnls/GAnQC+zrrLButiexJIo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=A/DOHiAzlJGaVkUWsAbUFRKMBb0dva8p0sac0a4b90WzkaOjXXFSp9hBpYAfk+yc2
	 9pMiCKWqoiFso2VgdZUNtING7810MG8Tv1O4VX0F0FcO9CfPEjqhe4g2G4mjjisIpc
	 b+atIB1CCIQOZ1zfs7ymHURM0Zo1cphXnJfCIsvh2gMRhAx0fvWA3Ej/bsgy+7lPBy
	 RwwWv8xQcKU2X6Zmb02P8DErFYW/zcllqKjTPz9xnBxknRXfFgH564vwud4j1XCVdl
	 OLrN8YfmCIYp6jpbh6lOwkc2vnv9Yi3R8yNkZpHbZnZjaNi6cZqDY6OpXoO4pPLQbA
	 gY4uTlM3LhWQw==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 10 Sep 2026 14:22:02 -0400
Subject: [PATCH RFC nfs-utils 1/7] nfsdctl: sync nfsd_netlink.h with the
 kernel
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260910-nfsdctl-rpcb-v1-1-4bba1e7a3a43@kernel.org>
References: <20260910-nfsdctl-rpcb-v1-0-4bba1e7a3a43@kernel.org>
In-Reply-To: <20260910-nfsdctl-rpcb-v1-0-4bba1e7a3a43@kernel.org>
To: Steve Dickson <steved@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2351; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=wv2OccFFKLkXr+YGWy2rzbry5U+NwLKxDOIg6uFw+yo=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqovVPgbTDh5xidmcLwbq/SoEi6F3Axvd1+ia/0
 Wo2+AaeiHWJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqL1TwAKCRAADmhBGVaC
 FTa/D/9WcvPSPvvUAplnswwCRulOQVYWxJIv3ur1c/IK6f6iFsk0ETrL9z+f6bOdeytH5QuIGc8
 EKY9yxaykcc8wcOSM+wm6yy7b5HGfrOEvDy08j9cGPWseko2+1XwKJgjZNvtPCSyrR+gvq5jO/2
 GRMKRD9BmzzBtGinnIMw/9CNKcjmuGHIVH++b3V61ZllXuA6i4CUmF3OZ4dAGkun1qpM8Nx9w/4
 yH+RtRYkEjNE+c4lkugL8pfNQfw38RIf2jThxir0UnRwlmDH1efx1dzHdPVqcgp8gpUZvn68eoO
 97ecbTem162Ee4DmUsNt8DyXhliJVLkA3/JKkS64Zqkz6gVxVUGHEm9dHesHgdnJ1pitf+rBny/
 8WxXlNISCF9no3poWbSiXid5AYyXDc8F+5i/GNdrHbNv79TnL61fCOOhhIuF4OiV/GKu8IfxmIn
 MAnFCWhrSyC1ktAcWHuetdAb+qyeHhKyY+aOFJB5WZKuZk873R8t1M3EHDNxgqlrb0IZ8Y9Aans
 j5EKhEUYzX6dIQjKtO1it3afndq2IDqigUzilyKMTy2r422F0kf8+f5i/DiHvb8r8iq5I6QjltD
 bOEl+PHRfX9Mh32bDpLOqLafVwut6NfJchtyGLO07IskweO88omyRphu0LnuSVRJOTPK/tm6bLF
 s+tknpAvhIAFRWw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Import the attributes that let a caller own rpcbind registration:

- NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND on the request
- NFSD_A_SERVER_SOCK_RPCBIND, and the NFSD_A_RPCBIND_* nest, on the reply

The file comes from include/uapi/linux/nfsd_netlink.h. No code reads the
new attributes yet.

Bump the USE_SYSTEM_NFSD_NETLINK_H probe to one of the new attributes.
It tested NFSD_CMD_SERVER_STATS_GET, which has been in the uapi header
since v6.9, so any host with headers that new picks the system copy and
loses everything imported here.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 configure.ac                   |  2 +-
 support/include/nfsd_netlink.h | 18 ++++++++++++++++++
 2 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index 2ce1e129e5d4..d9d268975d7d 100644
--- a/configure.ac
+++ b/configure.ac
@@ -259,7 +259,7 @@ AC_CHECK_HEADERS(linux/nfsd_netlink.h)
 
 # ensure the system netlink headers have the latest features
 AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <linux/nfsd_netlink.h>]],
-			                   [[int foo = NFSD_CMD_SERVER_STATS_GET;]])],
+			                   [[int foo = NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND;]])],
 			   [AC_DEFINE([USE_SYSTEM_NFSD_NETLINK_H], 1,
 				      ["Use system's linux/nfsd_netlink.h"])])
 AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <linux/lockd_netlink.h>]],
diff --git a/support/include/nfsd_netlink.h b/support/include/nfsd_netlink.h
index 87da1d0bb21e..400322857d16 100644
--- a/support/include/nfsd_netlink.h
+++ b/support/include/nfsd_netlink.h
@@ -50,6 +50,13 @@ enum nfsd_xprtsec_mode {
 	NFSD_XPRTSEC_MODE_MTLS = 4,
 };
 
+/*
+ * Constraints that apply to an rpcbind registration.
+ */
+enum nfsd_rpcbind_flags {
+	NFSD_RPCBIND_FLAGS_NO_UDP = 1,
+};
+
 enum {
 	NFSD_A_CACHE_NOTIFY_CACHE_TYPE = 1,
 
@@ -113,8 +120,19 @@ enum {
 	NFSD_A_SOCK_MAX = (__NFSD_A_SOCK_MAX - 1)
 };
 
+enum {
+	NFSD_A_RPCBIND_PROGRAM = 1,
+	NFSD_A_RPCBIND_VERSION,
+	NFSD_A_RPCBIND_FLAGS,
+
+	__NFSD_A_RPCBIND_MAX,
+	NFSD_A_RPCBIND_MAX = (__NFSD_A_RPCBIND_MAX - 1)
+};
+
 enum {
 	NFSD_A_SERVER_SOCK_ADDR = 1,
+	NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND,
+	NFSD_A_SERVER_SOCK_RPCBIND,
 
 	__NFSD_A_SERVER_SOCK_MAX,
 	NFSD_A_SERVER_SOCK_MAX = (__NFSD_A_SERVER_SOCK_MAX - 1)

-- 
2.55.0

