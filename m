From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: trouble with file locking
Date: 19 Nov 2003 15:21:31 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsd6bohzxw.fsf@charged.uio.no>
References: <20031112105043.020c1548.erik@thiele-hydraulik.de>
	<Pine.LNX.4.58.0311191259400.846@lewis.et.byu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Erik Thiele <erik@thiele-hydraulik.de>,
	  "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AMYpW-0006Js-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Nov 2003 12:21:38 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AMYpW-00011z-0R
	for nfs@lists.sourceforge.net; Wed, 19 Nov 2003 12:21:38 -0800
To: David Dougall <davidd@et.byu.edu>
In-Reply-To: <Pine.LNX.4.58.0311191259400.846@lewis.et.byu.edu>
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

>>>>> " " == David Dougall <davidd@et.byu.edu> writes:

     > Is this test program run on a HP-UX client or a linux client?
     > My experience with HP-UX nfs client is that locking is very
     > flaky if it even works at all.  You might try flock instead of
     > fcntl.  That seems to work better.  You might also, if you have
     > a support contract, check out HP-UX nfs patches.  They might
     > suddenly make it work.  --David Dougall

flock() doesn't work at all over NFS in Linux. It just does local
locking.

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
