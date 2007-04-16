From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 002 of 2] Avoid
	flush-when-locking	when	interclient consistency not needed.
Date: Mon, 16 Apr 2007 10:41:43 -0400
Message-ID: <1176734503.6761.37.camel@heimdal.trondhjem.org>
References: <20070306163710.8128.patches@notabene> <1070306054029.8360@suse.de>
	<1173192029.6393.52.camel@heimdal.trondhjem.org>
	<17903.17597.832563.922428@notabene.brown>
	<1176589265.6089.20.camel@heimdal.trondhjem.org>
	<4622D614.5030500@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: chuck.lever@oracle.com, Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HdSP2-0006l6-HP
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 07:42:00 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18I5ASRn080Qz1pyvpCwwWjyrc86DVjubU=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HdSP3-0007HB-DH
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 07:42:03 -0700
In-Reply-To: <4622D614.5030500@oracle.com>
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

On Sun, 2007-04-15 at 21:49 -0400, Chuck Lever wrote:
> Trond Myklebust wrote:
> > On Thu, 2007-03-08 at 10:03 +1100, Neil Brown wrote:
> >>> You can argue for or against the need to invalidate caches when the user
> >>> has specified "nolock" (it might be nice to add a Solaris-style "llock"
> >>> alias to this one day, btw: nolock == local locking != no locking at
> >>> all). We used to do this in early 2.4.x kernels, but that was changed.
> >>> The reason is that locking is the only way of ensuring that the NFS
> >>> cache is in sync with the server, and the "nolock" exception was
> >>> breaking this.
> 
> Why not create a special fcntl for NFS files that invalidates cached 
> data for that file?  That way, no matter what semantics a lock or unlock 
> operation has, there is always a well-defined way to flush the page cache.

That would break the code portability requirement. Locking is the only
operation that has known and portable semantics w.r.t. cache
consistency.

> I don't necessarily disagree with Trond about requiring some mechanism 
> for cache invalidation to be available.  However, as an aside, if the 
> NFS cache invalidation logic is working overall, it really shouldn't 
> ever be necessary for applications to trigger invalidation by hand.

Not sure what you mean here. Portable applications may have
synchronisation needs that go outside or beyond the usual close-to-open
model. If they use NLM locking, then they have no problems. If they have
their own locking, then they might not want to use NLM, but they still
may have a need to invalidate the cache.


On Mon, 16 Apr 2007 at 10:12:09 -0400, Peter Staubach wrote:
> "llock" or "local lock" implies that only local locks will be used.
> Thus, only the locks that the kernel is managing are used or kept
> track of.  No over the wire traffic for locking is issued.
> 
> With this option, caching is enabled.

So are you saying that 'llock' basically mirrors our 'nolock', or does
it additionally disable the flushing operations? If the latter, then I
suggest that we add a mount flag, NFS_MOUNT_LLOCK which automatically
sets NFS_MOUNT_NONLM + a new flag that just disables the cache flush on
lock/unlock.

Cheers
 Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
