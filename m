From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [RFC Patch 00/09] NFS/RDMA client
Date: Wed, 11 Jul 2007 17:06:56 -0400
Message-ID: <EXNANE013melfSudpuo00000c5f@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I8jQ5-00021d-ND
	for nfs@lists.sourceforge.net; Wed, 11 Jul 2007 14:08:21 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I8jQ8-0003YL-7e
	for nfs@lists.sourceforge.net; Wed, 11 Jul 2007 14:08:25 -0700
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com
	[10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l6BL8Ihc018933
	for <nfs@lists.sourceforge.net>; Wed, 11 Jul 2007 14:08:18 -0700 (PDT)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

The following 9 messages implement the NFS/RDMA client,
and are RFC at this time, though many of you have seen
them before. They represent a long cycle of development!

The patches are applied against 2.6.22, and are tested on
both Infiniband (Mellanox) and iWARP (Chelsio) RDMA providers,
using NFSv3 and NFSv4. The changes are almost completely
in the RPC (net/sunrpc) layer, only one line is changed in NFS,
to allow NFSv4 mounts to work on a non-IPv4 server.

The first 5 (patches 01 through 05) are prerequisites for
integration into 2.6.22. 01, 02 and 03 are from Chuck Lever
and implement dynamic RPC transport switch modules,
allowing RPCRDMA to be added. 04 and 05 are small and
allow NFS/RDMA mounts to proceed on non-UDP, non-TCP
protocols.

The 6th (patch 06) is the rpcrdma protocol header file, this
file is also a part of Tom Tucker's knfsd/RDMA submission,
and is included here for completeness.

The remaining three (patches 07, 08 and 09) implement the
RPCRDMA transport. They are organized into three components,
the core configuration and transport implementation, the rpcrdma
protocol handling, and the RDMA verbs interfacing. Patch 07 has
stub versions of two files, which (hopefully) provides clarity but
also allows building the patch cleanly.

Comments are welcome.

Tom.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
