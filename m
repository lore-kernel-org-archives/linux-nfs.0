From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Different NFSSVC_MAXBLKSIZE for udp and tcp clients?
Date: Thu, 27 Nov 2003 11:35:42 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16325.18142.376089.406722@notabene.cse.unsw.edu.au>
References: <3FC3929C.EFFE5CDF@moving-picture.com>
	<3FC3FD0C.B2DD2183@melbourne.sgi.com>
	<3FC483D6.6753DCA3@moving-picture.com>
	<16325.9710.935587.140271@notabene.cse.unsw.edu.au>
	<3FC54373.EC448BB1@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Pearson <james-p@moving-picture.com>,
    Trond Myklebust <trond.myklebust@fys.uio.no>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1APA8a-0000L7-00
	for <nfs@lists.sourceforge.net>; Wed, 26 Nov 2003 16:36:04 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.24)
	id 1APA8Z-000190-GX
	for nfs@lists.sourceforge.net; Wed, 26 Nov 2003 16:36:03 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <gnb@melbourne.sgi.com>) (for <james-p@moving-picture.com>)
	(for <trond.myklebust@fys.uio.no>) (for <nfs@lists.sourceforge.net>)
	By note With Smtp ; Thu, 27 Nov 2003 11:35:45 +1100
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: message from Greg Banks on Thursday November 27
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

On Thursday November 27, gnb@melbourne.sgi.com wrote:
> Neil Brown wrote:
> > 
> > request size is completely under the control of the client via rsize
> > and wsize (except that you cannot exceed the server's maximum).
> 
> The point is that the server's maximum is too low, at least when
> the client and server are powerful machines with a clean network
> between them (i.e. a significant part of SGI's customers).

Why didn't you say so then (or did you and I missed it?).

The code in 2.4 is not ready to cope well with larger NFS packets.  It
requires any nfs message to be linear in memory, so that means that a
large (multi-page) kmalloc has to succeed, and there is no gurantee
that it will.

For udp, any incoming packet that is not already 'linear' is
'linearize'd (in svc_udp_recvfrom).  For a 32k write, that means a
kmalloc(32768) has to succeed, and very often free memory is too
fragmented for it to succeed.

For tcp, the request will be copied into a pre-allocated buffer.  The
(large) buffer is allocated when the nfsd thread is started, and I
have several times found that I couldn't start as many nfsd threads as
I wanted because the system could not do the order-3 allocations that
were needed. (this was when I was playing with large block sizes).

2.6 copes with page-lists and so can handle requests and replies that
are not cntiguous in memory, so this is not an issue and MAXBLKSIZE
can safely be increased.

I suggest that you simply recompile the kernel with a larger
NFSSVC_MAXBLKSIZE and see how well it works.
I can see no reasonable for having different values for udp and tcp
though.  Just make it uniformly 32768 and see how it goes.

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
