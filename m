From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Improving unfsd scalability: TI-RPC
Date: Fri, 01 Dec 2006 11:50:24 -0500
Message-ID: <45705D50.8070905@RedHat.com>
References: <9c8209a10611292254s79849a6ci11fe10341017ae7e@mail.gmail.com>	<Pine.LNX.4.64.0611301056440.15692@maggie.lkpg.cendio.se>	<20061130102238.GA11918@suse.de>	<9c8209a10611300958q7fd8bcb8u1001cc936062308b@mail.gmail.com>	<20061130181308.GA12747@suse.de>	<Pine.LNX.4.64.0611301919430.25539@maggie.lkpg.cendio.se>	<20061130200110.GA26145@suse.de>
	<1164973277.23144.81.camel@frecb000687.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: Olaf Kirch <okir@suse.de>, Peter Astrand <astrand@cendio.se>,
	nfs@lists.sourceforge.net, cyril.lacabanne@ema.fr
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GqBay-0006hg-6k
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 08:50:40 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GqBaz-00085A-CR
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 08:50:41 -0800
To: Tony Reix <tony.reix@bull.net>
In-Reply-To: <1164973277.23144.81.camel@frecb000687.frec.bull.fr>
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

Tony Reix wrote:
> Le jeudi 30 novembre 2006 =E0 21:01 +0100, Olaf Kirch a =E9crit :
>>> instead? TI-RPC? It has thread support, but it's also much more =

>>> complicated. The implementation is not as tested and the libtirpc =

>>> implementation is not based on the latest Sun release. And, libtirpc ha=
s =

>>> not been ported to Windows yet, and the thread stuff makes porting =

>>> somewhat difficult. =

>> I'm not a huge fan of TIRPC either.
> =

> Hi Olaf, Peter,
> =

> We'll have a student, Cyril, in 2007 during 5 months about TI-RPC.
> His main goal deals with writing tests for RPC and TI-RPC lib.
> But any ideas are welcome to improve TI-RPC and make you a fan of it !
Note... the libtirpc Tony is talking about is available in FC6...
its in the core repo... There are already a few patches that
fixed a couple of issued... but over all it seem to be working...

steved.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=3Djoin.php&p=3Dsourceforge&CID=3DDE=
VDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
