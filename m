From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: NFS server hang, looking for suggestions
Date: Thu, 21 Apr 2005 11:09:10 -0700
Message-ID: <1114106950.27207.130.camel@seki.nac.uci.edu>
References: <426735CC.9020900@pacbell.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-JaN8kQH9GDOE3UUS15iK"
Cc: strombrg@dcs.nac.uci.edu, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOg6z-0003y5-HP
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 11:09:13 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DOg6y-0003XL-Pu
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 11:09:13 -0700
To: Kenneth Sumrall <ksumrall@pacbell.net>
In-Reply-To: <426735CC.9020900@pacbell.net>
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


--=-JaN8kQH9GDOE3UUS15iK
Content-Type: multipart/alternative; boundary="=-kS/Uj0ylTod4kLr3HmPT"


--=-kS/Uj0ylTod4kLr3HmPT
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


You may find that if you back it up, and repartition into a bunch of 2
terabyte partitions, that you'll get something more stable.  If that
works, then you can be pretty much assured that the problem is somehow
related to the 2T limit.  If you cannot give up your single 2T+ slice,
you might try going to x86-64 or PowerPC, or even sparcv9.

You probably should check your logs, if you haven't already.

Some URL's that you might find (somewhat :) relevant:

http://dcs.nac.uci.edu/~strombrg/Problem-solving-on-unix-linux-
systems.html

http://dcs.nac.uci.edu/~strombrg/NFS-troubleshooting-2.html

http://dcs.nac.uci.edu/~strombrg/crashy-system.html

http://dcs.nac.uci.edu/~strombrg/RAID-notes.html

FWIW, we had some very bad experiences with both Lustre and GFS, in
combination with NFS, on some x86 (32 bit) systems with SuperMicro
motherboards.  We never figured out definitively if it was related to
(both of) the distributed filesystems, the 3Ware RAID controllers, the
Maxtor disks, the SuperMicro motherboards, or some combination.  Anyway,
IBM is going to take their hardware back, and give us our money back in
return...

On Wed, 2005-04-20 at 22:10 -0700, Kenneth Sumrall wrote:

> At work, we have a very large (5.6 Tb) SCSI raid unit, which is formatted
> as 1 XFS filesystem.  It is connected to a SuperMicro 6012P-6 dual CPU
> Pentium-4 server.  The server is running on Suse 9.2, but we've upgraded
> the kernel from the 2.6.8 that shipped with it to 2.6.11.7 from kernel.or=
g.
> The server exports the XFS filesystem using the kernel NFSD Version 3.
>=20
> The machine has recently been hanging on a regular basis.  We think it's
> related to NFS as the hangs often occur during a time in our nightly buil=
ds
> when a bunch of machines are all writing data to the server at the same t=
ime.
> However, sometimes the hangs occur when the write load is not as heavy.
>=20
> The things we've tried are:
>    Swap the server box with a spare.  Just to make sure it's not a hardwa=
re
>    problem.
>=20
>    Tried booting with "nosmp noapic" in case SMP was causing us problems.
>=20
>    Update to 2.6.11.7, because I read about a problem exporting XFS over =
NFS
>    in 2.6.8.  One thing I'm not clear on, with the 2.6.8 XFS over NFS bug=
,
>    could that cause XFS filesystem corruption.  Should I run xfs_check on
>    my XFS filesystem?
>=20
>    We recently re-cabled a bunch of the clients for this machine, and in =
the
>    process, removed a choke point where 13 of our clients were funnelled =
through
>    a 100 Mbs ethernet switch.  That could have caused major fragmentation=
 issues,
>    which I've read are a bad thing.  It's only been 1 day since we did th=
at, so
>    no data yet on if things are better.
>=20
> Other things to note.  Because the RAID is so big, we are running XFS dir=
ectly
> on the raw disk device, not a partition.  The partition format seems to h=
ave
> problems with sizes over 2 terabytes.  Of course, I had to turn on CONFIG=
_LBD
> in order to access such a large block device.
>=20
> The ethernet interface is an e1000 gigabit interface.  It plugs directly =
into
> our main Foundry ethernet switch.  The clients all have 100 Mbit interfac=
es, but
> there's a bunch of them.
>=20
> Also, the RAID uses a sector size of 2048 bytes, not the typical 512 byte=
s.
> The SCSI controller in the server is an Adaptec Ultra160 chip, and we're =
using
> the aic7xxx driver.
>=20
> Does anyone have any suggestions on how to further diagnose our problem? =
 I've
> not used magic sysrq before, but I'm thinking maybe trying to dump a list=
 of
