Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51702 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932308AbbBIOHY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Feb 2015 09:07:24 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t19E7Of5004993
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 9 Feb 2015 09:07:24 -0500
Received: from smallhat.boston.devel.redhat.com (vpn-60-202.rdu2.redhat.com [10.10.60.202])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t19E7NN4026918
	for <linux-nfs@vger.kernel.org>; Mon, 9 Feb 2015 09:07:24 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] rpc-statd-notify: Don't wait for the network to come up
Date: Mon,  9 Feb 2015 09:07:21 -0500
Message-Id: <1423490841-20097-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpc-statd-notify only needs to wait for the network
interface to be configured not to be connected since
it forks into background and will wait 15mins for
the network to come up.

This decrease boot times when networks are not
and will not be connected.

Signed-off-by: Steve Dickson <steved@redhat.com>
Reported-By: Eric Work <work.eric@gmail.com>
---
 systemd/rpc-statd-notify.service | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.service
index 941afe5..a655445 100644
--- a/systemd/rpc-statd-notify.service
+++ b/systemd/rpc-statd-notify.service
@@ -1,7 +1,7 @@
 [Unit]
 Description=Notify NFS peers of a restart
 Requires=network-online.target
-After=network-online.target nss-lookup.target
+After=network.target nss-lookup.target
 
 # if we run an nfs server, it needs to be running before we
 # tell clients that it has restarted.
-- 
2.1.0

