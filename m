From: Chip Salzenberg <chip@debian.org>
Subject: Re: [chip@debian.org: Debian Bug#203918 - statd request on eth interface, not localhost?]
Date: Wed, 20 Aug 2003 13:59:51 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030820175951.GB3639@perlsupport.com>
References: <20030812152154.GQ24349@perlsupport.com> <16185.47443.33945.603458@gargle.gargle.HOWL> <20030813082216.GA14015@nubol.int.oskuro.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net,
	203918-quiet@bugs.debian.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from panoramix.vasoftware.com ([198.186.202.147] helo=externalmx.vasoftware.com)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ptyl-0004Re-00
	for <nfs@lists.sourceforge.net>; Thu, 21 Aug 2003 11:16:11 -0700
Received: from tandu.perlsupport.com ([66.220.6.226]:51848)
	by externalmx.vasoftware.com with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 4.20 #1 (Debian))
	id 19pXG6-0002UM-Hk
	for <nfs@lists.sourceforge.net>; Wed, 20 Aug 2003 11:00:34 -0700
To: Jordi Mallach <jordi@debian.org>
In-Reply-To: <20030813082216.GA14015@nubol.int.oskuro.net>
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
> I told Chip I'd try to upgrade to the latest 2.6.0 kernel soon. If this
> makes it improve, I'll tell you.

So, what news?

If you're still getting invalid statd requests from an IP other than
127.0.0.1, they're not from the kernel.  Can you use tcpdump to find
out where the statd requests are coming from?
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
