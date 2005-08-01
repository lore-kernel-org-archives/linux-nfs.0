From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Fix nfsd rewrite performance
Date: Mon, 1 Aug 2005 07:53:19 -0400
Message-ID: <20050801115319.GD6497@fieldses.org>
References: <20050801113954.GA8698@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DzYrO-0007Oe-3p
	for nfs@lists.sourceforge.net; Mon, 01 Aug 2005 04:53:34 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DzYrM-0006gw-SG
	for nfs@lists.sourceforge.net; Mon, 01 Aug 2005 04:53:34 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050801113954.GA8698@suse.de>
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

I haven't had the chance to read carefully; just one quick question:

On Mon, Aug 01, 2005 at 01:39:54PM +0200, Olaf Kirch wrote:
> +	this_page = (unsigned char *) vec[vlen-1].iov_base;
> +	for (i = vlen-1; i; --i) {
> +		prev_page = (unsigned char *) vec[i-1].iov_base;
> +
> +		/* Push trailing partial page so it's
> +		 * aligned with the end of the page, then
> +		 * pull up the missing chunk from the previous
> +		 * page */
> +		memmove(this_page + chunk0, this_page, chunk1);
> +		memcpy(this_page, prev_page + chunk1, chunk0);
> +		vec[i].iov_len = PAGE_CACHE_SIZE;
> +		this_page = prev_page;
> +	}

If there's stuff after the write data (as there could be in the NFSv4
case at least), does this overwrite it?

--b.


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
