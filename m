From: David Chinner <dgc@sgi.com>
Subject: Re: several messages
Date: Fri, 6 Oct 2006 10:33:39 +1000
Message-ID: <20061006003339.GF19345@melbourne.sgi.com>
References: <Pine.LNX.4.64.0609191533240.25914@madrid.max-t.internal>
	<451A618B.5080901@agami.com>
	<Pine.LNX.4.64.0610020939450.5072@madrid.max-t.internal>
	<20061002223056.GN4695059@melbourne.sgi.com>
	<Pine.LNX.4.64.0610030917060.31738@madrid.max-t.internal>
	<1159893642.5592.12.camel@lade.trondhjem.org>
	<Pine.LNX.4.64.0610051108140.9190@madrid.max-t.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: xfs@oss.sgi.com, David Chinner <dgc@sgi.com>,
	nfs@lists.sourceforge.net, Shailendra Tripathi <stripathi@agami.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GVdfD-0003gG-Ip
	for nfs@lists.sourceforge.net; Thu, 05 Oct 2006 17:34:07 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GVdfD-0001JX-7r
	for nfs@lists.sourceforge.net; Thu, 05 Oct 2006 17:34:08 -0700
To: Stephane Doyon <sdoyon@max-t.com>
In-Reply-To: <Pine.LNX.4.64.0610051108140.9190@madrid.max-t.internal>
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

On Thu, Oct 05, 2006 at 11:39:45AM -0400, Stephane Doyon wrote:
> 
> I hadn't realized that the issue isn't just with the final flush on 
> close(). It's actually been flushing all along, delaying some of the 
> subsequent write()s, getting NOSPC errors but not reporting them until the 
> end.

Other NFS clients will report an ENOSPC on the next write() or close()
if the error is reported during async writeback. The clients that typically
do this throw away any unwritten data as well on the basis that the
application was returned an error ASAP and it is now Somebody Else's
Problem (i.e. the application needs to handle it from there).

> I understand that since my application did not request any syncing, the 
> system cannot guarantee to report errors until cached data has been 
> flushed. But some data has indeed been flushed with an error; can't this 
> be reported earlier than on close?

It could, but...

> Would it be incorrect for a subsequent write to return the error that 
> occurred while flushing data from previous writes? Then the app could 
> decide whether to continue and retry or not. But I guess I can see how 
> that might get convoluted.

.... there's many entertaining hoops to jump through to do this
reliably.

FWIW, these are simply two different approaches to handling ENOSPC
(and other server) errors.  Mostly it comes down to how the ppl who
implemented the NFS client think it's best to handle the errors in
the scenarios that they most care about.

For example: when you have large amounts of cached data, expedient
error reporting and tossing unwritten data leads to much faster
error recovery than trying to write every piece of data (hence the
Irix use of this method).

OTOH, when you really want as much of the data to get to the server,
regardless of whether you lose some (e.g.  log files) before
reporting an error then you try to write every bit of data before
telling the application.

There's no clear right or wrong approach here - both have their
advantages and disadvantages for different workloads. If it
weren't for the sub-optimal behaviour of XFS in this case, you
probably wouldn't have even cared about this....

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
