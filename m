From: Olaf Kirch <okir@suse.de>
Subject: Small patch to nfs.5 manpage
Date: Mon, 22 Mar 2004 16:47:33 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040322154733.GF23862@suse.de>
References: <20040322143922.GA2452@posern.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="IS0zKkzwUGydFO0o"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B5ReM-0003HO-K8
	for nfs@lists.sourceforge.net; Mon, 22 Mar 2004 07:47:38 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B5ReK-00068K-Oi
	for nfs@lists.sourceforge.net; Mon, 22 Mar 2004 07:47:37 -0800
To: util-linux@math.uio.no
In-Reply-To: <20040322143922.GA2452@posern.org>
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


--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

Hi Andries,

As the limitation on the number of auxiliary groups obviously
baffles people again and again, I thought it might be useful
to document this limitation in nfs(5).

Please find attached a small patch to nfs.5 that adds a small
section on NFS authentication. It also updates the manpage
slightly: cto and tcp are implemented now, and broken_suid
was missing.

Cheers,
Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 

--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: attachment; filename="nfs-auth-doc.patch"

--- util-linux-2.12/mount/nfs.5.okir	2004-03-22 16:26:31.000000000 +0100
+++ util-linux-2.12/mount/nfs.5	2004-03-22 16:43:38.000000000 +0100
@@ -213,10 +213,45 @@
 NFS version 3. (On NFS version 2 filesystems this option has no effect.)
 This option also deactivates the GETACL and SETACL remote procedure calls
 which are otherwise used to manipulate ACLs.
+.TP 1.5i
+.I broken_suid
+This option tries to help applications that are a little careless
+in dealing with effective vs real user and group ID. See below in
+section
+.IR "NFS Authentication" .
 .P
 All of the non-value options have corresponding nooption forms.
 For example, nointr means don't allow file operations to be
 interrupted.
+.SS NFS Authentication
+NFS currently supports only the AUTH_SYS RPC authentication flavor,
+which basically transmits the user's user and group ID to the server,
+along with the list of supplementary groups. However, this doesn't
+transport the full set of user credentials to the server, so that some
+operations may fail with a permission error, which would have succeeded
+on a local file system.
+.P
+One limitation of AUTH_SYS authentication is that not the full set of
+user and group ids are transmitted. By default, only the fsuid and fsgid
+and the auxiliary group vector are transmitted. (fsuid and fsgid mostly
+reflect the effective uid and gid, but can differ in special cases,
+see
+.BR setfsuid (2)
+for details).
+.P
+If this behavior causes certain applications to break, it may help to
+enable the
+.B broken_suid
+mount option. This tells the NFS client to retry an operation with
+the real uid and gid if it fails using the fsuid and fsgid.
+.P
+Another common problem occurs when users have a large number of
+auxiliary groups. The AUTH_SYS flavor limits the number of auxiliary
+groups that can be transmitted to 16. Additional groups are simply
+ignored, and may cause operations to fail which would otherwise be
+allowed based on the user's group membership.
+The only fix for this problem is to limit the number of groups the user
+is part of.
 .SH FILES
 .I /etc/fstab
 .SH "SEE ALSO"
@@ -224,11 +259,7 @@
 .SH AUTHOR
 "Rick Sladkey" <jrs@world.std.com>
 .SH BUGS
-The posix, and nocto options are parsed by mount
-but currently are silently ignored.
-.P
-The tcp and namlen options are implemented but are not currently
-supported by the Linux kernel.
+The posix option is parsed by mount but is currently ignored by the kernel.
 .P
 The umount command should notify the server
 when an NFS filesystem is unmounted.

--IS0zKkzwUGydFO0o--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
