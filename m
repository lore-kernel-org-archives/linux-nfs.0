Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33340 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750777AbaIVFVb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Sep 2014 01:21:31 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s8M5LVmB025329
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 22 Sep 2014 01:21:31 -0400
Received: from mmyllyne.csb (vpn1-7-35.ams2.redhat.com [10.36.7.35])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s8M5LUEd002441
	for <linux-nfs@vger.kernel.org>; Mon, 22 Sep 2014 01:21:31 -0400
Message-ID: <541FB1DA.9030600@redhat.com>
Date: Mon, 22 Sep 2014 08:21:30 +0300
From: Marko Myllynen <myllynen@redhat.com>
Reply-To: myllynen@redhat.com
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsstat: document io/ra server facilities
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>From 5cdb2d26fb01c9e28acdf0666ac53f15d6cda51e Mon Sep 17 00:00:00 2001
From: Marko Myllynen <myllynen@redhat.com>
Date: Mon, 22 Sep 2014 08:18:30 +0300
Subject: [PATCH] nfsstat: document io/ra server facilities

---
 utils/nfsstat/nfsstat.man |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/utils/nfsstat/nfsstat.man b/utils/nfsstat/nfsstat.man
index cd573b0..2e52935 100644
--- a/utils/nfsstat/nfsstat.man
+++ b/utils/nfsstat/nfsstat.man
@@ -67,6 +67,14 @@ total number of lookups, and the number of hits and misses.
 Usage information on the server's request reply cache, including the
 total number of lookups, and the number of hits and misses.
 .TP
+.B io
+Usage information on the server's io statistics; bytes read and
+written.
+.TP
+.B ra
+Usage information on the server's read ahead cache, including the
+ra cache size, the depth of ra cache hits, and ra cache misses.
+.TP
 .B all
 Display all of the above facilities.
 .RE
-- 
1.7.1

-- 
Marko Myllynen
