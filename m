From: Chip Salzenberg <chip@debian.org>
Subject: Re: Debian bug #165744 - 'Received erroneous SM_UNMON request'
Date: Wed, 20 Aug 2003 14:06:52 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030820180652.GD3639@perlsupport.com>
References: <20030812152154.GQ24349@perlsupport.com> <16185.47443.33945.603458@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, Jordi Mallach <jordi@debian.org>,
	165744-quiet@bugs.debian.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from panoramix.vasoftware.com ([198.186.202.147] helo=externalmx.vasoftware.com)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19psm7-000537-00
	for <nfs@lists.sourceforge.net>; Thu, 21 Aug 2003 09:59:04 -0700
Received: from tandu.perlsupport.com ([66.220.6.226]:51863)
	by externalmx.vasoftware.com with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 4.20 #1 (Debian))
	id 19pXMN-0004Tr-GO
	for <nfs@lists.sourceforge.net>; Wed, 20 Aug 2003 11:07:03 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16185.47443.33945.603458@gargle.gargle.HOWL>
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

According to Neil Brown:
> The first is the "Call to statd from non-local host".  Given that
> the in-kernel lockd *always* uses 127.0.0.1 to talk to statd, this
> request cannot have come from there.

Neil, would you be so kind as to examine this old (nearly a year now),
but still open, Debian bug report?

    http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=165744

This complaint *is* very rare, but it seems not to be specific to the
use of 2.6.  Or do you think you know what's up with this old report?
Please advise.
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
