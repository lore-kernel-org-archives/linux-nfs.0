From: "Jose R. Santos" <jrsantos@austin.ibm.com>
Subject: dentry/inode cache invalidation when using nfsd filesystem on 2.6
Date: Tue, 21 Oct 2003 08:07:02 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031021130702.GQ1516@dbz.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; Format=Flowed; DelSp=Yes; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1ACI0Z-0007ep-00
	for <nfs@lists.sourceforge.net>; Wed, 22 Oct 2003 05:22:35 -0700
Received: from e35.co.us.ibm.com ([32.97.110.133])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 1ABwHP-0007H3-4d
	for nfs@lists.sourceforge.net; Tue, 21 Oct 2003 06:10:31 -0700
Received: from westrelay04.boulder.ibm.com (westrelay04.boulder.ibm.com [9.17.193.32])
	by e35.co.us.ibm.com (8.12.10/8.12.2) with ESMTP id h9LD6jIl426844
	for <nfs@lists.sourceforge.net>; Tue, 21 Oct 2003 09:06:45 -0400
Received: from austin.ibm.com (d03av02.boulder.ibm.com [9.17.193.82])
	by westrelay04.boulder.ibm.com (8.12.9/NCO/VER6.6) with ESMTP id h9LD6hEp139722
	for <nfs@lists.sourceforge.net>; Tue, 21 Oct 2003 07:06:44 -0600
Received: from dbz (jsantos@dbz.austin.ibm.com [9.41.90.53])
	by austin.ibm.com (8.12.10/8.12.10) with ESMTP id h9LD6hZL036450
	for <nfs@lists.sourceforge.net>; Tue, 21 Oct 2003 08:06:43 -0500
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi,

I have come across a interesting behavior when using NFS server on machines  
with large amounts of memory(16/32Gb).  If I have exported filesystems with  
lots of data and many directories that were access and had dentry/inode cache  
entries cached on the server, the clients took a long time(sometimes minutes)  
to mount the NFS exported directories.

While the client was mostly IDLE, the servers rpc.mountd thread was consuming  
100% of one CPU on the system.  After some digging, I found that the problem  
lies on the new nfsd filesystem code that talks to nfsctl.  Every time I issue  
a mount on the client, the server invalidates both inode and dentry caches.

Inode cache get invalidated on sys_nfsservctl(fs/nfsctl.c) on the fput call  
which eventually calls invalidate_inodes. Dentry caches get invalidated on  
do_open(fs/nfsctl.c) when calling do_kernel_mount which eventually calls  
shrink_dcache_sb.

The inode cache invalidation is easy to work around by just mounting the nfsd  
to something like /tmp/nfsd, but I haven't been able(except with a very  
dangerous and stupid patch) to work around the dentry cache invalidation.

This invalidation seem unnecessary and it cause by the interaction with this  
new interface for nfsctl.

Any help would be appreciated. :)

Thanks - JRS


-------------------------------------------------------
This SF.net email is sponsored by OSDN developer relations
Here's your chance to show off your extensive product knowledge
We want to know what you know. Tell us and you have a chance to win $100
http://www.zoomerang.com/survey.zgi?HRPT1X3RYQNC5V4MLNSV3E54
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
