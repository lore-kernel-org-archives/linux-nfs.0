Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57342 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751981AbaKZTOC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Nov 2014 14:14:02 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sAQJE2G2006140
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:14:02 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sAQJE2Rd010793
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:14:02 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sAQJE2rp037782
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:14:02 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sAQJE29w037781
	for linux-nfs@vger.kernel.org; Wed, 26 Nov 2014 14:14:02 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v2 16/17] mountstats: Added man page for ms-nfsstat(8)
Date: Wed, 26 Nov 2014 14:13:54 -0500
Message-Id: <1417029235-37675-17-git-send-email-smayhew@redhat.com>
In-Reply-To: <1417029235-37675-1-git-send-email-smayhew@redhat.com>
References: <1417029235-37675-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/ms-nfsstat.man | 49 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 49 insertions(+)
 create mode 100644 tools/mountstats/ms-nfsstat.man

diff --git a/tools/mountstats/ms-nfsstat.man b/tools/mountstats/ms-nfsstat.man
new file mode 100644
index 0000000..53bfb30
--- /dev/null
+++ b/tools/mountstats/ms-nfsstat.man
@@ -0,0 +1,49 @@
+.\"
+.\" ms-nfsstat(8)
+.\"
+.TH ms-nfsstat 8 "25 Nov 2014"
+.SH NAME
+ms-nfsstat \- nfsstat-like program that uses NFS client per-mount statistics
+.SH SYNOPSIS
+.BI "ms-nfsstat [" OPTIONS "] [" mountpoint " [" mountpoint "] " ...  " ]" 
+.SH DESCRIPTION
+The
+.B ms-nfsstat
+command is an nfsstat-like program to display NFS client statistics generated from /proc/self/mountstats instead of from /proc/net/rpc/nfs.
+.P
+If one or more
+.I mountpoint
+names are specified, statistics for only these mount points will be displayed.  Otherwise, statistics for all NFS mount points on the client are listed.
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
+instead of /proc/self/mountstats.
+.TP
+\fB\-S \fISINCE\fR, \fB\-\-since \fISINCE
+Show difference between current stats and those in
+.IR SINCE .
+.TP
+.B -3
+Show only NFS version 3 statistics.  The default is to show both version 3 and version 4 statistics.
+.TP
+.B -4
+Show only NFS version 4 statistics.  The default is to show both version 3 and version 4 statistics.
+.SH FILES
+.TP
+.B /proc/self/mountstats
+.SH SEE ALSO
+.BR iostat (8),
+.BR nfsiostat (8),
+.BR nfsstat (8),
+.BR mountstats (8),
+.BR ms-iostat (8)
+.SH AUTHOR
+Chuck Lever <chuck.lever@oracle.com>
-- 
1.9.3

