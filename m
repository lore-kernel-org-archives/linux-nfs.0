From: Theo Markettos <nfs@markettos.org.uk>
Subject: Re: Multiple heterogeneous NFS servers on one machine
Date: Mon, 29 May 2006 21:42:53 +0100
Message-ID: <20060529204252.GD30710@chiark.greenend.org.uk>
References: <20060529182400.GQ13353@chiark.greenend.org.uk> <Pine.LNX.4.64.0605292046470.13557@maggie.lkpg.cendio.se> <20060529191851.GC30710@chiark.greenend.org.uk> <200605292136.16422.bernd-schubert@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FkoZn-0000zy-ES
	for nfs@lists.sourceforge.net; Mon, 29 May 2006 13:42:59 -0700
Received: from chiark.greenend.org.uk ([193.201.200.170])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FkoZm-0001Jk-6c
	for nfs@lists.sourceforge.net; Mon, 29 May 2006 13:42:59 -0700
Received: by chiark.greenend.org.uk (Debian Exim 3.36 #1) with local
	(return-path theom@chiark.greenend.org.uk)
	id 1FkoZh-0004pZ-00
	for nfs@lists.sourceforge.net; Mon, 29 May 2006 21:42:53 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <200605292136.16422.bernd-schubert@gmx.de>
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

On Mon, May 29, 2006 at 09:36:16PM +0200, Bernd Schubert wrote:
> Anything in the logs of the Server? If the problem persist, can you could 
> start unfsd with '-p', so that it does't detach from the terminal.
> Whats are your current unfs3 options?  Have you already tried to put port and 
> mountport on the same portnumber (with unfs3 its suggested anyway).

OK, I get:
ordovician:/tmp/nfs-user-server-2.2beta47# unfsd -n 1599 -m 1599 -p -d
UNFS3 unfsd 0.9.13 (C) 2004 Pascal Schmidt <der.eremit@email.de>
/home: ip 172.21.115.2 mask 255.255.255.255 options 4
/home: ip 127.0.0.1 mask 255.255.255.255 options 4
/nc: ip 172.21.115.0 mask 255.255.255.0 options 2
/: ip 172.21.115.2 mask 255.255.255.255 options 2
/store: ip 172.21.115.2 mask 255.255.255.255 options 4
/store: ip 127.0.0.1 mask 255.255.255.255 options 4
172.21.115.14 attempted mount with unsupported protocol version
172.21.115.12 attempted mount with unsupported protocol version

(tried the command I posted from two different machines)

If I append ,nfsvers=3 to the mount options, it hangs for about 5-10 mins
then succeeds without further log output.  (Linux 2.4.26 and 2.6.15.4
respectively, both Debian stable).

If I try to connect from the NFS client on my RISC OS machine it says "NFS
call failed (Operation is not supported)" which looking at the source means
it's got a code 10004, NFSERR_NOTSUPP, from the RPC mechanism.  That's with
it in NFS 3 mode - in NFS 2 mode it just says "Unknown error" which, when I
make it output the number, is 22.  I have the source for this client so  I
can make it output more information if you can suggest what would be of
help.

> You may also want to read:
> 
> http://www.pci.uni-heidelberg.de/tc/usr/bernd/downloads/nfs-root-howto/diskless-nfs-howto.txt

Thanks, that's very useful.  Sounds like unfs is the way to go, if only I
can persuade it to work with my clients.

Theo


-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
