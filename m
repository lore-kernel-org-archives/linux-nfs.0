From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Linux client on Solaris 7 NFS server
Date: Mon, 29 Dec 2003 08:49:05 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07AFF@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1Ab0a3-0007p8-P0
	for nfs@lists.sourceforge.net; Mon, 29 Dec 2003 08:49:23 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ab0a3-0004uc-HA
	for nfs@lists.sourceforge.net; Mon, 29 Dec 2003 08:49:23 -0800
To: "Wade Hampton" <wade.hampton@nsc1.net>
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

> Also, if my Fedora box is accessing the server via a WAN,
> should I use NFS over TCP/IP?   If my network goes down,
> do I have to unmount and remount if I am using TCP/IP?

yes, you should use TCP when running NFS over a WAN.

generally on these late kernels network partitions will
not cause issues that require a umount/remount sequence.
if you are unsure about the reliability of TCP, may i
suggest you use it with the "soft" mount option and a
high retrans setting (see the "mount" and "nfs" man pages).

(and btw, i agree with steve, if you can reproduce this
problem and capture a network trace, that would be helpful:
use "tcpdump -s0 -w /tmp/dump host server-name-here" to
capture a raw network trace).


-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
