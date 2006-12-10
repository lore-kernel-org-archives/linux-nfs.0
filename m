From: "Baptiste Gaillard" <b_gaillard@hotmail.com>
Subject: NFS V3 and Fat 32 problem
Date: Sun, 10 Dec 2006 13:18:22 +0000
Message-ID: <BAY124-F39D4AAA3125E51A94DDE27EAD10@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GtOZX-0005Te-Rb
	for nfs@lists.sourceforge.net; Sun, 10 Dec 2006 05:18:27 -0800
Received: from bay0-omc2-s30.bay0.hotmail.com ([65.54.246.166])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GtOZY-0000DE-16
	for nfs@lists.sourceforge.net; Sun, 10 Dec 2006 05:18:29 -0800
To: nfs@lists.sourceforge.net
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

Hi, i'm trying to export a FAT32 partition using NFS v3. The operation =

succeed but when I mount this partition on a client I observe a strange =

problem, the size of the partition isn't right (on the clients). The =

partition I export is 250Go but my clients only display 33.32Go of them. =

Also, on the , I observe that files are absent, but on the server those =

files are really here !

The partition i'm trying to export is on an USB disk and is formated in =

FAT32, i suppose the problem comes from FAT/VFAT but i don't know what =

exactly is the problem.

I've tried to mount this partition using two different clients, a MacBook =

whith MacOSX 10.4 and a PC with an Ubuntu, there is always the same problem=
. =

So I suppose the problem comes from the server, here is the configuration o=
f =

my server:

Gentoo Linux - kernel 2.6.18-gentoo-r3, NFS V3 compiled inside.

The /etc/exports file:
/media/lacie 192.168.1.3(rw,sync,insecure)    # for the MacBook
/media/lacie 192.168.1.4(ro,sync)                 # PC with ubuntu


Do you know what could be the problem ?

Thanks.

Baptiste Gaillard


PS:Sorry if it is difficult to understand me, I'm french ;-)

_________________________________________________________________
D=E9couvrez le blog Eragon sur Windows Live Spaces! =

http://eragon-heroic-fantasy.spaces.live.com/


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=3Djoin.php&p=3Dsourceforge&CID=3DDE=
VDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
