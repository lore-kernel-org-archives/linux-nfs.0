From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/17] NLM: Add helper to handle IPv4 addresses
Date: Thu, 04 Dec 2008 14:20:16 -0500
Message-ID: <20081204192015.8039.92290.stgit@ingres.1015granger.net>
References: <20081204191113.8039.76714.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:21171 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752600AbYLDTUi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2008 14:20:38 -0500
In-Reply-To: <20081204191113.8039.76714.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: introduce a helper function to generate IPv4 addresses using
the same style as the IPv6 helper function we just added.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index eddb176..417e071 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -105,6 +105,13 @@ static void nlm_clear_port(struct sockaddr *sap)
 	}
 }
 
+static void nlm_display_ipv4_address(const struct sockaddr *sap, char *buf,
+				     const size_t len)
+{
+	const struct sockaddr_in *sin = (struct sockaddr_in *)sap;
+	snprintf(buf, len, NIPQUAD_FMT, NIPQUAD(sin->sin_addr.s_addr));
+}
+
 static void nlm_display_ipv6_address(const struct sockaddr *sap, char *buf,
 				     const size_t len)
 {
@@ -125,7 +132,7 @@ static void nlm_display_address(const struct sockaddr *sap,
 {
 	switch (sap->sa_family) {
 	case AF_INET:
-		snprintf(buf, len, NIPQUAD_FMT, NIPQUAD(sin->sin_addr.s_addr));
+		nlm_display_ipv4_address(sap, buf, len);
 		break;
 	case AF_INET6:
 		nlm_display_ipv6_address(sap, buf, len);

