From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Poor NFS performance, kernel 2.6.6.
Date: Thu, 27 May 2004 18:09:13 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1085695748.23934.94.camel@lade.trondhjem.org>
References: <Pine.LNX.4.58.0405271331430.7539@penti.sit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTT4L-0001JX-R8
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 15:09:45 -0700
Received: from [141.211.133.132] (helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BTT4K-000533-WB
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 15:09:45 -0700
To: Harald Hannelius <harald+nfs@arcada.fi>
In-Reply-To: <Pine.LNX.4.58.0405271331430.7539@penti.sit.fi>
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

P=E5 to , 27/05/2004 klokka 06:31, skreiv Harald Hannelius:

> But dd'ing the 2GB file over nfs as some NFS-HOWTO suggests takes over 5
> minutes. That should equal to something around 49 Mbps, correct?

So what is the speed when dding the file locally on the server? (that is
*not* the same as rsync)

What if you then do the same thing on the server via a loopback mount on
the server (i.e. mount localhost:/home /mnt)?

Finally, if you do "nfsstat", what sort of values are you getting for
"retrans"?

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
