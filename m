From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Kernel 2.6 vs. Kernel 2.4: higher NFS traffic
Date: Wed, 27 Jul 2005 13:17:15 -0400
Message-ID: <1122484635.8068.8.camel@lade.trondhjem.org>
References: <20050726201432.22AA.BRANDEN@terra.com.br>
	 <1122425163.23486.8.camel@lade.trondhjem.org>
	 <20050727112639.22B1.BRANDEN@terra.com.br>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DxpX9-000293-Cw
	for nfs@lists.sourceforge.net; Wed, 27 Jul 2005 10:17:31 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DxpX6-0006F3-Rf
	for nfs@lists.sourceforge.net; Wed, 27 Jul 2005 10:17:31 -0700
To: Filipe Brandenburger <branden@terra.com.br>
In-Reply-To: <20050727112639.22B1.BRANDEN@terra.com.br>
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

on den 27.07.2005 Klokka 11:41 (-0300) skreiv Filipe Brandenburger:
> Hi.
> 
> Thanks for the answer.
> 
> * Tue, 26 Jul 2005 20:46:03 -0400, Trond Myklebust <trond.myklebust@fys.uio.no>:
> > There were a couple of kernels in the mid-2.6 series where the caching
> > didn't work too well. More recent kernels should be fine, though.
> 
> My kernel is 2.6.9, is it recent enough for the right behaviour of
> caching code?

I'd move to 2.6.12. There have been several patches to the access code
since 2.6.9.

> As to the lots of "access" calls that I found, can it be that they're
> causing the increase of about 20% to the eth1 network inbound traffic?
> As I see, "access" responses are or should be small. I don't think it
> could be the reason why I'm having such an increase in NFS network
> traffic... Any other thoughts about that?

GETATTR?

> I also gave a look at nfsstat, and found out something interesting. More
> specifically, nfsstat -rc.
> 
> On kernel 2.4, I have this:
> 
> [root@congo root]# nfsstat -rc
> Client rpc stats:
> calls      retrans    authrefrsh
> 844988800   8307       0
> 
> The average growth of "calls" is about 240k/min, and "retrans" grows
> about 3 or 4 per minute.
> 
> On kernel 2.6:
> 
> [root@talara ~]# nfsstat -rc
> Client rpc stats:
> calls      retrans    authrefrsh
> 8933863    9543       0
> 
> The average growth of "calls" is about 410k/min. Ok, I can see that as
> the "access" calls that are being done only on kernel 2.6, this could
> justify the big growth on RPC calls done on these clients. But on this
> host, "retrans" grows at a rate of 400 to 500 per minute, and that seems
> to be a lot to me.

Sounds like a UDP networking regression. Could be related to anything
from scheduling changes to NIC driver changes.

> I think it has something to do with the timeo= mount parameter, so I
> tried to set timeo=30 (3 seconds) on all my NFS mounts (I used the
> default of 7 tenths of seconds before). But even after the change, the
> "retrans" rate seems to keep high.

Recent kernels (both 2.4 and 2.6) use a self-tuning algorithm for UDP.

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
