From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: Different NFSSVC_MAXBLKSIZE for udp and tcp clients?
Date: Wed, 26 Nov 2003 12:51:22 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FC4071A.9214A0D3@melbourne.sgi.com>
References: <3FC3929C.EFFE5CDF@moving-picture.com>
		<3FC3FD0C.B2DD2183@melbourne.sgi.com> <shsvfp7zz2y.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Pearson <james-p@moving-picture.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AOoq8-0002uR-00
	for <nfs@lists.sourceforge.net>; Tue, 25 Nov 2003 17:51:36 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=rj.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AOoq8-00085w-1W
	for nfs@lists.sourceforge.net; Tue, 25 Nov 2003 17:51:36 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

Trond Myklebust wrote:
> 
> >>>>> " " == Greg Banks <gnb@melbourne.sgi.com> writes:
> 
>      > What I would like is to allow UDP clients to use up to 48K and
>      > TCP clients to use up to 4M.
> 
> Those are already on the roadmap, but haven't yet made it to the top
> of the priority list...

Are there preliminary patches or analysis/random thoughts somewhere online?

> They will never make it into 2.4.x though. The main reason is the
> xdr_kmap() stuff, which doesn't really scale too well.

Suits me.

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
