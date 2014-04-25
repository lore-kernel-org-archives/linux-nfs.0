Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f41.google.com ([209.85.220.41]:39724 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750AbaDYDF1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Apr 2014 23:05:27 -0400
Received: by mail-pa0-f41.google.com with SMTP id fa1so2615807pad.14
        for <linux-nfs@vger.kernel.org>; Thu, 24 Apr 2014 20:05:26 -0700 (PDT)
Message-ID: <5359D0EE.7030408@gmail.com>
Date: Fri, 25 Apr 2014 11:05:18 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Subject: [PATCH nfs-utils/systemd] systemd: add PATH for finding systemctl
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The 1.3.0 release adds a call to systemctl fails for it's in /usr/bin.

[root@localhost nfs-utils]# start-statd
/usr/sbin/start-statd: line 9: systemctl: command not found
Statd service already running!

Reported-by: Allan Duncan <amd1234@fastmail.com.au>
Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 utils/statd/start-statd | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/statd/start-statd b/utils/statd/start-statd
index cde3583..8ac3798 100644
--- a/utils/statd/start-statd
+++ b/utils/statd/start-statd
@@ -4,7 +4,7 @@
 # /var/run/rpc.statd.pid).
 # It should run statd with whatever flags are apropriate for this
 # site.
-PATH=/sbin:/usr/sbin
+PATH="/sbin:/usr/sbin:/bin:/usr/bin"
 if systemctl start statd.service
 then :
 else
-- 
1.9.0

