From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] update manpages for showmount and mountd
Date: Wed, 20 Dec 2006 09:54:11 -0500 (EST)
Message-ID: <20061220145411.2DCEDC0189@mail.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gx2pm-0003LI-2d
	for nfs@lists.sourceforge.net; Wed, 20 Dec 2006 06:54:18 -0800
Received: from ms-smtp-01.southeast.rr.com ([24.25.9.100])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gx2pm-0001Wp-9g
	for nfs@lists.sourceforge.net; Wed, 20 Dec 2006 06:54:19 -0800
Received: from mail.poochiereds.net (cpe-071-070-159-068.nc.res.rr.com
	[71.70.159.68])
	by ms-smtp-01.southeast.rr.com (8.13.6/8.13.6) with ESMTP id
	kBKEsBaR014695
	for <nfs@lists.sourceforge.net>; Wed, 20 Dec 2006 09:54:12 -0500 (EST)
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This patch updates the manpages for showmount and mountd. It adds a
description of the new mountd option, and a caveat about the unreliability
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
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
