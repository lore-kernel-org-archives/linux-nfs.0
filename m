From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS not negotiating MTU correctly?
Date: Tue, 25 May 2004 11:04:49 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1085497489.3872.26.camel@lade.trondhjem.org>
References: <1085491125.30311.20808.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BSdU5-000808-JG
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 08:04:53 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BSdU5-0006qm-2U
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 08:04:53 -0700
To: Chris Worley <cworley@lnxi.com>
In-Reply-To: <1085491125.30311.20808.camel@localhost>
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

P=E5 ty , 25/05/2004 klokka 09:18, skreiv Chris Worley:

> In grilling my switch vendor, they assure me that it's the client &
> servers job to negotiate properly fragmented packets based on the lessor
> MTU.

That sounds like a piss-poor switch to me. AFAIK all routers are
supposed to automatically fragment datagrams when forwarding between
networks that have a different MTU. Automatic MTU discovery is not part
of the IP protocol (although methods for doing so under certain
circumstances do exist).

In any case, dealing with MTUs is entirely the networking layer's job.
NFS just deals with sockets. I suggest that you check that the
ip_no_pmtu_disc sysctl is set correctly, and then check with the Linux
networking mailing list (netdev@oss.sgi.com) if there are further
problems.

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
