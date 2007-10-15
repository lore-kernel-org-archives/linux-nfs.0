From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: reply cache
Date: Mon, 15 Oct 2007 13:09:44 -0400
Message-ID: <EXNANE016gx3lKy8VBD000006fc@exnane01.hq.netapp.com>
References: <47139B20.7070805@cesca.es>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jordi Prats <jprats@cesca.es>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IhTU1-0006sM-48
	for nfs@lists.sourceforge.net; Mon, 15 Oct 2007 10:12:01 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IhTU2-0001SK-9T
	for nfs@lists.sourceforge.net; Mon, 15 Oct 2007 10:12:05 -0700
In-Reply-To: <47139B20.7070805@cesca.es>
References: <47139B20.7070805@cesca.es>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

At 12:53 PM 10/15/2007, Jordi Prats wrote:
>Hi all,
>According to the file fs/nfsd/nfscache.c (line 30 on 2.6.23), reply 
>cache is fixed size. Why is this a fixed size cache? Shouldn't be 
>relative to the number of nfsd threads? I've a server with this statistics:
>
>rc 0 959398 336415498
>
>By what I've been researching this means: 0 hits, 959398 misses (I 
>supose that means something like "recently deleted") and 336415498 not 
>in cache (and never has been). Is that right?

No, the large number is NOCACHE, which means the operation does not
require caching at all (it's an idempotent operation). The smaller number
is either a new operation that does require caching, or a retransmit that
didn't hit.

>Modifying the CACHESIZE to a bigger size do you think it could enhance 
>NFS performance by getting some hits on the reply cache?

A bigger cache will only waste memory in your case. If you had a very
large miss count, then it might be warranted, but in any case it is not
going to help performance unless you're seeing a large number of client
retransmits. And even then, the fix is not a bigger cache.

Tom.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
