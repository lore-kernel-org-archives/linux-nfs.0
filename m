From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Different NFSSVC_MAXBLKSIZE for udp and tcp clients?
Date: 25 Nov 2003 20:40:53 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsvfp7zz2y.fsf@charged.uio.no>
References: <3FC3929C.EFFE5CDF@moving-picture.com>
	<3FC3FD0C.B2DD2183@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Pearson <james-p@moving-picture.com>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AOog7-0002Ig-00
	for <nfs@lists.sourceforge.net>; Tue, 25 Nov 2003 17:41:15 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AOog7-0007Ia-2Y
	for nfs@lists.sourceforge.net; Tue, 25 Nov 2003 17:41:15 -0800
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <3FC3FD0C.B2DD2183@melbourne.sgi.com>
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

>>>>> " " == Greg Banks <gnb@melbourne.sgi.com> writes:

     > What I would like is to allow UDP clients to use up to 48K and
     > TCP clients to use up to 4M.

Those are already on the roadmap, but haven't yet made it to the top
of the priority list...

They will never make it into 2.4.x though. The main reason is the
xdr_kmap() stuff, which doesn't really scale too well.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
