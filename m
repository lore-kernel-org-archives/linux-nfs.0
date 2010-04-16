From: Steve Dickson <steved@redhat.com>
Subject: [RFC PATCH 1/3] Introduce man page for the mountstats command
Date: Fri, 16 Apr 2010 11:10:19 -0400
Message-ID: <1271430621-8663-2-git-send-email-steved@redhat.com>
References: <1271430621-8663-1-git-send-email-steved@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:47350 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753871Ab0DPPKY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Apr 2010 11:10:24 -0400
Received: from [192.168.62.20] (helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1O2nBW-00018J-MT
	for linux-nfs@vger.kernel.org; Fri, 16 Apr 2010 11:10:22 -0400
In-Reply-To: <1271430621-8663-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 tools/mountstats/mountstats.man |   32 ++++++++++++++++++++++++++++++++
 1 files changed, 32 insertions(+), 0 deletions(-)
 create mode 100644 tools/mountstats/mountstats.man

diff --git a/tools/mountstats/mountstats.man b/tools/mountstats/mountstats.man
new file mode 100644
index 0000000..0de31b7
--- /dev/null
+++ b/tools/mountstats/mountstats.man
@@ -0,0 +1,32 @@
+.\"
+.\" mountstats(8)
+.\"
+.TH mountstats 8 "15 Apr 2010"
+.SH NAME
+mountstats \- Displays NFS client per-mount statistics
+.SH SYNOPSIS
+.BI "mountstats ["<options> "] " <mount_point> " [ " <mount_point> "]" 
+.SH DESCRIPTION
+The
+.B mountstats
+command displays NFS client statisitics on each given
+.I <mount_point>
+.SH OPTIONS
+.TP
+.B " \-\-nfs
+display only the NFS statistics
+.TP
+.B " \-\-rpc 
+display only the RPC statistics
+.TP
+.B " \-\-version 
+display the version of this command
+.SH FILES
+.TP
+.B /proc/self/mountstats
+.SH SEE ALSO
+.BR iostat (8),
+.BR nfsiostat (8),
+.BR nfsstat(8)
+.SH AUTHOR
+Chuck Lever <chuck.lever@oracle.com>
-- 
1.6.6.1

