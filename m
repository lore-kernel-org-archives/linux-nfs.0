From: Ian Kent <raven@themaw.net>
Subject: Re: how to force umount when "Device or resource busy"?
Date: Wed, 15 Sep 2004 09:09:30 +0800 (WST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0409150908100.20157@wombat.indigo.net.au>
References: <AB813470-0682-11D9-9080-000A95C71776@freezone.co.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C7OIb-0000CM-RY
	for nfs@lists.sourceforge.net; Tue, 14 Sep 2004 18:09:29 -0700
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1C7OIa-0001wa-1A
	for nfs@lists.sourceforge.net; Tue, 14 Sep 2004 18:09:29 -0700
To: ms419@freezone.co.uk
In-Reply-To: <AB813470-0682-11D9-9080-000A95C71776@freezone.co.uk>
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

On Tue, 14 Sep 2004 ms419@freezone.co.uk wrote:

> How does one unmount when umount doesn't work?
> 
> Somehow, I got an NFS / AutoFS mount that just won't unmount.
> 
> I noticed /var/autofs/net was mounted twice, so I stopped AutoFS & 
> tried killing the remaining automount process. "kill 14986" didn't 
> work; I needed "kill -9 14986". The following mounts remain:

What versions are you using?
Kernel version?
Patched?

Try the autofs list at

http://linux.kernel.org/mailman/listinfo/autofs

Ian



-------------------------------------------------------
This SF.Net email is sponsored by: thawte's Crypto Challenge Vl
Crack the code and win a Sony DCRHC40 MiniDV Digital Handycam
Camcorder. More prizes in the weekly Lunch Hour Challenge.
Sign up NOW http://ad.doubleclick.net/clk;10740251;10262165;m
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
