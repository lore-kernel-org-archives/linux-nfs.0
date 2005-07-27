From: Filipe Brandenburger <branden@terra.com.br>
Subject: Re: Kernel 2.6 vs. Kernel 2.4: higher NFS traffic
Date: Wed, 27 Jul 2005 14:25:37 -0300
Message-ID: <20050727142031.22BF.BRANDEN@terra.com.br>
References: <20050727112639.22B1.BRANDEN@terra.com.br> <1122484635.8068.8.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dxpf2-0002hN-Br
	for nfs@lists.sourceforge.net; Wed, 27 Jul 2005 10:25:40 -0700
Received: from loncoche.terra.com.br ([200.176.10.196])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Dxpf1-0007MR-Uz
	for nfs@lists.sourceforge.net; Wed, 27 Jul 2005 10:25:40 -0700
Received: from ibadan.terra.com.br (ibadan.terra.com.br [200.176.10.7])
	by loncoche.terra.com.br (Postfix) with ESMTP id E7AE2D50024
	for <nfs@lists.sourceforge.net>; Wed, 27 Jul 2005 14:25:37 -0300 (BRT)
Received: from [200.176.1.176] (dsk17134-vm.terra.com.br [200.176.1.176])
	(authenticated user branden)
	by ibadan.terra.com.br (Postfix) with ESMTP id DFF3348072
	for <nfs@lists.sourceforge.net>; Wed, 27 Jul 2005 14:25:37 -0300 (BRT)
To: nfs@lists.sourceforge.net
In-Reply-To: <1122484635.8068.8.camel@lade.trondhjem.org>
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


* Wed, 27 Jul 2005 13:17:15 -0400, Trond Myklebust <trond.myklebust@fys.uio.no>:
> I'd move to 2.6.12. There have been several patches to the access code
> since 2.6.9.

Ok, I'll consider that. Thanks for the tip.

> > As to the lots of "access" calls that I found, can it be that they're
> > causing the increase of about 20% to the eth1 network inbound traffic?
> > As I see, "access" responses are or should be small. I don't think it
> > could be the reason why I'm having such an increase in NFS network
> > traffic... Any other thoughts about that?
> 
> GETATTR?

Yes, actually the number of GETATTR calls raised a lot from 2.4 to 2.6.
Why exactly is that? 2.4 didn't call GETATTR as much as 2.6 does.

I found out with tcpdump that these are the average number of operation
calls in 10.000 packets on kernel 2.6:

     12 link
     13 rename
     14 commit
     14 write
     32 readdir
     45 remove
    200 setattr
    666 readdirplus
   1902 lookup
   1929 read
   2085 getattr
   3088 access

And the same on 10.000 packets on kernel 2.4:

      2 create
     52 rename
     60 commit
     62 write
     79 getattr
     93 link
    115 remove
    238 setattr
    667 readdir
   3243 read
   5389 lookup



Why is there so much difference? Why does 2.6 make 21% getattr while 2.4
does less then 1%?

Are there any mount options that I can use to do some tuning on this?

Thanks,
Filipe



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
