From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Re: corruption over NFS with 2.6 client, locking,
	truncating and appending...
Date: Wed, 6 Apr 2005 12:43:10 +1000
Message-ID: <16979.19646.790800.298347@cse.unsw.edu.au>
References: <16977.57630.766727.608029@cse.unsw.edu.au>
	<1112664792.11910.12.camel@lade.trondhjem.org>
	<16977.60501.153237.389021@cse.unsw.edu.au>
	<1112667216.11740.4.camel@lade.trondhjem.org>
	<16978.3509.329730.989580@cse.unsw.edu.au>
	<1112676829.11900.4.camel@lade.trondhjem.org>
	<16978.9443.679431.70613@cse.unsw.edu.au>
	<1112732661.10536.8.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJ0Vk-0005Dy-UG
	for nfs@lists.sourceforge.net; Tue, 05 Apr 2005 19:43:20 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DJ0Vk-0000dI-F9
	for nfs@lists.sourceforge.net; Tue, 05 Apr 2005 19:43:20 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: message from Trond Myklebust on Tuesday April 5
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

On Tuesday April 5, trond.myklebust@fys.uio.no wrote:
> 
> OK. Attached is a patch that appears to fix things up for me (at least
> for the case of fcntl() locking). It should apply on top of the latest
> -mm kernel with the SEEKDIR_END patch that I sent you last night.

Thanks.  It seems to be doing the right thing for me, both with fcntl
locking and with .lock file locking.

> 
> Basically, it says that the client must synchronize to the server-given
> value of fattr->size _unless_ we still have pending writes (in which
> case we only accept size values > inode->i_size) or if the getattr() RPC
> call raced with an attribute-changing RPC call (a cached write would
> indeed count as an "attribute-changing RPC call").
> 
> Note that this differs greatly from the current behaviour where we only
> accept updates to inode->i_size if the file is not open for writing and
> we didn't race.
> 

I assume it is adequately safe....
It protects against concurrent writes changing the size, but not
concurrent setattrs. .... But as the setattr updates i_size *after*
the NFS request completes, it should be safe, yes?

Would this be a candidate for 2.6.11.7 ??

Thanks again,

NeilBrown


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
