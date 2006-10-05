From: Stephane Doyon <sdoyon@max-t.com>
Subject: Re: several messages
Date: Thu, 5 Oct 2006 11:39:45 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610051108140.9190@madrid.max-t.internal>
References: <Pine.LNX.4.64.0609191533240.25914@madrid.max-t.internal>
	<451A618B.5080901@agami.com>
	<Pine.LNX.4.64.0610020939450.5072@madrid.max-t.internal>
	<20061002223056.GN4695059@melbourne.sgi.com>
	<Pine.LNX.4.64.0610030917060.31738@madrid.max-t.internal>
	<1159893642.5592.12.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Chinner <dgc@sgi.com>, nfs@lists.sourceforge.net,
	Shailendra Tripathi <stripathi@agami.com>, xfs@oss.sgi.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GVVLX-0005zb-EP
	for nfs@lists.sourceforge.net; Thu, 05 Oct 2006 08:41:18 -0700
Received: from h216-18-124-229.gtcust.grouptelecom.net ([216.18.124.229]
	helo=mail.max-t.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GVVLW-00057o-0Z
	for nfs@lists.sourceforge.net; Thu, 05 Oct 2006 08:41:16 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1159893642.5592.12.camel@lade.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, 3 Oct 2006, Trond Myklebust wrote:

> On Tue, 2006-10-03 at 09:39 -0400, Stephane Doyon wrote:
>> Sorry for insisting, but it seems to me there's still a problem in need of
>> fixing: when writing a 5GB file over NFS to an XFS file system and hitting
>> ENOSPC, it takes on the order of 22hours before my application gets an
>> error, whereas it would normally take about 2minutes if the file system
>> did not become full.
>>
>> Perhaps I was being a bit too "constructive" and drowned my point in
>> explanations and proposed workarounds... You are telling me that neither
>> NFS nor XFS is doing anything wrong, and I can understand your points of
>> view, but surely that behavior isn't considered acceptable?
>
> Sure it is.

If you say so :-).

> You are allowing the kernel to cache 5GB, and that means you
> only get the error message when close() completes.

But it's not actually caching the entire 5GB at once... I guess you're 
saying that doesn't matter...?

> If you want faster error reporting, there are modes like O_SYNC,
> O_DIRECT, that will attempt to flush the data more quickly. In addition,
> you can force flushing using fsync().

What if the program is a standard utility like cp?

> Finally, you can tweak the VM into
> flushing more often using /proc/sys/vm.

It doesn't look to me like a question of degrees about how early to flush. 
Actually my client can't possibly be caching all of 5GB, it doesn't have 
the RAM or swap for that. Tracing it more carefully, it appears dirty data 
starts being flushed after a few hundred MBs. No error is returned on the 
subsequent writes, only on the final close(). I see some of the write() 
calls are delayed, presumably when the machine reaches the dirty 
threshold. So I don't see how the vm settings can help in this case.

I hadn't realized that the issue isn't just with the final flush on 
close(). It's actually been flushing all along, delaying some of the 
subsequent write()s, getting NOSPC errors but not reporting them until the 
end.

I understand that since my application did not request any syncing, the 
system cannot guarantee to report errors until cached data has been 
flushed. But some data has indeed been flushed with an error; can't this 
be reported earlier than on close?

Would it be incorrect for a subsequent write to return the error that 
occurred while flushing data from previous writes? Then the app could 
decide whether to continue and retry or not. But I guess I can see how 
that might get convoluted.

Thanks for your patience,

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
