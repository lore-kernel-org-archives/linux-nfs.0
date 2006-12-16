From: devzero@web.de
Subject: Re:
 =?iso-8859-15?q?kernel+userspace_based_nfsd_running_in_para?=
 =?iso-8859-15?q?llel_on_linux=3F?=
Date: Sat, 16 Dec 2006 23:26:05 +0100
Message-ID: <1499627837@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gvhys-00058J-Gv
	for nfs@lists.sourceforge.net; Sat, 16 Dec 2006 14:26:11 -0800
Received: from fmmailgate09.web.de ([217.72.192.184])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gvhyt-0003N2-M8
	for nfs@lists.sourceforge.net; Sat, 16 Dec 2006 14:26:12 -0800
To: Bernd Schubert <bernd-schubert@gmx.de>, Olaf Kirch <okir@suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

>Oh, and what about locking? :)

good point - but not an issue here, because i only need to export read-only.

> -----Urspr=FCngliche Nachricht-----
> Von: Olaf Kirch <okir@suse.de>
> Gesendet: 16.12.06 22:55:45
> An: Bernd Schubert <bernd-schubert@gmx.de>
> CC: nfs@lists.sourceforge.net
> Betreff: Re: [NFS] kernel+userspace based nfsd running in parallel on lin=
ux?


> On Sat, Dec 16, 2006 at 05:17:30PM +0100, Bernd Schubert wrote:
> > Hmm, I thing this is presently not possible. I might be wrong, but I th=
ink =

> > neither knfsd nor any userspace nfs daemon presently supports binding t=
o =

> > selected interfaces. Thinks they alsways bind to all interfaces.
> > We doing it by using different ports for the daemons, knfsd is running =
as =

> > usual on 2049 and unfsd (unfs3) is running on another port.  One also n=
eeds =

> > to tell one of the daemon not to register to the portmapper, unfs3 also =

> > supports that.
> =

> The big problem will be mountd. There's only one portmapper, and you
> can register only one mountd - and the file handles given out by unfs
> mountd don't work with the kernel nfsd and vice versa.
> =

> Oh, and what about locking? :)
> =

> Olaf
> -- =

> Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
> okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
> =



___________________________________________________________________________=
___
"Ein Herz f=FCr Kinder" - Ihre Spende hilft! Aktion: www.deutschlandsegelt.=
de
Unser Dankesch=F6n: Ihr Name auf dem Segel der 1. deutschen America's Cup-Y=
acht!


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=3Djoin.php&p=3Dsourceforge&CID=3DDE=
VDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
