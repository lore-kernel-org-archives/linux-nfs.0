From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: statd for NFSv4 does not create file
Date: Thu, 14 Jul 2005 06:30:19 -0700 (PDT)
Message-ID: <20050714133019.30046.qmail@web51613.mail.yahoo.com>
References: <1121347282.8202.49.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net, steved@redhat.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dt3nH-0007vY-Qj
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 06:30:27 -0700
Received: from web51613.mail.yahoo.com ([68.142.224.86])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.44)
	id 1Dt3nF-00056z-8Q
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 06:30:27 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1121347282.8202.49.camel@lade.trondhjem.org>
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

Hi Trond ,=20
     Lock recovery worked with nfsv3 even if
     nfs server fail over to some other system
     This was possible because sm directory was shared
     across systems.
     Will this work with nfsv4 though there are
     no files in sm directory.=20

thanks,
 kiran

--- Trond Myklebust <trond.myklebust@fys.uio.no>
wrote:

> to den 14.07.2005 Klokka 05:55 (-0700) skreiv mehta
> kiran:
> > Hi ,=20
> >         I have observed the following.
> >         RHEL4 GA and U1=20
> >         client accesses filesystem exported
> >         by server using nfsv4 .
> >=20
> >         It takes lock  on a file.
> >         Other clients on "different" systems
> >         get NFSERR_DENIED and they retry to
> acquire
> >         lock.
> >=20
> >         When first client release lock , other
> client
> >         gets the lock.
> >         But when i see in /var/lib/nfs/statd/sm=20
> >         directory , i cannot see any file with
> >         name =3D server's name.
>=20
> An NFSv4 client has no use for statd. The NFSv4
> protocol has its own
> methods for tracking client and server reboots.
>=20
> Cheers,
>   Trond
>=20
>=20
>=20
>
-------------------------------------------------------
> This SF.Net email is sponsored by the 'Do More With
> Dual!' webinar happening
> July 14 at 8am PDT/11am EDT. We invite you to
> explore the latest in dual
> core and dual graphics technology at this free one
> hour event hosted by HP,=20
> AMD, and NVIDIA.  To register visit
> http://www.hp.com/go/dualwebinar
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happen=
ing
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by H=
P,=20
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
