From: Filipe Brandenburger <branden@terra.com.br>
Subject: Re: Kernel 2.6 vs. Kernel 2.4: higher NFS traffic
Date: Wed, 27 Jul 2005 11:41:07 -0300
Message-ID: <20050727112639.22B1.BRANDEN@terra.com.br>
References: <20050726201432.22AA.BRANDEN@terra.com.br> <1122425163.23486.8.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dxp2C-00009e-1G
	for nfs@lists.sourceforge.net; Wed, 27 Jul 2005 09:45:32 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Dxoi9-0004KN-Fe
	for nfs@lists.sourceforge.net; Wed, 27 Jul 2005 09:24:50 -0700
Received: from linares.terra.com.br ([200.154.55.228])
	by externalmx-1.sourceforge.net with esmtp (Exim 4.41)
	id 1Dxn7l-0003U0-9D
	for nfs@lists.sourceforge.net; Wed, 27 Jul 2005 07:43:12 -0700
Received: from talara.terra.com.br (talara.terra.com.br [200.176.10.15])
	by linares.terra.com.br (Postfix) with ESMTP id 319AD4DC054
	for <nfs@lists.sourceforge.net>; Wed, 27 Jul 2005 11:41:08 -0300 (BRT)
Received: from [200.176.1.176] (dsk17134-vm.terra.com.br [200.176.1.176])
	(authenticated user branden)
	by talara.terra.com.br (Postfix) with ESMTP id 16AEE47C035
	for <nfs@lists.sourceforge.net>; Wed, 27 Jul 2005 11:41:08 -0300 (BRT)
To: nfs@lists.sourceforge.net
In-Reply-To: <1122425163.23486.8.camel@lade.trondhjem.org>
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


Hi.

Thanks for the answer.

* Tue, 26 Jul 2005 20:46:03 -0400, Trond Myklebust <trond.myklebust@fys.uio.no>:
> There were a couple of kernels in the mid-2.6 series where the caching
> didn't work too well. More recent kernels should be fine, though.

My kernel is 2.6.9, is it recent enough for the right behaviour of
caching code?

As to the lots of "access" calls that I found, can it be that they're
causing the increase of about 20% to the eth1 network inbound traffic?
As I see, "access" responses are or should be small. I don't think it
could be the reason why I'm having such an increase in NFS network
traffic... Any other thoughts about that?


I also gave a look at nfsstat, and found out something interesting. More
specifically, nfsstat -rc.

On kernel 2.4, I have this:

[root@congo root]# nfsstat -rc
Client rpc stats:
calls      retrans    authrefrsh
844988800   8307       0

The average growth of "calls" is about 240k/min, and "retrans" grows
about 3 or 4 per minute.

On kernel 2.6:

[root@talara ~]# nfsstat -rc
Client rpc stats:
calls      retrans    authrefrsh
8933863    9543       0

The average growth of "calls" is about 410k/min. Ok, I can see that as
the "access" calls that are being done only on kernel 2.6, this could
justify the big growth on RPC calls done on these clients. But on this
host, "retrans" grows at a rate of 400 to 500 per minute, and that seems
to be a lot to me.

I think it has something to do with the timeo= mount parameter, so I
tried to set timeo=30 (3 seconds) on all my NFS mounts (I used the
default of 7 tenths of seconds before). But even after the change, the
"retrans" rate seems to keep high.

I don't seem to be with problems in reassembling fragments, as seen
below.

On kernel 2.4:

[root@congo root]# netstat -s | grep -i -e frag -e reass
    137 fragments dropped after timeout
    1016022512 reassemblies required
    213674528 packets reassembled ok
    137 packet reassembles failed
    2234663 fragments created

On kernel 2.6:

[root@talara ~]# netstat -s | grep -i -e frag -e reass
    5 fragments dropped after timeout
    10776696 reassemblies required
    2124805 packets reassembled ok
    5 packet reassembles failed
    8825 fragments received ok

Both seem very low, and neither of them is growing.

Anyone has any ideas on this?

Thanks a lot,
Filipe.



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
