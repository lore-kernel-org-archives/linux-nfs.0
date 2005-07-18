From: Olaf Kirch <okir@suse.de>
Subject: Re: making the 'addr=' mount option an address hint
Date: Mon, 18 Jul 2005 21:54:32 +0200
Message-ID: <20050718195432.GC24783@suse.de>
References: <1121614708.6713.41.camel@localhost.localdomain> <1121700961.8780.13.camel@lade.trondhjem.org> <1121711065.23863.31.camel@barsoom.rdu.redhat.com> <1121711870.8707.5.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jtlayton@poochiereds.net>,
	nfs@lists.sourceforge.net, autofs@linux.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DubhT-0002UY-D0
	for nfs@lists.sourceforge.net; Mon, 18 Jul 2005 12:54:51 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by sc8-sf-mx2.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DubhS-0007Hk-8R
	for nfs@lists.sourceforge.net; Mon, 18 Jul 2005 12:54:51 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1121711870.8707.5.camel@lade.trondhjem.org>
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

On Mon, Jul 18, 2005 at 02:37:50PM -0400, Trond Myklebust wrote:
> I would not at all support doing this sort of thing in autofs. If it is
> to be done, it should be done by the mount program.

That would make mount awfully slow, and we're suffering from excessive
boot times already. Besides, mount can see just the current state,
a daemon would be able to collect statistics over a period of time and
average it.

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
