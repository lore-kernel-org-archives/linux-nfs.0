From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS possible race condition, nfs_unlink vs. d_lookup
Date: Fri, 03 Mar 2006 12:47:51 -0800
Message-ID: <1141418871.10976.31.camel@lade.trondhjem.org>
References: <Pine.LNX.4.62.0603030955060.11612@snowball.fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FFHC0-0004tP-3z
	for nfs@lists.sourceforge.net; Fri, 03 Mar 2006 12:48:04 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FFHBy-0005WG-JO
	for nfs@lists.sourceforge.net; Fri, 03 Mar 2006 12:48:04 -0800
To: Steven Timm <timm@fnal.gov>
In-Reply-To: <Pine.LNX.4.62.0603030955060.11612@snowball.fnal.gov>
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

On Fri, 2006-03-03 at 09:57 -0600, Steven Timm wrote:

> My question.. is the 2.4.21-37 kernel as distributed by Red Hat also
> vulnerable to this race condition? If so, is there any
> patch that is available?  The code in dir.c in the 2.4 series
> kernel is different enough such that this patch won't apply to it.

No idea. Are you saying that RedHat shipped a 2.4.x kernel with RCU
patches to the vfs before they had been tested in the 2.6.x kernel?

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
