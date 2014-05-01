Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:31216 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751286AbaEAOhE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 May 2014 10:37:04 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s41Eb3DS001374
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 1 May 2014 10:37:04 -0400
Received: from smallhat.boston.devel.redhat.com (vpn-48-26.rdu2.redhat.com [10.10.48.26])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s41Eb28i005947
	for <linux-nfs@vger.kernel.org>; Thu, 1 May 2014 10:37:02 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] start-statd: rpc.statd's systemd unit changed names.
Date: Thu,  1 May 2014 10:37:00 -0400
Message-Id: <1398955020-18614-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/statd/start-statd | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/statd/start-statd b/utils/statd/start-statd
index 8ac3798..dcdaf77 100644
--- a/utils/statd/start-statd
+++ b/utils/statd/start-statd
@@ -5,7 +5,7 @@
 # It should run statd with whatever flags are apropriate for this
 # site.
 PATH="/sbin:/usr/sbin:/bin:/usr/bin"
-if systemctl start statd.service
+if systemctl start rpc-statd.service
 then :
 else
     exec rpc.statd --no-notify
-- 
1.9.0

