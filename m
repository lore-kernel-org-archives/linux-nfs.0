From: Olaf Kirch <okir@suse.de>
Subject: Re: Poor NFS performance, kernel 2.6.6.
Date: Fri, 28 May 2004 15:55:15 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040528135515.GG5657@suse.de>
References: <Pine.LNX.4.58.0405271331430.7539@penti.sit.fi> <1085695748.23934.94.camel@lade.trondhjem.org> <Pine.LNX.4.58.0405280953240.29286@penti.sit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BThs6-0007WO-1u
	for nfs@lists.sourceforge.net; Fri, 28 May 2004 06:58:06 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BThs5-0007eD-Gv
	for nfs@lists.sourceforge.net; Fri, 28 May 2004 06:58:05 -0700
To: Harald Hannelius <harald+nfs@arcada.fi>
In-Reply-To: <Pine.LNX.4.58.0405280953240.29286@penti.sit.fi>
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

[2.6 over loopback nfs]
> real    6m21.086s
> user    0m1.712s
> sys     0m5.454s

[2.4 over loopback nfs]
> real    1m11.875s
> user    0m1.730s
> sys     0m7.730s

This roughly matches some performance issues I've been seeing on a 2.6.5
kernel. Are you using reiser or ext3?

In general, dd to a local file is much different from what NFS does,
because nfsd flushes data to disk.

The NFS client will usually issue a COMMIT call roughly every 1 Meg,
so the following should mimic the behavior of nfsd a little better,
when run on your file system locally

	iozone -s 1g -r 1m -o -i 0

Higher numbers indicate better performance.

Could you run this on 2.4 and 2.6, please?

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
