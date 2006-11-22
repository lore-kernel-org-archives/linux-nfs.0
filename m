From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC] Change filesystem mount without
	disconnecting	clients
Date: Wed, 22 Nov 2006 13:15:46 -0500
Message-ID: <1164219346.5694.31.camel@lade.trondhjem.org>
References: <4563C1A4.5060608@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Robert Nelson <rlnelson@google.com>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gmwdu-0002uN-C4
	for nfs@lists.sourceforge.net; Wed, 22 Nov 2006 10:16:18 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19MTfXIY0qK7Kn4XXJSkNdkyKlGjqymvG8=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gmwdt-0006qM-AZ
	for nfs@lists.sourceforge.net; Wed, 22 Nov 2006 10:16:19 -0800
To: Daniel Phillips <phillips@google.com>
In-Reply-To: <4563C1A4.5060608@google.com>
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

On Tue, 2006-11-21 at 19:19 -0800, Daniel Phillips wrote:
> Hi all,
> 
> This patch provides an interface to let us quietly change the block device
> on which a filesystem is mounted, without disrupting client TCP connections.
> Why would anybody want to do such a strange thing?  Answer: remote block
> device replication.
> 
> Each replication cycle results in a new virtual block device containing a
> new, consistent state of the filesystem.  We want clients to see the changed
> filesystem transparently, without remounting, as if somebody had just gone
> in and directly operated on the local filesystem, adding files, deleting
> files, changing file contents, renaming and so on.  This should all just
> work, even if clients have files open and are in the middle of operating on
> them.  This can cause some file operations to error out, but will not crash
> the client or server.  Operations on unchanged files should work as expected,
> in spite of the underlying block device having been changed.Note: to avoid
> state file handles we do need to take some care with the fsid, which is not
> within the scope of this patch (we just specify a known fsid in the exports
> file for the time being).
> 
> The interface works as follows:
>     write anything to /proc/fs/nfsd/suspend ->
>        flush nfsd export cache and suspend nfs transaction processing
> 
>     read anything from /proc/fs/nfsd/suspend ->
>        resume nfs transaction processing
> 
> The suspend is accomplished by taking a write lock on the export cache's
> hash_sem, which by fortuitous circumstance encloses all nfs transaction
> processing.  We then flush the export cache, driving the underlying
> filesystem mount count down to one, in which state it can be unmounted.
> Holding the hash_sem prevents mountd from reloading the export cache.  To
> resume, we just release the write lock.

Definitely not the correct way to do this. Causing the NFS server to
hang for long periods of time will, for instance, cause all NFSv4 state
to be unnecessarily lost, forcing a full state recovery. It will also
cause UDP clients to flood the network with retries.

Ideally, you want to be returning NFS3ERR_JUKEBOX to the NFSv3 clients
(or NFS4ERR_DELAY for NFSv4) in order to request that they back off and
retry the operation later. For some operations that don't involve files
(e.g. the NFSv4 RENEW requests, NULL RPC pings) you may actually want to
process the request despite the disk being offline.

  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
