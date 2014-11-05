Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:49848 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932263AbaKERBP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 12:01:15 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sA5H1Fqe022733
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:15 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sA5H1FRH030318
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:15 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sA5H1EIV000927
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:14 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sA5H1EEA000926
	for linux-nfs@vger.kernel.org; Wed, 5 Nov 2014 12:01:14 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils RFC PATCH 07/15] mountstats: Make print_iostat_summary handle newly appearing mounts
Date: Wed,  5 Nov 2014 12:01:04 -0500
Message-Id: <1415206872-864-8-git-send-email-smayhew@redhat.com>
In-Reply-To: <1415206872-864-1-git-send-email-smayhew@redhat.com>
References: <1415206872-864-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index d08384e..67bca51 100755
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -666,7 +666,7 @@ def print_iostat_summary(old, new, devices, time):
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

