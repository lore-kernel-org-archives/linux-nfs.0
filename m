From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Failover using wackamole?
Date: Mon, 28 Feb 2005 14:21:01 -0500
Message-ID: <20050228192101.GD21364@fieldses.org>
References: <42234450.9070004@cshl.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D5qRh-0000wN-D1
	for nfs@lists.sourceforge.net; Mon, 28 Feb 2005 11:20:45 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D5qRf-0003ZL-VX
	for nfs@lists.sourceforge.net; Mon, 28 Feb 2005 11:20:45 -0800
To: "Vsevolod (Simon) Ilyushchenko" <simonf@cshl.edu>
In-Reply-To: <42234450.9070004@cshl.edu>
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

On Mon, Feb 28, 2005 at 11:18:24AM -0500, Vsevolod (Simon) Ilyushchenko wrote:
> I had this neat idea that NFS failover of read-only filesystems can be 
> achieved using wackamole (floating IP adresses providing very simple 
> HA). This did not work with NFS 3 because the filehandles are different 
> on the primary and the secondary servers, so I was getting a "stale NFS 
> filehandle" error after the failover.
> 
> I tried this using NFS 4 nfs-utils-1.0.6-52 from FC3 updates. However, 
> it still failed with the following error:
> 	ls: reading directory a: Input/output error
> and this in the error log on the client:
> 	kernel: RPC: garbage, exit EIO
> 
> Is this a bug or a feature?

Hm, there may be a bug there.  But in any case v4 isn't going to help
you here.  It's constructing filehandles in exactly the same was as v3.

--b.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
