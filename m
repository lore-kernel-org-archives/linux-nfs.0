From: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>
Subject: RE: huge number of intr/s on large nfs server
Date: Tue, 15 Oct 2002 16:40:43 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B9160C773F@poexmb3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from usamail1.conoco.com ([12.31.208.226])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181ZQk-00024p-00
	for <nfs@lists.sourceforge.net>; Tue, 15 Oct 2002 14:40:46 -0700
To: "Eric Whiting" <ewhiting@amis.com>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

After doing some reading I figured out my mistake.

Others had told me that it ran 4 pairs at 125Mhz each, and that it=20
worked just like 100BT (1 bit per clock cycle), apparently they are
sending 2bit per cycle so 2 bits x 125Mhz * 4 channels is=20
1Gbps, if they were only using 1 bit per cycle it would be
only 50MB/second.

What is your underlying setup to get the 93MB/second,
ie disks/controllers/cpus?

				Roger

> -----Original Message-----
> From:	Eric Whiting [SMTP:ewhiting@amis.com]
> Sent:	Tuesday, October 15, 2002 3:52 PM
> To:	Heflin, Roger A.
> Cc:	nfs@lists.sourceforge.net
> Subject:	Re: [NFS] huge number of intr/s on large nfs server
>=20
> I'm running 93MBytes/s on gigE copper (testing using a 1000M file).
> (jumbo frames enabled)
>=20
> eric
>=20
>=20
>=20
> "Heflin, Roger A." wrote:
> >=20
> >         Something else,
> >=20
> >         if you are dd a 10mb file on the local machine that is all =
going to be in cache, so
> >         the rate will be horribly incorrect.
> >=20
> >         Also these are gigabit copper cards correct?  Gigabit copper =
cards only run
> >         a max of 50MB/second, so getting 35MB/second over one of =
them is pretty good.
> >=20
> >         I am getting 1500cs/second and 6500ints/second at about =
8MB/second to
> >         the network.
> >=20
> >         I get 3600cs/second and 15000ints/second at about =
20MB/second to the
> >         network.
> >=20
> >         How fast of IO are you getting on the local machine?
> >=20
> >                                                         Roger
> >=20
> > -------------------------------------------------------
> > This sf.net email is sponsored by:ThinkGeek
> > Welcome to geek heaven.
> > http://thinkgeek.com/sf
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
