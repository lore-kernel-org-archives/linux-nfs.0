Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38326 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758258Ab0IGUWa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 16:22:30 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o87KMUtU021975
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 7 Sep 2010 16:22:30 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o87KMSnn001714
	for <linux-nfs@vger.kernel.org>; Tue, 7 Sep 2010 16:22:29 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/3] Document the rdma mount option in the nfs man page
Date: Tue,  7 Sep 2010 16:22:01 -0400
Message-Id: <1283890921-3447-4-git-send-email-steved@redhat.com>
In-Reply-To: <1283890921-3447-1-git-send-email-steved@redhat.com>
References: <1283890921-3447-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Co-Authored-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/nfs.man |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 3806635..8964512 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -495,9 +495,15 @@ command,
 .I netid
 is a valid netid listed in
 .IR /etc/netconfig .
-Otherwise,
+The value "rdma" may also be specified.
+If the
+.B mount.nfs
+command does not have TI-RPC support, then
 .I netid
 is one of "tcp," "udp," or "rdma," and only IPv4 may be used.
+Also with "rdma" the version 3 NFS protocol will be used
+unless a different protocol is specified on the command
+line.
 .IP
 Each transport protocol uses different default
 .B retrans
@@ -537,6 +543,12 @@ option is an alternative to specifying
 .BR proto=tcp.
 It is included for compatibility with other operating systems.
 .TP 1.5i
+.B rdma
+The
+.B rdma
+option is an alternative to specifying
+.BR proto=rdma.
+.TP 1.5i
 .BI port= n
 The numeric value of the server's NFS service port.
 If the server's NFS service is not available on the specified port,
-- 
1.7.2.1

