From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH kNFSd 0 of 12] Introduction
Date: Tue, 8 Feb 2005 14:30:46 +1100
Message-ID: <16904.12902.298401.1645@cse.unsw.edu.au>
References: <20050208140033.24886.patches@notabene>
	<20050207192453.2a0a206b.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: J "." Bruce Fields <bfields@citi.umich.edu>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyM5V-0007v2-Tn
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 19:30:53 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CyM5T-0006Vp-Of
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 19:30:53 -0800
To: Andrew Morton <akpm@osdl.org>
Cc: nfs@lists.sourceforge.net
In-Reply-To: message from Andrew Morton on Monday February 7
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

On Monday February 7, akpm@osdl.org wrote:
> 
> > The 6 from Bruce fix a real performance problem with locking.
> 
> That one depends on a bunch of the preceding ones, yes?

The set of six (numbered 3 to 8) should be independent of the rest.  I
believe Bruce has done substantial testing on them.  I'll leave him to
make a case or not.

> 
> > The rest could be safely delayed if that seem appropriate, but they are 
> > either quite trivial or (for the last one) quite well tested.
> 
> Maybe just the readdir and append patches for 2.6.11??

I'm OK with that if Bruce is.

Thanks,

NeilBrown


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
