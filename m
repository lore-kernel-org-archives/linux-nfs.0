From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: Different NFSSVC_MAXBLKSIZE for udp and tcp clients?
Date: Thu, 27 Nov 2003 12:33:50 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FC5547E.7EBF817@melbourne.sgi.com>
References: <3FC3929C.EFFE5CDF@moving-picture.com>
		<3FC3FD0C.B2DD2183@melbourne.sgi.com>
		<3FC483D6.6753DCA3@moving-picture.com>
		<16325.9710.935587.140271@notabene.cse.unsw.edu.au>
		<3FC54373.EC448BB1@melbourne.sgi.com> <16325.18142.376089.406722@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Pearson <james-p@moving-picture.com>,
   Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1APB2x-0007ln-00
	for <nfs@lists.sourceforge.net>; Wed, 26 Nov 2003 17:34:19 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=rj.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1APB2v-0005gC-BT
	for nfs@lists.sourceforge.net; Wed, 26 Nov 2003 17:34:17 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
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

Neil Brown wrote:
> 
> On Thursday November 27, gnb@melbourne.sgi.com wrote:
> > Neil Brown wrote:
> >
> > The point is that the server's maximum is too low, [...]
> 
> Why didn't you say so then (or did you and I missed it?).

Sorry, just being obscure ;-)

> The code in 2.4 is not ready to cope well with larger NFS packets. [...]
> For a 32k write, that means a
> kmalloc(32768) has to succeed, and very often free memory is too
> fragmented for it to succeed.
> 
> For tcp, the request will be copied into a pre-allocated buffer.  The
> (large) buffer is allocated when the nfsd thread is started,[...]

Ok, so if physical memory fragmentation is the only issue I'll just
try it.  With 16K pages the allocation orders will be more reasonable.

> 2.6 copes with page-lists and so can handle requests and replies that
> are not cntiguous in memory, so this is not an issue and MAXBLKSIZE
> can safely be increased.

Excellent, this sounds like it deals with my long-term issue.

> I suggest that you simply recompile the kernel with a larger
> NFSSVC_MAXBLKSIZE and see how well it works.
> I can see no reasonable for having different values for udp and tcp
> though.  Just make it uniformly 32768 and see how it goes.

How about I conditionally define NFSSVC_MAXBLKSIZE to 32k if the
page size is sufficently large?  Would such a patch make it into 2.4?

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
