From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS cache problem
Date: Wed, 25 May 2005 22:12:14 -0400
Message-ID: <1117073534.10938.6.camel@lade.trondhjem.org>
References: <429503BA.4060908@utwente.nl>
	 <1117064050.12336.67.camel@lade.trondhjem.org>
	 <42950DCE.9050109@utwente.nl>
	 <1117066353.12336.82.camel@lade.trondhjem.org>
	 <42951852.6050501@utwente.nl>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Db7rO-0003T5-QK
	for nfs@lists.sourceforge.net; Wed, 25 May 2005 19:12:34 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Db7rO-0002Ob-8G
	for nfs@lists.sourceforge.net; Wed, 25 May 2005 19:12:34 -0700
To: Anton Starikov <A.Starikov@utwente.nl>
In-Reply-To: <42951852.6050501@utwente.nl>
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

to den 26.05.2005 Klokka 02:29 (+0200) skreiv Anton Starikov:
> Trond Myklebust wrote:
> > "noac" just means that the client rereads the attributes every time it
> > reads or writes.
> > If the size and the mtime on the file haven't changed, then the client
> > assumes the data in the file itself also hasn't changed. That is usually
> > a good assumption on something like XFS (which has nanosecond precision
> > on mtime). It can be rather inaccurate on something like EXT3 (which has
> > a precision of only 1 second on mtime).
> I use ReiserFS.
> And here we talk not about seconds...we talk about hours sometimes.
> That's seems too strange for me. For seconds I can find plenty of
> explanations :)
> In principal even if it will be one minute, I'll be much more happy than
> now.

I repeat: if the file attributes do not change, then the NFS client will
not update its data cache. That is true of Solaris too.

> > If you seriously need uncached reads and writes, then you should rather,
> > consider using O_DIRECT.
> Unfortunatelly this is not trivial problem. A lot of software are
> involved here. And I beleive that NFS should be able to work in this
> conditions properly. At least it did with solaris in similar environment.

Mind describing _what_ kind of environment it works under? In other
words, what is the Solaris client doing that the Linux client is not
doing when running under the _same_ conditions (i.e. against the same
server and running the same applications)?

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
