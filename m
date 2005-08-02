From: Olaf Kirch <okir@suse.de>
Subject: Re: IA64 Server / IA32 Client problem
Date: Tue, 2 Aug 2005 17:27:04 +0200
Message-ID: <20050802152704.GH29054@suse.de>
References: <482A3FA0050D21419C269D13989C611308539E55@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brett Petrusek <brettp@aspsys.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dzyfe-0005gm-Hp
	for nfs@lists.sourceforge.net; Tue, 02 Aug 2005 08:27:10 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Dzyfc-000196-6O
	for nfs@lists.sourceforge.net; Tue, 02 Aug 2005 08:27:10 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611308539E55@lavender-fe.eng.netapp.com>
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

On Tue, Aug 02, 2005 at 07:36:17AM -0700, Lever, Charles wrote:
> can you tell us about the file system on the ia64 server.  block size,
> fstype, etc?
> 
> what's the page size on that system?

This pretty much matches the symptoms we've seen with SGI servers
on 2.6.5.  You may want to try a recent kernel on your clients, which
has support for write sizes larger than the client's PAGE_CACHE_SIZE.

Exactly these bad performance numbers made us backport the large
wsize/rsize patches to 2.6.5 for SLES.

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