> current tasks, and the registers might be useful to see if it hangs in th=
e
> same place everytime.  Or I could apply the KGDB patch, and try using tha=
t.
>=20
> Does anyone have any other ideas on how to diagnose this?  Any known prob=
lems
> I'm not aware of?  I'd really like to make this server rock solid.
>=20
> Thanks.
>=20
> Ken Sumrall
> ksumrall@pacbell.net
>=20
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by: New Crystal Reports XI.
> Version 11 adds new functionality designed to reduce time involved in
> creating, integrating, and deploying reporting solutions. Free runtime in=
fo,
> new features, or free trial, at: http://www.businessobjects.com/devxi/728
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

--=-kS/Uj0ylTod4kLr3HmPT
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 TRANSITIONAL//EN">
<HTML>
<HEAD>
  <META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; CHARSET=3DUTF-8">
  <META NAME=3D"GENERATOR" CONTENT=3D"GtkHTML/3.3.2">
</HEAD>
<BODY>
<BR>
You may find that if you back it up, and repartition into a bunch of 2 tera=
byte partitions, that you'll get something more stable.&nbsp; If that works=
, then you can be pretty much assured that the problem is somehow related t=
o the 2T limit.&nbsp; If you cannot give up your single 2T+ slice, you migh=
t try going to x86-64 or PowerPC, or even sparcv9.<BR>
<BR>
You probably should check your logs, if you haven't already.<BR>
<BR>
Some URL's that you might find (somewhat :) relevant:<BR>
<BR>
<A HREF=3D"http://dcs.nac.uci.edu/~strombrg/Problem-solving-on-unix-linux-s=
ystems.html">http://dcs.nac.uci.edu/~strombrg/Problem-solving-on-unix-linux=
-systems.html</A><BR>
<BR>
<A HREF=3D"http://dcs.nac.uci.edu/~strombrg/NFS-troubleshooting-2.html">htt=
p://dcs.nac.uci.edu/~strombrg/NFS-troubleshooting-2.html</A><BR>
<BR>
<A HREF=3D"http://dcs.nac.uci.edu/~strombrg/crashy-system.html">http://dcs.=
nac.uci.edu/~strombrg/crashy-system.html</A><BR>
<BR>
<A HREF=3D"http://dcs.nac.uci.edu/~strombrg/RAID-notes.html">http://dcs.nac=
.uci.edu/~strombrg/RAID-notes.html</A><BR>
<BR>
FWIW, we had some very bad experiences with both Lustre and GFS, in combina=
tion with NFS, on some x86 (32 bit) systems with SuperMicro motherboards.&n=
bsp; We never figured out definitively if it was related to (both of) the d=
istributed filesystems, the 3Ware RAID controllers, the Maxtor disks, the S=
uperMicro motherboards, or some combination.&nbsp; Anyway, IBM is going to =
take their hardware back, and give us our money back in return...<BR>
<BR>
On Wed, 2005-04-20 at 22:10 -0700, Kenneth Sumrall wrote:
<BLOCKQUOTE TYPE=3DCITE>
<PRE>
<FONT COLOR=3D"#000000">At work, we have a very large (5.6 Tb) SCSI raid un=
it, which is formatted</FONT>
<FONT COLOR=3D"#000000">as 1 XFS filesystem.  It is connected to a SuperMic=
ro 6012P-6 dual CPU</FONT>
<FONT COLOR=3D"#000000">Pentium-4 server.  The server is running on Suse 9.=
2, but we've upgraded</FONT>
<FONT COLOR=3D"#000000">the kernel from the 2.6.8 that shipped with it to 2=
.6.11.7 from kernel.org.</FONT>
<FONT COLOR=3D"#000000">The server exports the XFS filesystem using the ker=
nel NFSD Version 3.</FONT>

<FONT COLOR=3D"#000000">The machine has recently been hanging on a regular =
basis.  We think it's</FONT>
<FONT COLOR=3D"#000000">related to NFS as the hangs often occur during a ti=
me in our nightly builds</FONT>
<FONT COLOR=3D"#000000">when a bunch of machines are all writing data to th=
e server at the same time.</FONT>
<FONT COLOR=3D"#000000">However, sometimes the hangs occur when the write l=
oad is not as heavy.</FONT>

<FONT COLOR=3D"#000000">The things we've tried are:</FONT>
<FONT COLOR=3D"#000000">   Swap the server box with a spare.  Just to make =
sure it's not a hardware</FONT>
<FONT COLOR=3D"#000000">   problem.</FONT>

<FONT COLOR=3D"#000000">   Tried booting with &quot;nosmp noapic&quot; in c=
ase SMP was causing us problems.</FONT>

<FONT COLOR=3D"#000000">   Update to 2.6.11.7, because I read about a probl=
em exporting XFS over NFS</FONT>
<FONT COLOR=3D"#000000">   in 2.6.8.  One thing I'm not clear on, with the =
2.6.8 XFS over NFS bug,</FONT>
<FONT COLOR=3D"#000000">   could that cause XFS filesystem corruption.  Sho=
uld I run xfs_check on</FONT>
<FONT COLOR=3D"#000000">   my XFS filesystem?</FONT>

