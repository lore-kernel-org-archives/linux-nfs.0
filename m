From: Nathaniel Stahl <nrs@levanta.com>
Subject: Small mountd bug & potential fix
Date: Wed, 02 Mar 2005 17:01:48 -0800
Message-ID: <422661FC.2080701@levanta.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050707040003060003090900"
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D6gbB-0001XF-ID
	for nfs@lists.sourceforge.net; Wed, 02 Mar 2005 19:02:01 -0800
Received: from mail.levanta.com ([69.36.243.36] helo=mail.linuxcare.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D6elu-0002M5-U3
	for nfs@lists.sourceforge.net; Wed, 02 Mar 2005 17:05:43 -0800
Received: from [10.1.1.183] (cisco-6509.levanta.com [69.36.253.2] (may be forged))
	by mail.linuxcare.com (8.12.11/8.12.8) with ESMTP id j230m0CC029068
	for <nfs@lists.sourceforge.net>; Wed, 2 Mar 2005 16:48:00 -0800
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

This is a multi-part message in MIME format.
--------------050707040003060003090900
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


We have a management product that can manage a Linux-based NFS server to 
allocate and export storage to managed servers.  (Then automatically 
mount the storage on those servers so it can be used)

I was seeing a problem where sometimes the directory I was exporting 
would not be mountable on the server it was exported to.

 >From the server machine's /var/log/messages:
Mar 1 10:49:53 fedora3 rpc.mountd: refused mount request from 
172.31.183.2 for
/mnt/NAS/exports/Levanta-1109702993-18 (/): not exported

But according to exportfs:

[root@fedora3 ~]# exportfs
/mnt/NAS/exports/Levanta-1109702992-17
172.31.183.2
/mnt/NAS/exports/Levanta-1109702993-18
172.31.183.2
/mnt/NAS/exports/Levanta-0
172.31.183.2

It looks like exportfs updates /var/lib/nfs/etab to inform mountd that 
there are new exports.

mountd decides whether to re-read etab based on whether the data 
modification time has changed since it was last read.  This fails if 
there are multiple updates in a second - quite possible on fast new 
machines if the NFS server is being programmatically controlled.  This 
patch updates mountd to track when it actually read the file, and 
compare that with the file's modification time.  If it last read the 
file at the same time it was last modified, re-read the file again in 
case there were other modifications later that second.  (Strictly 
speaking, the modification time equal check isn't necessary... only 
comparing the modification time to the current time, but I guess isn't a 
bad idea as added protection against someone playing with the clock).

-Nate


--------------050707040003060003090900
Content-Type: text/x-patch;
 name="mountd-auth.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mountd-auth.patch"

--- /usr/src/redhat/SOURCES/nfs-utils-1.0.7/utils/mountd/auth.c	2004-12-05 16:46:40.000000000 -0800
+++ nfs-utils-1.0.7/utils/mountd/auth.c	2005-03-02 16:52:22.403733192 -0800
@@ -12,6 +12,7 @@
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <errno.h>
+#include <time.h>
 #include "misc.h"
 #include "nfslib.h"
 #include "exportfs.h"
@@ -49,12 +50,14 @@
 {
 	struct stat		stb;
 	static time_t		last_modified = 0;
+	static time_t		last_read = 0;
 
 	if (stat(_PATH_ETAB, &stb) < 0)
 		xlog(L_FATAL, "couldn't stat %s", _PATH_ETAB);
-	if (stb.st_mtime == last_modified)
+	if ((stb.st_mtime == last_modified) && (last_read > last_modified))
 		return 0;
 	last_modified = stb.st_mtime;
+	last_read = time(NULL);
 
 	export_freeall();
 	memset(&my_client, 0, sizeof(my_client));

--------------050707040003060003090900--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
