From: "Steinar H. Gunderson" <sesse@debian.org>
Subject: [PATCH] gssd(8) manpage typo
Date: Wed, 25 Jul 2007 20:54:43 +0200
Message-ID: <20070725185443.GA24265@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDm0S-0000vs-9n
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 11:54:44 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IDm0U-0003O8-TM
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 11:54:48 -0700
Received: from trofast.sesse.net ([129.241.93.32])
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1IDm0R-0000wk-6W
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 20:54:43 +0200
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1IDm0R-0006Jk-00
	for <nfs@lists.sourceforge.net>; Wed, 25 Jul 2007 20:54:43 +0200
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

Hi,

This patch came in from a user; it's a trivial typo fix in the gssd man page.
I doubt a Signed-off-by line is required for it. :-)

Index: nfs-utils-1.1.0/utils/gssd/gssd.man
===================================================================
--- nfs-utils-1.1.0.orig/utils/gssd/gssd.man
+++ nfs-utils-1.1.0/utils/gssd/gssd.man
@@ -35,7 +35,7 @@ With the \-n option, "machine credential
 for accesses by UID 0.  Instead, credentials must be obtained
 manually like all other users.  Use of this option means that
 "root" must manually obtain Kerberos credentials before
-attemtpting to mount an nfs filesystem requiring Kerberos
+attempting to mount an nfs filesystem requiring Kerberos
 authentication.
 .TP
 .B -k keytab

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
