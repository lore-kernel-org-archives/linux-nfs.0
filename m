From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/17] NLM: Remove AF_UNSPEC arm in nlm_display_address()
Date: Thu, 04 Dec 2008 14:20:01 -0500
Message-ID: <20081204192000.8039.23852.stgit@ingres.1015granger.net>
References: <20081204191113.8039.76714.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:16693 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753067AbYLDTU3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2008 14:20:29 -0500
In-Reply-To: <20081204191113.8039.76714.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

AF_UNSPEC support is no longer needed in nlm_display_address() now
that a presentation address is no longer generated for the h_srcaddr
field.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 9bc61f4..359e1aa 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -112,9 +112,6 @@ static void nlm_display_address(const struct sockaddr *sap,
 	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
 
 	switch (sap->sa_family) {
-	case AF_UNSPEC:
-		snprintf(buf, len, "unspecified");
-		break;
 	case AF_INET:
 		snprintf(buf, len, NIPQUAD_FMT, NIPQUAD(sin->sin_addr.s_addr));
 		break;

