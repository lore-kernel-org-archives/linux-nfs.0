From: Bernd Schubert <bernd-schubert@gmx.de>
Subject: Re: Multiple heterogeneous NFS servers on one machine
Date: Mon, 29 May 2006 23:15:23 +0200
Message-ID: <200605292315.23951.bernd-schubert@gmx.de>
References: <20060529182400.GQ13353@chiark.greenend.org.uk> <200605292136.16422.bernd-schubert@gmx.de> <20060529204252.GD30710@chiark.greenend.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fkp5J-0004Es-DQ
	for nfs@lists.sourceforge.net; Mon, 29 May 2006 14:15:33 -0700
Received: from mail.gmx.de ([213.165.64.20] helo=mail.gmx.net)
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1Fkp5H-0000Ni-ON
	for nfs@lists.sourceforge.net; Mon, 29 May 2006 14:15:33 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20060529204252.GD30710@chiark.greenend.org.uk>
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

>
> OK, I get:
> ordovician:/tmp/nfs-user-server-2.2beta47# unfsd -n 1599 -m 1599 -p -d
> UNFS3 unfsd 0.9.13 (C) 2004 Pascal Schmidt <der.eremit@email.de>
> /home: ip 172.21.115.2 mask 255.255.255.255 options 4
> /home: ip 127.0.0.1 mask 255.255.255.255 options 4
> /nc: ip 172.21.115.0 mask 255.255.255.0 options 2
> /: ip 172.21.115.2 mask 255.255.255.255 options 2
> /store: ip 172.21.115.2 mask 255.255.255.255 options 4
> /store: ip 127.0.0.1 mask 255.255.255.255 options 4
> 172.21.115.14 attempted mount with unsupported protocol version
> 172.21.115.12 attempted mount with unsupported protocol version
>
> (tried the command I posted from two different machines)

Can you add mountvers=3D3,nolock as described in my howto?=20

>
> If I append ,nfsvers=3D3 to the mount options, it hangs for about 5-10 mi=
ns
> then succeeds without further log output.  (Linux 2.4.26 and 2.6.15.4
> respectively, both Debian stable).

If it still waits this long time, after adding the options above, could you=
=20
capture via ethereal and look whats going on? The nfsvers=3D3 option is als=
o=20
still important as the default option is nfsvers=3D2, which is not supporte=
d by=20
unfs3.=20

>
> If I try to connect from the NFS client on my RISC OS machine it says "NFS
> call failed (Operation is not supported)" which looking at the source mea=
ns
> it's got a code 10004, NFSERR_NOTSUPP, from the RPC mechanism.  That's wi=
th
> it in NFS 3 mode - in NFS 2 mode it just says "Unknown error" which, when=
 I
> make it output the number, is 22.  I have the source for this client so  I
> can make it output more information if you can suggest what would be of
> help.

An ethereal capture (and the sources ) would be helpfull in that case. My n=
fs=20
protocol knowlegde got a bit rosty, but I need to refresh it anyway to fini=
sh=20
my pending patches for unfs3 (if I only had the time to write them :(  )

>
> > You may also want to read:
> >
> > http://www.pci.uni-heidelberg.de/tc/usr/bernd/downloads/nfs-root-howto/=
di
> >skless-nfs-howto.txt
>
> Thanks, that's very useful.  Sounds like unfs is the way to go, if only I
> can persuade it to work with my clients.

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
