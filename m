From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: lockd todo item
Date: Tue, 2 Aug 2005 06:04:25 -0400
Message-ID: <20050802100425.GB1940@fieldses.org>
References: <20050801214537.GA30924@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DztdU-0001nl-HP
	for nfs@lists.sourceforge.net; Tue, 02 Aug 2005 03:04:36 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DztdT-0001Ha-A3
	for nfs@lists.sourceforge.net; Tue, 02 Aug 2005 03:04:36 -0700
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20050801214537.GA30924@infradead.org>
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

On Mon, Aug 01, 2005 at 10:45:37PM +0100, Christoph Hellwig wrote:
> the client-side lockd still pokes into file_lock_list, despite having
> an XXX comment to remove this during 2.5.  Given that the NFS team seems
> to be rewriting parts of the locking code constantlt it would be nice
> if someone could fix this layering violation while they're at it.

OK, we'll take a look at that, thanks.--b.


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
