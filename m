From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] Fix 32bit statfs on NFS
Date: Mon, 5 Apr 2004 17:09:14 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040405150914.GT11477@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ZmUaFz6apKcXQszQ"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BAVjf-0000a1-HG
	for nfs@lists.sourceforge.net; Mon, 05 Apr 2004 08:10:03 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BAVje-0002AV-Vt
	for nfs@lists.sourceforge.net; Mon, 05 Apr 2004 08:10:03 -0700
To: akpm@osdl.org
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--ZmUaFz6apKcXQszQ
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

Hi Andrew,

the attached patch fixes a problem with the 32bit statfs call on NFS
file systems. Some NFS servers return a value of -1 for the f_files
and f_ffree. The current code would think this is a 64bit value that
cannot be converted to 32bits. Consequently, the system call would
always fail.

The patch adds two special if() to detect a value of -1 for f_files
and f_ffree.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 

--ZmUaFz6apKcXQszQ
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: attachment; filename=statfs-no-eoverflow

--- linux-2.6.4/fs/open.c.overflow	2004-04-01 22:22:25.000000000 +0200
+++ linux-2.6.4/fs/open.c	2004-04-01 22:27:13.000000000 +0200
@@ -57,10 +57,17 @@
 		memcpy(buf, &st, sizeof(st));
 	else {
 		if (sizeof buf->f_blocks == 4) {
-			if ((st.f_blocks | st.f_bfree |
-			     st.f_bavail | st.f_files | st.f_ffree) &
+			if ((st.f_blocks | st.f_bfree | st.f_bavail) &
 			    0xffffffff00000000ULL)
 				return -EOVERFLOW;
+			/* f_files and f_ffree may be -1; it's okay
+			 * to stuff that into 32 bits */
+			if (st.f_files != 0xffffffffffffffffULL
+			 && (st.f_files & 0xffffffff00000000ULL))
+				return -EOVERFLOW;
+			if (st.f_ffree != 0xffffffffffffffffULL
+			 && (st.f_ffree & 0xffffffff00000000ULL))
+				return -EOVERFLOW;
 		}
 
 		buf->f_type = st.f_type;

--ZmUaFz6apKcXQszQ--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
