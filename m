From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: Different NFSSVC_MAXBLKSIZE for udp and tcp clients?
Date: Thu, 27 Nov 2003 11:08:06 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FC54066.C04EBA49@melbourne.sgi.com>
References: <482A3FA0050D21419C269D13989C6113020AC79F@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Pearson <james-p@moving-picture.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AP9hh-0006qV-00
	for <nfs@lists.sourceforge.net>; Wed, 26 Nov 2003 16:08:17 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=rj.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AP9hg-0006VU-Ou
	for nfs@lists.sourceforge.net; Wed, 26 Nov 2003 16:08:16 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
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

"Lever, Charles" wrote:
> 
> here's a vote for leaving these values variable rather than
> fixed on the server side.  48KB maximum for UDP is great on
> a clean network, but some folks would probably prefer setting
> it to 8KB to ensure clients on more realistically congested
> networks retain reasonable UDP performance.

Agreed.

> is there any evidence to show that a 4MB TCP maximum will
> have benefits over something smaller, like say 1MB ?  

None at all on Linux.  I mention that specific number only
because it's the hardcoded maximum on IRIX.

However there is evidence that 8K isn't enough.  In particular,
it's smaller than an Altix client's PAGE_CACHE_SIZE so all writes
between two Altix boxes go synchronous.

> [...] there's probably a sweet spot where the sum
> of both per-op and per-byte costs reach a minimum.  

Yes.

> as
> far as i can tell that value is around 16KB in the current
> Linux client implementations.

The value will be higher for Altix clients and servers, which
have more RAM, CPU, and larger pages than the machines you're
probably thinking of.

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
