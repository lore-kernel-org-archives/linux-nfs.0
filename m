From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: Linux' NFS locking b0rken?
Date: Tue, 25 May 2004 13:08:25 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0405251307290.24001-100000@fattire.ngdc.noaa.gov>
References: <1085511385.11596.21.camel@tesuji.nac.uci.edu>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
   Jeffrey Layton <jtlayton@poochiereds.net>, Olaf Kirch <okir@suse.de>,
   <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BShI9-0002Eq-Ba
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 12:08:49 -0700
Received: from fattire.ngdc.noaa.gov ([140.172.187.207])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BShI8-0008VN-V4
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 12:08:48 -0700
To: Dan Stromberg <strombrg@dcs.nac.uci.edu>
In-Reply-To: <1085511385.11596.21.camel@tesuji.nac.uci.edu>
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

On Tue, 25 May 2004, Dan Stromberg wrote:

> On Tue, 2004-05-25 at 10:47, Trond Myklebust wrote:
> > P=E5 ty , 25/05/2004 klokka 12:42, skreiv Jeffrey Layton:
> >=20
> > > Perhaps Solaris does some sort of BSD-POSIX lock translation which ma=
kes
> > > flock() work there?
> >=20
> > The convention for local filesystems under Linux is that BSD and POSIX
> > locks are not allowed to see each other. That rules out using the above
> > trick for NFS.
> >=20
> > Cheers,
> >    Trond
>=20
> Actually, wouldn't you be OK if you had a flock that was just a wrapper
> around fcntl?

yes, in that it would work, you simply would not coordinate with other
processes which do NOT use fcntl based locks.  ruby and perl ship with
implemtations of flock which are, in fact, fctnl under the hood.

-a
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
