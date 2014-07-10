Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:9510 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751021AbaGJS24 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jul 2014 14:28:56 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s6AISsVk022213
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 14:28:55 -0400
Received: from smallhat.boston.devel.redhat.com (smallhat.boston.devel.redhat.com [10.19.60.65])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s6AISsVE016801
	for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 14:28:54 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] gssd: Fixed errno typo in get_servername()
Date: Thu, 10 Jul 2014 14:28:52 -0400
Message-Id: <1405016932-19599-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/gssd_proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 40ff188..9925dab 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -218,7 +218,7 @@ get_servername(const char *name, const struct sockaddr *sa, const char *addr)
 			  NI_NAMEREQD);
 	if (err) {
 		printerr(0, "ERROR: unable to resolve %s to hostname: %s\n",
-			 addr, err == EAI_SYSTEM ? strerror(err) :
+			 addr, err == EAI_SYSTEM ? strerror(errno) :
 						   gai_strerror(err));
 		return NULL;
 	}
-- 
1.9.3

