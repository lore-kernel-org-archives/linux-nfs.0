Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52515 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751065AbaKZTOC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Nov 2014 14:14:02 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sAQJE22b018352
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:14:02 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sAQJE29t018477
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:14:02 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sAQJE18s037778
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:14:01 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sAQJE18t037777
	for linux-nfs@vger.kernel.org; Wed, 26 Nov 2014 14:14:01 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v2 15/17] mountstats: Added man page for ms-iostat(8)
Date: Wed, 26 Nov 2014 14:13:53 -0500
Message-Id: <1417029235-37675-16-git-send-email-smayhew@redhat.com>
In-Reply-To: <1417029235-37675-1-git-send-email-smayhew@redhat.com>
References: <1417029235-37675-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/ms-iostat.man | 64 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 64 insertions(+)
 create mode 100644 tools/mountstats/ms-iostat.man

diff --git a/tools/mountstats/ms-iostat.man b/tools/mountstats/ms-iostat.man
new file mode 100644
index 0000000..73002c2
--- /dev/null
+++ b/tools/mountstats/ms-iostat.man
@@ -0,0 +1,64 @@
+.\"
+.\" ms-iostat(8)
+.\"
+.TH ms-iostat 8 "25 Nov 2014"
+.SH NAME
+ms-iostat \- iostat-like program to display NFS client per-mount statistics
+.SH SYNOPSIS
+.BI "ms-iostat [" OPTIONS "] [" interval "] [" count "] [" mountpoint " [" mountpoint "] " ...  " ]" 
+.SH DESCRIPTION
+The
+.B ms-iostat
+command is an iostat-like program to display NFS client per-mount statistics.
+.P
+The
+.I interval
+parameter specifies the amount of time in seconds between each report.  The first report contains statistics for the time since each file system was mounted.  Each subsequent report contains statistics collected during the interval since the previous report.
+.P
+If the
+.I count
+parameter is specified, the value of
+.I count
+determines the number of reports generated at
+.I interval
+seconds apart.  If the
+.I interval
+parameter is specified without the
+.I count
+parameter, the command generates reports continuously.
+.P
+If one or more
+.I mountpoint
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
+Read stats from
+.I INFILE
+instead of /proc/self/mountstats.  This may not be used with the 
+.IR interval " or " count
+options.
+.TP
+\fB\-S \fISINCE\fR, \fB\-\-since \fISINCE
+Show difference between current stats and those in
+.IR SINCE .
+This may not be used with the 
+.IR interval " or " count
+options.
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

