From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: Different NFSSVC_MAXBLKSIZE for udp and tcp clients?
Date: Wed, 26 Nov 2003 12:08:28 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FC3FD0C.B2DD2183@melbourne.sgi.com>
References: <3FC3929C.EFFE5CDF@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AOoAi-0007Ay-00
	for <nfs@lists.sourceforge.net>; Tue, 25 Nov 2003 17:08:48 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=rj.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AOoAi-0003uo-5U
	for nfs@lists.sourceforge.net; Tue, 25 Nov 2003 17:08:48 -0800
To: James Pearson <james-p@moving-picture.com>
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

James Pearson wrote:
> 
> Is it possible to force a different maximum [rw]size on the server
> depending on whether the client uses udp or tcp?

If someone writes the code, e.g. some new export options?

> Currently, when a client NFS mounts a file system without specifying a
> [rw]size, it defaults to whatever NFSSVC_MAXBLKSIZE was defined as (at
> compile time) on the server. However, this is the same for udp and tcp
> clients.

Also NFSSVC_MAXBLKSIZE acts as a limit even when [wr]size is specifically
set in mount options.

> What I would like is to have a smaller default [rw]size for udp clients,
> but allow tcp clients to use 32k.

What I would like is to allow UDP clients to use up to 48K and TCP
clients to use up to 4M.  And on 2.4 kernels, ensure that MAXBLKSIZE
is at least PAGE_CACHE_SIZE.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
