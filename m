From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] Fix xprt_bindresvport
Date: Sun, 17 Jul 2005 18:45:41 +0200
Message-ID: <20050717164541.GC22503@suse.de>
References: <482A3FA0050D21419C269D13989C611308539DC6@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>, nfs@lists.sourceforge.net,
	akpm@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DuCGw-0006oG-EW
	for nfs@lists.sourceforge.net; Sun, 17 Jul 2005 09:45:46 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DuCGv-0004E3-0X
	for nfs@lists.sourceforge.net; Sun, 17 Jul 2005 09:45:46 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611308539DC6@lavender-fe.eng.netapp.com>
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

On Sun, Jul 17, 2005 at 09:02:20AM -0700, Lever, Charles wrote:
> in addition, part of AUTH_SYS security (such as it is) is connecting via
> a privileged port.
> 
> a better solution, which trond recently suggested, is to disable
> xprt->resvport for AUTH_GSS-secured transports, but leave the other
> security flavors as they are now.

I'm fine with capping the max port at 1023. I just thought it was
an elegant way to allow admins to dispense with the privport nonsense
altogether, if they want. The alternative would have been a mount
option "noprivports" or similar.

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
