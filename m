Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:45406 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726044AbeIAKSM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Sep 2018 06:18:12 -0400
Received: by mail-io0-f194.google.com with SMTP id e12-v6so12096428iok.12
        for <linux-nfs@vger.kernel.org>; Fri, 31 Aug 2018 23:07:23 -0700 (PDT)
Received: from hut.sorensonfamily.com ([2603:300a:2104:9500:4eeb:42ff:fec7:ee1c])
        by smtp.gmail.com with ESMTPSA id h11-v6sm2902880itf.4.2018.08.31.23.07.22
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Aug 2018 23:07:22 -0700 (PDT)
To: linux-nfs@vger.kernel.org
From: Frank Sorenson <sorenson@redhat.com>
Subject: [nfs-utils PATCH] statd: fix use-after-free in monitor list if
 insertion fails
Message-ID: <d93ed8c0-0f17-4671-a852-8cea6330f5ba@redhat.com>
Date: Sat, 1 Sep 2018 01:07:21 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If nsm_insert_monitored_host() fails while saving the record to
stable storage, we can't just assume the entry was new. Existing
records must be removed from the list before being freed.

Signed-off-by: Frank Sorenson <sorenson@redhat.com>

diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
index 45c4346..9400048 100644
--- a/utils/statd/monitor.c
+++ b/utils/statd/monitor.c
@@ -197,7 +197,7 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 
 	if (!nsm_insert_monitored_host(dnsname,
 				(struct sockaddr *)(char *)&my_addr, argp)) {
-		nlist_free(NULL, clnt);
+		nlist_free(existing ? &rtnl : NULL, clnt);
 		goto failure;
 	}
 
