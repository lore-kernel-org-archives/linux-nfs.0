From: James Pearson <james-p@moving-picture.com>
Subject: rpc.mountd: getfh failed: Operation not permitted
Date: Fri, 23 Jan 2004 13:26:59 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40112123.D2A8518D@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ak1L3-0002jW-4s
	for nfs@lists.sourceforge.net; Fri, 23 Jan 2004 05:27:09 -0800
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Ak1L2-0001Kn-N6
	for nfs@lists.sourceforge.net; Fri, 23 Jan 2004 05:27:08 -0800
Received: from darke.mpc.local ([172.16.11.6] helo=moving-picture.com)
	by moving-picture.com with esmtp (Exim 4.24)
	id 1Ak1Kt-00017B-97
	for nfs@lists.sourceforge.net; Fri, 23 Jan 2004 13:26:59 +0000
To: nfs@lists.sourceforge.net
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

I have a strange problem with an NFS client that can not mount file
systems from some NFS servers.

e.g.:

mount clark:/disk1 /mnt/tmp
mount: clark:/disk1 failed, reason given by server: Permission denied

The server logs:

Jan 23 12:56:02 clark rpc.mountd: authenticated mount request from
rc0478:623 for /disk1 (/disk1) 
Jan 23 12:56:02 clark rpc.mountd: getfh failed: Operation not permitted 


However, doing:

mount clark:/disk2 /mnt/tmp

works fine - after this mount, /proc/mounts shows:

clark:/disk2 /mnt/tmp nfs
rw,v3,rsize=32768,wsize=32768,hard,udp,lock,addr=clark 0 0


On the server, /disk1 and /disk2 are separate disks exported in exactly
the same way:

/disk1 *(rw)
/disk2 *(rw)


The server is running a 2.4.19 based kernel with nfs-utils v0.3.3
(RedHat 7.2) (all a bit old, but they work fine)

The same client (running a 2.4.23 based kernel) is having the same
problem with a few other servers (but not all). Some of these other
servers are running a 2.4.21 based kernel.

However, every other client (100's of them) has no problems mounting
these same filesystems.

Any ideas?

Thanks

James Pearson


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
