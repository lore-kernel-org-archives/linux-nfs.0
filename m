Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:36098 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751262AbdBIXBY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Feb 2017 18:01:24 -0500
Received: by mail-qt0-f171.google.com with SMTP id k15so19069333qtg.3
        for <linux-nfs@vger.kernel.org>; Thu, 09 Feb 2017 15:01:24 -0800 (PST)
Received: from hut.sorenson.redhat.com (198-0-247-150-static.hfc.comcastbusiness.net. [198.0.247.150])
        by smtp.gmail.com with ESMTPSA id u5sm10459220qkd.46.2017.02.09.15.01.22
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 15:01:22 -0800 (PST)
To: linux-nfs@vger.kernel.org
From: Frank Sorenson <sorenson@redhat.com>
Subject: [nfs-utils PATCH V2 1/2] Replace non-thread-safe strtok function
 calls in gssd
Message-ID: <911ff1ff-ac59-2c10-e165-cd1186b1f940@redhat.com>
Date: Thu, 9 Feb 2017 17:01:22 -0600
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Author: Frank Sorenson <sorenson@redhat.com>
Date:   2017-02-09 16:35:51 -0600

    gssd: replace non-thread-safe strtok with strsep
    
    gssd uses the non-thread-safe strtok() function, which
    can lead to incorrect program behavior.
    
    Replace strtok() with the thread-safe strsep().
    
    Signed-off-by: Frank Sorenson <sorenson@redhat.com>

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index d74d372..30c6ace 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -729,10 +729,11 @@ handle_gssd_upcall(struct clnt_upcall_info *info)
 	char			*target = NULL;
 	char			*service = NULL;
 	char			*enctypes = NULL;
+	char			*pbuf = info->lbuf;
 
 	printerr(2, "\n%s: '%s' (%s)\n", __func__, info->lbuf, clp->relpath);
 
-	for (p = strtok(info->lbuf, " "); p; p = strtok(NULL, " ")) {
+	while ((p = strsep(&pbuf, " "))) {
 		if (!strncmp(p, "mech=", strlen("mech=")))
 			mech = p + strlen("mech=");
 		else if (!strncmp(p, "uid=", strlen("uid=")))
