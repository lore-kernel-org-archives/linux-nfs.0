From: Olaf Kirch <okir@suse.de>
Subject: Re: Improving unfsd scalability
Date: Thu, 30 Nov 2006 21:01:10 +0100
Message-ID: <20061130200110.GA26145@suse.de>
References: <9c8209a10611292254s79849a6ci11fe10341017ae7e@mail.gmail.com>
	<Pine.LNX.4.64.0611301056440.15692@maggie.lkpg.cendio.se>
	<20061130102238.GA11918@suse.de>
	<9c8209a10611300958q7fd8bcb8u1001cc936062308b@mail.gmail.com>
	<20061130181308.GA12747@suse.de>
	<Pine.LNX.4.64.0611301919430.25539@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gps5z-0001XG-S8
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 12:01:24 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gps5y-0004Ak-7m
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 12:01:25 -0800
To: Peter Astrand <astrand@cendio.se>
In-Reply-To: <Pine.LNX.4.64.0611301919430.25539@maggie.lkpg.cendio.se>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, Nov 30, 2006 at 07:27:15PM +0100, Peter Astrand wrote:
> > I just wish people would leave this old code to Rot In Peace :)
> 
> Yes, the old ONC RPC code is far from optimal. But, what do you suggest 

Oh, I'm sorry. I was referring to unfsd.

> instead? TI-RPC? It has thread support, but it's also much more 
> complicated. The implementation is not as tested and the libtirpc 
> implementation is not based on the latest Sun release. And, libtirpc has 
> not been ported to Windows yet, and the thread stuff makes porting 
> somewhat difficult. 

I'm not a huge fan of TIRPC either.

> Btw, I'm also not convinced that threading is the best solution. I tend to 
> like multi-process or select-based solutions better.

I agree.  It makes for trickier code though.

The premise of the "java way" of writing network services (one thread
per connection) is you trade complexity for computing resources. If
you create complex applications, you need expensive programmers and
QA. If you solve a problem by throwing more threads at it, the customer
will need more expensive hardware - which is too bad, but at least
it doesn't show up on your R&D budget :)

Olaf
-- 
Walks like a duck. Quacks like a duck. Must be a chicken.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
