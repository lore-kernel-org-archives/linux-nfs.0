From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] Fix nfsd rewrite performance
Date: Mon, 1 Aug 2005 13:59:22 +0200
Message-ID: <20050801115922.GE8698@suse.de>
References: <20050801113954.GA8698@suse.de> <20050801115319.GD6497@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DzYxA-0007cp-QW
	for nfs@lists.sourceforge.net; Mon, 01 Aug 2005 04:59:32 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DzYx8-0000iQ-5z
	for nfs@lists.sourceforge.net; Mon, 01 Aug 2005 04:59:33 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20050801115319.GD6497@fieldses.org>
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

On Mon, Aug 01, 2005 at 07:53:19AM -0400, J. Bruce Fields wrote:
> On Mon, Aug 01, 2005 at 01:39:54PM +0200, Olaf Kirch wrote:
> > +	this_page = (unsigned char *) vec[vlen-1].iov_base;
> > +	for (i = vlen-1; i; --i) {
> > +		prev_page = (unsigned char *) vec[i-1].iov_base;
> > +
> > +		/* Push trailing partial page so it's
> > +		 * aligned with the end of the page, then
> > +		 * pull up the missing chunk from the previous
> > +		 * page */
> > +		memmove(this_page + chunk0, this_page, chunk1);
> > +		memcpy(this_page, prev_page + chunk1, chunk0);
> > +		vec[i].iov_len = PAGE_CACHE_SIZE;
> > +		this_page = prev_page;
> > +	}
> 
> If there's stuff after the write data (as there could be in the NFSv4
> case at least), does this overwrite it?

It does. I hadn't thought of these cursed NFSv4 compound requests.

Alternatively, we could pull in everything and align it with the beginning
of the message. This would clobber the RPC header etc.  I don't see us
doing doing any in-place decodes of strings etc in the svcauth code,
so that may be a safer choice. I would like to avoid allocating an extra
page just for aligning things.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
