From: "Jocky Wilson" <jocky_wilson@hotmail.com>
Subject: Re: rsize, wsize > 32Kb : how?
Date: Fri, 10 Dec 2004 13:54:48 +0000
Message-ID: <BAY21-F57470B0FF357BCAE964EEE4A80@phx.gbl>
References: <1102636343.3784.27.camel@tesuji.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CclEq-0000MI-N5
	for nfs@lists.sourceforge.net; Fri, 10 Dec 2004 05:55:16 -0800
Received: from bay21-f5.bay21.hotmail.com ([65.54.233.94] helo=hotmail.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CclEq-0008N1-KE
	for nfs@lists.sourceforge.net; Fri, 10 Dec 2004 05:55:16 -0800
In-Reply-To: <1102636343.3784.27.camel@tesuji.nac.uci.edu>
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

In http://nfs.sourceforge.net/nfs-howto/performance.html#PACKET-AND-NETWORK 
it is written:
"Note that NFS Version 2 is limited to a maximum of 8K, regardless of the 
maximum block size defined by NFSSVC_MAXBLKSIZE; Version 3 will support up 
to 64K, if permitted"

My question is what requirements must be fullfilled such that NFSv3 daemon 
will permit 64k blocksizes?

Cheers,
JockyW




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
