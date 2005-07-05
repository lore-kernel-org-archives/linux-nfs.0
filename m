From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Linux client with MS SFU server
Date: Tue, 05 Jul 2005 14:05:27 -0400
Message-ID: <1120586727.8093.34.camel@lade.trondhjem.org>
References: <Pine.LNX.4.61.0507051838180.28175@maggie.lkpg.cendio.se>
	 <1120582557.8093.15.camel@lade.trondhjem.org>
	 <Pine.LNX.4.61.0507051918280.28861@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.91] (helo=sc8-sf-mx1-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dprnj-0002nX-E6
	for nfs@lists.sourceforge.net; Tue, 05 Jul 2005 11:05:43 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1-new.sourceforge.net with esmtp (Exim 4.44)
	id 1Dprnh-00024D-OA
	for nfs@lists.sourceforge.net; Tue, 05 Jul 2005 11:05:43 -0700
To: Peter =?ISO-8859-1?Q?=C5strand?= <astrand@cendio.se>
In-Reply-To: <Pine.LNX.4.61.0507051918280.28861@maggie.lkpg.cendio.se>
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

ty den 05.07.2005 Klokka 19:19 (+0200) skreiv Peter =C3=85strand:
> On Tue, 5 Jul 2005, Trond Myklebust wrote:
>=20
> > ty den 05.07.2005 Klokka 18:47 (+0200) skreiv Peter =C3=85strand:
> >
> >> I've tried both UDP and TCP, and both v2 and v3. The packet capture is
> >> available as http://www.cendio.se/~peter/tmp/sfu22-auth-error.cap.
> >
> > Your server is returning similar errors for that file. ;-)
>=20
> Oops. Try again now.

It is actually returning an AUTH_REJECTEDCRED to the readdir request,
which is very odd since we're not actually using AUTH_SHORT.

Looks like a pretty clear-cut server bug to me.

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
