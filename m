Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34308 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752870AbaLHUw3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Dec 2014 15:52:29 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sB8KqJJU007286
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 8 Dec 2014 15:52:28 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sB8KF9Hr018387
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Mon, 8 Dec 2014 15:15:10 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sB8JvT2c010198
	for <linux-nfs@vger.kernel.org>; Mon, 8 Dec 2014 14:57:29 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sB8JvTSU010197
	for linux-nfs@vger.kernel.org; Mon, 8 Dec 2014 14:57:29 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v3 07/17] mountstats: Make print_iostat_summary handle newly appearing mounts
Date: Mon,  8 Dec 2014 14:57:15 -0500
Message-Id: <1418068645-10134-8-git-send-email-smayhew@redhat.com>
In-Reply-To: <1418068645-10134-1-git-send-email-smayhew@redhat.com>
References: <1418068645-10134-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index ee68b24..eaf0719 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -594,7 +594,7 @@ def print_iostat_summary(old, new, devices, time):
     for device in devices:
         stats = DeviceData()
         stats.parse_stats(new[device])
-        if not old:
+        if not old or device not in old:
             stats.display_iostats(time)
         else:
             old_stats = DeviceData()
-- 
1.9.3