<FONT COLOR=3D"#000000">   We recently re-cabled a bunch of the clients for=
 this machine, and in the</FONT>
<FONT COLOR=3D"#000000">   process, removed a choke point where 13 of our c=
lients were funnelled through</FONT>
<FONT COLOR=3D"#000000">   a 100 Mbs ethernet switch.  That could have caus=
ed major fragmentation issues,</FONT>
<FONT COLOR=3D"#000000">   which I've read are a bad thing.  It's only been=
 1 day since we did that, so</FONT>
<FONT COLOR=3D"#000000">   no data yet on if things are better.</FONT>

<FONT COLOR=3D"#000000">Other things to note.  Because the RAID is so big, =
we are running XFS directly</FONT>
<FONT COLOR=3D"#000000">on the raw disk device, not a partition.  The parti=
tion format seems to have</FONT>
<FONT COLOR=3D"#000000">problems with sizes over 2 terabytes.  Of course, I=
 had to turn on CONFIG_LBD</FONT>
<FONT COLOR=3D"#000000">in order to access such a large block device.</FONT=
>

<FONT COLOR=3D"#000000">The ethernet interface is an e1000 gigabit interfac=
e.  It plugs directly into</FONT>
<FONT COLOR=3D"#000000">our main Foundry ethernet switch.  The clients all =
have 100 Mbit interfaces, but</FONT>
<FONT COLOR=3D"#000000">there's a bunch of them.</FONT>

<FONT COLOR=3D"#000000">Also, the RAID uses a sector size of 2048 bytes, no=
t the typical 512 bytes.</FONT>
<FONT COLOR=3D"#000000">The SCSI controller in the server is an Adaptec Ult=
ra160 chip, and we're using</FONT>
<FONT COLOR=3D"#000000">the aic7xxx driver.</FONT>

<FONT COLOR=3D"#000000">Does anyone have any suggestions on how to further =
diagnose our problem?  I've</FONT>
<FONT COLOR=3D"#000000">not used magic sysrq before, but I'm thinking maybe=
 trying to dump a list of</FONT>
<FONT COLOR=3D"#000000">current tasks, and the registers might be useful to=
 see if it hangs in the</FONT>
<FONT COLOR=3D"#000000">same place everytime.  Or I could apply the KGDB pa=
tch, and try using that.</FONT>

<FONT COLOR=3D"#000000">Does anyone have any other ideas on how to diagnose=
 this?  Any known problems</FONT>
<FONT COLOR=3D"#000000">I'm not aware of?  I'd really like to make this ser=
ver rock solid.</FONT>

<FONT COLOR=3D"#000000">Thanks.</FONT>

<FONT COLOR=3D"#000000">Ken Sumrall</FONT>
<FONT COLOR=3D"#000000"><A HREF=3D"mailto:ksumrall@pacbell.net">ksumrall@pa=
cbell.net</A></FONT>



<FONT COLOR=3D"#000000">---------------------------------------------------=
----</FONT>
<FONT COLOR=3D"#000000">This SF.Net email is sponsored by: New Crystal Repo=
rts XI.</FONT>
<FONT COLOR=3D"#000000">Version 11 adds new functionality designed to reduc=
e time involved in</FONT>
<FONT COLOR=3D"#000000">creating, integrating, and deploying reporting solu=
tions. Free runtime info,</FONT>
<FONT COLOR=3D"#000000">new features, or free trial, at: <A HREF=3D"http://=
www.businessobjects.com/devxi/728">http://www.businessobjects.com/devxi/728=
</A></FONT>
<FONT COLOR=3D"#000000">_______________________________________________</FO=
NT>
<FONT COLOR=3D"#000000">NFS maillist  -  <A HREF=3D"mailto:NFS@lists.source=
forge.net">NFS@lists.sourceforge.net</A></FONT>
<FONT COLOR=3D"#000000"><A HREF=3D"https://lists.sourceforge.net/lists/list=
info/nfs">https://lists.sourceforge.net/lists/listinfo/nfs</A></FONT>
</PRE>
</BLOCKQUOTE>
</BODY>
</HTML>

--=-kS/Uj0ylTod4kLr3HmPT--

--=-JaN8kQH9GDOE3UUS15iK
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCZ+xGo0feVm00f/8RAm8SAJ9e+1UvFKDO4QgO1srzuK4c+G/AbwCghw7o
IpG+0Q7AmKcPNnHU5bkUBZs=
=TwFP
-----END PGP SIGNATURE-----

--=-JaN8kQH9GDOE3UUS15iK--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
