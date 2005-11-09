From: email builder <emailbuilder88@yahoo.com>
Subject: Re: OT: RAID perf doldrums: advice/recommendations?
Date: Wed, 9 Nov 2005 12:55:22 -0800 (PST)
Message-ID: <20051109205522.54312.qmail@web51905.mail.yahoo.com>
References: <OF4F03C35B.15525291-ON862570AB.0052D3A1-862570AB.005389DD@kcp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EZwyh-00088L-7q
	for nfs@lists.sourceforge.net; Wed, 09 Nov 2005 12:55:31 -0800
Received: from web51905.mail.yahoo.com ([206.190.48.68])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1EZwyg-00058H-2Y
	for nfs@lists.sourceforge.net; Wed, 09 Nov 2005 12:55:31 -0800
To: mhaverkamp@kcp.com, nfs@lists.sourceforge.net
In-Reply-To: <OF4F03C35B.15525291-ON862570AB.0052D3A1-862570AB.005389DD@kcp.com>
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

> > > If you stay with RAID5, get something with a battery backed write=20
> cache.=20
> > > That will make a huge difference in RAID5 performance.
> >=20
> > Really?  I was under the impression that this was just a safety=20
> precaution or
> > similar... it is called a "backup" after all.  :)  How exactly does i=
t
> > increase performance?=20
>=20
> Without one, writes must be flushed to disk before the RAID controller =
can=20
> report them as complete.  This includes even trivial things like updati=
ng=20
> file access times.  With one, writes only need to get into the=20
> controller's write cache before they are reported as complete.  This=20
> allows the controller to schedule the actual write to disk at an optima=
l=20
> time.

Thank you sincerely for this excellent explanation.  We are currently loo=
king
at the new 3Ware SATA II card, the 9550SX:

http://3ware.com/products/serial_ata2-9000.asp

What is strange about these is that the battery backup is sold separately=
.=20
Does anyone have experience with the BBUs (battery backup units) on the 3=
Ware
9000 series cards?

  - Do they really provide the bang for the extra $100?
  - What kind of configuration/installation mess are the BBUs?


> A good way to show this is to untar a tar file full of small files (e.g=
.=20
> kernel source).  On RAID5 without write cache, this takes at least 10=20
> times longer than even a single ATA disk.
>=20
> >=20
> > (And, yes, I have seen this mentioned in many places, so this would b=
e a
> > criteria for our next purchase. :) )



	=09
__________________________________=20
Yahoo! FareChase: Search multiple travel sites in one click.
http://farechase.yahoo.com


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Downl=
oad
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
