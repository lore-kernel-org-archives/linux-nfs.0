From: btinsley <btinsley@gmail.com>
Subject: Re: NFS High Availability Cluster
Date: Mon, 13 Jun 2005 06:47:43 -0500
Message-ID: <263a8b3505061304472dee4701@mail.gmail.com>
References: <42AD5820.4060109@gmail.com>
Reply-To: btinsley <btinsley@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DhnPt-0002hs-Ev
	for nfs@lists.sourceforge.net; Mon, 13 Jun 2005 04:47:45 -0700
Received: from wproxy.gmail.com ([64.233.184.192])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DhnPs-0002WX-2D
	for nfs@lists.sourceforge.net; Mon, 13 Jun 2005 04:47:45 -0700
Received: by wproxy.gmail.com with SMTP id 69so972881wra
        for <nfs@lists.sourceforge.net>; Mon, 13 Jun 2005 04:47:43 -0700 (PDT)
To: nfs@lists.sourceforge.net
In-Reply-To: <42AD5820.4060109@gmail.com>
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

To get started, see:

http://wiki.linux-ha.org/HaNFS


On 6/13/05, Oded Maimon <oded.maimon@gmail.com> wrote:
> Hi,
>=20
> Is it possible to set an NFS HA cluster?
>=20
> That means, that several servers will share the same disks in a SAN and
> will provide an NFS service for
>=20
> all my other servers?
>=20
>=20
> I need that when one NFS server will fail (or the network connection to
> it)  then no server using the NFS will be affected and will continue to
>=20
> work with one of the other NFS servers.
>=20
>=20
> Is it possible?
>=20
>=20
> Thanks,
>=20
> Oded.
>=20
>=20
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you sho=
tput
> a projector? How fast can you ride your desk chair down the office luge t=
rack?
> If you want to score the big prize, get to know the little guy.
> Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=3D20
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>


-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.  
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
