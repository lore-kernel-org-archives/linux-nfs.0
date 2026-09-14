Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E26E629DB64
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 16:00:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789401654; cv=none; b=SXBuvulrMVS/S3MJaxVJBaqmcyEgb+W1tB7KfzwEZ6YHQB210Ua9dIa/G7qkleRLjawaO6X+bR+A8m3d7AOSrMWvSNOCgJh31PRxfuWUu2doY+qnVkeQmDMGIAUl9jz3TFCWon7pLiOqG5cQ2HYHQEwOkXqcitQQ6Hj1qNKxu0Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789401654; c=relaxed/simple;
	bh=wv2OccFFKLkXr+YGWy2rzbry5U+NwLKxDOIg6uFw+yo=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=FSGTTSy0Ci/8A4GaUparNFHPXbihQ2HDdYNvn1XXtsY9jB6Yo+Z5NVRqg/knSi2oBuIXQIST4BTnfAKtY5pyx5ACTPTKY9V8zNwppLVtisVuEahPmODhCF3MD7BrlndLpA1wjGdueGfm5OVt4becFOwefCQsCJlPXmQTPO+uepU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=I4Z3HsXr; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="I4Z3HsXr"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C542D1F00899;
	Mon, 14 Sep 2026 16:00:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789401652;
	bh=UQzN4TV7ckJxcZ7ca7fcnls/GAnQC+zrrLButiexJIo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=I4Z3HsXrZa/yLQbDKLufTkzB/ft8PcomCxrgp2pX4CJWI/A5VCIG/6Gvxn88IRpjV
	 Dmfx5hbMi9XnMm1AmTF4+mmiKH9oXpCqvE7DVp4HYsCbTZMAFwTGH+drSn1FoWR2Vw
	 TaRPnMsj0NNvLn7cab0IoopDNlaqsdm2R6oKo6XmHSJv4EdHjY2KsfZdTCBp4d2OOq
	 FiOsKUuVuQuQCSnq9tYTEfJkpLMHrDLQJonSnPXB6eroXIC4nQQhbEO92V07QGow/z
	 WLgMb0qpsD4vSwaYh1KALCK/OzGh9G+oP3pKlwvHZxSjPl4b/bzs1Gjn9atpAqT6Y2
	 fOP3qsdi0q58g==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 14 Sep 2026 12:00:29 -0400
Subject: [PATCH RFC nfs-utils v2 01/10] nfsdctl: sync nfsd_netlink.h with
 the kernel
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-nfsdctl-rpcb-v2-1-b2c679ac0107@kernel.org>
References: <20260914-nfsdctl-rpcb-v2-0-b2c679ac0107@kernel.org>
In-Reply-To: <20260914-nfsdctl-rpcb-v2-0-b2c679ac0107@kernel.org>
To: Steve Dickson <steved@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2351; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=wv2OccFFKLkXr+YGWy2rzbry5U+NwLKxDOIg6uFw+yo=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqqBow9U3pDtvCjdD2EKLSXAEy4+c++v3M0qpEV
 F8j5A5KismJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqgaMAAKCRAADmhBGVaC
 FYPWD/4p9HNFHyRGwi30OqPdgcRTd8O4K3lcmWgAM2JgkcE+weEe6OMGCLQnkAJVntY/xtDE2KS
 hsyCek1amFl3KCMEnNz/rMHeRZh5bjGTUbIQv16oU9uwUagkDtnVQnvvRzsqvS+JboJAARlbyIC
 Jw9EnGQ1uBzgB0VkTQ9HWn7akqVXk9l+5Xpu6waUF896308iV6lGSG2NDhalS9y+O6xt7myn+8v
 Wi7o/0mdT5nTufzO8Q4wkTaUpiQMSlgcouBFtOBh5oC+yKIllLSfSaI083IvvqR+GPCf1RrbPMg
 OrLwcbL0bVbeqGCZlV9QG0TUs2u5QpB0YGwiTK+brw4hPs/joZH0pNH68m+Ue2ahcf0jSuB33Wa
 uDg/L0Tcc4K2SbjAMBfdnfOKqWAdUDRuKCdpzyNkj54OdZ/M2LXjxmuGCJ4U0L++6taBSPrZlkv
 WdXtG4Yq+fSxLhFAb4ByL+Frmuu3UJYBgRuvEnmTyaJRitgmh8JZ+xhpCrjxcLiZNvEtrjhA7/f
 PZvMnseMGEe1607NcZ4U9RapAk4ioXdko2BC2ErEQ9kkpXZJLEpj1AYeea89y5mrblkFmhRmTDo
 b4VaR5973kOQR8SFCM1y7ZPUtyZXIfy0fTu69BEIrAZ+um7D+Pd/hlFwT6bfDE8tqE6DvOAifVA
 7ICgmA/mmyCpVnQ==
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

