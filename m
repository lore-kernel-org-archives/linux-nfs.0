From: "Vsevolod (Simon) Ilyushchenko" <simonf@cshl.edu>
Subject: Re: Failover using wackamole?
Date: Mon, 28 Feb 2005 15:24:07 -0500
Message-ID: <42237DE7.9010404@cshl.edu>
References: <42234450.9070004@cshl.edu> <20050228192101.GD21364@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D5rRh-0003x3-VB
	for nfs@lists.sourceforge.net; Mon, 28 Feb 2005 12:24:49 -0800
Received: from mercury.cshl.edu ([143.48.1.21])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D5rRg-0001r8-BV
	for nfs@lists.sourceforge.net; Mon, 28 Feb 2005 12:24:49 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20050228192101.GD21364@fieldses.org>
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



>>I tried this using NFS 4 nfs-utils-1.0.6-52 from FC3 updates. However, 
>>it still failed with the following error:
>>	ls: reading directory a: Input/output error
>>and this in the error log on the client:
>>	kernel: RPC: garbage, exit EIO
>>
>>Is this a bug or a feature?
> 
> 
> Hm, there may be a bug there.  But in any case v4 isn't going to help
> you here.  It's constructing filehandles in exactly the same was as v3.

Oh. :( Bummer. Thanks, though.

Is there then an official NFS 4 way of doing a transparent failover with 
non-shared storage?

Simon
-- 

Simon (Vsevolod ILyushchenko)   simonf@cshl.edu
				http://www.simonf.com

Terrorism is a tactic and so to declare war on terrorism
is equivalent to Roosevelt's declaring war on blitzkrieg.

Zbigniew Brzezinski, U.S. national security advisor, 1977-81


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
