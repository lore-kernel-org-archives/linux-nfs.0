From: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
Subject: RE: 2.4.19 hang (was unlink perf pb !)
Date: Wed, 14 Aug 2002 14:12:03 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8D7D56C6ED3DD411998D009027DC685E0874E22A@srv-grp-s1.segin.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from hermes8.atos-group.com ([160.92.18.57] helo=hermes8.segin.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ex0I-0003hV-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 05:11:58 -0700
To: "'Lever, Charles'" <Charles.Lever@netapp.com>
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

try a stock 2.4.19 without nfs patches : no hang !


seems that nfs patches broke something !

valery

> -----Original Message-----
> From: Lever, Charles [mailto:Charles.Lever@netapp.com]
> Sent: Tuesday, August 13, 2002 8:42 PM
> To: 'Brasseur Val=E9ry'
> Cc: nfs@lists.sourceforge.net
> Subject: RE: [NFS] 2.4.19 hang (was unlink perf pb !)
>=20
>=20
> if your client works OK with 2.4.18 but stops with your 2.4.19+nfs
> kernels, can you try hunting down exactly which kernel causes the
> problem?  does 2.4.19 without any nfs patches work, for example?
>=20
> > after some more investigation on my D state hang here is some=20
> > observations :
> >=20
> > * I couldn't get a clear trace of state : sysrq-t was not=20
> > dump on a file !
> > don't know why !
> >   so I hand wrote extract of what I see and let ksymsoops try !
> > =20
> >    got this : processes was in kmap or in flush_tbl !
> >=20
> > * now after a clean boot, lauchn my prog : after a few second=20
> > the LA grow,
> > blocked processes grow too ! (in my vmstat all the processes=20
> > are in block
> > queue !) and only 1 waiting process !
> >=20
> >   when in this state, I can't do  many things as all what I=20
> > can do seems to
> > hang too !
> >=20
> > =3D> I was not having this probleme in 2.4.18 !
> >=20
> > note : when this arrive I've got something like 10 to 20 Mbs=20
> > to nfs server.
> >=20
> >=20
> > valery
> >=20
> >=20
> >=20
> > -------------------------------------------------------
> > This sf.net email is sponsored by: Dice - The leading=20
> online job board
> > for high-tech professionals. Search and apply for tech jobs today!
> > http://seeker.dice.com/seeker.epl?rel_code=3D31
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> >=20
>=20


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
