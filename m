From: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
Subject: RE: nfs unlink perf !
Date: Tue, 13 Aug 2002 17:05:25 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8D7D56C6ED3DD411998D009027DC685E0874E222@srv-grp-s1.segin.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from hermes4.atos-group.com ([160.92.18.11])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17edEl-000819-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 08:05:35 -0700
To: nfs@lists.sourceforge.net
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

I have check my code, the unlink is done after the close.


> -----Original Message-----
> From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
> Sent: Monday, August 12, 2002 8:55 PM
> To: Brasseur Val=E9ry
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] nfs unlink perf !
>=20
>=20
> >>>>> " " =3D=3D Brasseur Val=E9ry <Valery.Brasseur@atosorigin.com> =
writes:
>=20
>      > I am testing an application which to a lot of link/unlink
>      > server is a NetApp filer, client is linux 2.4.19+nfs patches.
>=20
>      > under load it seems that the unlink call is very long when all
>      > over calls response time seems to be OK.  is there any =
problems
>      > with the unlink code ?
>=20
> There should be no problems, but it depends on what type of test you
> are doing...
>=20
> The NFS protocol has to work around some nasty compatibility problems
> w.r.t. the POSIX expected behaviour of unlink. In particular, POSIX
> allows you to do
>=20
>   open(file);
>   write(file);
>   unlink(file);
>   read(file);
>   close(file);
>=20
> i.e. to unlink an open file...
>=20
> In order for the above to work with NFS, one can't immediately unlink
> the file when it is open(). Instead, NFS does a 'sillyrename': it
> renames the file to something of the form .nfsXXXXX (where XXXX is
> some number) and then performs the unlink when the 'close()' has been
> performed.
>=20
> Would this suffice to explain your 'bad performance'?
>=20
> Cheers,
>   Trond
>=20


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
