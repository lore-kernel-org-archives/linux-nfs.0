From: David Chinner <dgc@sgi.com>
Subject: Re: several messages
Date: Thu, 5 Oct 2006 18:30:15 +1000
Message-ID: <20061005083015.GC19345@melbourne.sgi.com>
References: <Pine.LNX.4.64.0609191533240.25914@madrid.max-t.internal>
	<451A618B.5080901@agami.com>
	<Pine.LNX.4.64.0610020939450.5072@madrid.max-t.internal>
	<20061002223056.GN4695059@melbourne.sgi.com>
	<Pine.LNX.4.64.0610030917060.31738@madrid.max-t.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: xfs@oss.sgi.com, David Chinner <dgc@sgi.com>,
	nfs@lists.sourceforge.net, Shailendra Tripathi <stripathi@agami.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GVOd3-0007Xl-Fo
	for nfs@lists.sourceforge.net; Thu, 05 Oct 2006 01:30:53 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GVOd2-0006eM-5a
	for nfs@lists.sourceforge.net; Thu, 05 Oct 2006 01:30:54 -0700
To: Stephane Doyon <sdoyon@max-t.com>
In-Reply-To: <Pine.LNX.4.64.0610030917060.31738@madrid.max-t.internal>
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

On Tue, Oct 03, 2006 at 09:39:55AM -0400, Stephane Doyon wrote:
> Sorry for insisting, but it seems to me there's still a problem in need of 
> fixing: when writing a 5GB file over NFS to an XFS file system and hitting 
> ENOSPC, it takes on the order of 22hours before my application gets an 
> error, whereas it would normally take about 2minutes if the file system 
> did not become full.
>
> Perhaps I was being a bit too "constructive" and drowned my point in 
> explanations and proposed workarounds... You are telling me that neither 
> NFS nor XFS is doing anything wrong, and I can understand your points of 
> view, but surely that behavior isn't considered acceptable?

I agree that this a little extreme and I can't recall of seeing
anything like this before, but I can see how that may happen if the
NFS client continues to try to write every dirty page after getting
an ENOSPC and each one of those writes has to wait for 500ms.

However, you did not mention what kernel version you are running.
One recent bug (introduced by a fix for deadlocks at ENOSPC) could
allow oversubscription of free space to occur in XFS, resulting in
the write being allowed to proceed (i.e. sufficient space for the
data blocks) but then failing the allocation because there weren't
enough blocks put aside for potential btree splits that occur during
allocation. If the linux client is using sync writes on retry, then
this would trigger a 500ms sleep on every write.  That's the right
sort of ballpark for the slowness you were seeing - 5GB / 32k * 0.5s
= ~22 hours....

This got fixed in 2.6.18-rc6 - can you retry with a 2.6.18 server
and see if your problem goes away?

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
