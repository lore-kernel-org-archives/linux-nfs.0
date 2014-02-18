Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59567 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754057AbaBRIsz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Feb 2014 03:48:55 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s1I8msEm032328
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 18 Feb 2014 03:48:55 -0500
Received: from smallhat.boston.devel.redhat.com (vpn-63-232.rdu2.redhat.com [10.10.63.232])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s1I8mpqR022496
	for <linux-nfs@vger.kernel.org>; Tue, 18 Feb 2014 03:48:54 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] rpc-svcgssd.service: removed a the start up triggers
Date: Tue, 18 Feb 2014 03:48:48 -0500
Message-Id: <1392713329-17979-2-git-send-email-steved@redhat.com>
In-Reply-To: <1392713329-17979-1-git-send-email-steved@redhat.com>
References: <1392713329-17979-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The file /proc/net/rpc/use-gss-proxy exists whether
gss-proxy is or is not installed. So is existence
can not be used as start up trigger.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 systemd/rpc-svcgssd.service | 1 -
 1 file changed, 1 deletion(-)

diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
index 6bd4588..8e10b98 100644
--- a/systemd/rpc-svcgssd.service
+++ b/systemd/rpc-svcgssd.service
@@ -7,7 +7,6 @@ PartOf=nfs-utils.service
 
 After=gssproxy.service
 ConditionPathExists=|!@localstatedir@/run/gssproxy.pid
-ConditionPathExists=|!/proc/net/rpc/use-gss-proxy
 ConditionPathExists=/etc/krb5.keytab
 
 [Service]
-- 
1.8.5.3

