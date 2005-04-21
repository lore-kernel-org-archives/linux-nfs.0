From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Detectiong Network and umount / mount NFS
Date: Thu, 21 Apr 2005 17:20:52 -0400
Message-ID: <1114118453.12750.44.camel@lade.trondhjem.org>
References: <1114027379.4266b57354785@webmail.tusofona.com>
	 <4266C21D.9030305@RedHat.com>
	 <1114038052.4266df245e54e@webmail.tusofona.com>
	 <1114042784.17214.11.camel@lade.trondhjem.org>
	 <Pine.LNX.4.61.0504211009380.3889@maggie.lkpg.cendio.se>
	 <1114088708.10727.9.camel@lade.trondhjem.org>
	 <Pine.LNX.4.61.0504212119170.16285@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOj6g-0004vD-Ml
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 14:21:06 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DOj6e-0001Sa-SQ
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 14:21:06 -0700
To: Peter =?ISO-8859-1?Q?=C5strand?= <astrand@cendio.se>
In-Reply-To: <Pine.LNX.4.61.0504212119170.16285@maggie.lkpg.cendio.se>
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

to den 21.04.2005 Klokka 21:26 (+0200) skreiv Peter =C3=85strand:
> On Thu, 21 Apr 2005, Trond Myklebust wrote:
>=20
> > to den 21.04.2005 Klokka 10:14 (+0200) skreiv Peter =C3=85strand:
> >>> If you want that sort of behaviour, then read all about the "soft" mo=
unt
> >>> option ("man 5 nfs", and http://nfs.sourceforge.net/#faq_d6).
> >>
> >> I think Esqueleto wants a Solaris-type "umount -f". I'd like to have t=
hat
> >> too.
> >
> > You didn't actually read that FAQ entry, that I pointed to, did you?
> > Please do.
>=20
> I did not, because I thought it was only about soft mounts. I don't want=20
> soft mounts.
>=20
> I've read it now, but it didn't make me much wiser. It talks about soft=20
> mounts, which I don't want. It takes about killing processes, which I=20
> don't want to do by hand: I think "umount -f" should suffice. The the=20
> processes itself can decide what to do with the EIO.

The kernel already aborts all pending I/O and returns EIO with "umount
-f". That doesn't do anything for those tasks that are not waiting on
I/O, though. Nor will it do anything for those that handle EIOs without
aborting.

Solaris' version of "umount -f" combines the above behaviour with our
"lazy umount". There's nothing stopping you doing that in linux too
("umount -lf"). That still doesn't guarantee that processes will die in
a timely manner, though.

> > This is not something that will happen soon, unless you or someone else=
=20
> > who feels strongly about it pulls up their sleeves, and starts=20
> > developing. Adding bugzilla entries for this type of feature will just=20
> > serve to annoy.
>=20
> I'm patient. I don't understand why people are annoyed by bugzilla=20
> entries, though.

Three reasons:

  1) That bugzilla is meant for reporting kernel bugs, not for feature
requests

  2) It is rigged to send out periodic mails. Whereas that may be useful
for bugs, it only serves to irritate when it comes to feature requests.

  3) There is in any case no provision for "voting" in that bugzilla.
The kernel works on the principle "Whoever wants the feature is free to
implement it at their leisure".

--=20
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
