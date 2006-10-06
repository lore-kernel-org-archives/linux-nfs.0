From: Stephane Doyon <sdoyon@max-t.com>
Subject: Re: several messages
Date: Fri, 6 Oct 2006 09:03:03 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610060859270.31641@madrid.max-t.internal>
References: <Pine.LNX.4.64.0609191533240.25914@madrid.max-t.internal>
	<451A618B.5080901@agami.com>
	<Pine.LNX.4.64.0610020939450.5072@madrid.max-t.internal>
	<20061002223056.GN4695059@melbourne.sgi.com>
	<Pine.LNX.4.64.0610030917060.31738@madrid.max-t.internal>
	<20061005083015.GC19345@melbourne.sgi.com>
	<Pine.LNX.4.64.0610051139540.31641@madrid.max-t.internal>
	<20061005232935.GE19345@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: xfs@oss.sgi.com, nfs@lists.sourceforge.net,
	Shailendra Tripathi <stripathi@agami.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GVpNG-0000Ff-Ba
	for nfs@lists.sourceforge.net; Fri, 06 Oct 2006 06:04:22 -0700
Received: from h216-18-124-229.gtcust.grouptelecom.net ([216.18.124.229]
	helo=mail.max-t.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GVpNF-0005DY-0a
	for nfs@lists.sourceforge.net; Fri, 06 Oct 2006 06:04:23 -0700
To: David Chinner <dgc@sgi.com>
In-Reply-To: <20061005232935.GE19345@melbourne.sgi.com>
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

>> The backtrace looked like this:
>>
>> ... nfsd_write nfsd_vfs_write vfs_writev do_readv_writev xfs_file_writev
>> xfs_write generic_file_buffered_write xfs_get_blocks __xfs_get_blocks
>> xfs_bmap xfs_iomap xfs_iomap_write_delay xfs_flush_space xfs_flush_device
>> schedule_timeout_uninterruptible.
>
> Ahhh, this gets hit on the ->prepare_write path (xfs_iomap_write_delay()),

Yes.

> not the allocate path (xfs_iomap_write_allocate()). Sorry - I got myself
> (and probably everyone else) confused there which why I suspected sync
> writes - they trigger the allocate path in the write call. I don't think
> 2.6.18 will change anything.
>
> FWIW, I don't think we can avoid this sleep when we first hit ENOSPC
> conditions, but perhaps once we are certain of the ENOSPC status
> we can tag the filesystem with this state (say an xfs_mount flag)
> and only clear that tag when something is freed. We could then
> use the tag to avoid continually trying extremely hard to allocate
> space when we know there is none available....

Yes! That's what I was trying to suggest :-). Thank you.

Is that hard to do?

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
