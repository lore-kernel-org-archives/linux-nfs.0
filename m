From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH kNFSd 2 of 4] Minor memory leak fix.
Date: Tue, 24 Aug 2004 22:43:22 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1093401801.7439.28.camel@lade.trondhjem.org>
References: <20040820164909.27056.patches@notabene>
	 <E1By3FQ-000738-5m@notabene.cse.unsw.edu.au>
	 <20040824202048.GB2057@fieldses.org> <20040824220215.GA3521@fieldses.org>
	 <16683.61807.372405.848939@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@osdl.org>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bznl4-00037j-FC
	for nfs@lists.sourceforge.net; Tue, 24 Aug 2004 19:43:30 -0700
Received: from dh138.citi.umich.edu
	([141.211.133.138] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1Bznl1-0006uv-Rp
	for nfs@lists.sourceforge.net; Tue, 24 Aug 2004 19:43:30 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16683.61807.372405.848939@cse.unsw.edu.au>
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

P=E5 ty , 24/08/2004 klokka 21:54, skreiv Neil Brown:

> How about we just decide that fixed-length string buffers are OK (as
> the reality is that any value other than "nfsd" is extremely
> unlikely), and use the following instead.

Note that this whole "domain" checking code needs to be moved out of the
generic AUTH_SYS server code ASAP anyway. As it stands, it is entirely
nfsd specific, and really belongs in fs/nfsd.

It is already a nuisance in the case of the lockd client callbacks (i.e.
the "GRANTED" and "NOTIFY" RPC functions). It would have broken the
NFSv4 client delegation callbacks too if I hadn't written an ad-hoc
workaround.
In both these cases, we want to authenticate against a known list of
kernel objects rather than do upcalls to userland.

Cheers,
  Trond


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
