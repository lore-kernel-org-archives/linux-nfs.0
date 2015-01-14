Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:55135 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751065AbbANTzk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Jan 2015 14:55:40 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t0EJteuZ012465
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 14 Jan 2015 14:55:40 -0500
Received: from smallhat.boston.devel.redhat.com (vpn-51-251.rdu2.redhat.com [10.10.51.251])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t0EJtdHv001871
	for <linux-nfs@vger.kernel.org>; Wed, 14 Jan 2015 14:55:39 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] sm-notify: notify hosts in background
Date: Wed, 14 Jan 2015 14:55:37 -0500
Message-Id: <1421265337-8438-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

sm-notify needs to notify hosts in background so the boot
will not hang when the notified hosts do not answer.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 systemd/rpc-statd-notify.service | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.service
index 6b13b32..3ce669e 100644
--- a/systemd/rpc-statd-notify.service
+++ b/systemd/rpc-statd-notify.service
@@ -14,6 +14,5 @@ After=nfs-config.service
 
 [Service]
 EnvironmentFile=-/run/sysconfig/nfs-utils
-Type=oneshot
-RemainAfterExit=yes
+Type=forking
 ExecStart=-/usr/sbin/sm-notify -d $SMNOTIFYARGS
-- 
2.1.0

