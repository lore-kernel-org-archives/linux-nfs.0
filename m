From: Peter Staubach <staubach@redhat.com>
Subject: Re: Large FSINFO3resok.rtmax, UDP and stuff
Date: Mon, 11 Dec 2006 16:59:26 -0500
Message-ID: <457DD4BE.3000008@redhat.com>
References: <Pine.LNX.4.64.0612111105270.31602@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GttBS-0005Q6-MI
	for nfs@lists.sourceforge.net; Mon, 11 Dec 2006 13:59:39 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GttBT-0002fc-Ti
	for nfs@lists.sourceforge.net; Mon, 11 Dec 2006 13:59:40 -0800
To: =?ISO-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
In-Reply-To: <Pine.LNX.4.64.0612111105270.31602@maggie.lkpg.cendio.se>
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

Peter =C5strand wrote:
> I'd like to configure my (unfs3) server to support large read and write =

> sizes, to get good speed on high latency links. The plan is to increase =

> FSINFO3resok.{rtmax,wtmax} to something very large, like 256KB, and then =

> mount with the same rsize/wsize. Will this work with various versions of =

> the kernel, or can I expect problems? =

>
> Another question is how UDP should be handled. Although I will mostly use =

> TCP, I'd still like the server to be functional for UDP. Since UDP is =

> limited to 65K, I need some special handling. Which one is best?:
>
> 1) Have FSINFO return the same large (256KB) rtmax/wtmax, even when calle=
d =

>    via UDP. In practice, I guess clients won't ask for a READ with =

>    count=3D256K or count=3D65535, but what if they do? As far as I unders=
tand, =

>    the server is not allowed to return a short read if count is less than =

>    rtmax.
>
> or
>
> 2) Have FSINFO return something smaller when called via UDP. It's a littl=
e =

>    bit strange that FSINFO returns different values depending on if you =

>    call it over TCP or UDP, but it does solve the problem above.
>
>
> Also, I'm a bit unsure of which packet sizes I should specify to =

> svcudp_bufcreate(), to get the largest possible UDP RPC packets. Can I =

> specify 65535, or should I compensate for the RPC header size?

In the past, the general concensus has been to leave the maximum at 32K for
UDP transfers.  The RPC protocol requires that all RPCs over UDP must be
contained in a single UDP datagram and the UDP protocol limits the maximum
size of a datagram to 64K.  It is not possible to put 64K NFS data into a
UDP datagram because there is also NFS metadata and RPC metadata which be
included in the datagram size.  You could consider 56K or perhaps even
60K to still be at a multiple of most pagesizes, but the additional
performance gains appear to be minimal and have not even been measured.

Servers such as the Solaris server return 32K for connectionless (ie. UDP)
and 1M for connect-oriented (ie. TCP) protocols.

       ps

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=3Djoin.php&p=3Dsourceforge&CID=3DDE=
VDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
