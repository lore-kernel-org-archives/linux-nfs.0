From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] nfs-utils: update manpages for showmount and mountd
Date: Mon, 7 May 2007 07:53:32 -0400
Message-ID: <20070507115328.GA26568@salusa.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hl1ma-0005eI-DL
	for nfs@lists.sourceforge.net; Mon, 07 May 2007 04:53:36 -0700
Received: from ms-smtp-04.southeast.rr.com ([24.25.9.103])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hl1mc-0008EV-Md
	for nfs@lists.sourceforge.net; Mon, 07 May 2007 04:53:39 -0700
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

Hi Neil, I sent this patch ~December, but I see that it never got picked up
in nfs-utils git tree.

This patch updates the manpages for showmount and mountd. It adds a
description of the new mountd -r option, and a caveat about the unreliability
of showmount -a.

Signed-off-by: Jeff Layton <jlayton@redhat.com>

diff --git a/utils/mountd/mountd.man b/utils/mountd/mountd.man
index 70166c1..2d8904e 100644
--- a/utils/mountd/mountd.man
+++ b/utils/mountd/mountd.man
@@ -125,6 +125,13 @@ If this option is not specified the default of
 .BR /var/lib/nfs
 is used.
 .TP
+.BI "\-r," "" " \-\-reverse\-lookup"
+mountd tracks IP addresses in the rmtab, and when a DUMP request is made (by
+someone running showmount -a, for instance), it returns IP addresses instead
+of hostnames by default. This option causes mountd to do a reverse
+lookup on each IP address and return that hostname instead. Enabling this can
+have a substantial negative effect on performance in some situations.
+.TP
 .BR "\-t N" " or " "\-\-num\-threads=N"
 This option specifies the number of worker threads that rpc.mountd
 spawns.  The default is 1 thread, which is probably enough.  More
diff --git a/utils/showmount/showmount.man b/utils/showmount/showmount.man
index 30c9d82..8effd27 100644
--- a/utils/showmount/showmount.man
+++ b/utils/showmount/showmount.man
@@ -25,8 +25,10 @@ appear as though it were processed through ``sort -u''.
 .SH OPTIONS
 .TP
 .BR \-a " or " \-\-all
-List both the client hostname and mounted directory in
-host:dir format.
+List both the client hostname or IP address and mounted directory in
+host:dir format. This info should not be considered reliable. See the notes
+on rmtab in 
+.BR rpc.mountd (8).
 .TP
 .BR \-d " or " \-\-directories
 List only the directories mounted by some client.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
