From: "david m. richter" <richterd@citi.umich.edu>
Subject: [PATCH 5/5] nfsstat: include -Z/--sleep in the manpage
Date: Tue, 7 Aug 2007 19:53:48 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0708071949541.26009@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIYrw-0006QI-S4
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 16:53:45 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IIYs0-0006Du-RM
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 16:53:49 -0700
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

	Add a little blurb about -Z/--sleep to the nfsstat manpage.

Signed-off-by: David M. Richter <richterd@citi.umich.edu>

---
 utils/nfsstat/nfsstat.man |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/utils/nfsstat/nfsstat.man b/utils/nfsstat/nfsstat.man
index 895c36b..b17f76e 100644
--- a/utils/nfsstat/nfsstat.man
+++ b/utils/nfsstat/nfsstat.man
@@ -2,7 +2,7 @@
 .\" nfsstat(8)
 .\" 
 .\" Copyright (C) 1996-2005 Olaf Kirch <okir@suse.de>
-.TH nfsstat 8 "11 Apr 2005"
+.TH nfsstat 8 "7 Aug 2007"
 .SH NAME
 nfsstat \- list NFS statistics
 .SH SYNOPSIS
@@ -71,6 +71,16 @@ Display all of the above facilities.
 .TP
 .B \-v, \-\-verbose
 This is equivalent to \fB\-o all\fR.
+.TP
+.B \-Z, \-\-sleep
+Instead of printing statistics and immediately exiting,
+.B nfsstat
+takes a snapshot of the current statistics and pauses until it receives
+.B SIGINT
+(typically from
+.BR Ctrl-C ),
+at which point it takes another snapshot and displays the difference 
+between the two.
 .SH EXAMPLES
 .TP
 .B nfsstat \-o all \-234
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
