From: Frank van Maarseveen <F.vanMaarseveen@inter.NL.net>
Subject: Re: NFS on a freeswan gateway?
Date: Tue, 25 Jun 2002 23:15:40 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020625231540.A31629@iapetus.localdomain>
References: <20020624223641.GA16108@backlot.linas.org> <shsptygs21r.fsf@charged.uio.no> <20020625002317.GA16309@backlot.linas.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from grootstal.nijmegen.internl.net ([217.149.192.7])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17MyhD-0007Ko-00
	for <nfs@lists.sourceforge.net>; Tue, 25 Jun 2002 15:21:59 -0700
Received: from iapetus.localdomain by grootstal.nijmegen.internl.net
	via 1Cust175.tnt3.rtm1.nl.uu.net [213.116.100.175] with ESMTP for <nfs@lists.sourceforge.net>
	id AAA12992 (8.8.8/1.3); Wed, 26 Jun 2002 00:21:53 +0200 (MET DST)
Received: (from inet1@localhost)
	by iapetus.localdomain (8.11.6/8.11.6) id g5PLFeH04353
	for nfs@lists.sourceforge.net; Tue, 25 Jun 2002 23:15:40 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <20020625002317.GA16309@backlot.linas.org>; from linas@linas.org on Mon, Jun 24, 2002 at 07:23:17PM -0500
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Mon, Jun 24, 2002 at 07:23:17PM -0500, Linas Vepstas wrote:
> 
> Hi,
> 
> I think I made some progress on my freeswan/nfs-mount problem;
> see below.
> 
> To summarize, it appears that freeswan and/or the linux kernel is 
> issueing packets from the ipsec0 interface that do not carry the
> ipsec0-device default source address, but rather carry the source
> address of eth0/eth1.  And that seems wrong to me:  if a gateway

I have played with FreeS/WAN and saw that an ipsec interface would always
get the same address as the eth interface (i.e. on the internet) emitting
the corresponding ESP packet. Routing happens in a nonobvious way.
This addressing scheme is fundamentally broken (the FreeS/WAN people
know it) and may be the cause of the problem.

There is some other weirdness with FreeS/WAN: when you connect
two networks each having a FreeS/WAN gateway machine then any packet
generated on the gateway machine itself cannot be tunnelled: the packets
are dropped by the FreeS/WAN address checking code (source address problem
as far as I remember). Sounds like the problem you are experiencing.

-- 
Frank


-------------------------------------------------------
This sf.net email is sponsored by: Jabber Inc.
Don't miss the IM event of the season | Special offer for OSDN members! 
JabConf 2002, Aug. 20-22, Keystone, CO http://www.jabberconf.com/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
