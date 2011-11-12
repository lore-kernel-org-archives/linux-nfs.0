Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:55931 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754470Ab1KLQUR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Nov 2011 11:20:17 -0500
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1RPFMV-0003Gq-BQ
	for linux-nfs@vger.kernel.org; Sat, 12 Nov 2011 10:19:19 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] nss_getpwnam: ignore case when comparing domain names
Date: Sat, 12 Nov 2011 10:21:50 -0500
Message-Id: <1321111310-9481-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nss_getpwnam() fails to find the password entry when the
DNS domain name has both upper and lower characters,
which is wrong. Case need to be ignored when comparing
domain names.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 nss.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/nss.c b/nss.c
index 04aff19..b2b1227 100644
--- a/nss.c
+++ b/nss.c
@@ -141,7 +141,7 @@ static char *strip_domain(const char *name, const char *domain)
 	if (c == NULL && domain == NULL) {
 		len = strlen(name) + 1;
 	} else {
-		if (domain && strcmp(c + 1, domain) != 0)
+		if (domain && strcasecmp(c + 1, domain) != 0)
 			goto out;
 		len = c - name;
 	}
-- 
1.7.7

