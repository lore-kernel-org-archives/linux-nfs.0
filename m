From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] Fix xprt_bindresvport
Date: Sat, 16 Jul 2005 09:11:45 +0200
Message-ID: <20050716071144.GA7451@suse.de>
References: <20050711092556.GD27163@suse.de> <42D68C0B.9000106@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, akpm@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dtgq7-00022g-6y
	for nfs@lists.sourceforge.net; Sat, 16 Jul 2005 00:11:59 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Dtgq5-00041W-PN
	for nfs@lists.sourceforge.net; Sat, 16 Jul 2005 00:11:59 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <42D68C0B.9000106@RedHat.com>
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

On Thu, Jul 14, 2005 at 12:00:11PM -0400, Steve Dickson wrote:
> Question, why is 65535 one being used here instead of something
> like 1023 (or PROT_SOCK-1)? Since since inet_bind() will only
> succeed with a source ports that are less than PROT_SOCK, so it
> may not make sense to allow the user to set the max reserver port
> to a value greater than PROT_SOCK-1, true?

I don't understand. Of course you can bind to any socket up to 65535,
not just 1023.
And in an environment where the admin doesn't care for privileged
vs unprivileged ports, it's good to give him the choice of allowing
the kernel to bind to any port.

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
