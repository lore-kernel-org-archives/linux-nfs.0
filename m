From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: RE: How to unlock a file if an NFSv3 client dies forever?
Date: Wed, 26 May 2004 14:18:47 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0405261417060.24001-100000@fattire.ngdc.noaa.gov>
References: <4F28105F70F4324A8723F0C949088941BCB773@pa-exch5.vmware.com>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BT4rd-0004CC-8L
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 13:19:01 -0700
Received: from fattire.ngdc.noaa.gov ([140.172.187.207])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BT4rc-00076T-Jj
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 13:19:00 -0700
To: Howie Xu <howie@vmware.com>
In-Reply-To: <4F28105F70F4324A8723F0C949088941BCB773@pa-exch5.vmware.com>
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

On Wed, 26 May 2004, Howie Xu wrote:

> Thanks for letting me the workaround, it is nice to know. I am implementi=
ng
> my own NFS client, and of course I cannot expect my customers to do the s=
ame
> trick.:)=20
>=20
> This sounds a generic problem, and I wonder how other people deal with it=
?
> NLM is useless to me if I cannot find a nicer solution around it.
>=20
> Btw, anyone knows that NFSv4 is immune to this "dead lock" scenario?
>=20
> thanks a lot,
>=20
> -howie

it seems i had some luck at some point with this approach:

  mv dead_locked_file /tmp/dead_locked_file && mv /tmp/dead_locked_file dea=
d_locked_file

-a

>=20
> > > For example, if my linux NFS client holds a write lock on=20
> > /home/howie/README,
> > > then crashes and I reinstall the OS upon rebooting. Does=20
> > that mean my NFS
> > > server will hold this lock on this file *forever*? The NFS locks are
> > > advisory, but my other NFS clients who speak NLM with the=20
> > same NFS server
> > > will not be granted lock for a file no one else ever cares.:(
> >=20
> > Here's a hack for how to do it.
> >=20
> >=20
> > On the client:
> >=20
> >         Stop the rpc.statd service
> >         touch /var/lib/nfs/sm/<ip-address-of-my-server>
> >         then restart rpc.statd
> >=20
> > Note that on some distributions, the path is /var/lib/nfs/statd/sm. It
> > may also be that your distribution runs rpc.statd as an unprivileged
> > user, in which case make sure that you chown the file
> > <ip-address-of-my-server> to that unprivileged user account.
> >=20
> > Cheers,
> >   Trond
> >=20
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by: Oracle 10g
> Get certified on the hottest thing ever to hit the market... Oracle 10g.=
=20
> Take an Oracle 10g class now, and we'll give you the exam FREE.
> http://ads.osdn.com/?ad_id149&alloc_id=8166&op=CCk
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20

--=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| ADDRESS :: E/GC2 325 Broadway, Boulder, CO 80305-3328
| URL     :: http://www.ngdc.noaa.gov/stp/
| "640K ought to be enough for anybody." - Bill Gates, 1981
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D



-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
