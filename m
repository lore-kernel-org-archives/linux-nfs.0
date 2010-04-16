From: Steve Dickson <steved@redhat.com>
Subject: [RFC PATCH 2/3] Introduce man page for the nfsiostats command
Date: Fri, 16 Apr 2010 11:10:20 -0400
Message-ID: <1271430621-8663-3-git-send-email-steved@redhat.com>
References: <1271430621-8663-1-git-send-email-steved@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:47351 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757191Ab0DPPKZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Apr 2010 11:10:25 -0400
Received: from [192.168.62.20] (helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1O2nBW-00018J-Rl
	for linux-nfs@vger.kernel.org; Fri, 16 Apr 2010 11:10:22 -0400
In-Reply-To: <1271430621-8663-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 tools/nfs-iostat/nfsiostat.man |   70 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 70 insertions(+), 0 deletions(-)
 create mode 100644 tools/nfs-iostat/nfsiostat.man

diff --git a/tools/nfs-iostat/nfsiostat.man b/tools/nfs-iostat/nfsiostat.man
new file mode 100644
index 0000000..7b1e0a8
--- /dev/null
+++ b/tools/nfs-iostat/nfsiostat.man
@@ -0,0 +1,70 @@
+.\"
+.\" nfsiostat(8)
+.\"
+.TH nfsiostat 8 "15 Apr 2010"
+.SH NAME
+nfsiostat \- Emulate iostat for NFS mount points using /proc/self/mountstats
+.SH SYNOPSIS
+.BI "nfsiostat [[" <interval> "] [" <count> "]] [" <options> "]["<mount_point> "]
+.SH DESCRIPTION
+The
+.B nfsiostat
+command displays NFS client per-mount statisitics. 
+.TP 
+<interval>
+specifies the amount of time in seconds between each report.
+The first report contains statistics for the time since each file
+system was mounted.  Each subsequent report contains statistics collected
+during the interval since the previous report.
+.TP
+<count>
+If the
+.I <count>
+parameter is
+specified, the value of 
+.I <count> 
+determines the number of reports generated at
+. <interval> 
+seconds apart. if the interval parameter is 
+specified without the
+.I <count> 
+parameter, the command generates reports continuously.
+.TP
+<options>
+Define below
+.TP
+<mount_point>
+If one or more
+.I <mount point> 
+names are specified, statistics for only these mount points will
+be displayed.  Otherwise, all NFS mount points on the client are listed.
+.SH OPTIONS
+.TP
+.B \-a " or " \-\-attr
+displays statistics related to the attribute cache
+.TP
+.B \-d " or " \-\-dir 
+displays statistics related to directory operations
+.TP
+.B \-h " or " \-\-help 
+shows help message and exit
+.TP
+.B \-l LIST or " \-\-list=LIST 
+only print stats for first LIST mount points
+.TP
+.B \-p " or " \-\-page
+displays statistics related to the page cache
+.TP
+.B \-s " or " \-\-sort
+Sort NFS mount points by ops/second
+.B \-\-version
+show program's version number and exit
+.SH FILES
+.TP
+.B /proc/self/mountstats
+.SH SEE ALSO
+.BR iostat (8),
+.BR mountstats (8),
+.BR nfsstat(8)
+.SH AUTHOR
+Chuck Lever <chuck.lever@oracle.com>
-- 
1.6.6.1

