From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Different NFSSVC_MAXBLKSIZE for udp and tcp clients?
Date: 26 Nov 2003 19:53:04 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs1xrutyxb.fsf@charged.uio.no>
References: <482A3FA0050D21419C269D13989C6113020AC79F@lavender-fe.eng.netapp.com>
	<3FC54066.C04EBA49@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,
	  James Pearson <james-p@moving-picture.com>,
	  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1APAPF-0001UM-00
	for <nfs@lists.sourceforge.net>; Wed, 26 Nov 2003 16:53:17 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1APAPE-0003In-Tx
	for nfs@lists.sourceforge.net; Wed, 26 Nov 2003 16:53:17 -0800
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <3FC54066.C04EBA49@melbourne.sgi.com>
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

    >> is there any evidence to show that a 4MB TCP maximum will have
    >> benefits over something smaller, like say 1MB ?

     > None at all on Linux.  I mention that specific number only
     > because it's the hardcoded maximum on IRIX.

Actually, there is plenty of evidence that this would help Linux too.

A couple of the 64-bit architectures with large page sizes would
definitely benefit, since the NFS client code currently is forced to
doing synchronous reads/writes if the r/wsize is less than the page
size (yes - fixing this in the client is on the agenda too).

Those that still want to use NFSv2, or that wish to write short files
under NFSv3 will benefit too (the latter from the fact that you can
coalesce the unstable writes + commit into 1 stable write). Ditto for
smallish O_SYNC writes.

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
