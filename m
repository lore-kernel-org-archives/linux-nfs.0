Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57337 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752077AbaKZTOC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Nov 2014 14:14:02 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sAQJE2Wt006134
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:14:02 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sAQJE18J023667
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:14:02 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sAQJE1kM037773
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:14:01 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sAQJE1Q5037772
	for linux-nfs@vger.kernel.org; Wed, 26 Nov 2014 14:14:01 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v2 14/17] mountstats: Updated the mountstats(8) man page.
Date: Wed, 26 Nov 2014 14:13:52 -0500
Message-Id: <1417029235-37675-15-git-send-email-smayhew@redhat.com>
In-Reply-To: <1417029235-37675-1-git-send-email-smayhew@redhat.com>
References: <1417029235-37675-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Updated the mounstats(8) man page to match the --help output.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.man | 45 ++++++++++++++++++++++++++++++++---------
 1 file changed, 35 insertions(+), 10 deletions(-)

diff --git a/tools/mountstats/mountstats.man b/tools/mountstats/mountstats.man
index 0de31b7..1269a8c 100644
--- a/tools/mountstats/mountstats.man
+++ b/tools/mountstats/mountstats.man
@@ -1,32 +1,57 @@
 .\"
 .\" mountstats(8)
 .\"
-.TH mountstats 8 "15 Apr 2010"
+.TH mountstats 8 "25 Nov 2014"
 .SH NAME
 mountstats \- Displays NFS client per-mount statistics
 .SH SYNOPSIS
-.BI "mountstats ["<options> "] " <mount_point> " [ " <mount_point> "]" 
+.BI "mountstats [" OPTIONS "] [" mountpoint " [" mountpoint "] " ...  " ]" 
 .SH DESCRIPTION
 The
 .B mountstats
 command displays NFS client statisitics on each given
-.I <mount_point>
+.IR mountpoint .
+.P
+If no
+.I mountpoint
+is given, statistics will be displayed for all NFS mountpoints on the client.
 .SH OPTIONS
 .TP
-.B " \-\-nfs
-display only the NFS statistics
+.B \-h, \-\-help
+show the help message and exit
 .TP
-.B " \-\-rpc 
-display only the RPC statistics
+.B \-v, \-\-version
+show program's version number and exit
 .TP
-.B " \-\-version 
-display the version of this command
+\fB\-f \fIINFILE\fR, \fB\-\-file \fIINFILE
+Read stats from
+.I INFILE
+instead of /proc/self/mountstats
+.TP
+\fB\-S \fISINCE\fR, \fB\-\-since \fISINCE
+Show difference between current stats and those in
+.I SINCE
+.TP
+.B \-n, \-\-nfs
+Display only the NFS statistics
+.TP
+.B \-r, \-\-rpc 
+Display only the RPC statistics
+.TP
+.B \-R, \-\-raw 
+Display only the raw statistics.  This is intended for use with the
+.B \-f/\-\-file
+and
+.B \-S/\-\-since
+options.
 .SH FILES
 .TP
 .B /proc/self/mountstats
 .SH SEE ALSO
 .BR iostat (8),
 .BR nfsiostat (8),
-.BR nfsstat(8)
+.BR nfsstat (8),
+.BR ms-iostat (8),
+.BR ms-nfsstat (8)
 .SH AUTHOR
 Chuck Lever <chuck.lever@oracle.com>
-- 
1.9.3

