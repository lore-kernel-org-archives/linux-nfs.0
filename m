From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS cache problem
Date: Wed, 25 May 2005 20:12:33 -0400
Message-ID: <1117066353.12336.82.camel@lade.trondhjem.org>
References: <429503BA.4060908@utwente.nl>
	 <1117064050.12336.67.camel@lade.trondhjem.org>
	 <42950DCE.9050109@utwente.nl>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Db5zR-0003WZ-9j
	for nfs@lists.sourceforge.net; Wed, 25 May 2005 17:12:45 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Db5zQ-0001CS-Qx
	for nfs@lists.sourceforge.net; Wed, 25 May 2005 17:12:45 -0700
To: Anton Starikov <A.Starikov@utwente.nl>
In-Reply-To: <42950DCE.9050109@utwente.nl>
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

to den 26.05.2005 Klokka 01:44 (+0200) skreiv Anton Starikov:
> Trond Myklebust wrote:
> > The NFS cache consistency model is discussed in the FAQ. Please see
> > http://nfs.sourceforge.net/#faq_a8
> 
> I did it long time ago. I've reread it now.
> My usage fits this. I have "noac" and "sync" on client side. What's more? :)

"noac" just means that the client rereads the attributes every time it
reads or writes.
If the size and the mtime on the file haven't changed, then the client
assumes the data in the file itself also hasn't changed. That is usually
a good assumption on something like XFS (which has nanosecond precision
on mtime). It can be rather inaccurate on something like EXT3 (which has
a precision of only 1 second on mtime).

If you seriously need uncached reads and writes, then you should rather
consider using O_DIRECT.

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is sponsored by: GoToMeeting - the easiest way to collaborate
online with coworkers and clients while avoiding the high cost of travel and
communications. There is no equipment to buy and you can meet as often as
you want. Try it free.http://ads.osdn.com/?ad_id=7402&alloc_id=16135&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
