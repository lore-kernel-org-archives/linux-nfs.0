From: "Steinar H. Gunderson" <sesse@debian.org>
Subject: [PATCH] Clarify language in man exportfs
Date: Mon, 29 Oct 2007 19:04:43 +0100
Message-ID: <20071029180443.GA6109@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ImYyp-0004ez-ES
	for nfs@lists.sourceforge.net; Mon, 29 Oct 2007 11:04:51 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ImYyq-0001w7-GK
	for nfs@lists.sourceforge.net; Mon, 29 Oct 2007 11:04:57 -0700
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766]
	helo=trofast.sesse.net) by cassarossa.samfundet.no with esmtps
	(TLS-1.0:RSA_AES_256_CBC_SHA1:32) (Exim 4.63)
	(envelope-from <sesse@samfundet.no>) id 1ImYyl-0001xJ-0J
	for nfs@lists.sourceforge.net; Mon, 29 Oct 2007 19:04:47 +0100
Received: from root by trofast.sesse.net with local (Exim 4.68)
	(envelope-from <sesse@samfundet.no>) id 1ImYyh-0001au-35
	for nfs@lists.sourceforge.net; Mon, 29 Oct 2007 19:04:43 +0100
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

(I still have two pending minor patches, by the way :-) )

As discussed in a user case earlier, the wording in the exportfs man page can
be a bit confusing, implying that "exportfs -u :/foo" will unexport /foo from
all hosts, which it won't. Thus, make the language clearer -- based on
suggestion/patch from David Liontooth.

Signed-off-by: Steinar H. Gunderson <sesse@debian.org>

--- nfs-utils-1.1.1.orig/utils/exportfs/exportfs.man
+++ nfs-utils-1.1.1/utils/exportfs/exportfs.man
@@ -167,11 +167,13 @@ all entries listed in
 are removed from the kernel export tables, and the file is cleared. This
 effectively shuts down all NFS activity.
 .P
-To remove individual export entries, one can specify a
+To remove an export to a host, specify a
 .I host:/path
 pair. This deletes the specified entry from
 .B xtab
 and removes the corresponding kernel entry (if any).
+To remove one or more exports to several hosts, use
+.BR "exportfs -ua" .
 .P
 .\" -------------------- Dumping the Export Table -----------------
 .SS Dumping the Export Table 

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
