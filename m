From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [kNFSD] [PATCH] fixed '-p port' arg to rpc.nfsd plus more.
Date: Tue, 22 Mar 2005 08:10:39 -0500
Message-ID: <4240194F.706@RedHat.com>
References: <423EDD43.8000209@RedHat.com> <16959.23048.930497.833801@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDj1l-0001GB-R5
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 05:02:33 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DDj1V-0000LG-5y
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 05:02:33 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16959.23048.930497.833801@cse.unsw.edu.au>
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

Neil Brown wrote:
> 
> "ports".... should we allow different protocols to use different
>    ports?  2049 for tcp, but use 5123 for udp ???
I would not think so... How often has something like this
been needed in the past?

> 
>    Maybe a better interface is to open and bind a socket in userspace,
>    and pass it down to the kernel.  Maybe not..
True.... ;-)

> 
>  How about the "ports" file contains lines:
>    family:proto:address:port
>  e.g.
>    ipv4:udp:*:2049
Maybe a better name for the file should be 'address'?
since thats what we are defining....

> 
>  A port could be disabled with
>    echo "-ipv4:udp:*:2049" > /proc/fs/nfsd/ports
>  maybe.
hmm... I think I would rather just restart the server
verses disable something.... I just doesn't sound good ;-)

steved.





-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
