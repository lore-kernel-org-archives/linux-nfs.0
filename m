From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: Unknown error 525 from getdents from a connection to
	an AIX nfs server
Date: Wed, 22 Jun 2005 06:10:59 -0400
Message-ID: <1119435059.11251.22.camel@lade.trondhjem.org>
References: <200506041341.11421.bartoschek@or.uni-bonn.de>
	 <200506211433.18308.bartoschek@or.uni-bonn.de>
	 <1119384290.10648.21.camel@lade.trondhjem.org>
	 <200506221124.26189.bartoschek@or.uni-bonn.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dl2CU-0002Y0-3I
	for nfs@lists.sourceforge.net; Wed, 22 Jun 2005 03:11:18 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Dl2CT-000829-Gr
	for nfs@lists.sourceforge.net; Wed, 22 Jun 2005 03:11:17 -0700
To: Christoph Bartoschek <bartoschek@or.uni-bonn.de>
In-Reply-To: <200506221124.26189.bartoschek@or.uni-bonn.de>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

on den 22.06.2005 Klokka 11:24 (+0200) skreiv Christoph Bartoschek:

> I do not know how to read NFS traffic. Therefore I made an ethereal dump 
> during  the rm -rf a in the following sequence:
> 
> mkdir a
> touch a/b
> rm -rf a
> 
> I hope you find some useful information. If you need other information, give 
> me short instruction on how to obtain it.

That appears to be a server bug.

The client is performing a READDIRPLUS operation using a cookie that
used to be valid but now refers to an entry that was deleted. Instead of
returning the correct error of NFS3ERR_BADCOOKIE, the server is
returning NFS3ERR_TOOSMALL.

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
