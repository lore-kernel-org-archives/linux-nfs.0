From: James Pearson <james-p@moving-picture.com>
Subject: Re: Different NFSSVC_MAXBLKSIZE for udp and tcp clients?
Date: Wed, 26 Nov 2003 10:43:34 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FC483D6.6753DCA3@moving-picture.com>
References: <3FC3929C.EFFE5CDF@moving-picture.com> <3FC3FD0C.B2DD2183@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AOx95-000324-00
	for <nfs@lists.sourceforge.net>; Wed, 26 Nov 2003 02:43:43 -0800
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AOx94-0008I6-ST
	for nfs@lists.sourceforge.net; Wed, 26 Nov 2003 02:43:43 -0800
To: Greg Banks <gnb@melbourne.sgi.com>,
 	Trond Myklebust <trond.myklebust@fys.uio.no>
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

Greg Banks wrote:
> 
> James Pearson wrote:
> >
> > Is it possible to force a different maximum [rw]size on the server
> > depending on whether the client uses udp or tcp?
> 
> If someone writes the code, e.g. some new export options?

Do you know if this would be possible with 2.4 kernels?

If it is possible, and someone could give me some pointers, I won't mind
giving it a a go ...

James Pearson


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
