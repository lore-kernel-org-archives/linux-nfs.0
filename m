From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Poor NFS performance, kernel 2.6.6.
Date: Thu, 27 May 2004 15:01:14 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1085684474.4074.100.camel@lade.trondhjem.org>
References: <Pine.LNX.4.58.0405271331430.7539@penti.sit.fi>
	 <200405272007.10918.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net, Harald Hannelius <harald+nfs@arcada.fi>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTQ7y-0007YA-Sa
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 12:01:18 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BTQ7y-0005wE-Gz
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 12:01:18 -0700
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200405272007.10918.bernd-schubert@web.de>
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

P=E5 to , 27/05/2004 klokka 14:07, skreiv Bernd Schubert:
> if you read the list archive, you will see that Trond always suggests to =
use=20
> tcp in situations like this. Some weeks ago there was a discussion on LKM=
L=20
> about 2.6., udp and nfs, the final statement was, that one always should =
use=20
> tcp with 2.6. kernel versions (I still don't understand why, but my knowl=
edge=20
> about network protocol design and kernel internal networking is probably =
too=20
> much limited to understand the reason ;) ).

It has all to do with the network protocols. It's nothing we can fix in
the kernel.

See the discussion in FAQ number B10 on http://nfs.sourceforge.net

see also Casper's discussion on the same issue on
   http://www.netsys.com/sunmgr/1997-09/msg00070.html

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
