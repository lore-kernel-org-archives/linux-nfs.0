From: Stephane Doyon <sdoyon@max-t.com>
Subject: Re: several messages
Date: Fri, 6 Oct 2006 09:25:28 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610060903280.31641@madrid.max-t.internal>
References: <Pine.LNX.4.64.0609191533240.25914@madrid.max-t.internal>
	<451A618B.5080901@agami.com>
	<Pine.LNX.4.64.0610020939450.5072@madrid.max-t.internal>
	<20061002223056.GN4695059@melbourne.sgi.com>
	<Pine.LNX.4.64.0610030917060.31738@madrid.max-t.internal>
	<1159893642.5592.12.camel@lade.trondhjem.org>
	<Pine.LNX.4.64.0610051108140.9190@madrid.max-t.internal>
	<20061006003339.GF19345@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: xfs@oss.sgi.com, nfs@lists.sourceforge.net,
	Shailendra Tripathi <stripathi@agami.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GVpii-0002FE-6T
	for nfs@lists.sourceforge.net; Fri, 06 Oct 2006 06:26:32 -0700
Received: from h216-18-124-229.gtcust.grouptelecom.net ([216.18.124.229]
	helo=mail.max-t.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GVpii-0004tm-Mm
	for nfs@lists.sourceforge.net; Fri, 06 Oct 2006 06:26:33 -0700
To: David Chinner <dgc@sgi.com>
In-Reply-To: <20061006003339.GF19345@melbourne.sgi.com>
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

On Fri, 6 Oct 2006, David Chinner wrote:

> On Thu, Oct 05, 2006 at 11:39:45AM -0400, Stephane Doyon wrote:
>>
>> I hadn't realized that the issue isn't just with the final flush on
>> close(). It's actually been flushing all along, delaying some of the
>> subsequent write()s, getting NOSPC errors but not reporting them until the
>> end.
>
> Other NFS clients will report an ENOSPC on the next write() or close()
> if the error is reported during async writeback. The clients that typically
> do this throw away any unwritten data as well on the basis that the
> application was returned an error ASAP and it is now Somebody Else's
> Problem (i.e. the application needs to handle it from there).

Well the client wouldn't necessarily have to throw away cached data. It 
could conceivably be made to return ENOSPC on some subsequent write. It 
would need to throw away the data for that write, but not necessarily 
destroy its cache. It could then clear the error condition and allow the 
application to keep trying if it wants to...

>> Would it be incorrect for a subsequent write to return the error that
>> occurred while flushing data from previous writes? Then the app could
>> decide whether to continue and retry or not. But I guess I can see how
>> that might get convoluted.
>
> .... there's many entertaining hoops to jump through to do this
> reliably.

I imagine there would be...

> For example: when you have large amounts of cached data, expedient
> error reporting and tossing unwritten data leads to much faster
> error recovery than trying to write every piece of data (hence the
> Irix use of this method).

In my case, I didn't think I was caching that much data though, only a few 
hundred MBs, and I wouldn't have minded so much if an error had been 
returned after that much. The way it's implemented though, I can write an 
unbounded amount of data through that cache and not be told of the problem 
until I close or fsync. It may not be technically wrong, but given the 
outrageous delay I saw in my particular situation, it felt pretty 
suboptimal.

> There's no clear right or wrong approach here - both have their
> advantages and disadvantages for different workloads. If it
> weren't for the sub-optimal behaviour of XFS in this case, you
> probably wouldn't have even cared about this....

Indeed not! In fact, changing the client is not practical for me, what I 
need is a fix for the XFS behavior. I just thought it was also worth 
reporting what I perceived to be an issue with the NFS client.

Thanks

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
