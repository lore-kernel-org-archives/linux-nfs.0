From: kaushik <karandikar.kaushik@spsoftindia.com>
Subject: RE: nfs/rdma
Date: 01 Jan 2000 00:18:51 +0530
Message-ID: <946666131.1095.6.camel@kaushik>
References: <482A3FA0050D21419C269D13989C611307CF4B8D@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cf9tK-0002d3-GP
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 20:38:58 -0800
Received: from [203.187.215.134] (helo=spsoftindia.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Cf9tJ-0000Ze-IK
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 20:38:58 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611307CF4B8D@lavender-fe.eng.netapp.com>
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

Hi All,
	Thanks for your immediate support. I want to know that there is
NFS/RDMA Linux client , so will it work with the NFS Server say which is
also on other Linux machine.As they talks about the performance of
350MB/s with RDMA compliant NICs in both the machines. 
How NFS server side works with RDMA as there is no NFS/RDMA Server
available. 
Can u explain or suggest any document which explains NFS/RDMA Client
-Server architecture?
I have to see whether i can port the NFS/RDMA Linux Client on to MAC
Osx.
Please give me some guidelines on this.


Thank You
Kaushik
 


On Thu, 2004-12-16 at 21:22, Lever, Charles wrote:
> > I want to use the NFS/RDMA protocol for faster file access 
> > and to reduce the CPU time.How NFS is well supported for RDMA 
> > protocol? My NFS Server will be on MAC Os 10.3.Does my 
> > NFS/RDMA Linux client will work? I have both  the NICs those 
> > are RDMA compliant. I am new to this. Please guide me.
> 
> although currently under development, the Linux NFS client does not yet
> support RDMA directly, nor does it currently support network protocol
> offload.  i am also not aware of any plans for MacOS to support an
> RDMA-capable NFS server.
> 
> in fact the MacOS server is only marginally supported with the Linux NFS
> client because of bugs in that server.  in addition, i don't expect that
> server to be fast enough to allow the client to take advantage of the
> kind of performance that RDMA provides.
> 
> if you have measurements that show that the Linux NFS client is
> consuming inappropriate amounts of CPU, please post those to the list,
> and we will try to help.  there is one known problem with CPU
> consumption with random write-intensive workloads on large files; there
> is no workaround for this problem at present.




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
