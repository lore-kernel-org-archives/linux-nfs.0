From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS possible race condition, nfs_unlink vs. d_lookup
Date: Fri, 03 Mar 2006 13:22:17 -0800
Message-ID: <1141420937.10976.42.camel@lade.trondhjem.org>
References: <Pine.LNX.4.62.0603030955060.11612@snowball.fnal.gov>
	 <1141418871.10976.31.camel@lade.trondhjem.org>
	 <Pine.LNX.4.62.0603031514140.6140@snowball.fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FFHjH-00008z-L6
	for nfs@lists.sourceforge.net; Fri, 03 Mar 2006 13:22:27 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FFHjH-0007i3-2V
	for nfs@lists.sourceforge.net; Fri, 03 Mar 2006 13:22:27 -0800
To: Steven Timm <timm@fnal.gov>
In-Reply-To: <Pine.LNX.4.62.0603031514140.6140@snowball.fnal.gov>
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

On Fri, 2006-03-03 at 15:15 -0600, Steven Timm wrote:

> I don't have enough expertise to tell what they have done.  I
> can attach the dir.c in question if someone is able to look.
> All I know is that we are seeing a similar condition, namely
> nfs_safe_remove errors happening on our client, for what
> this patch was supposed to fix in the 2.5/2.6 series kernels.
> Any help would be appreciated.

Have you checked if the same problem exists on a more recent 2.4.x
kernel (say 2.4.28)? If not, then there may be a patch floating around
in the patch graveyard on

	http://client.linux-nfs.org/Linux-2.4.x/

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
