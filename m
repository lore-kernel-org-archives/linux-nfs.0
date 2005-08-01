From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Fix nfsd rewrite performance
Date: Mon, 1 Aug 2005 08:10:53 -0400
Message-ID: <20050801121053.GA8238@fieldses.org>
References: <20050801113954.GA8698@suse.de> <20050801115319.GD6497@fieldses.org> <20050801115922.GE8698@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DzZ8D-0007zA-OJ
	for nfs@lists.sourceforge.net; Mon, 01 Aug 2005 05:10:57 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DzZ8C-0003X8-C9
	for nfs@lists.sourceforge.net; Mon, 01 Aug 2005 05:10:57 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050801115922.GE8698@suse.de>
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

On Mon, Aug 01, 2005 at 01:59:22PM +0200, Olaf Kirch wrote:
> Alternatively, we could pull in everything and align it with the beginning
> of the message. This would clobber the RPC header etc.  I don't see us
> doing doing any in-place decodes of strings etc in the svcauth code,
> so that may be a safer choice. I would like to avoid allocating an extra
> page just for aligning things.

Yeah.  We'd also need to check, though, that we aren't taking pointers
to data before the write (when decoding a previous compound op).  I
think we might be....

--b.


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
