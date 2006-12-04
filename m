From: Tony Reix <tony.reix@bull.net>
Subject: Re: Improving unfsd scalability: TI-RPC test suite
Date: Mon, 04 Dec 2006 09:51:59 +0100
Message-ID: <1165222319.18251.10.camel@frecb000687.frec.bull.fr>
References: <9c8209a10611292254s79849a6ci11fe10341017ae7e@mail.gmail.com>
	<Pine.LNX.4.64.0611301056440.15692@maggie.lkpg.cendio.se>
	<20061130102238.GA11918@suse.de>
	<9c8209a10611300958q7fd8bcb8u1001cc936062308b@mail.gmail.com>
	<20061130181308.GA12747@suse.de>
	<Pine.LNX.4.64.0611301919430.25539@maggie.lkpg.cendio.se>
	<20061130200110.GA26145@suse.de>
	<1164973277.23144.81.camel@frecb000687.frec.bull.fr>
	<Pine.LNX.4.64.0612011448540.29202@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: cyril.lacabanne@ema.fr, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gr9Yj-000206-QD
	for nfs@lists.sourceforge.net; Mon, 04 Dec 2006 00:52:21 -0800
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gr9Yj-0000Cf-JK
	for nfs@lists.sourceforge.net; Mon, 04 Dec 2006 00:52:23 -0800
To: Peter Astrand <astrand@cendio.se>
In-Reply-To: <Pine.LNX.4.64.0612011448540.29202@maggie.lkpg.cendio.se>
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

Le vendredi 01 d=E9cembre 2006 =E0 14:52 +0100, Peter Astrand a =E9crit :
> On Fri, 1 Dec 2006, Tony Reix wrote:

> > We'll have a student, Cyril, in 2007 during 5 months about TI-RPC.
> > His main goal deals with writing tests for RPC and TI-RPC lib.
> =

> This sounds great. Have you decided on the test framework and/or language =

> yet? pynfs might be useful... :-)

Not decided yet. The decision will be done after the student has built
the design of the tests to be done. C and Python are candidates. Since
the test suite is aimed to be delivered to the LTP project, we'll follow
their rules.

Though the TI-RPC already appears in FC6 with no known issues, providing
a RPC test suite will help to stabilize it.

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
