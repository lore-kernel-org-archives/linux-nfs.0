From: Tony Reix <tony.reix@bull.net>
Subject: Re: Improving unfsd scalability: TI-RPC
Date: Fri, 01 Dec 2006 12:41:16 +0100
Message-ID: <1164973277.23144.81.camel@frecb000687.frec.bull.fr>
References: <9c8209a10611292254s79849a6ci11fe10341017ae7e@mail.gmail.com>
	<Pine.LNX.4.64.0611301056440.15692@maggie.lkpg.cendio.se>
	<20061130102238.GA11918@suse.de>
	<9c8209a10611300958q7fd8bcb8u1001cc936062308b@mail.gmail.com>
	<20061130181308.GA12747@suse.de>
	<Pine.LNX.4.64.0611301919430.25539@maggie.lkpg.cendio.se>
	<20061130200110.GA26145@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: Peter Astrand <astrand@cendio.se>, cyril.lacabanne@ema.fr,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gq6lh-0007WN-7i
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 03:41:25 -0800
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gq6lg-0003ou-U7
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 03:41:26 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20061130200110.GA26145@suse.de>
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

Le jeudi 30 novembre 2006 =E0 21:01 +0100, Olaf Kirch a =E9crit :
> =

> > instead? TI-RPC? It has thread support, but it's also much more =

> > complicated. The implementation is not as tested and the libtirpc =

> > implementation is not based on the latest Sun release. And, libtirpc ha=
s =

> > not been ported to Windows yet, and the thread stuff makes porting =

> > somewhat difficult. =

> =

> I'm not a huge fan of TIRPC either.

Hi Olaf, Peter,

We'll have a student, Cyril, in 2007 during 5 months about TI-RPC.
His main goal deals with writing tests for RPC and TI-RPC lib.
But any ideas are welcome to improve TI-RPC and make you a fan of it !
Do you have a list of complaints about TI-RPC ?

Regards,

Tony


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=3Djoin.php&p=3Dsourceforge&CID=3DDE=
VDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
