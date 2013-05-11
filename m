Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f182.google.com ([209.85.210.182]:40431 "EHLO
	mail-ia0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042Ab3EKLyd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 11 May 2013 07:54:33 -0400
Received: by mail-ia0-f182.google.com with SMTP id j5so3547493iaf.27
        for <linux-nfs@vger.kernel.org>; Sat, 11 May 2013 04:54:32 -0700 (PDT)
Received: from [192.168.21.211] (CPE0018e7e4b223-CM0013718c1d6c.cpe.net.cable.rogers.com. [99.232.58.77])
        by mx.google.com with ESMTPSA id qs4sm4320594igb.10.2013.05.11.04.54.30
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 11 May 2013 04:54:31 -0700 (PDT)
Message-ID: <518E316A.8050002@gmail.com>
Date: Sat, 11 May 2013 07:54:18 -0400
From: Doug Nazar <nazard.michi@gmail.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Fix gssd ignore machine credentials for root
Content-Type: multipart/mixed;
 boundary="------------020408040004030901040406"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020408040004030901040406
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Commit 1c787f14 [gssd: scan for DIR: ccaches, too] changed the default 
prefix for the credential cache files. Update the check to ignore the 
machine credential file when running with -n (root ignores machine 
credentials).

Doug


--------------020408040004030901040406
Content-Type: text/plain; charset=windows-1252;
 name="nfs-utils-root-ignore-machine-creds-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="nfs-utils-root-ignore-machine-creds-fix.patch"

--- utils/gssd/krb5_util.c	2013-05-11 00:33:08.054297810 -0400
+++ ../nfs-utils-1.2.7.new/utils/gssd/krb5_util.c	2012-11-11 18:01:23.000000000 -0500
@@ -231,7 +231,7 @@
 				continue;
 			}
 			if (uid == 0 && !root_uses_machine_creds && 
-				strstr(namelist[i]->d_name, "_machine_")) {
+				strstr(namelist[i]->d_name, "machine_")) {
 				printerr(3, "CC '%s' not available to root\n",
 					 statname);
 				free(namelist[i]);

--------------020408040004030901040406--
