Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58310 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966245AbaLLTPE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Dec 2014 14:15:04 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sBCJF3ik025529
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Fri, 12 Dec 2014 14:15:03 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sBCJF30w010187
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 12 Dec 2014 14:15:03 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sBCJF26c000561
	for <linux-nfs@vger.kernel.org>; Fri, 12 Dec 2014 14:15:02 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sBCJF2rh000560
	for linux-nfs@vger.kernel.org; Fri, 12 Dec 2014 14:15:02 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v4 14/14] mountstats: Updated the mountstats(8) man page.
Date: Fri, 12 Dec 2014 14:14:57 -0500
Message-Id: <1418411697-65535-15-git-send-email-smayhew@redhat.com>
In-Reply-To: <1418411697-65535-1-git-send-email-smayhew@redhat.com>
References: <1418411697-65535-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Added documentation for the iostat and nfsstat sub-commands.  Added
documentation for all of the options that have recently been added.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.man | 142 ++++++++++++++++++++++++++++++++++++----
 1 file changed, 128 insertions(+), 14 deletions(-)

diff --git a/tools/mountstats/mountstats.man b/tools/mountstats/mountstats.man
index 0de31b7..bee3f86 100644
--- a/tools/mountstats/mountstats.man
+++ b/tools/mountstats/mountstats.man
@@ -1,32 +1,146 @@
 .\"
 .\" mountstats(8)
 .\"
-.TH mountstats 8 "15 Apr 2010"
+.TH mountstats 8 "12 Dec 2014"
 .SH NAME
-mountstats \- Displays NFS client per-mount statistics
+mountstats \- Displays various NFS client per-mount statistics
 .SH SYNOPSIS
-.BI "mountstats ["<options> "] " <mount_point> " [ " <mount_point> "]" 
-.SH DESCRIPTION
-The
 .B mountstats
-command displays NFS client statisitics on each given
-.I <mount_point>
+.RB [ \-h | \-\-help ]
+.RB [ \-v | \-\-version ]
+.RB [ \-f | \-\-file
+.IR infile ]
+.RB [ \-s | \-\-since
+.IR sincefile ]
+.\" .RB [ \-n | \-\-nfs | \-r | \-\-rpc | \-R | \-\-raw ]
+.R [
+.RB [ \-n | \-\-nfs ]
+.R |
+.RB [ \-r | \-\-rpc ]
+.R |
+.RB  [ \-R | \-\-raw ]
+.R ]
+.RI [ mountpoint ] ...
+.P
+.B mountstats iostat
+.RB [ \-h | \-\-help ]
+.RB [ \-v | \-\-version ]
+.RB [ \-f | \-\-file
+.IR infile ]
+.RB [ \-s | \-\-since
+.IR sincefile ]
+.RI [ interval ]
+.RI [ count ]
+.RI [ mountpoint ] ...
+.P
+.B mounstats nfsstat
+.RB [ \-h | \-\-help ]
+.RB [ \-v | \-\-version ]
+.RB [ \-f | \-\-file
+.IR infile ]
+.RB [ \-s | \-\-since
+.IR sincefile ]
+.RB [ \-3 ]
+.RB [ \-4 ]
+.RI [ mountpoint ] ...
+.P
+.SH DESCRIPTION
+.RB "The " mountstats " command displays various NFS client statisitics for each given"
+.IR mountpoint .
+.P
+.RI "If no " mountpoint " is given, statistics will be displayed for all NFS mountpoints on the client."
+.SS Sub-commands
+Valid
+.BR mountstats (8)
+subcommands are:
+.IP "\fBmountstats\fP"
+Display a combination of per-op RPC statistics, NFS event counts, and NFS byte counts.  This is the default sub-command that will be executed if no sub-command is given.
+.IP "\fBiostat\fP"
+Display iostat-like statistics.
+.IP "\fBnfsstat\fP"
+Display nfsstat-like statistics.
 .SH OPTIONS
+.SS Options valid for all sub-commands
+.TP
+.B \-h, \-\-help
+show the help message and exit
+.TP
+.B \-v, \-\-version
+show program's version number and exit
+.TP
+\fB\-f \fIinfile\fR, \fB\-\-file \fIinfile
+Read stats from
+.I infile
+instead of 
+.IR /proc/self/mountstats ".  " infile
+must be in the same format as 
+.IR /proc/self/mountstats .
+This may be used with the
+.BR \-S | \-\-since
+options to display the delta between two different points in time.
+This may not be used with the
+.IR interval " or " count
+options of the
+.B iostat
+sub-command.
 .TP
-.B " \-\-nfs
-display only the NFS statistics
+\fB\-S \fIsincefile\fR, \fB\-\-since \fIsincefile
+Show difference between current stats and those in
+.IR sincefile ".  " sincefile
+must be in the same format as 
+.IR /proc/self/mountstats .
+This may be used with the
+.BR \-f | \-\-file
+options to display the delta between two different points in time.
+This may not be used with the
+.IR interval " or " count
+options of the
+.B iostat
+sub-command.
+.SS Options specific to the mountstats sub-command
+.B \-n, \-\-nfs
+Display only the NFS statistics
 .TP
-.B " \-\-rpc 
-display only the RPC statistics
+.B \-r, \-\-rpc
+Display only the RPC statistics
 .TP
-.B " \-\-version 
-display the version of this command
+.B \-R, \-\-raw
+Display only the raw statistics.  This is intended for use with the
+.BR \-f | \-\-file
+and
+.BR \-S | \-\-since
+options.
+.SS Options specific to the iostat sub-command
+.IP "\fIinterval\fP"
+Specifies the amount of time in seconds between each report.  The first report contains statistics for the time since each file system was mounted.  Each subsequent report contains statistics collected during the interval since the previous report.  This may not be used with the
+.BR \-f | \-\-file
+or
+.BR \-s | \-\-since
+options.
+.P
+.IP "\fIcount\fP"
+Determines the number of reports generated at
+.I interval
+seconds apart.  If the
+.I interval
+parameter is specified without the
+.I count
+parameter, the command generates reports continuously.  This may not be used with the
+.BR \-f | \-\-file
+or
+.BR \-s | \-\-since 
+options.
+.SS Options specific to the nfsstat sub-command
+.IP "\fB\-3\fP"
+Show only NFS version 3 statistics.  The default is to show both version 3 and version 4 statistics.
+.IP "\fB\-4\fP"
+Show only NFS version 4 statistics.  The default is to show both version 3 and version 4 statistics.
 .SH FILES
 .TP
 .B /proc/self/mountstats
 .SH SEE ALSO
 .BR iostat (8),
 .BR nfsiostat (8),
-.BR nfsstat(8)
+.BR nfsstat (8)
 .SH AUTHOR
 Chuck Lever <chuck.lever@oracle.com>
-- 
1.9.3

