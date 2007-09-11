From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [PATCH 2/3] Remove old logging implementation for idmapd
	and rework gssd and idmapd to use the new xlog logging
	infrastructure.
Date: Tue, 11 Sep 2007 12:00:53 -0400
Message-ID: <4d569c330709110900l63cf8248jfa5769b103811ad4@mail.gmail.com>
References: <1189459543.7914.16.camel@moss-terrapins.epoch.ncsc.mil>
	<1189515746.12340.4.camel@moss-terrapins.epoch.ncsc.mil>
	<4d569c330709110800g558b1fect5f84ea20e25efc7b@mail.gmail.com>
	<1189523208.12340.10.camel@moss-terrapins.epoch.ncsc.mil>
	<4d569c330709110824t60745764l3fc63a393d51b0b9@mail.gmail.com>
	<1189524230.12340.15.camel@moss-terrapins.epoch.ncsc.mil>
	<4d569c330709110832s58b4e7f8n4aefbde162530cf3@mail.gmail.com>
	<1189524918.12340.23.camel@moss-terrapins.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
To: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IV8AT-0001wp-EA
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 09:00:49 -0700
Received: from rv-out-0910.google.com ([209.85.198.185])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IV8AX-0002T4-M1
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 09:00:54 -0700
Received: by rv-out-0910.google.com with SMTP id g11so4687719rvb
	for <nfs@lists.sourceforge.net>; Tue, 11 Sep 2007 09:00:53 -0700 (PDT)
In-Reply-To: <1189524918.12340.23.camel@moss-terrapins.epoch.ncsc.mil>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

I'll have to agree with Bruce that we should just remove the calls to
print_hexl() altogether.  I'll write a patch for that.

The stuff in gssd/cacheio. can/should be gotten rid of as well.  They
are mostly straight copies of the functions in support/nfs/cacheio.c.
There are a couple of important minor changes that could be moved into
the common routine.  I'll work on a patch to do that.

K.C.

