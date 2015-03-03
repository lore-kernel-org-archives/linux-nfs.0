Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40896 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756006AbbCCSgr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Mar 2015 13:36:47 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Systemd Mailing List <systemd-devel@lists.freedesktop.org>
Subject: [PATCH] systemd: Have rpc-statd-notify.service Require network.target
Date: Tue,  3 Mar 2015 13:36:43 -0500
Message-Id: <1425407803-5278-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Its been reported that having the rpc-statd-notify service
depend on network.target instead network-online.target
decrease boot times as much as 10 seconds on some
installs

Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=1183293

Signed-off-by: Steve Dickson <steved@redhat.com>
Reported-by: Eric Work <work.eric@gmail.com>
---
 systemd/rpc-statd-notify.service |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.service
index a655445..b608a14 100644
--- a/systemd/rpc-statd-notify.service
+++ b/systemd/rpc-statd-notify.service
@@ -1,6 +1,6 @@
 [Unit]
 Description=Notify NFS peers of a restart
-Requires=network-online.target
+Requires=network.target
 After=network.target nss-lookup.target
 
 # if we run an nfs server, it needs to be running before we
-- 
1.7.1

