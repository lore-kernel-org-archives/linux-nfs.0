From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Different NFSSVC_MAXBLKSIZE for udp and tcp clients?
Date: Thu, 27 Nov 2003 09:15:10 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16325.9710.935587.140271@notabene.cse.unsw.edu.au>
References: <3FC3929C.EFFE5CDF@moving-picture.com>
	<3FC3FD0C.B2DD2183@melbourne.sgi.com>
	<3FC483D6.6753DCA3@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Banks <gnb@melbourne.sgi.com>,
    Trond Myklebust <trond.myklebust@fys.uio.no>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AP7wb-00058u-00
	for <nfs@lists.sourceforge.net>; Wed, 26 Nov 2003 14:15:33 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.24)
	id 1AP7wb-0006Em-9t
	for nfs@lists.sourceforge.net; Wed, 26 Nov 2003 14:15:33 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <james-p@moving-picture.com>) (for <gnb@melbourne.sgi.com>)
	(for <trond.myklebust@fys.uio.no>) (for <nfs@lists.sourceforge.net>)
	By note With Smtp ; Thu, 27 Nov 2003 09:15:11 +1100
To: James Pearson <james-p@moving-picture.com>
In-Reply-To: message from James Pearson on Wednesday November 26
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

On Wednesday November 26, james-p@moving-picture.com wrote:
> Greg Banks wrote:
> > 
> > James Pearson wrote:
> > >
> > > Is it possible to force a different maximum [rw]size on the server
> > > depending on whether the client uses udp or tcp?
> > 
> > If someone writes the code, e.g. some new export options?
> 
> Do you know if this would be possible with 2.4 kernels?
> 
> If it is possible, and someone could give me some pointers, I won't mind
> giving it a a go ...
> 

I have yet to see the point, so presumably I am missing something....

request size is completely under the control of the client via rsize
and wsize (except that you cannot exceed the server's maximum).  So
why do you want to add an option to the server? Why not just use the
already-existing-and-working option on the client?

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
