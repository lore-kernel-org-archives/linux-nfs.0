From: Jeremy Sanders <jss@ast.cam.ac.uk>
Subject: rebooting server
Date: Thu, 23 Jan 2003 18:41:32 +0000 (GMT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.53.0301231834070.1796@xpc1.ast.cam.ac.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rose.csi.cam.ac.uk ([131.111.8.13])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18bmIi-0004iH-00
	for <nfs@lists.sourceforge.net>; Thu, 23 Jan 2003 10:42:09 -0800
Received: from cass41.ast.cam.ac.uk ([131.111.69.186])
	by rose.csi.cam.ac.uk with esmtp (Exim 4.10)
	id 18bmI8-0005we-00
	for nfs@lists.sourceforge.net; Thu, 23 Jan 2003 18:41:32 +0000
Received: from xserv1.ast.cam.ac.uk (IDENT:EoEktBM8NrDLrvSRsEJur5ud6qq/cbkT@xserv1.ast.cam.ac.uk [131.111.69.235])
	by cass41.ast.cam.ac.uk (8.12.5+Sun/8.12.5) with ESMTP id h0NIfWNS009622
	for <nfs@lists.sourceforge.net>; Thu, 23 Jan 2003 18:41:32 GMT
Received: from xpc1.ast.cam.ac.uk (IDENT:MYTDbsfC63AaPqtWwhhcDkPkNQcPOWdr@xpc1.ast.cam.ac.uk [131.111.68.219])
	by xserv1.ast.cam.ac.uk (8.11.6/8.11.6) with ESMTP id h0NIfWU02264
	for <nfs@lists.sourceforge.net>; Thu, 23 Jan 2003 18:41:32 GMT
To: nfs@lists.sourceforge.net
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

Hi

We had to reboot our linux NFS server today (RedHat kernel-2.4.18-17.7.x)
to fix a disk in our RAID array. When the server came back, clients
running this kernel (or ...-19.7.x) couldn't see the exported directory
(giving permission denied). In the client logs we saw

Jan 23 17:46:16 xpc1 kernel: nfs_statfs: statfs error = 13
Jan 23 17:46:16 xpc1 kernel: nfs_statfs: statfs error = 13

Rebooting the clients fixed the problem, however we don't really want this
to happen in the future if the server dies.

The server was shut down cleanly. The /etc/exports file looks like

/dir @netgroup(rw,no_root_squash)

The exported directory is mounted using autofs, with maps supplied using
NIS.

The clients use the following options (in /proc/mounts).
server:/dir /mntpoint/dir nfs
rw,v3,rsize=4096,wsize=4096,hard,intr,udp,lock,addr=server.blah 0 0

Any ideas? Is it simply that the RedHat kernel has bugs? NFS utils is at
nfs-utils-0.3.3-5. Restarting /etc/rc.d/init.d/nfslock on the clients
didn't help, nor sending HUP signals to any of the rpc processes.

Thanks

Jeremy

-- 
Jeremy Sanders <jss@ast.cam.ac.uk>   http://www-xray.ast.cam.ac.uk/~jss/
X-Ray Group, Institute of Astronomy, University of Cambridge, UK.
Public Key Server PGP Key ID: E1AAE053


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
