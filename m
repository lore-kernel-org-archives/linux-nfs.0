From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: How many nfsd's can I run?
Date: Fri, 24 Jun 2005 11:48:27 +1000
Message-ID: <17083.26219.859400.874299@cse.unsw.edu.au>
References: <42B8C69C.6010302@affymetrix.com>
	<17080.52358.24058.797844@cse.unsw.edu.au>
	<42B9B819.5030900@affymetrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DldJD-0003o2-Kl
	for nfs@lists.sourceforge.net; Thu, 23 Jun 2005 18:48:43 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DldJC-0005aS-5w
	for nfs@lists.sourceforge.net; Thu, 23 Jun 2005 18:48:43 -0700
To: Hugh Caley <Hugh_Caley@affymetrix.com>
In-Reply-To: message from Hugh Caley on Wednesday June 22
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

On Wednesday June 22, Hugh_Caley@affymetrix.com wrote:
> Thanks for the advice.  So, if I run "nfsd 256", it will increase the 
> currently running 125 daemons to 256?

Yes.

> 
> Filesystem is reiser, and the disk device is a Nexsan Atabeast. 
> 

I don't know of any particular performance issues or tuning
possibilities with reiserfs, and I've never heard of an Atabeast..

So I don't think I can be any more helpful.

NeilBrown


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
