From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: nfs/rdma
Date: Thu, 16 Dec 2004 07:52:56 -0800
Message-ID: <482A3FA0050D21419C269D13989C611307CF4B8D@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cexw7-0005Y2-Hc
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 07:53:03 -0800
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Cexw6-0005wa-Ot
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 07:53:03 -0800
To: "kaushik" <karandikar.kaushik@spsoftindia.com>
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

> I want to use the NFS/RDMA protocol for faster file access=20
> and to reduce the CPU time.How NFS is well supported for RDMA=20
> protocol? My NFS Server will be on MAC Os 10.3.Does my=20
> NFS/RDMA Linux client will work? I have both  the NICs those=20
> are RDMA compliant. I am new to this. Please guide me.

although currently under development, the Linux NFS client does not yet
support RDMA directly, nor does it currently support network protocol
offload.  i am also not aware of any plans for MacOS to support an
RDMA-capable NFS server.

in fact the MacOS server is only marginally supported with the Linux NFS
client because of bugs in that server.  in addition, i don't expect that
server to be fast enough to allow the client to take advantage of the
kind of performance that RDMA provides.

if you have measurements that show that the Linux NFS client is
consuming inappropriate amounts of CPU, please post those to the list,
and we will try to help.  there is one known problem with CPU
consumption with random write-intensive workloads on large files; there
is no workaround for this problem at present.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
