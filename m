From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: nfs disk utilization in terms of stress
Date: Wed, 23 Feb 2005 07:21:56 -0800
Message-ID: <482A3FA0050D21419C269D13989C611307CF4BFB@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D3yL1-0003KL-GS
	for nfs@lists.sourceforge.net; Wed, 23 Feb 2005 07:22:07 -0800
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D3yL0-0005QE-4u
	for nfs@lists.sourceforge.net; Wed, 23 Feb 2005 07:22:07 -0800
To: "Rock VZ" <rockvz@hotmail.com>
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

> I would like to know how to get  disk utilization stats (like=20
> the one iostat gives - %util) from a nfs client.

currently the nfs client does not provide any such capability.  i'm
developing it now in 2.6.

> With nfsstat -c I can get the read/write ratio but I am=20
> interested more in-terms of "stress".  For example
> I would like to calculate the stress average by taking the delta of =20
> /proc/net/rpc/nfs between 2 time intervals and calculate=20
> percentages based=20
> on total rpcs "possible" rather the rpcs that occured in that=20
> interval. i.e.
> Even if  only one rpc read call is made then based on nfsstat=20
> calculations=20
> it would show a 100% read but it does not mean that the mount=20
> point was 'fully utilized' in reading.

the only way i can think of doing this would be at the network level.
the maximum theoretical throughput of your network would be the "fully
utilized" baseline; then look at the network statistics on your clients
to see how much throughput was actually achieved.  for example, you can
get 12.5 MB/s on 100base-TX ethernet; if your NFS client is pushing 6.25
MB/s, then your utilization is 50%.  likewise on the server.
unfortunately, currently the kernel does not report the throughput of
just the NFS-generated network traffic.  this is an upcoming feature, as
i say, in some future release of 2.6.

there really is no way to determine a "maximum theoretical RPC
throughput."  in addition, you'll have to measure NFS server disk
utilization, which is also important to overall NFS performance, in some
other way.  and finally, using this method you aren't really measuring
the _efficiency_ of the NFS client -- is it generating an optimally
small number of operations and network bytes for the given application
workload?  that's a much harder question to answer.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
