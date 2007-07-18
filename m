From: "Steinar H. Gunderson" <sesse@debian.org>
Subject: [PATCH] Properly ignore quota options
Date: Wed, 18 Jul 2007 19:09:31 +0200
Message-ID: <20070718170931.GA30174@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IBD1r-0006SX-Er
	for nfs@lists.sourceforge.net; Wed, 18 Jul 2007 10:09:37 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IBD1t-0001EV-SO
	for nfs@lists.sourceforge.net; Wed, 18 Jul 2007 10:09:39 -0700
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766]
	helo=trofast.sesse.net)
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1IBD1n-0001Qk-GR
	for nfs@lists.sourceforge.net; Wed, 18 Jul 2007 19:09:31 +0200
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1IBD1n-0007r8-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Jul 2007 19:09:31 +0200
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

Now that NFS mounting has been taken over by nfs-utils, it seems like I've
gotten a few bugs on my hands. The included patch is based on a user
suggestion from about a year ago. It would be great if someone could also
check out these two bugs:

  http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=301955
  http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=301953


The mount(5) man page states that the noquota, quota, usrquota and
grpquota options are ignored. (They are, however, used by the quota
tools, so having them in fstab can be useful.) Make mount.nfs ignore
them properly, matching the man page. There are a few aliases (like
usrjquota) that are parsed by quota, but as these are not documented
nor seem to be widely used, they are not included.

Signed-off-by: Steinar H. Gunderson <sesse@debian.org>

Index: nfs-utils-1.1.0/utils/mount/mount.c
===================================================================
--- nfs-utils-1.1.0.orig/utils/mount/mount.c
+++ nfs-utils-1.1.0/utils/mount/mount.c
@@ -132,6 +132,10 @@ static const struct opt_map opt_map[] = 
   { "diratime", 0, 1, MS_NODIRATIME },  /* Update dir access times */
   { "nodiratime", 0, 0, MS_NODIRATIME },/* Do not update dir access times */
 #endif
+  { "noquota", 0, 0, MS_DUMMY },        /* Don't enforce quota */
+  { "quota", 0, 0, MS_DUMMY },          /* Enforce user quota */
+  { "usrquota", 0, 0, MS_DUMMY },       /* Enforce user quota */
+  { "grpquota", 0, 0, MS_DUMMY },       /* Enforce group quota */
   { NULL,	0, 0, 0		}
 };
 
/* Steinar */ 
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
