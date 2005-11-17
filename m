From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NLM GRANT callback using AUTH_NULL is rejected
Date: Thu, 17 Nov 2005 08:20:48 -0800
Message-ID: <044B81DE141D7443BCE91E8F44B3C1E2013327B7@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <neilb@suse.de>, "Olaf Kirch" <okir@suse.de>,
	<nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EcmVV-0006cX-W3
	for nfs@lists.sourceforge.net; Thu, 17 Nov 2005 08:21:05 -0800
Received: from mx1.netapp.com ([216.240.18.38])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EcmVP-00087x-UE
	for nfs@lists.sourceforge.net; Thu, 17 Nov 2005 08:21:05 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
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

> On Thu, Nov 17, 2005 at 07:38:22AM -0800, Lever, Charles wrote:
> > our filer sends NLM GRANTED callbacks back to clients using=20
> AUTH_NULL
> > authentication.  Linux clients always seem to reject these=20
> callbacks.
> >=20
> > parsing through fs/lockd and net/sunrpc, i see a comment=20
> that indicates
> > that AUTH_NULL RPC requests are subject to IP access control (a la
> > /etc/exports).  theoretically, if lockd doesn't register=20
> the filer in
> > the ip_map cache, then all the filer's callbacks will be rejected,
> > right?
>=20
> See
>=20
> http://marc.theaimsgroup.com/?l=3Dlinux-nfs&m=3D110608174305835&w=3D2
>=20
> and following messages.  These appear to have gone into 2.6 in early
> March sometime, so I assume that was about 2.6.12?

thanks bruce.

ok, these appear not to be in RHEL 4 update 2, which is what our
internal test happens to be using at the moment.  i would assume that an
FC4 system running the latest update would already have this series of
patches integrated...?

was it the judgement of the community that no IP address checking for
AUTH_NULL callbacks is better than having at least *some* sanity
checking?  seems reasonable to me to register the IP address of the file
server so that not just any joe IP address can grant locks.
(limitations of authentication via IP address notwithstanding).

obtw, did you happen to have a test to see if GRANTED callbacks were
being accepted after your patch is applied?  that will save me the
trouble of working up a test myself.


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
