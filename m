From: Greg Banks <gnb@sgi.com>
Subject: [PATCH 2.6] SGI 901086: NFSv2 SETATTR current server time support
Date: Fri, 28 May 2004 20:10:49 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040528101049.GF9014@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTeKJ-0001Nm-Cf
	for nfs@lists.sourceforge.net; Fri, 28 May 2004 03:10:59 -0700
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx2.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BTeKI-0000gL-Rp
	for nfs@lists.sourceforge.net; Fri, 28 May 2004 03:10:58 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

G'day,

This is the 2.6 version of the client side NFSv2 SETATTR current
server time patch.  This is the first send.

SGI bug 901086.

In the NFSv3 RFC, the sattr3 structure passed in the SETATTR call allows
for the client to request that the mtime and/or atime of an inode be set
to the current server time, the given (client) time, or not changed.  The
set-to-current-server value is used when you run "touch file" on the client.

This is significant for two reasons.  First, if there is clock skew between
the client and server there are times when you want the server time.  Secondly, the filesystem permissions checks for the two cases are actually different:
setting to an explicit time requires the setting process to own the file (or
be root), but setting to the current time requires only that the file be
writable to the process (or the process be root).

The NFSv2 RFC defines no such encoding for the sattr structure.  However
Solaris and Irix machine obey a convention where passing the invalid value
mtime.useconds=1000000 means "set both mtime and atime to the current
server time".  The convention is documented in the book "NFS Illustrated"
by Brent Callaghan.  The patch below implements this convention for the
Linux client and server (hence multiple To:s).

Tested between ia64 Linux 2.6.4 Irix & Solaris.


--- linux.orig/fs/nfs/nfs2xdr.c	Fri May 28 18:20:02 2004
+++ linux/fs/nfs/nfs2xdr.c	Fri May 28 19:36:48 2004
@@ -95,6 +95,23 @@
 }
 
 static inline u32*
+xdr_encode_current_server_time(u32 *p, struct timespec *timep)
+{
+	/*
+	 * Passing the invalid value useconds=1000000 is a
+	 * Sun convention for "set to current server time".
+	 * It's needed to make permissions checks for the
+	 * "touch" program across v2 mounts to Solaris and
+	 * Irix boxes work correctly. See description of
+	 * sattr in section 6.1 of "NFS Illustrated" by
+	 * Brent Callaghan, Addison-Wesley, ISBN 0-201-32750-5
+	 */
+	*p++ = htonl(timep->tv_sec);
+	*p++ = htonl(1000000);
+	return p;
+}
+
+static inline u32*
 xdr_decode_time(u32 *p, struct timespec *timep)
 {
 	timep->tv_sec = ntohl(*p++);
@@ -142,15 +159,19 @@
 	SATTR(p, attr, ATTR_GID, ia_gid);
 	SATTR(p, attr, ATTR_SIZE, ia_size);
 
-	if (attr->ia_valid & (ATTR_ATIME|ATTR_ATIME_SET)) {
+	if (attr->ia_valid & ATTR_ATIME_SET) {
 		p = xdr_encode_time(p, &attr->ia_atime);
+	} else if (attr->ia_valid & ATTR_ATIME) {
+		p = xdr_encode_current_server_time(p, &attr->ia_atime);
 	} else {
 		*p++ = ~(u32) 0;
 		*p++ = ~(u32) 0;
 	}
 
-	if (attr->ia_valid & (ATTR_MTIME|ATTR_MTIME_SET)) {
+	if (attr->ia_valid & ATTR_MTIME_SET) {
 		p = xdr_encode_time(p, &attr->ia_mtime);
+	} else if (attr->ia_valid & ATTR_MTIME) {
+		p = xdr_encode_current_server_time(p, &attr->ia_mtime);
 	} else {
 		*p++ = ~(u32) 0;	
 		*p++ = ~(u32) 0;


Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
