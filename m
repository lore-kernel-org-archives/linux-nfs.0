From: Bernd Schubert <bernd-schubert@gmx.de>
Subject: Re: Multiple heterogeneous NFS servers on one machine
Date: Mon, 29 May 2006 21:36:16 +0200
Message-ID: <200605292136.16422.bernd-schubert@gmx.de>
References: <20060529182400.GQ13353@chiark.greenend.org.uk> <Pine.LNX.4.64.0605292046470.13557@maggie.lkpg.cendio.se> <20060529191851.GC30710@chiark.greenend.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FknXZ-0002hp-F5
	for nfs@lists.sourceforge.net; Mon, 29 May 2006 12:36:37 -0700
Received: from mail.gmx.de ([213.165.64.20] helo=mail.gmx.net)
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FknXX-0001pX-PT
	for nfs@lists.sourceforge.net; Mon, 29 May 2006 12:36:37 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20060529191851.GC30710@chiark.greenend.org.uk>
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

> shepherd:~#  mount -t nfs -o port=3D1299,mountport=3D1289,tcp ordovician:=
/nc
> /mnt/
>
> mount: ordovician:/nc failed, reason given by server: unknown nfs status
> return value: 22
>
> The same happened if I tried to mount from the local machine, or tried ud=
p.
> At this point I gave up with unfs3.  Any suggestions as to why that error
> is happening?

Anything in the logs of the Server? If the problem persist, can you could=20
start unfsd with '-p', so that it does't detach from the terminal.
Whats are your current unfs3 options?  Have you already tried to put port a=
nd=20
mountport on the same portnumber (with unfs3 its suggested anyway).

You may also want to read:

http://www.pci.uni-heidelberg.de/tc/usr/bernd/downloads/nfs-root-howto/disk=
less-nfs-howto.txt

If you find something need to be explained more in detail, just tell me.


Cheers,
	Bernd



=2D-=20
Bernd Schubert
PCI / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg



-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
