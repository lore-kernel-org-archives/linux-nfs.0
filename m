From: Chip Salzenberg <chip@debian.org>
Subject: Re: Possible breakthrough Re: Debian Bug#203918 - statd request on eth interface, not localhost?
Date: Thu, 21 Aug 2003 15:31:26 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030821193126.GM14355@perlsupport.com>
References: <20030821180214.GA12129@perlsupport.com> <20030821185454.GA4643@nubol.int.oskuro.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tandu.perlsupport.com ([66.220.6.226] ident=mail)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19pv9h-0002lA-00
	for <nfs@lists.sourceforge.net>; Thu, 21 Aug 2003 12:31:33 -0700
To: Jordi Mallach <jordi@debian.org>
In-Reply-To: <20030821185454.GA4643@nubol.int.oskuro.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

According to Jordi Mallach:
> Ok. Apparently it doesn't help either.

Darn.

> Of course, I haven't remounted or anything after doing these changes,
> because I can't umount the share. Should I reboot the client to see?

Well, the message is on the server (right?), so if anything, rebooting
the server (or at least stopping and starting nfs-kernel-server and
nfs-common) would be called for as a complete test.
-- 
Chip Salzenberg               - a.k.a. -               <chip@pobox.com>
"I wanted to play hopscotch with the impenetrable mystery of existence,
    but he stepped in a wormhole and had to go in early."  // MST3K


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
