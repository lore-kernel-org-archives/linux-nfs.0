From: Peter Whysall <peter.whysall@serco.com>
Subject: OpenVMS clients, Linux servers, Version 3, Oh my!
Date: Wed, 10 Sep 2003 12:45:26 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1063194326.2137.52.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19x3Pj-0007yB-00
	for <nfs@lists.sourceforge.net>; Wed, 10 Sep 2003 04:45:35 -0700
Received: from porky.serco.com ([195.50.81.243])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19x3Pi-000319-Sh
	for nfs@lists.sourceforge.net; Wed, 10 Sep 2003 04:45:35 -0700
Received: from [10.22.1.247] (helo=mail2.technology.serco.com)
	by porky.serco.com with esmtp (Exim 4.12)
	id 19x3PC-0003tH-01
	for nfs@lists.sourceforge.net; Wed, 10 Sep 2003 12:45:02 +0100
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

Objective - have an OpenVMS client mount an export on a Linux server
using NFS version 3.

I have a Red Hat Enterprise Linux WS 2.1 box acting as NFS server;
running kernel 2.4.9-e.27 with nfs-utils 0.3.3 and all errata applied.

In /etc/sysconfig/nfs I have set MOUNTD_NFS_V2=no.

At the client end, it's OVMS 7.3-1 with TCP/IP services 5.3.

The command line used to mount the export is:

$ tcpip mount dnfs1: /sys /struct=5 /host=nfstest /uid=501 /gid=501
/path="/export/mount_point"

At this point I should point out that there is not a switch to indicate
which version of NFS you want to use.

The output of rpcinfo -p on the server indicates that rpc.mountd is only
offering v3 mounts, but rpc.nfsd is offering v2 and v3.

Somehow, despite mountd's best efforts, the VMS box manages to mount the
export with v2; nfsstat indicates that all the activity is in the v2
section.

Can anyone shed any light on this?

Many thanks

Peter.
-- 
Peter Whysall <peter.whysall@serco.com>





-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
