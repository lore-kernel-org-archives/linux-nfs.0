From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: Different NFSSVC_MAXBLKSIZE for udp and tcp clients?
Date: Thu, 27 Nov 2003 11:21:07 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FC54373.EC448BB1@melbourne.sgi.com>
References: <3FC3929C.EFFE5CDF@moving-picture.com>
		<3FC3FD0C.B2DD2183@melbourne.sgi.com>
		<3FC483D6.6753DCA3@moving-picture.com> <16325.9710.935587.140271@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Pearson <james-p@moving-picture.com>,
   Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AP9uT-0007Tk-00
	for <nfs@lists.sourceforge.net>; Wed, 26 Nov 2003 16:21:29 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=rj.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AP9uT-0007wf-E2
	for nfs@lists.sourceforge.net; Wed, 26 Nov 2003 16:21:29 -0800
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
> request size is completely under the control of the client via rsize
> and wsize (except that you cannot exceed the server's maximum).

The point is that the server's maximum is too low, at least when
the client and server are powerful machines with a clean network
between them (i.e. a significant part of SGI's customers).

When I say too low, I have two separate issues:

1.  wsize<16K means an Altix client does synchronous writes, which
    results in a catastrophic performance hit (writes proceed at
    no more than 0.7% of line rate on gige).  This is a hot issue
    right now.

2.  Experience with IRIX shows that (up to a point) better performance
    can be achieved for some loads with larger transfer sizes.  On
    IRIX that point is beyond Linux' current hardcoded maximums.  This
    is more of a long-term issue.

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
