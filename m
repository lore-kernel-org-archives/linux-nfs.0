From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH kNFSd 0 of 16] Introduction
Date: Tue, 22 Mar 2005 17:56:31 +1100
Message-ID: <16959.49567.10267.644275@cse.unsw.edu.au>
References: <20050322163830.8762.patches@notabene>
	<20050321225059.05dc503b.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDdJe-0001ao-3P
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 22:56:38 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DDdJc-0004aC-Jl
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 22:56:38 -0800
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: message from Andrew Morton on Monday March 21
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

On Monday March 21, akpm@osdl.org wrote:
> NeilBrown <neilb@cse.unsw.edu.au> wrote:
> >
> >  Following are 16 patches against nfsd in 2.6.12-rc1-mm1
> > 
> >  Most are nfsv4 related.
> >  Patch 2 removes an inexplicable increment of f_count for a file.  This 
> >  fixes a problem wherein an exported filesystem may never be unmountable because a
> >  file on it is never closed.
> 
> OK, I'll send nlm-fix-f_count-leak.patch in for 2.6.12 and will buffer the
> rest.

Thanks.

> 
> >  This could possibly be a candidate for 2.6.12.  The rest should wait to go 
> >  in to 2.6.13-rc
> 
> Is it a 2.6.11.x candidate?

Not really.  It is a long way for serious.  Just annoyingly inconvenient
very occasionally (it needs to be fix in 2.4 too, which shows how long
it has been around).

NeilBrown


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
