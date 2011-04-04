From: Steven Procter <steven-BxoHJBdta+vVtiohHAVwjA@public.gmane.org>
Subject: Re: Prioritizing readdirplus/getattr/lookup
Date: Mon, 04 Apr 2011 09:22:04 -0700
Message-ID: <4694.1301934124@risen.void.org>
References: <802792.85762.qm@web65404.mail.ac4.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: Andrew Klaassen <clawsoon@yahoo.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dsl017-049-228.sfo4.dsl.speakeasy.net ([69.17.49.228]:33422
	"EHLO void.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751572Ab1DDQWI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Apr 2011 12:22:08 -0400
In-reply-to: <802792.85762.qm-GjowA9KT+PL5nGHA2nhOEg9VFclH1bkmQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I'd recommend using a packet sniffer to see what is going on at the
protocol level when there are performance issues.  I've found that
wireshark works well for this kind of investigation.

--Steven

> X-Mailer: YahooMailClassic/12.0.2 YahooMailWebService/0.8.109.295617
> Date:	Mon, 4 Apr 2011 06:31:09 -0700 (PDT)
> From:	Andrew Klaassen <clawsoon@yahoo.com>
> Subject: Prioritizing readdirplus/getattr/lookup
> To:	linux-nfs@vger.kernel.org
> Sender:	linux-nfs-owner@vger.kernel.org
>=20
> How difficult would it be to make nfsd give priority to the calls gen=
erated by "ls -l" (i.e. readdirplus, getattr, lookup) over read and wri=
te calls?=C2=A0 Is it a matter of tweaking a couple of sysctls or chang=
ing a few lines of code, or would it mean a major re-write?
>=20
> I'm working in an environment where it's important to have reasonably=
 good throughput for the HPC farm (50-200 machines reading and writing =
5-10MB files as fast as they can pump them through), while simultaneous=
ly providing snappy responses to "ls -l" and equivalents for people rev=
iewing file sizes and times and browsing through the filesystem and con=
structing new jobs and whatnot.
>=20
> I've tried a small handful of server OSes (Solaris, Exastore, various=
 Linux flavours and tunings and nfsd counts) that do great on the throu=
ghput side but horrible on the "ls -l" under load side (as mentioned in=
 my previous emails).
>=20
> However, I know what I need is possible, because Netapp GX on very si=
milar hardware (similar processor, memory, and spindle count), does sli=
ghtly worse (20% or so) on total throughput but much better (10-100 tim=
es better than Solaris/Linux/Exastore) on under-load "ls -l" responsive=
ness.
>=20
> In the Linux case, I think I've narrowed to the problem down to nfsd =
rather than filesystem or VM system.=C2=A0 It's not filesystem or VM sy=
stem, because when the server is under heavy local load equivalent to m=
y HPC farm load, both local and remote "ls -l" commands are fast.=C2=A0=
 It's not that the NFS load overwhelms the server, because when the ser=
ver is under heavy HPC farm load, local "ls -l" commands are still fast=
=2E
>=20
> It's only when there's an NFS load and an NFS "ls -l" that the "ls -l=
" is slow.  Like so:
>=20
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 throughput=C2=A0 =C2=A0=
=C2=A0=C2=A0ls -l
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=C2=A0 =C2=A0=C2=A0=C2=A0=3D=3D=3D=3D=3D
> Heavy local load, local ls -l=C2=A0 =C2=A0=C2=A0=C2=A0fast=C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0=C2=A0=C2=A0fast
> Heavy local load, NFS ls -l=C2=A0 =C2=A0 =C2=A0=C2=A0=C2=A0fast=C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0=C2=A0fast
> Heavy NFS load, local ls -l=C2=A0 =C2=A0 =C2=A0=C2=A0=C2=A0fast=C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0=C2=A0fast
> Heavy NFS load, NFS ls -l=C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0=C2=A0fast=C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0=C2=A0very slow
>=20
> This suggests to me that it's nfsd that's slowing down the ls -l resp=
onse times rather than the filesystem or VM system.
>=20
> Would fixing the bottom-right-corner case - even if it meant a modest=
 throughput slowdown - be an easy tweak/patch?=C2=A0 Or major re-write?=
  (Or just a kernel upgrade?)
