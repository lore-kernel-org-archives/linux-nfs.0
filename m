Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37397 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752952AbbBKQnk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Feb 2015 11:43:40 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1BGhes0005456
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 11 Feb 2015 11:43:40 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: steved@redhat.com
Subject: [PATCH] nfs-utils: Fix rpc.gssd and rpc.svcgssd args variable names
Date: Wed, 11 Feb 2015 11:17:30 -0500
Message-Id: <88e82aeaea947c3aa47f57dc5c02c5bdbe901961.1423671114.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This fixes mis-matched variable names from fedora's /etc/sysconfig/nfs.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 systemd/rpc-gssd.service    |    2 +-
 systemd/rpc-svcgssd.service |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/systemd/rpc-gssd.service b/systemd/rpc-gssd.service
index d4a3819..6e1af86 100644
--- a/systemd/rpc-gssd.service
+++ b/systemd/rpc-gssd.service
@@ -16,4 +16,4 @@ After=nfs-config.service
 EnvironmentFile=-/run/sysconfig/nfs-utils
 
 Type=forking
-ExecStart=/usr/sbin/rpc.gssd $GSSDARGS
+ExecStart=/usr/sbin/rpc.gssd $RPCGSSDARGS
diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
index f7424b0..0aeaed9 100644
--- a/systemd/rpc-svcgssd.service
+++ b/systemd/rpc-svcgssd.service
@@ -16,4 +16,4 @@ After=nfs-config.service
 [Service]
 EnvironmentFile=-/run/sysconfig/nfs-utils
 Type=forking
-ExecStart=/usr/sbin/rpc.svcgssd $SVCGSSDARGS
+ExecStart=/usr/sbin/rpc.svcgssd $RPCSVCGSSDARGS
-- 
1.7.1

