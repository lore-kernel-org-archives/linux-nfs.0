From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Data coherency trouble with multiple clients on 2.6.14-rc5
Date: Mon, 7 Nov 2005 08:08:28 -0800
Message-ID: <044B81DE141D7443BCE91E8F44B3C1E288E5F1@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EZ9Y7-0001D6-Mw
	for nfs@lists.sourceforge.net; Mon, 07 Nov 2005 08:08:47 -0800
Received: from mx1.netapp.com ([216.240.18.38])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EZ9Y5-0006pN-EI
	for nfs@lists.sourceforge.net; Mon, 07 Nov 2005 08:08:47 -0800
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
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

> on den 26.10.2005 klokka 08:27 (-0700) skreiv Lever, Charles:
>=20
> > i agree that O_DIRECT is the right solution.  however, even=20
> with "noac"
> > i would expect mr. duffy's workload to behave correctly most of the
> > time.  sounds like he is able to make it fail very easily.
>=20
> Why would you expect that?
>=20
> "noac" does not turn off data caching, nor does it change the policy
> that the client will not invalidate the data cache while it is holding
> the file open for write.

i just figured out what was troubling me about this.

in the case of "noac", OTW writes are always synchronous.  thus you
should never have the problem where concurrent async writes will obscure
server-side changes on "noac" mounts.


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