>=20
> I know it's doable because the Netapp does it; the question is how la=
rge a job would it be on Linux.
>=20
> Thanks again.
>=20
>=20
> FWIW, here's what I've tried so far to try to make this problem go aw=
ay without success:
>=20
> Server side:
>=20
> kernels (all x86_64): 2.6.32-[something] on Scientific Linux 6.0, 2.6=
=2E32.4 on Slackware, 2.6.37.5 on Slackware
> filesystems: xfs, ext4
> nfsd counts: 8,32,64,127,128,256,1024
> schedulers: cfq,deadline
> export options: async,no_root_squash
>=20
> Client side:
> kernel: 2.6.31.14-0.6-desktop, x86_64, from openSUSE 11.3
> hard,intr,noatime,vers=3D3,mountvers=3D3 # always on
> rsize,wsize:=C2=A0 32768,65536
> proto:=C2=A0 =C2=A0 =C2=A0 =C2=A0 tcp,udp
> nolock=C2=A0 =C2=A0 =C2=A0 =C2=A0 # on or off
> noac=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 # on or off
> actimeo:=C2=A0 =C2=A0 =C2=A0 3,5,60,240,600=C2=A0 # I had really hope=
d this would help
>=20
> Andrew
>=20
>=20
> --- On Thu, 3/31/11, Andrew Klaassen <clawsoon@yahoo.com> wrote:
>=20
> > Setting actimeo=3D600 gave me part of
> > the behaviour I expected; on the first directory listing,
> > the calls were all readdirplus and no getattr.
> >=20
> > However, there were now long stretches where nothing was
> > happening.=C2=A0 During a single directory listing to a
> > loaded server, there'd be:
> >=20
> >=C2=A0 ~10 seconds of readdirplus calls and replies, followed by
> >=C2=A0 ~70 seconds of nothing, followed by
> >=C2=A0 ~10 seconds of readdirplus calls and replies, followed by
> >=C2=A0 ~100 seconds of nothing, followed by
> >=C2=A0 ~10 seconds of readdirplus calls and replies, followed by
> >=C2=A0 ~110 seconds of nothing, followed by
> >=C2=A0 ~2 seconds of readdirplus calls and replies
> >=20
> > Why the long stretches of nothing?=C2=A0 If I'm reading my
> > tshark output properly, it doesn't seem like the client was
> > waiting for a server response.=C2=A0 Here are a couple of
> > lines before and after a long stretch of nothing:
> >=20
> >=C2=A0 28.575537 192.168.10.158 -> 192.168.10.5 NFS V3
> > READDIRPLUS Call, FH:0xa216e302
> >=C2=A0 28.593943 192.168.10.5 -> 192.168.10.158 NFS V3
> > READDIRPLUS Reply (Call In 358) random_1168.exr
> > random_2159.exr random_2188
> > .exr random_0969.exr random_1662.exr random_0022.exr
> > random_0785.exr random_2316.exr random_0831.exr
> > random_0443.exr random_
> > 1203.exr random_1907.exr
> >=C2=A0 28.594006 192.168.10.158 -> 192.168.10.5 NFS V3
> > READDIRPLUS Call, FH:0xa216e302
> >=C2=A0 28.623736 192.168.10.5 -> 192.168.10.158 NFS V3
> > READDIRPLUS Reply (Call In 362) random_1575.exr
> > random_0492.exr random_0335
> > .exr random_2460.exr random_0754.exr random_1114.exr
> > random_2001.exr random_2298.exr random_1858.exr
> > random_1889.exr random_
> > 2249.exr random_0782.exr
> > 103.811801 192.168.10.158 -> 192.168.10.5 NFS V3
> > READDIRPLUS Call, FH:0xa216e302
> > 103.883930 192.168.10.5 -> 192.168.10.158 NFS V3
> > READDIRPLUS Reply (Call In 2311) random_0025.exr
> > random_1665.exr random_231
> > 1.exr random_1204.exr random_0444.exr random_0836.exr
> > random_0332.exr random_0495.exr random_1572.exr
> > random_1900.exr random
> > _2467.exr random_1113.exr
> > 103.884014 192.168.10.158 -> 192.168.10.5 NFS V3
> > READDIRPLUS Call, FH:0xa216e302
> > 103.965167 192.168.10.5 -> 192.168.10.158 NFS V3
> > READDIRPLUS Reply (Call In 2316) random_0753.exr
> > random_2006.exr random_021
> > 6.exr random_1824.exr random_1456.exr random_1790.exr
> > random_1037.exr random_0677.exr random_2122.exr
> > random_0101.exr random
> > _1741.exr random_2235.exr
> >=20
> > Calls are sent and replies received at the 28 second mark,
> > and then... nothing... until the 103 second mark.=C2=A0 I'm
> > sure the server must be somehow telling the client that it's
> > busy, but - at least with the tools I'm looking at - I don't
> > see how.=C2=A0 Is tshark just hiding TCP delays and
> > retransmits from me?
> >=20
> > Thanks again.
> >=20
> > Andrew
> >=20
> >=20
> > --- On Thu, 3/31/11, Andrew Klaassen <clawsoon@yahoo.com>
> > wrote:
> >=20
> > > Interesting.=C2=A0 So the reason it's
> > > switching back and forth between readdirplus and
> > getattr
> > > during the same ls command is because the command is
> > taking
> > > so long to run that the cache is periodically expiring
> > as
> > > the command is running?
> > >=20
> > > I'll do some playing with actimeo to see if I'm
> > actually
> > > understanding this.
> > >=20
> > > Thanks!
> > >=20
> > > Andrew
> > >=20
> > >=20
> > > --- On Thu, 3/31/11, Steven Procter <steven-BxoHJBdta+vVtiohHAVwjA@public.gmane.org>
> > > wrote:
> > >=20
> > > > This is due to client caching.=C2=A0
> > > > When the second ls -l runs the cache
> > > > contains an entry for the directory.=C2=A0 The client
> > can
> > > > check if the cached
> > > > directory data is still valid by issuing a
> > GETATTR on
> > > the
> > > > directory.
> > > >=20
> > > > But this only validates the names, not the
> > > attributes,
> > > > which are not
> > > > actually part of the directory.=C2=A0 Those must be
> > > > refetched.=C2=A0 So the client
> > > > issues a GETATTR for each entry in the
> > directory.=C2=A0
> > > It
> > > > issues them
> > > > sequentially, probably as ls calls readdir() and
> > then
> > > > stat()
> > > > sequentially on the directory entries.
> > > >=20
> > > > This takes so long that the cache entry times out
> > and
> > > the
> > > > next time you
> > > > run ls -l the client reloads the directory using
> > > > READDIRPLUS.
> > > >=20
> > > > --Steven
> > > >=20
> > > > > X-Mailer: YahooMailClassic/12.0.2
> > > > YahooMailWebService/0.8.109.295617
> > > > > Date:=C2=A0=C2=A0=C2=A0 Thu, 31 Mar 2011 15:24:15
> > > > -0700 (PDT)
> > > > > From:=C2=A0=C2=A0=C2=A0 Andrew Klaassen <clawsoon@yahoo.com>
> > > > > Subject: readdirplus/getattr
> > > > > To:=C2=A0=C2=A0=C2=A0 linux-nfs@vger.kernel.org
> > > > > Sender:=C2=A0=C2=A0=C2=A0 linux-nfs-owner@vger.kernel.org
> > > > >=20
> > > > > Hi,
> > > > >=20
> > > > > I've been trying to get my Linux NFS clients
> > to
> > > be a
> > > > little snappier about listing large directories
> > from
> > > > heavily-loaded servers.=C2=A0 I found the following
> > > > fascinating behaviour (this is with
> > > 2.6.31.14-0.6-desktop,
> > > > x86_64, from openSUSE 11.3, Solaris Express 11
> > NFS
> > > server):
> > > > >=20
> > > > > With "ls -l --color=3Dnone" on a directory
> > with
> > > 2500
> > > > files:
> > > > >=20
> > > > >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0
> > > > |=C2=A0 =C2=A0 =C2=A0 rdirplus=C2=A0=C2=A0=C2=A0|=C2=A0
> > > > =C2=A0 nordirplus=C2=A0=C2=A0=C2=A0|
> > > > >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0
> > > > |1st=C2=A0 |2nd=C2=A0 |1st=C2=A0 |1st=C2=A0 |2nd=C2=A0
> > > > |1st=C2=A0 |
> > > > >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0
> > > > |run=C2=A0 |run=C2=A0 |run=C2=A0 |run=C2=A0 |run=C2=A0
> > > > |run=C2=A0 |
> > > > >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0
> > > > |light|light|heavy|light|light|heavy|
> > > > >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |load
> > > > |load |load |load |load |load |
> > > > >
> > > --------------------------------------------------
> > > > > readdir=C2=A0 =C2=A0 =C2=A0 |=C2=A0=C2=A0=C2=A00
> > > > |=C2=A0=C2=A0=C2=A00 |=C2=A0=C2=A0=C2=A00 |=C2=A0 25
> > > > |=C2=A0=C2=A0=C2=A00 |=C2=A0 25 |
> > > > > readdirplus=C2=A0 | 209 |=C2=A0=C2=A0=C2=A00 | 276
> > > > |=C2=A0=C2=A0=C2=A00 |=C2=A0=C2=A0=C2=A00
> > > > |=C2=A0=C2=A0=C2=A00 |
> > > > > lookup=C2=A0 =C2=A0 =C2=A0=C2=A0=C2=A0|=C2=A0 16
> > > > |=C2=A0=C2=A0=C2=A00 |=C2=A0 10 |2316 |=C2=A0=C2=A0=C2=A00
> > > > |2473 |
> > > > > getattr=C2=A0 =C2=A0 =C2=A0 |=C2=A0=C2=A0=C2=A01 |2501
> > > > |2452 |=C2=A0=C2=A0=C2=A01 |2465 |=C2=A0=C2=A0=C2=A01 |
> > > > >=20
> > > > > The most interesting case is with rdirplus
> > > specified
> > > > as a mount option to a heavily loaded server.=C2=A0
> > The
> > > NFS
> > > > client keeps switching back and forth between
> > > readdirplus
> > > > and getattr:
> > > > >=20
> > > > >=C2=A0 ~10 seconds doing ~70 readdirplus calls,
> > > > followed by
> > > > >=C2=A0 ~150 seconds doing ~800 gettattr calls,
> > > followed
> > > > by
> > > > >=C2=A0 ~12 seconds doing ~70 readdirplus calls,
> > > > followed by
> > > > >=C2=A0 ~200 seconds doing ~800 gettattr calls,
> > > followed
> > > > by
> > > > >=C2=A0 ~20 seconds doing ~130 readdirplus calls,
> > > > followed by
> > > > >=C2=A0 ~220 seconds doing ~800 gettattr calls
> > > > >=20
> > > > > All the calls appear to get reasonably
> > prompt
> > > replies
> > > > (never more than a second or so), which makes me
> > > wonder why
> > > > it keeps switching back and forth between the
> > > > strategies.=C2=A0 (Especially since I've specified
> > > rdirplus
> > > > as a mount option.)
> > > > >=20
> > > > > Is it supposed to do that?
> > > > >=20
> > > > > I'd really like to see how it does with
> > > readdirplus
> > > > ~only~, no getattr calls, since it's spending
> > only 40
> > > > seconds in total on readdirplus calls compared to
> > 570
> > > > seconds in total on (redundant, I think, based on
> > the
> > > > lightly-loaded case) getattr calls.
> > > > >=20
> > > > > It'd also be nice to be able to force
> > > readdirplus
> > > > calls instead of getattr calls for second and
> > > subsequent
> > > > listings of a directory.
> > > > >=20
> > > > > I saw a recent thread talking about
> > readdirplus
> > > > changes in 2.6.37, so I'll give that a try when I
> > get
> > > a
> > > > chance to see how it behaves.
> > > > >=20
> > > > > Andrew
> > > > >=20
> > > > >=20
> > > > > --
> > > > > To unsubscribe from this list: send the
> > line
> > > > "unsubscribe linux-nfs" in
> > > > > the body of a message to majordomo@vger.kernel.org
> > > > > More majordomo info at=C2=A0 http://vger.kernel.org/majordomo=
-info.html
> > > > --
> > > > To unsubscribe from this list: send the line
> > > "unsubscribe
> > > > linux-nfs" in
> > > > the body of a message to majordomo@vger.kernel.org
> > > > More majordomo info at=C2=A0 http://vger.kernel.org/majordomo-i=
nfo.html
> > > >=20
> > > --
> > > To unsubscribe from this list: send the line
> > "unsubscribe
> > > linux-nfs" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at=C2=A0 http://vger.kernel.org/majordomo-inf=
o.html
> > >=20
> > --
> > To unsubscribe from this list: send the line "unsubscribe
> > linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at=C2=A0 http://vger.kernel.org/majordomo-info.=
html
> >
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
