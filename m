From: Bernd Schubert <bernd-schubert@gmx.de>
Subject: Re: kernel+userspace based nfsd running in parallel on linux?
Date: Sat, 16 Dec 2006 17:17:30 +0100
Message-ID: <200612161717.31090.bernd-schubert@gmx.de>
References: <1499049521@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: devzero@web.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GvcEJ-0002rd-Hx
	for nfs@lists.sourceforge.net; Sat, 16 Dec 2006 08:17:43 -0800
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1GvcEH-0005FK-Tu
	for nfs@lists.sourceforge.net; Sat, 16 Dec 2006 08:17:45 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <1499049521@web.de>
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

Hi Roland,

On Saturday 16 December 2006 16:20, devzero@web.de wrote:
> Hello !
>
> for a special scenario, i&#180;m thinking about running the classic
> userspace nfsd in parallel with the kernel based.

we are are already doing this for a long time.

>
> i think this _could_ be possible by binding the userspace one to the
> primary interface (eth0, ip 1.2.3.4) and the kernel based one to a virtual
> interface (eth0:1, ip 1.2.3.5)

Hmm, I thing this is presently not possible. I might be wrong, but I think =

neither knfsd nor any userspace nfs daemon presently supports binding to =

selected interfaces. Thinks they alsways bind to all interfaces.
We doing it by using different ports for the daemons, knfsd is running as =

usual on 2049 and unfsd (unfs3) is running on another port.  One also needs =

to tell one of the daemon not to register to the portmapper, unfs3 also =

supports that.

[...]

> if there isn&#180;t a killer argument against this (does not work by desi=
gn
> because...), i would like to try to elaborate to make this work. if this
> fails because there is no way to specify a dedicated interface to listen =
on
> - maybe this could be fixed with some few modifications to the code...

Any argument against simply using different ports?

Cheers,
Bernd

-- =

Bernd Schubert
PCI / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=3Djoin.php&p=3Dsourceforge&CID=3DDE=
VDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
