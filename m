From: Theo Markettos <nfs@markettos.org.uk>
Subject: Re: Multiple heterogeneous NFS servers on one machine
Date: Mon, 29 May 2006 20:18:51 +0100
Message-ID: <20060529191851.GC30710@chiark.greenend.org.uk>
References: <20060529182400.GQ13353@chiark.greenend.org.uk> <Pine.LNX.4.64.0605292046470.13557@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FknGQ-0000uh-KD
	for nfs@lists.sourceforge.net; Mon, 29 May 2006 12:18:54 -0700
Received: from chiark.greenend.org.uk ([193.201.200.170])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FknGP-0006Qv-39
	for nfs@lists.sourceforge.net; Mon, 29 May 2006 12:18:54 -0700
Received: by chiark.greenend.org.uk (Debian Exim 3.36 #1) with local
	(return-path theom@chiark.greenend.org.uk)
	id 1FknGN-0002Es-00
	for nfs@lists.sourceforge.net; Mon, 29 May 2006 20:18:51 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <Pine.LNX.4.64.0605292046470.13557@maggie.lkpg.cendio.se>
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

On Mon, May 29, 2006 at 08:50:14PM +0200, Peter ?strand wrote:
> 
> >Is it possible to run NFS without portmap?
> 
> Sure. With unfs3, just use the "-p" option. You can use the same or 
> different ports for the NFS and MOUNT service. Typically, I run unfs3 
> with:
> 
> unfsd -n 4711 -m 4711 -p

Which is interesting, because I tried unfs3 (giving them distinct port
numbers for NFS and MOUNT) and got:

shepherd:~#  mount -t nfs -o port=1299,mountport=1289,tcp ordovician:/nc /mnt/

mount: ordovician:/nc failed, reason given by server: unknown nfs status
return value: 22

The same happened if I tried to mount from the local machine, or tried udp. 
At this point I gave up with unfs3.  Any suggestions as to why that error is
happening?

Theo


-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
