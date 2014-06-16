Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56821 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751890AbaFPNwF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jun 2014 09:52:05 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s5GDq47J026523
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 16 Jun 2014 09:52:05 -0400
Received: from smallhat.boston.devel.redhat.com (vpn-57-83.rdu2.redhat.com [10.10.57.83])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s5GDq3XD030143
	for <linux-nfs@vger.kernel.org>; Mon, 16 Jun 2014 09:52:04 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfsiostat: Document the output columns in the manpage
Date: Mon, 16 Jun 2014 09:52:01 -0400
Message-Id: <1402926721-8104-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jan Chaloupka <jchaloup@redhat.com>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 tools/nfs-iostat/nfsiostat.man | 55 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 55 insertions(+)

diff --git a/tools/nfs-iostat/nfsiostat.man b/tools/nfs-iostat/nfsiostat.man
index 3ec245d..b477a9a 100644
--- a/tools/nfs-iostat/nfsiostat.man
+++ b/tools/nfs-iostat/nfsiostat.man
@@ -38,6 +38,61 @@ If one or more
 .I <mount point> 
 names are specified, statistics for only these mount points will
 be displayed.  Otherwise, all NFS mount points on the client are listed.
+.TP
+The meaning of each column of \fBnfsiostat\fR's output is the following:
+.RS 8
+- \fBop/s\fR
+.RS
+This is the number of operations per second.
+.RS
+.RE
+.RE
+.RE
+.RS 8
+- \fBrpc bklog\fR
+.RS
+This is the length of the backlog queue.
+.RE
+.RE
+.RE
+.RS 8
+- \fBkB/s\fR
+.RS
+This is the number of kB written/read per second.
+.RE
+.RE
+.RE
+.RS 8
+- \fBkB/op\fR
+.RS
+This is the number of kB written/read per each operation.
+.RE
+.RE
+.RE
+.RS 8
+- \fBretrans\fR
+.RS
+This is the number of retransmissions.
+.RE
+.RE
+.RE
+.RS 8
+- \fBavg RTT (ms)\fR
+.RS
+This is the duration from the time that client's kernel sends the RPC request until the time it receives the reply.
+.RE
+.RE
+.RE
+.RS 8
+- \fBavg exe (ms)\fR
+.RS
+This is the duration from the time that NFS client does the RPC request to its kernel until the RPC request is completed, this includes the RTT time above.
+.RE
+.RE
+.RE
+.TP
+Note that if an interval is used as argument to \fBnfsiostat\fR, then the diffrence from previous interval will be displayed, otherwise the results will be from the time that the share was mounted.
+
 .SH OPTIONS
 .TP
 .B \-a " or " \-\-attr
-- 
1.9.0

