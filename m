From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: nfs/rdma
Date: Fri, 17 Dec 2004 06:47:31 -0800
Message-ID: <482A3FA0050D21419C269D13989C611307CF4B91@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CfJOM-0003AW-PR
	for nfs@lists.sourceforge.net; Fri, 17 Dec 2004 06:47:38 -0800
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CfJOL-0000DR-Fp
	for nfs@lists.sourceforge.net; Fri, 17 Dec 2004 06:47:38 -0800
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

> I want to know that=20
> there is NFS/RDMA Linux client , so will it work with the NFS=20
> Server say which is also on other Linux machine.

currently there are no productized RDMA-enabled NFS servers anywhere.
there are two server prototypes i am aware of, neither of which are open
source.

to take advantage of RDMA, both client *and* server must support direct
data placement.  that is a significant modification of the RPC client
and server.  we are working towards that goal now, but we won't have
anything for quite some time on Linux.

> Can u explain or suggest any document which explains NFS/RDMA
> Client -Server architecture? I have to see whether i can port
> the NFS/RDMA Linux Client on to MAC Osx.

there are three internet drafts available describing NFS/RDMA and
proposing NFSv4 sessions to help manage RDMA transports.  use google and
search for "Talpey NFS RDMA" (Talpey is one of the authors of these
drafts).

the open source Linux NFS/RDMA project is described here:

http://www.citi.umich.edu/projects/rdma/


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
