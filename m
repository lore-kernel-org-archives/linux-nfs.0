From: Junfeng Yang <yjf@stanford.edu>
Subject: Re: [CHECKER] inconsistent NFS stat cache (NFS on ext3, 2.6.11)
Date: Sat, 12 Mar 2005 23:04:45 -0800 (PST)
Message-ID: <Pine.GSO.4.44.0503122300030.6817-100000@elaine24.Stanford.EDU>
References: <1110690267.24123.7.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net, <mc@cs.Stanford.EDU>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAN9d-0000ci-TV
	for nfs@lists.sourceforge.net; Sat, 12 Mar 2005 23:04:49 -0800
Received: from smtp3.stanford.edu ([171.67.16.138])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DAN9d-00019r-JY
	for nfs@lists.sourceforge.net; Sat, 12 Mar 2005 23:04:49 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1110690267.24123.7.camel@lade.trondhjem.org>
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

> This is a known problem. Turn off the (default - grrr) subtree checking
> export option on the server, and it will all work properly. The subtree
> checking option violates the NFS standards for filehandle generation in
> so many ways, that it isn't even funny.

Hi Trond,

Turn off this option in /etc/exports does fix the inconsistency.  However
I looked throught the export man page and seems that subtree checking will
cause problems only in the following case: "accessing files that are
renamed while a client has them open".  My test case is *not* doing this.
It does renames but it never does so with a file opened.  Can you please
clarify?

Thanks,
-Junfeng



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
