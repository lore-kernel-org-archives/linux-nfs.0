From: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
Subject: RE: nfs_notify_change: revalidate_failed, error=-512
Date: Tue, 11 Mar 2003 12:41:04 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B916A3286D@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from usamail1.conoco.com ([12.31.208.226])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18sogf-0008HJ-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Mar 2003 10:41:17 -0800
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
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

Cute.

I will need to figure out exactly how this is happening then, this is in =
the
middle of a non-interactive (PBS Queued) job, I don't think anyone has a
tty to press ctrl-c on, but one could send the corresponding signal,=20
knowing that I will examine things more closely to see if I can =
determine
the real cause.

                             Roger

> -----Original Message-----
> From:	Trond Myklebust [SMTP:trond.myklebust@fys.uio.no]
> Sent:	Tuesday, March 11, 2003 12:34 PM
> To:	Heflin, Roger A.
> Cc:	nfs@lists.sourceforge.net
> Subject:	Re: [NFS] nfs_notify_change: revalidate_failed, error=3D-512
>=20
> >>>>> " " =3D=3D Roger A Heflin <Heflin> writes:
>=20
>      > 	Hello,
>=20
>      > 	I am getting the following error on the client end.
>=20
>      > 	nfs_notify_change: revalidate_failed, error=3D-512
>=20
> 512 =3D=3D ERESTARTSYS =3D> somebody pressed Ctrl-C while the process =
was in
> the middle of the RPC call. Should be no big deal...
>=20
> Cheers,
>   Trond


-------------------------------------------------------
This SF.net email is sponsored by:Crypto Challenge is now open! 
Get cracking and register here for some mind boggling fun and 
the chance of winning an Apple iPod:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
