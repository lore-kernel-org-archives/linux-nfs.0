From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: nfs over tcp in linux kernel version 2.4.18
Date: Wed, 21 May 2003 13:47:00 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611312751A@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19IaUQ-0004F5-00
	for <nfs@lists.sourceforge.net>; Wed, 21 May 2003 13:47:10 -0700
To: "David Myer" <davidmyer800@yahoo.com>
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

david-

TCP support for the server is enabled on 2.4.20 with
a kernel build option.  it may only appear if you have
checked the "Prompt for development and/or incomplete
code/drivers" box under "Code maturity level options."

i don't see why a 2.4.18 NFS client shouldn't work
with the 2.4.20 server over TCP, but the server TCP
support is still under development so it may be a
little rocky.

> -----Original Message-----
> From: David Myer [mailto:davidmyer800@yahoo.com]
> Sent: Wednesday, May 21, 2003 1:25 PM
> To: David Myer; Dan Brunner; guolin@alexa.com
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] nfs over tcp in linux kernel version 2.4.18
>=20
>=20
> Any thoughts on my questions guys ? Would appreciate
> any information.
>=20
> Also, will 2.4.18 kernel as nfs client work with
> 2.4.20 kernel as nfs server if trying to tcp ? Anyone
> have tried this ?
>=20
> David
> --- David Myer <davidmyer800@yahoo.com> wrote:
> > Thanks for the information guys,
> >=20
> > Looking at svcsock.c in 2.4.18/linux/net/sunrpc/
> > it does seem to have STREAM type of socket support.
> > if I just want to do basic mount/ls/vi type of
> > operations, which patch do I actually need or is
> > there
> > a comiple switch to set during kernel compilation
> > time
> > just to enable TCP support on sever side ? Client
> > side
> > definitely has this by looking at xprt.c code..
> >=20
> > Thanks again
> > David
> > --- Dan Brunner <daniel.brunner@duni.com> wrote:
> > > Guolin,
> > >=20
> > > That DOES sound like a pain in the a$$!!!!!!!
> > >=20
> > > And yes your right, not everyone has the same
> > > success...
> > >=20
> > > Good Luck!!
> > >=20
> > >=20
> > > Dan
> > >=20
> > >=20
> > > On Tuesday, May 20, 2003, at 02:19  PM,
> > > guolin@alexa.com wrote:
> > >=20
> > > > Dan,
> > > >
> > > >  try your luck.
> > > >
> > > >  BTW, let you know that I have to take the pain
> > to
> > > reboot 400 Linux=20
> > > > boxes to
> > > > get rid of "nfs over tcp" in our production
> > > environment.
> > > >
> > > >  --Guolin Cheng
> > > >
> > > > -----Original Message-----
> > > > From: Dan Brunner
> > [mailto:daniel.brunner@duni.com]
> > > > Sent: Tuesday, May 20, 2003 12:14 PM
> > > > To: Guolin Cheng
> > > > Cc: davidmyer800@yahoo.com;
> > > nfs@lists.sourceforge.net
> > > > Subject: Re: [NFS] nfs over tcp in linux kernel
> > > version 2.4.18
> > > >
> > > >
> > > > Guolin,
> > > >
> > > > I can't seem to agree with this...
> > > >
> > > > Maybe I don't have that many connections (17),
> > but
> > > I've been running
> > > > NFS over TCP since 2.4.18. And I haven't had
> > once
> > > MAJOR crash yet!! My
> > > > clients however, are all Mac OS X clients.
> > > 10.0.4-10.2.6.
> > > >
> > > > Maybe that has something to do with it....
> > > >
> > > >
> > > > And we don't get a lot of hangs either....
> > > >
> > > >
> > > > later
> > > >
> > > >
> > > > Dan
> > > >
> > > >
> > > > On Tuesday, May 20, 2003, at 01:41  PM,
> > > guolin@alexa.com wrote:
> > > >
> > > >> David,
> > > >>
> > > >>  "nfs over tcp" is terribly unstable until now,
> > I
> > > use version 2.4.20,
> > > >> and
> > > >> find that over 30 simultaneous nfs connection
> > can
> > > kill an "nfs over
> > > >> tcp"
> > > >> Linux nfs server easily. let clients' processes
> > > hangs there forever.
> > > >> But
> > > >> this didn't happen for Linux nfs server
> > enabling
> > > only "nfs over udp".
> > > >>
> > > >>  So the best choice now is totally disregard
> > > Linux "nfs over tcp" in
> > > >> production environment. just try it in research
> > > environment.
> > > >>
> > > >>  Thanks.
> > > >>  --Guolin Cheng
> > > >>
> > > >>
> > > >> -----Original Message-----
> > > >> From: David Myer
> > [mailto:davidmyer800@yahoo.com]
> > > >> Sent: Tuesday, May 20, 2003 11:03 AM
> > > >> To: nfs@lists.sourceforge.net
> > > >> Subject: [NFS] nfs over tcp in linux kernel
> > > version 2.4.18
> > > >>
> > > >>
> > > >> Hi,
> > > >>
> > > >> Can anyone advise me if nfs server over tcp is
> > > >> supported in 2.4.18 kernel version ? How to
> > > >> setup/enable on both server/client side ? Tried
> > > to
> > > >> looked at FAQ but information did not seem be
> > > there.
> > > >>
> > > >> Do I need to apply any patches ?
> > > >>
> > > >> Thanks
> > > >> David
> > > >>
> > > >> __________________________________
> > > >> Do you Yahoo!?
> > > >> The New Yahoo! Search - Faster. Easier. Bingo.
> > > >> http://search.yahoo.com
> > > >>
> > > >>
> > > >>
> > >
> >
> -------------------------------------------------------
> > > >> This SF.net email is sponsored by: ObjectStore.
> > > >> If flattening out C++ or Java code to make your
> > > application fit in a
> > > >> relational database is painful, don't do it!
> > > Check out ObjectStore.
> > > >> Now part of Progress Software.
> > > http://www.objectstore.net/sourceforge
> > > >> _______________________________________________
> > > >> NFS maillist  -  NFS@lists.sourceforge.net
> > > >>
> > https://lists.sourceforge.net/lists/listinfo/nfs
> > > >>
> > > >>
> > > >>
> > >
> >
> -------------------------------------------------------
> > > >> This SF.net email is sponsored by: ObjectStore.
> > > >> If flattening out C++ or Java code to make your
> > > application fit in a
> > > >> relational database is painful, don't do it!
> > > Check out ObjectStore.
> > > >> Now part of Progress Software.
> > > http://www.objectstore.net/sourceforge
> > > >> _______________________________________________
> > > >> NFS maillist  -  NFS@lists.sourceforge.net
> > > >>
> > https://lists.sourceforge.net/lists/listinfo/nfs
> > >=20
> > >=20
> > >=20
> > >
> >
> -------------------------------------------------------
> > > This SF.net email is sponsored by: ObjectStore.
> > > If flattening out C++ or Java code to make your
> > > application fit in a
> > > relational database is painful, don't do it! Check
> > > out ObjectStore.
> > > Now part of Progress Software.
> > > http://www.objectstore.net/sourceforge
> > > _______________________________________________
> > > NFS maillist  -  NFS@lists.sourceforge.net
> > > https://lists.sourceforge.net/lists/listinfo/nfs
> >=20
> > __________________________________
> > Do you Yahoo!?
> > The New Yahoo! Search - Faster. Easier. Bingo.
> > http://search.yahoo.com
> >=20
> >=20
> >
> -------------------------------------------------------
> > This SF.net email is sponsored by: ObjectStore.
> > If flattening out C++ or Java code to make your
> > application fit in a
> > relational database is painful, don't do it! Check
> > out ObjectStore.
> > Now part of Progress Software.
> > http://www.objectstore.net/sourceforge
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> >=20
> =3D=3D=3D message truncated =3D=3D=3D
>=20
> __________________________________
> Do you Yahoo!?
> The New Yahoo! Search - Faster. Easier. Bingo.
> http://search.yahoo.com
>=20
>=20
> -------------------------------------------------------
> This SF.net email is sponsored by: ObjectStore.
> If flattening out C++ or Java code to make your application fit in a
> relational database is painful, don't do it! Check out ObjectStore.
> Now part of Progress Software. http://www.objectstore.net/sourceforge
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
