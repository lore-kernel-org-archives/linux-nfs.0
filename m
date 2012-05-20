Return-Path: linux-nfs-owner@vger.kernel.org
Received: from filtteri5.pp.htv.fi ([213.243.153.188]:57667 "EHLO
	filtteri5.pp.htv.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658Ab2ETUnB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 May 2012 16:43:01 -0400
Received: from localhost (localhost [127.0.0.1])
	by filtteri5.pp.htv.fi (Postfix) with ESMTP id 1D5D75A63B5
	for <linux-nfs@vger.kernel.org>; Sun, 20 May 2012 23:33:25 +0300 (EEST)
Received: from smtp6.welho.com ([213.243.153.40])
	by localhost (filtteri5.pp.htv.fi [213.243.153.188]) (amavisd-new, port 10024)
	with ESMTP id B1tOnuxfc3yi for <linux-nfs@vger.kernel.org>;
	Sun, 20 May 2012 23:33:24 +0300 (EEST)
Received: from michael.steam.fi.bobcat.mine.nu (cs78200229.pp.htv.fi [62.78.200.229])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp6.welho.com (Postfix) with ESMTPS id 5A4345BC003
	for <linux-nfs@vger.kernel.org>; Sun, 20 May 2012 23:33:24 +0300 (EEST)
From: =?UTF-8?q?Ville=20Skytt=C3=A4?= <ville.skytta@iki.fi>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] idmapd.conf.5: Syntax fixes.
Date: Sun, 20 May 2012 23:33:23 +0300
Message-Id: <1337546003-5218-1-git-send-email-ville.skytta@iki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Ville Skyttä <ville.skytta@iki.fi>
---
 idmapd.conf.5 |   15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/idmapd.conf.5 b/idmapd.conf.5
index 9c7f1ae..7b9e762 100644
--- a/idmapd.conf.5
+++ b/idmapd.conf.5
@@ -234,7 +234,6 @@ Number of seconds before timing out an LDAP request
 .\" -------------------------------------------------------------------
 .\"
 .SH EXAMPLES
-."
 An example
 .I /etc/idmapd.conf
 file:
@@ -266,7 +265,7 @@ johndoe@OTHER.DOMAIN.ORG = johnny
 LDAP_server = ldap.domain.org
 LDAP_base = dc=org,dc=domain
 
-.fo
+.fi
 .\"
 .\" -------------------------------------------------------------------
 .\" Additional sections
@@ -275,11 +274,11 @@ LDAP_base = dc=org,dc=domain
 .SH SEE ALSO
 .BR idmapd (8)
 .BR svcgssd (8)
-.".SH COMPATIBILITY
-.".SH STANDARDS
-.".SH ACKNOWLEDGEMENTS
-.".SH AUTHORS
-.".SH HISTORY
+.\".SH COMPATIBILITY
+.\".SH STANDARDS
+.\".SH ACKNOWLEDGEMENTS
+.\".SH AUTHORS
+.\".SH HISTORY
 .SH BUGS
 Report bugs to <nfsv4@linux-nfs.org>
-.".SH CAVEATS
+.\".SH CAVEATS
-- 
1.7.10.1

