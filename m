From: Stephane Doyon <sdoyon@max-t.com>
Subject: Re: Long sleep with i_mutex in xfs_flush_device(),
 affects NFS service, was: Re: several messages
Date: Tue, 3 Oct 2006 12:25:22 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610031221020.482@madrid.max-t.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Shailendra Tripathi <stripathi@agami.com>, xfs@oss.sgi.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GUn6S-0002O7-V2
	for nfs@lists.sourceforge.net; Tue, 03 Oct 2006 09:26:45 -0700
Received: from h216-18-124-229.gtcust.grouptelecom.net ([216.18.124.229]
	helo=mail.max-t.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GUn6Q-0001ZJ-Fv
	for nfs@lists.sourceforge.net; Tue, 03 Oct 2006 09:26:42 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
	David Chinner <dgc@sgi.com>
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

[Ouch... terribly sorry for the mangled subject line on my previous post, 
insufficient coffee I guess. Sheepishly re-posting in hope of untangling 
the discussion threading mess...]

---------- Forwarded message ----------
Date: Tue, 3 Oct 2006 09:39:55 -0400 (EDT)
From: Stephane Doyon <sdoyon@max-t.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>, David Chinner <dgc@sgi.com>
Cc:  <xfs@oss.sgi.com>,  <nfs@lists.sourceforge.net>,
     Shailendra Tripathi <stripathi@agami.com>
Subject: Re: several messages

Sorry for insisting, but it seems to me there's still a problem in need of 
fixing: when writing a 5GB file over NFS to an XFS file system and hitting 
ENOSPC, it takes on the order of 22hours before my application gets an error, 
whereas it would normally take about 2minutes if the file system did not become 
full.

Perhaps I was being a bit too "constructive" and drowned my point in 
explanations and proposed workarounds... You are telling me that neither NFS 
nor XFS is doing anything wrong, and I can understand your points of view, but 
surely that behavior isn't considered acceptable?

On Tue, 26 Sep 2006, Trond Myklebust wrote:

>  On Tue, 2006-09-26 at 16:05 -0400, Stephane Doyon wrote:
> >  I suppose it's not technically wrong to try to flush all the pages of the
> >  file, but if the server file system is full then it will be at its worse.
> >  Also if you happened to be on a slower link and have a big cache to flush,
> >  you're waiting around for very little gain.
>
>  That all assumes that nobody fixes the problem on the server. If
>  somebody notices, and actually removes an unused file, then you may be
>  happy that the kernel preserved the last 80% of the apache log file that
>  was being written out.
>
>  ENOSPC is a transient error: that is why the current behaviour exists.

On Tue, 3 Oct 2006, David Chinner wrote:

>  This deep in the XFS allocation functions, we cannot tell if we hold
>  the i_mutex or not, and it plays no part in determining if we have
>  space or not. Hence we don't touch it here.


>  I doubt it's a good idea for an NFS server, either.
[...]
>  Remember that XFS, like most filesystems, trades off speed for
>  correctness as we approach ENOSPC. Many parts of XFS slow down as we
>  approach ENOSPC, and this is just one example of where we need to be
>  correct, not fast.
[...]
>  IMO, this is a non-problem.  You're talking about optimising a
>  relatively rare corner case where correctness is more important than
>  speed and your test case is highly artificial. AFAIC, if you are
>  running at ENOSPC then you get what performance is appropriate for
>  correctness and if you are continually runing at ENOSPC, then buy
>  some more disks.....

My recipe to reproduce the problem locally is admittedly somewhat artificial, 
but the problematic usage definitely isn't: simply an app on an NFS client that 
happens to fill up a file system. There must be some way to handle this better.

Thanks



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
