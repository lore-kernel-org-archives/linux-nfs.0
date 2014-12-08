Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33679 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754221AbaLHUwb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Dec 2014 15:52:31 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sB8KqLUJ010165
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 8 Dec 2014 15:52:31 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sB8KF9I3018387
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Mon, 8 Dec 2014 15:17:34 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sB8JvWud010231
	for <linux-nfs@vger.kernel.org>; Mon, 8 Dec 2014 14:57:32 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sB8JvWYU010230
	for linux-nfs@vger.kernel.org; Mon, 8 Dec 2014 14:57:32 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v3 15/17] mountstats: Added man page for ms-iostat(8)
Date: Mon,  8 Dec 2014 14:57:23 -0500
Message-Id: <1418068645-10134-16-git-send-email-smayhew@redhat.com>
In-Reply-To: <1418068645-10134-1-git-send-email-smayhew@redhat.com>
References: <1418068645-10134-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/ms-iostat.man | 49 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 49 insertions(+)
 create mode 100644 tools/mountstats/ms-iostat.man

diff --git a/tools/mountstats/ms-iostat.man b/tools/mountstats/ms-iostat.man
new file mode 100644
index 0000000..a254a37
--- /dev/null
+++ b/tools/mountstats/ms-iostat.man
@@ -0,0 +1,49 @@
+.\"
+.\" ms-iostat(8)
+.\"
+.TH ms-iostat 8 "25 Nov 2014"
+.SH NAME
+ms-iostat \- iostat-like program to display NFS client per-mount statistics
+.SH SYNOPSIS
+\fBms-iostat [\fIOPTION\fB]\fR... \fB[\fIinterval\fB] [\fIcount\fB] [\fImountpoint\fB]\fR...
+.SH DESCRIPTION
+.RB "The " ms-iostat " command is an iostat-like program to display NFS client per-mount statistics."
+.P
+.RI "The " interval
+parameter specifies the amount of time in seconds between each report.  The first report contains statistics for the time since each file system was mounted.  Each subsequent report contains statistics collected during the interval since the previous report.
+.P
+.RI "If the " count
+.RI "parameter is specified, the value of " count
+.RI "determines the number of reports generated at " interval
+.RI "seconds apart.  If the " interval
+.RI "parameter is specified without the " count
+parameter, the command generates reports continuously.
+.P
+.RI "If one or more " mountpoint
+names are specified, statistics for only these mount points will be displayed.  Otherwise, all NFS mount points on the client are listed.
+.SH OPTIONS
+.TP
+.B \-h, \-\-help
+show the help message and exit
+.TP
+.B \-v, \-\-version
+show program's version number and exit
+.TP
+\fB\-f \fIINFILE\fR, \fB\-\-file \fIINFILE
+.RI "Read stats from " INFILE " instead of " /proc/self/mountstats ".  "
+.RI "This may not be used with the " interval " or " count " options."
+.TP
+\fB\-S \fISINCE\fR, \fB\-\-since \fISINCE
+.RI "Show difference between current stats and those in " SINCE ".  "
+.RI "This may not be used with the " interval " or " count " options."
+.SH FILES
+.TP
+.B /proc/self/mountstats
+.SH SEE ALSO
+.BR iostat (8),
+.BR nfsiostat (8),
+.BR nfsstat (8),
+.BR ms-iostat (8),
+.BR ms-nfsstat (8)
+.SH AUTHOR
+Chuck Lever <chuck.lever@oracle.com>
-- 
1.9.3

