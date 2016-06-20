Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36650 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753641AbcFTRI1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jun 2016 13:08:27 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DA1F0128262
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jun 2016 16:45:01 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (vpn-62-104.rdu2.redhat.com [10.10.62.104])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u5KGj1Rv004280
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jun 2016 12:45:01 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] start-statd: Use flock to serialize the running of this script
Date: Mon, 20 Jun 2016 12:44:59 -0400
Message-Id: <1466441099-16166-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To once and for all stop multiple rpc.statd from
being started (mostly in HA environments), use
flock to serialize the running of the script

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/statd/start-statd | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/utils/statd/start-statd b/utils/statd/start-statd
index 19e6eb2..2fd6039 100755
--- a/utils/statd/start-statd
+++ b/utils/statd/start-statd
@@ -6,6 +6,10 @@
 # site.
 PATH="/sbin:/usr/sbin:/bin:/usr/bin"
 
+# Use flock to serialize the running of this script
+exec 200> /var/run/rpc.statd.lock
+flock -e 200
+
 if [ -s /var/run/rpc.statd.pid ] &&
        [ 1`cat /var/run/rpc.statd.pid` -gt 1 ] &&
        kill -0 `cat /var/run/rpc.statd.pid` > /dev/null 2>&1
-- 
2.5.5

