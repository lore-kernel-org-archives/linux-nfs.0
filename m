From: devzero@web.de
Subject: Re:
 =?iso-8859-15?q?kernel+userspace_based_nfsd_running_in_para?=
 =?iso-8859-15?q?llel__on_linux=3F?=
Date: Sat, 16 Dec 2006 19:07:54 +0100
Message-ID: <1499275894@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gvdx5-0004UF-2c
	for nfs@lists.sourceforge.net; Sat, 16 Dec 2006 10:08:03 -0800
Received: from fmmailgate09.web.de ([217.72.192.184])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gvdx2-0005Me-4U
	for nfs@lists.sourceforge.net; Sat, 16 Dec 2006 10:08:01 -0800
To: Bernd Schubert <bernd-schubert@gmx.de>, nfs@lists.sourceforge.net
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

Hi Bernd, =


> we are are already doing this for a long time.

any caveats with this? just tune one of both to use different port ?

> Hmm, I thing this is presently not possible. I might be wrong, but I thin=
k =

> neither knfsd nor any userspace nfs daemon presently supports binding to =

> selected interfaces. Thinks they alsways bind to all interfaces.

i wonder very often, why there are so many applications out there which act=
ually _DON`T_  support this. if you are a security aware person, this is a =
very nice feature to be able to make your box more secure, without any fire=
walling at all. an interface which isn`t actually listening is more secure =
than one being firewalled, because you could have misconfigured your firewa=
ll or it could be down by accident. such feature gives so much greater flex=
ibility - i wished i would be able to tell "-bind 1.2.3.4:1234" instead of =
just "-port 1234" to every type of application opening a listening socket.

> We doing it by using different ports for the daemons, knfsd is running as =

> usual on 2049 and unfsd (unfs3) is running on another port.  One also nee=
ds =

> to tell one of the daemon not to register to the portmapper, unfs3 also =

> supports that.

ah, thanks - this looks like one of those "caveats". btw - what about using=
 userspace nfsd via xinetd? xinetd supports binding to dedicated interfaces.

> > if there isn&#180;t a killer argument against this (does not work by de=
sign
> > because...), i would like to try to elaborate to make this work. if this
> > fails because there is no way to specify a dedicated interface to liste=
n on
> > - maybe this could be fixed with some few modifications to the code...
> =

> Any argument against simply using different ports?

ease of use for the clients? (because it&#180;s easier to tell them to conn=
ect to a different ip than to a different port) - what if the client doesn`=
t support connecting to different port (ok, don`t know details yet about nf=
s clients and specifying ports - but i know many apps which are not able to=
 use another port than the standard/default one.

thanks!

roland

_______________________________________________________________________
Viren-Scan f=FCr Ihren PC! Jetzt f=FCr jeden. Sofort, online und kostenlos.
Gleich testen! http://www.pc-sicherheit.web.de/freescan/?mc=3D022222


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=3Djoin.php&p=3Dsourceforge&CID=3DDE=
VDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
