From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH kNFSd 0 of 54] Introduction
Date: Wed, 9 Mar 2005 14:12:50 +1100
Message-ID: <16942.27058.554431.452175@cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
	<20050308000144.6599431b.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8rd4-0005Td-8O
	for nfs@lists.sourceforge.net; Tue, 08 Mar 2005 19:12:58 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8rd2-0000HX-P1
	for nfs@lists.sourceforge.net; Tue, 08 Mar 2005 19:12:58 -0800
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: message from Andrew Morton on Tuesday March 8
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

On Tuesday March 8, akpm@osdl.org wrote:
> NeilBrown <neilb@cse.unsw.edu.au> wrote:
> >
> >  54 (!!) patches for knfsd. Mostly nfsv4 related from Bruce Fields and co.
> 
> Fun, I'm up to 944 patches.
> 
> I assume that nfsv4 is still "experimental", so we can scoot these in
> fairly promptly?

Yes. 

> 
> There were a few rejects against things in Linus's tree now, or something. 
> I fixed them up.  I'll try to do another -mm 24 hours hence - please check
> that everything landed OK.

I checked. It all looks fine. 

> 
> I can tell you right now that the compiler will get huffy about this:
> 
> 
> 
> -void static inline nfs4_state_init(void){}
> +int static inline nfs4_state_init(void){}
> 
> I'll stick a `return 0;' in there...

:-)  Thanks.

NeilBrown


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
