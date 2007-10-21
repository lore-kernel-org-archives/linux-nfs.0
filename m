From: "Steinar H. Gunderson" <sesse@debian.org>
Subject: [PATCH] Fix logging segfaults on amd64
Date: Sun, 21 Oct 2007 13:02:57 +0200
Message-ID: <20071021110257.GA24016@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IjYaO-0002qG-9p
	for nfs@lists.sourceforge.net; Sun, 21 Oct 2007 04:03:12 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IjYaF-0001MN-Tu
	for nfs@lists.sourceforge.net; Sun, 21 Oct 2007 04:03:05 -0700
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766]
	helo=trofast.sesse.net) by cassarossa.samfundet.no with esmtps
	(TLS-1.0:RSA_AES_256_CBC_SHA1:32) (Exim 4.63)
	(envelope-from <sesse@samfundet.no>) id 1IjYaA-0005R7-Ng
	for nfs@lists.sourceforge.net; Sun, 21 Oct 2007 13:02:59 +0200
Received: from root by trofast.sesse.net with local (Exim 4.68)
	(envelope-from <sesse@samfundet.no>) id 1IjYa9-0006Fy-AC
	for nfs@lists.sourceforge.net; Sun, 21 Oct 2007 13:02:57 +0200
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

It seems an error crept into nfs-utils 1.1.1 just before release, so exportfs
-r segfaults on amd64 whenever there is a warning. The attached patch, from
Steve Langasek, fixes the issue (an abuse of va_list).

Signed-off-by: Steinar H. Gunderson <sesse@debian.org>
Signed-off-by: Steve Langasek <vorlon@debian.org>

--- nfs-utils-1.1.1.orig/support/nfs/xlog.c
+++ nfs-utils-1.1.1/support/nfs/xlog.c
@@ -133,9 +133,13 @@ xlog_enabled(int fac)
 void
 xlog_backend(int kind, const char *fmt, va_list args)
 {
+       va_list args2;
+
        if (!(kind & (L_ALL)) && !(logging && (kind & logmask)))
                return;

+       va_copy(args2, args);
+
        if (log_syslog) {
                switch (kind) {
                case L_FATAL:
@@ -172,10 +176,12 @@ xlog_backend(int kind, const char *fmt, 
                fprintf(stderr, "%s: ", log_name);
 #endif

-               vfprintf(stderr, fmt, args);
+               vfprintf(stderr, fmt, args2);
                fprintf(stderr, "\n");
        }

+       va_end(args2);
+
        if (kind == L_FATAL)
                exit(1);
 }

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
