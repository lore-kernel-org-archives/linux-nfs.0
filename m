From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH fs/locks 2 of 3] Use proper tgid in locks_remove_posix
Date: Sun, 17 Jul 2005 18:42:09 +0200
Message-ID: <20050717164209.GB22503@suse.de>
References: <20050711103250.GH27163@suse.de> <20050716151527.GA7726@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, akpm@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DuCDb-0006em-Tc
	for nfs@lists.sourceforge.net; Sun, 17 Jul 2005 09:42:19 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by sc8-sf-mx1.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DuCDa-0003jT-KM
	for nfs@lists.sourceforge.net; Sun, 17 Jul 2005 09:42:20 -0700
To: Olaf Hering <olh@suse.de>
In-Reply-To: <20050716151527.GA7726@suse.de>
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

On Sat, Jul 16, 2005 at 05:15:27PM +0200, Olaf Hering wrote:
> This leads to glibc make check errors on ppc64:
> 
> cat /usr/src/packages/BUILD/glibc-2.3/cc-nptl/nptl/tst-cancel16.out
> Timed out: killed the child process
> 1
> 
> tested with 2.6.13-rc3 and 'powerpc32 make check'

I thought we had fixed those. 

Anyway, as Trond pointed out, this patch is is irrelevant on 2.6.12.

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
