From: Harald Hannelius <harald+nfs@arcada.fi>
Subject: Re: Poor NFS performance, kernel 2.6.6.
Date: Fri, 28 May 2004 21:03:58 +0300 (EEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0405282058300.14886@penti.sit.fi>
References: <Pine.LNX.4.58.0405271331430.7539@penti.sit.fi>
 <1085695748.23934.94.camel@lade.trondhjem.org> <Pine.LNX.4.58.0405280953240.29286@penti.sit.fi>
 <20040528135515.GG5657@suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTli6-0008AP-7T
	for nfs@lists.sourceforge.net; Fri, 28 May 2004 11:04:02 -0700
Received: from penti.sit.fi ([193.167.33.237])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTli5-0008EP-JQ
	for nfs@lists.sourceforge.net; Fri, 28 May 2004 11:04:01 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040528135515.GG5657@suse.de>
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


On Fri, 28 May 2004, Olaf Kirch wrote:

> [2.6 over loopback nfs]
> > real    6m21.086s
> > user    0m1.712s
> > sys     0m5.454s
>
> [2.4 over loopback nfs]
> > real    1m11.875s
> > user    0m1.730s
> > sys     0m7.730s
>
> This roughly matches some performance issues I've been seeing on a 2.6.5
> kernel. Are you using reiser or ext3?

ext3.

> In general, dd to a local file is much different from what NFS does,
> because nfsd flushes data to disk.

I guess (as a total don't-know) that nfsd reads and writes files in a
different way than local processes do. I read somewhere something about
read-ahead but that was in 2.6.0-pre-something..

> The NFS client will usually issue a COMMIT call roughly every 1 Meg,
> so the following should mimic the behavior of nfsd a little better,
> when run on your file system locally
>
> 	iozone -s 1g -r 1m -o -i 0
>
> Higher numbers indicate better performance.
>
> Could you run this on 2.4 and 2.6, please?

Oh sorry, the server went into production to day so I can't run the tests
on 2.6 without rebooting first. Not a good idea right now :)

But here are (useless without 2.6 ditto) results with kernel 2.4.26 run
locally on the fileserver;

 http://people.arcada.fi/~harald/nfs/iozone-1MBcommit.txt
 http://people.arcada.fi/~harald/nfs/iozone-1MBcommit2.txt



-- 
A: Top Posters
Q: What is the most annoying thing on mailing lists?

Harald H Hannelius | harald/a\arcada.fi      | GSM +358 50 594 1020


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
