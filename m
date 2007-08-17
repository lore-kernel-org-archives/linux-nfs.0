From: "david m. richter" <richterd@citi.umich.edu>
Subject: [PATCH] nfsstat: update manpage for --since
Date: Fri, 17 Aug 2007 12:50:42 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0708171247130.32037@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IM520-0004qa-Ey
	for nfs@lists.sourceforge.net; Fri, 17 Aug 2007 09:50:40 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IM523-0005vr-HV
	for nfs@lists.sourceforge.net; Fri, 17 Aug 2007 09:50:44 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

	Add -S/--since to the manpage with a couple examples.

---
	Hello, Neil -- here's the manpage stuff.  I'm not so sure about 
the "Examples" additions, though.. meh.  thanks, d.

 utils/nfsstat/nfsstat.man |   41 ++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 40 insertions(+), 1 deletions(-)

diff --git a/utils/nfsstat/nfsstat.man b/utils/nfsstat/nfsstat.man
index 5d2acc5..6908b06 100644
--- a/utils/nfsstat/nfsstat.man
+++ b/utils/nfsstat/nfsstat.man
@@ -72,8 +72,27 @@ Display all of the above facilities.
 .B \-v, \-\-verbose
 This is equivalent to \fB\-o all\fR.
 .TP
+.BI "\-S, \-\-since " file
+Instead of printing current statistics,
+.B nfsstat
+imports statistics from
+.I file
+and displays the difference between those and the current statistics.
+Valid input
+.IR file "s may be in the form of "
+.B /proc/net/rpc/nfs
+(raw client stats),
+.B /proc/net/rpc/nfsd
+(raw server stats), or saved output from
+.B nfsstat
+itself (client and/or server stats).   Any statistics missing from a saved
+.B nfsstat
+output
+.I file
+are treated as zeroes.
+.TP
 .B \-Z, \-\-sleep
-Instead of printing statistics and immediately exiting,
+Instead of printing current statistics and immediately exiting,
 .B nfsstat
 takes a snapshot of the current statistics and pauses until it receives
 .B SIGINT
@@ -81,6 +100,7 @@ takes a snapshot of the current statisti
 .BR Ctrl-C ),
 at which point it takes another snapshot and displays the difference
 between the two.
+.\" --------------------- EXAMPLES -------------------------------
 .SH EXAMPLES
 .TP
 .B nfsstat \-o all \-234
@@ -97,6 +117,25 @@ Show statistics for \fBNFS\fR version 3
 .TP
 .B nfsstat \-m
 Show information about mounted \fBNFS\fR filesystems.
+.TP
+.B nfsstat -v >/tmp/stats; run_short_test.sh; nfsstat -v --since /tmp/stats
+Show statistics collected while a user's
+.B run_short_test.sh
+ran.
+.P
+.RE 3
+.nf
+.B run_long_test.sh &
+.B watch -n 5 eval 'nfsstat -4 --since /tmp/stats; nfsstat -4 >/tmp/stats'
+.fi
+.RS
+Using
+.BR watch (1),
+show updates every 5 seconds of NFSv4 activity being tested by a user's
+.B run_long_test.sh
+script.
+.RE
+
 .\" --------------------- DISPLAY --------------------------------
 .SH DISPLAY
 The \fBFlags\fR output from the \fB\-m\fR option is the same as the
-- 
1.4.4

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
