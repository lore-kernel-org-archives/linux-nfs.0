From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: ~800 mountpoint limitation
Date: Tue, 14 Oct 2003 12:44:20 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16268.10212.717980.343124@charged.uio.no>
References: <6AB920CC10586340BE1674976E0A991D59560D@slexch2.sugarland.unocal.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A9SHf-0003hE-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Oct 2003 09:44:31 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A9SHe-00067Z-F0
	for nfs@lists.sourceforge.net; Tue, 14 Oct 2003 09:44:30 -0700
To: "Ogden, Aaron A." <aogden@unocal.com>
In-Reply-To: <6AB920CC10586340BE1674976E0A991D59560D@slexch2.sugarland.unocal.com>
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

>>>>> " " == Aaron A Ogden <Ogden> writes:

     > Excellent!  I was hoping that you were following the
     > discussion.  It is something you can fix though?  It seems that
     > RPC may be involved as well...

     > Is there any hope of a patch for 2.4.20+ or is this strictly
     > 2.6 code?

I'm really too busy right now to do a backport for 2.4.x (hell, I'm
even too busy to forward-port to 2.6.0-test7 8-().

That said, it shouldn't be hard to do. I've made sure that the 2.4.x
and 2.6.x RPC code have been tracking one another, so there should be
few real differences to worry about. For all I know, the patch may
even apply without any changes...

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
