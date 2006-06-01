From: Theo Markettos <theo@markettos.org.uk>
Subject: Re: Multiple heterogeneous NFS servers on one machine
Date: Thu, 1 Jun 2006 21:37:35 +0100
Message-ID: <20060601203735.GF30710@chiark.greenend.org.uk>
References: <20060529182400.GQ13353@chiark.greenend.org.uk> <200605292136.16422.bernd-schubert@gmx.de> <20060529204252.GD30710@chiark.greenend.org.uk> <200605292315.23951.bernd-schubert@gmx.de> <20060531114254.GE30710@chiark.greenend.org.uk> <1149102588.32074.21.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FltvI-00056p-7J
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 13:37:40 -0700
Received: from chiark.greenend.org.uk ([193.201.200.170])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FltvG-0001Ow-Tv
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 13:37:40 -0700
Received: by chiark.greenend.org.uk (Debian Exim 3.36 #1) with local
	(return-path theom@chiark.greenend.org.uk)
	id 1FltvD-0006yS-00
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 21:37:35 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <1149102588.32074.21.camel@lade.trondhjem.org>
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

On Wed, May 31, 2006 at 03:09:48PM -0400, Trond Myklebust wrote:
> _IF_ unfs3 is returning the correct error when we call READDIRPLUS (i.e.
> NFS3ERR_NOTSUP == 10004), then the client will already automatically
> fall back to using READDIR only.

Exactly, but it isn't.  It (Sunfish) is just reporting the error then giving
up.  I've asked the author and he says it wouldn't be too hard to modify the
client to use READDIR all the time, except for a performance hit, but it
would be harder to make it fall back.  I'm going to have a look at how I can
modify it when I next have some spare time.

Theo


-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
