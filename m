From: devzero@web.de
Subject: Re:
 =?iso-8859-15?q?kernel+userspace_based_nfsd_running_in_para?=
 =?iso-8859-15?q?llel__on_linux=3F?=
Date: Sat, 16 Dec 2006 22:53:58 +0100
Message-ID: <1499583832@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
Cc: Bernd Schubert <bernd-schubert@gmx.de>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GvhTr-0002HU-78
	for nfs@lists.sourceforge.net; Sat, 16 Dec 2006 13:54:07 -0800
Received: from fmmailgate05.web.de ([217.72.192.243])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GvhTr-00036c-3L
	for nfs@lists.sourceforge.net; Sat, 16 Dec 2006 13:54:08 -0800
To: astrand@cendio.se
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

thanks - i just came across unfs3 some hours ago after searching this list =
for a while - i didn&#180;t know that there exists a nfsv3 userspace implem=
entation.

so - maybe it`s a good replacement for classic userspace nfsd and i don`t n=
eed knfsd at all - looks like it also supports files >2gb.

will give it a try!



> -----Urspr=FCngliche Nachricht-----
> Von: Peter =C5strand <astrand@cendio.se>
> Gesendet: 16.12.06 22:01:53
> An: devzero@web.de
> CC: Bernd Schubert <bernd-schubert@gmx.de>, nfs@lists.sourceforge.net
> Betreff: Re: [NFS] kernel+userspace based nfsd running in parallel  on li=
nux?


> On Sat, 16 Dec 2006, devzero@web.de wrote:
> =

> > > Hmm, I thing this is presently not possible. I might be wrong, but I =
think =

> > > neither knfsd nor any userspace nfs daemon presently supports binding=
 to =

> > > selected interfaces. Thinks they alsways bind to all interfaces.
> > =

> > i wonder very often, why there are so many applications out there which =

> > actually _DON`T_ support this. if you are a security aware person, this =

> =

> Actually, unfs3 does support this. Just use the -l argument. =

> =

> Regards, =

> ---
> Peter =C3&#65533;strand		ThinLinc Chief Developer
> Cendio AB		http://www.cendio.se
> Teknikringen 3
> 583 30 Link=C3=B6ping	Phone: +46-13-21 46 00
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
