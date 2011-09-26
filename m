Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:35811 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752087Ab1IZLmC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Sep 2011 07:42:02 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1R89Xg-0003y6-8s
	for linux-nfs@vger.kernel.org; Mon, 26 Sep 2011 07:40:14 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] Add a check for libdevmapper.h
Date: Mon, 26 Sep 2011 07:41:57 -0400
Message-Id: <1317037317-4329-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

When NFS v4.1 is enable, the libdevemapp.h header file has to exist.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/configure.ac b/configure.ac
index 80fb39d..572b33d 100644
--- a/configure.ac
+++ b/configure.ac
@@ -80,6 +80,7 @@ AC_ARG_ENABLE(nfsv41,
 			AC_MSG_ERROR([NFS v4.1 is enabled but NFS v4 is not. Use --disable-nfsv41])
 		fi
 		BLKMAPD=blkmapd
+   		AC_CHECK_HEADER(libdevmapper.h, , AC_MSG_ERROR([Cannot find libdevmapper.h header file. Try installing device-mapper-devel]))
 	else
 		enable_nfsv41=
 		BLKMAPD=
-- 
1.7.6

