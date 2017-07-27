Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61298 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751444AbdG0Oku (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 27 Jul 2017 10:40:50 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 380E813A4E
        for <linux-nfs@vger.kernel.org>; Thu, 27 Jul 2017 14:40:50 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id E7BB96FB9A
        for <linux-nfs@vger.kernel.org>; Thu, 27 Jul 2017 14:40:49 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] mountstats: remove shebang
Date: Thu, 27 Jul 2017 10:40:48 -0400
Message-Id: <20170727144048.6062-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There might be an issue that the script is executed with unwanted
version of <lang>.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 tools/mountstats/mountstats.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 88ccdae..a68d702 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -1,4 +1,4 @@
-#!/usr/bin/env python
+#!/usr/bin/python
 # -*- python-mode -*-
 """Parse /proc/self/mountstats and display it in human readable form
 """
-- 
2.13.3

