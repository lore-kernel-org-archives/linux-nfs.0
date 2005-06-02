From: Shantanu Goel <sgoel01@yahoo.com>
Subject: Re: [PATCH] Smooth out NFS client writeback
Date: Thu, 2 Jun 2005 05:16:24 -0700 (PDT)
Message-ID: <20050602121624.41192.qmail@web30705.mail.mud.yahoo.com>
References: <1117687110.10822.114.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddoch-0006BK-85
	for nfs@lists.sourceforge.net; Thu, 02 Jun 2005 05:16:31 -0700
Received: from web30705.mail.mud.yahoo.com ([68.142.200.138])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1Ddocf-0000cX-Gz
	for nfs@lists.sourceforge.net; Thu, 02 Jun 2005 05:16:30 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1117687110.10822.114.camel@lade.trondhjem.org>
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


--- Trond Myklebust <trond.myklebust@fys.uio.no>
wrote:
> What happens when you increase the file size to
> significantly beyond the
> memory size on a slow network. That is the
> interesting case.
> Try, for instance, booting with mem=3D32m and iozone
> -s=20
>=20

I'll run this case and report back.

> > I also ran iozone in mmap mode with same options
> as
> > above but specifying -B as well.  The machine hung
> > with the stock client so could not complete the
> test.=20
> > Here are the numbers with the patched client.
>=20
> Where was the machine hanging?
>=20

I didn't have console access due to X.  I'll try and
get a sysrq-t when I get a chance.

> BTW: how did you determine the values for
> NFS_WRITE_CLUSTER and
> NFS_COMMIT_CLUSTER. they appear to be completely
> arbitrary AFAICS.
>=20

NFS_WRITE_CLUSTER is a variant of SWAP_CLUSTER_MAX
used by kswapd.  NFS_COMMIT_CLUSTER was chosen to
match balance_dirty_pages() which uses 4MB for
throttling a writer.

> Also, have you compared to the latest NFS_ALL
> kernels? They contain a
> bunch of extra latency fixes that came from Ingo's
> RT work.
>=20

This patch is on top of 2.6.12-rc5 with NFS_ALL for
2.6.12-rc4.  The stock numbers I reported are with
NFS_ALL.  Is there a newer version somewhere?

> Finally, please explain _why_ have you removed the
> FLUSH_STABLE from
> nfs_writepage()? The reason for it in the existing
> code is to avoid the
> extra COMMIT call in situations where we know we are
> already very low on
> memory. I don't see anything new in your patches
> that avoids these low
> memory situations.

The current FLUSH_STABLE behaviour absolutely shoots
our performance on iozone -B compared to Solaris.
The low memory situation is avoided because of the
congestion check I added in writepage().  If the inode
is congested, it redirty's the page and returns.  It
also issues a commit request if there are at least
NFS_WRITE_CLUSTER pages.



=09
	=09
__________________________________=20
Do you Yahoo!?=20
Yahoo! Mail - You care about security. So do we.=20
http://promotions.yahoo.com/new_mail


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=3D7477&alloc_id=3D16492&op=3Dclic=
k
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
