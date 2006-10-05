From: Stephane Doyon <sdoyon@max-t.com>
Subject: Re: several messages
Date: Thu, 5 Oct 2006 12:33:05 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610051139540.31641@madrid.max-t.internal>
References: <Pine.LNX.4.64.0609191533240.25914@madrid.max-t.internal>
	<451A618B.5080901@agami.com>
	<Pine.LNX.4.64.0610020939450.5072@madrid.max-t.internal>
	<20061002223056.GN4695059@melbourne.sgi.com>
	<Pine.LNX.4.64.0610030917060.31738@madrid.max-t.internal>
	<20061005083015.GC19345@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: xfs@oss.sgi.com, nfs@lists.sourceforge.net,
	Shailendra Tripathi <stripathi@agami.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GVWAl-0002nU-Ir
	for nfs@lists.sourceforge.net; Thu, 05 Oct 2006 09:34:17 -0700
Received: from h216-18-124-229.gtcust.grouptelecom.net ([216.18.124.229]
	helo=mail.max-t.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GVWAk-0006t8-Jl
	for nfs@lists.sourceforge.net; Thu, 05 Oct 2006 09:34:12 -0700
To: David Chinner <dgc@sgi.com>
In-Reply-To: <20061005083015.GC19345@melbourne.sgi.com>
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

On Thu, 5 Oct 2006, David Chinner wrote:

> On Tue, Oct 03, 2006 at 09:39:55AM -0400, Stephane Doyon wrote:
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
> I agree that this a little extreme and I can't recall of seeing
> anything like this before, but I can see how that may happen if the
> NFS client continues to try to write every dirty page after getting
> an ENOSPC and each one of those writes has to wait for 500ms.
>
> However, you did not mention what kernel version you are running.
> One recent bug (introduced by a fix for deadlocks at ENOSPC) could
> allow oversubscription of free space to occur in XFS, resulting in

I do have that fix in my kernel. (I'm the one who pointed you to the patch 
that introduced that particular problem.)

> the write being allowed to proceed (i.e. sufficient space for the
> data blocks) but then failing the allocation because there weren't
> enough blocks put aside for potential btree splits that occur during
> allocation. If the linux client is using sync writes on retry, then

The writes from nfsd shouldn't be sync. Technically it's not even 
retrying, just plowing on...

> this would trigger a 500ms sleep on every write.  That's the right
> sort of ballpark for the slowness you were seeing - 5GB / 32k * 0.5s
> = ~22 hours....
>
> This got fixed in 2.6.18-rc6 -

You mean commit 4be536debe3f7b0c right? (Actually -rc7 I believe...) I do 
have that one in my kernel. My kernel is 2.6.17 plus assorted XFS fixes.

> can you retry with a 2.6.18 server
> and see if your problem goes away?

Unfortunately it will be several days before I have a chance to do that.

The backtrace looked like this:

... nfsd_write nfsd_vfs_write vfs_writev do_readv_writev xfs_file_writev 
xfs_write generic_file_buffered_write xfs_get_blocks __xfs_get_blocks 
xfs_bmap xfs_iomap xfs_iomap_write_delay xfs_flush_space xfs_flush_device 
schedule_timeout_uninterruptible.

with a 500ms sleep in xfs_flush_device().

Thanks

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