On 9/11/07, David P. Quigley <dpquigl@tycho.nsa.gov> wrote:
> If that is the format why do crazyness with the inner loop to get it
> printed out? It seems that the formating for that is ("%x %x %x %x",
> int1, int2, int3, int4); Using that inner loop to do that seems a bit
> excessive. It seems for each itteration of the outer loop I can have
> this print statement ("%04x: %04x %04x %04x %04x\n",length,
> (u_int)cp[i],(u_int)cp[i+4],(u_int)cp[i+8],(u_int)cp[i+12]);. This seems
> like a much better solution unless I am missing something.
>
> Dave
>
> On Tue, 2007-09-11 at 11:32 -0400, Kevin Coffman wrote:
> > Yes,
> > Here is sample output with the line accumlation re-enabled in printerr():
> >
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]: in_tok:
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]: length 490
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   0000: 6082 01e6 0609 2a86
> > 4886 f712 0102 0201  `.....*.H.......
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   0010: 006e 8201 d530 8201
> > d1a0 0302 0105 a103  .n...0..........
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   0020: 0201 0ea2 0703 0500
> > 2000 0000 a381 fa61  ........ ......a
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   0030: 81f7 3081 f4a0 0302
> > 0105 a110 1b0e 4349  ..0...........CI
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   0040: 5449 2e55 4d49 4348
> > 2e45 4455 a225 3023  TI.UMICH.EDU.%0#
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   0050: a003 0201 03a1 1c30
> > 1a1b 036e 6673 1b13  .......0...nfs..
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   0060: 726f 636b 2e63 6974
> > 692e 756d 6963 682e  rock.citi.umich.
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   0070: 6564 75a3 81b3 3081
> > b0a0 0302 0101 a103  edu...0.........
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   0080: 0201 18a2 81a3 0481
> > a09d 90d7 31a0 e661  ............1..a
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   0090: e698 f31c 1aa1 fd18
> > a9b0 706e 9e4c 36c4  ..........pn.L6.
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   00a0: 3391 0612 eab0 8c07
> > ea70 d087 98e6 ac94  3........p......
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   00b0: a81c 205a ba10 0f46
> > 2351 fbb5 12bd 67c8  .. Z...F#Q....g.
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   00c0: e7f5 627e 4b71 cd23
> > 0fea c6e3 a6f3 d122  ..b~Kq.#......."
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   00d0: a58d 1556 6788 4f0c
> > 908a 36b1 3569 1456  ...Vg.O...6.5i.V
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   00e0: 779e 3af7 ba6e afe9
> > c910 f502 a9f8 2a61  w.:..n........*a
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   00f0: a546 07c1 be5a c992
> > 8597 d9a4 6940 18bb  .F...Z......i@..
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   0100: e10c 263f 6afb 1a3f
> > ec58 a6c6 315a bd43  ..&?j..?.X..1Z.C
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   0110: 7486 903a 36ac 303b
> > 6cd9 ffc0 d3ec 724f  t..:6.0;l.....rO
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   0120: d7c4 da92 e1a1 33ab
> > 8fa4 81be 3081 bba0  ......3.....0...
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   0130: 0302 0101 a281 b304
> > 81b0 35cf 6330 7a2a  ..........5.c0z*
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   0140: 91b4 591c 38a8 6d3c
> > 9192 ad49 85e6 92d6  ..Y.8.m<...I....
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   0150: 539f 2a3a c66a 6e09
> > c320 589d 0ec8 0cc5  S.*:.jn.. X.....
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   0160: c433 cdeb d259 79a2
> > 6547 b0e8 21aa 0324  .3...Yy.eG..!..$
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   0170: 4cc5 ab73 fd76 d3b7
> > f36b 1ffc d140 a163  L..s.v...k...@.c
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   0180: c3e1 b1bd 8f82 c47c
> > a5d4 1bf1 7d09 9be6  .......|....}...
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   0190: 65dc 96d2 2bf4 cb5f
> > 637a 6649 0221 1973  e...+.._czfI.!.s
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   01a0: 6379 9537 ee31 fa8b
> > 43f1 fe12 3f50 4ea2  cy.7.1..C...?PN.
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   01b0: d426 70e3 59c8 1d1f
> > 933b 0e5a 384d a681  .&p.Y....;.Z8M..
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   01c0: 8399 6319 d1cc 1890
> > fe99 b78d 36f6 6d84  ..c.........6.m.
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   01d0: 4d3a d4f2 8da2 a3e0
> > bea7 1cea 77c0 1acd  M:..........w...
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]:   01e0: 4d27 5bfb 5e07 7562
> > 9ffd                 M'[.^.ub..
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]: sname =
> > nfs/rock.citi.umich.edu@CITI.UMICH.EDU
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]: DEBUG: serialize_krb5_ctx:
> > lucid version!
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]: prepare_krb5_rfc1964_buffer:
> > serializing keys with enctype 4 and length 8
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]: doing downcall
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]: \x01000000 2147483647 -1 -1 0
> > krb5 \x000000000000000018a0b8bfb0cfb0002001be0078520508000000000000000087b2e6463f15f013090000002a864886f7120102020400000008000000b9f42c618a2a3bdc04000000080000004904dc917adacb2c
> > Sep 11 11:16:43 rock rpc.svcgssd[22225]: sending null reply
> >
> >
> > On 9/11/07, David P. Quigley <dpquigl@tycho.nsa.gov> wrote:
> > > I am trying to figure out exactly what this function is doing. I think
> > > it might be best to precalculate the length of the string needed to
> > > convert this char * to hex and then use snprintf to build it here rather
> > > than in the logging subsystem. What exactly is the data that we are
> > > getting in via cp? Are we just getting a string of bytes that we want
> > > printed in hex?
> > >
> > > Dave
> > >
> > > On Tue, 2007-09-11 at 11:24 -0400, Kevin Coffman wrote:
> > > > On 9/11/07, David P. Quigley <dpquigl@tycho.nsa.gov> wrote:
> > > > > Could you point me to the second in gssd that is doing this? It might be
> > > > > better to use the print statements in a saner way.
> > > > >
> > > > > Dave
> > > >
> > > > Agreed.  The cuprit is print_hexl() in svcgssd_proc.c, which currently
> > > > calls printerr() multiple times.  I'll look to see if I can find other
> > > > instances that might be depending on the line acculation of printerr.
> > >
> > >
>
>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
