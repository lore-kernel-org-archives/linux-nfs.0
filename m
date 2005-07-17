From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [PATCH] Fix xprt_bindresvport
Date: Sun, 17 Jul 2005 09:02:20 -0700
Message-ID: <482A3FA0050D21419C269D13989C611308539DC6@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>, <akpm@osdl.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DuBb1-0005Cj-89
	for nfs@lists.sourceforge.net; Sun, 17 Jul 2005 09:02:27 -0700
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1DuBb1-0006Jz-2d
	for nfs@lists.sourceforge.net; Sun, 17 Jul 2005 09:02:27 -0700
To: "Steve Dickson" <SteveD@redhat.com>, "Olaf Kirch" <okir@suse.de>
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

> Olaf Kirch wrote:
> > On Thu, Jul 14, 2005 at 12:00:11PM -0400, Steve Dickson wrote:
> >=20
> >>Question, why is 65535 one being used here instead of something
> >>like 1023 (or PROT_SOCK-1)? Since since inet_bind() will only
> >>succeed with a source ports that are less than PROT_SOCK, so it
> >>may not make sense to allow the user to set the max reserver port
> >>to a value greater than PROT_SOCK-1, true?
> >=20
> >=20
> > I don't understand. Of course you can bind to any socket up=20
> to 65535,
> > not just 1023.
> Understood... but ports > 1023 are not considered privileged and
> connections that are not using privilege ports will not be accepted
> by a number of RPC daemon..

in addition, part of AUTH_SYS security (such as it is) is connecting via
a privileged port.

a better solution, which trond recently suggested, is to disable
xprt->resvport for AUTH_GSS-secured transports, but leave the other
security flavors as they are now.


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
