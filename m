From: "Rock VZ" <rockvz@hotmail.com>
Subject: nfs disk utilization in terms of stress
Date: Tue, 22 Feb 2005 21:54:15 -0800
Message-ID: <BAY12-F108C7E0E50EEB167828141D6630@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D3pUw-0000mA-Ow
	for nfs@lists.sourceforge.net; Tue, 22 Feb 2005 21:55:46 -0800
Received: from bay12-f10.bay12.hotmail.com ([64.4.35.10] helo=hotmail.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D3pUv-0007QP-Cf
	for nfs@lists.sourceforge.net; Tue, 22 Feb 2005 21:55:46 -0800
To: nfs@lists.sourceforge.net
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

Hi,

I would like to know how to get  disk utilization stats (like the one iostat 
gives - %util) from a nfs client.
With nfsstat -c I can get the read/write ratio but I am interested more 
in-terms of "stress".
For example
I would like to calculate the stress average by taking the delta of  
/proc/net/rpc/nfs between 2 time intervals and calculate percentages based 
on total rpcs "possible" rather the rpcs that occured in that interval.
i.e.
Even if  only one rpc read call is made then based on nfsstat calculations 
it would show a 100% read but it does not mean that the mount point was 
'fully utilized' in reading.

How can I know the max. rpc calls possible and then calculate the 
percentages based on this value.
Or is there any other way to get nfs "stress" stats.
I'm trying to tune the nfs load so that it operates at 80% utilization. How 
can I determine such stats?
We use nfs over tcp (2.4 or 2.6 kernel)

Thanks in advance
Rock

_________________________________________________________________
Don’t just search. Find. Check out the new MSN Search! 
http://search.msn.click-url.com/go/onm00200636ave/direct/01/



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
