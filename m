From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH kNFSd 4 of 4] Use llseek instead of f_pos= for directory seeking.
Date: Mon, 16 Aug 2004 10:23:02 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040816102302.B9177@infradead.org>
References: <20040816135256.9819.patches@notabene> <E1BwYdv-0002Zr-8C@notabene.cse.unsw.edu.au> <20040816102102.A9177@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bwdhy-0005Hp-Dz
	for nfs@lists.sourceforge.net; Mon, 16 Aug 2004 02:23:14 -0700
Received: from imladris.demon.co.uk ([193.237.130.41] helo=phoenix.infradead.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1Bwdhx-0005b8-Kh
	for nfs@lists.sourceforge.net; Mon, 16 Aug 2004 02:23:14 -0700
To: NeilBrown <neilb@cse.unsw.edu.au>
In-Reply-To: <20040816102102.A9177@infradead.org>; from hch@infradead.org on Mon, Aug 16, 2004 at 10:21:02AM +0100
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

On Mon, Aug 16, 2004 at 10:21:02AM +0100, Christoph Hellwig wrote:
> > So instead, we use 'llseek' copied out of fs/read_write.c
> > use that, both to seek at the start, and the find the new position at
> > the end.
> 
> llseek from fs/read_write.c has been renamed to vfs_llseek and you can
> just use it now.

Sorry for the noise, I see this is 2.4.  But I think the 2.6 variant would be
preferable for 2.4 aswell.



-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
