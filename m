Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43746 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751452AbbAMUhl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Jan 2015 15:37:41 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Systemd Mailing List <systemd-devel@lists.freedesktop.org>
Subject: [PATCH 2/3] systemd: Bind the nfs-mountd service to the nfs-server service
Date: Tue, 13 Jan 2015 15:37:36 -0500
Message-Id: <1421181457-8159-3-git-send-email-steved@redhat.com>
In-Reply-To: <1421181457-8159-1-git-send-email-steved@redhat.com>
References: <1421181457-8159-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use BindTo, instead of PartOf, to bind the nfs-mountd
service to the nfs-server service. Its a much tighter
bind than PartOf.

The Partof=nfs-utils.service was not needed.

One side effect of this tighter bond is when rpc.mountd
is stop, that will also bring the nfs server down,
due to the Requires=nfs-mountd.service in the 
nfs-server service

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 systemd/nfs-mountd.service | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/systemd/nfs-mountd.service b/systemd/nfs-mountd.service
index 7ccc0f7..c16af57 100644
--- a/systemd/nfs-mountd.service
+++ b/systemd/nfs-mountd.service
@@ -3,8 +3,7 @@ Description=NFS Mount Daemon
 Requires=proc-fs-nfsd.mount
 After=proc-fs-nfsd.mount
 After=network.target
-PartOf=nfs-server.service
-PartOf=nfs-utils.service
+BindTo=nfs-server.service
 
 Wants=nfs-config.service
 After=nfs-config.service
-- 
2.1.0

