From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 001 of 8] knfsd: Add nfs-export support to tmpfs
Date: Fri, 29 Sep 2006 20:41:04 +0100 (BST)
Message-ID: <Pine.LNX.4.64.0609292014160.23046@blonde.wat.veritas.com>
References: <20060929130518.23919.patches@notabene>
	<1060929030839.24024@suse.de>
	<20060928232953.6da08f19.akpm@osdl.org>
	<17692.49605.248998.607609@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>,
	Gilad Ben-Yossef <gilad@codefidence.com>,
	"David M. Grimes" <dgrimes@navisite.com>,
	linux-kernel@vger.kernel.org,
	Atal Shargorodsky <atal@codefidence.com>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GTOEi-00046X-Ka
	for nfs@lists.sourceforge.net; Fri, 29 Sep 2006 12:41:28 -0700
Received: from excu-mxob-2.symantec.com ([198.6.49.23])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GTOEd-0005zj-Ua
	for nfs@lists.sourceforge.net; Fri, 29 Sep 2006 12:41:29 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17692.49605.248998.607609@cse.unsw.edu.au>
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

On Fri, 29 Sep 2006, Neil Brown wrote:
> On Thursday September 28, akpm@osdl.org wrote:
> > 
> > Why don't other filesystems have the same problem?
> 
> Because most filesystems that hash their inodes do so at the point
> where the 'struct inode' is initialised, and that has suitable locking
> (I_NEW).  Here in shmem, we are hashing the inode later, the first
> time we need an NFS file handle for it.  We no longer have I_NEW to
> ensure only one thread tries to add it to the hash table.
> 
> The comment tries to explain this, but obviously isn't completely
> successful.

That makes sense.

This patch looks mostly good to me, thanks to David and you for it;
and my apologies to Atal and Gilad for never quite getting around
to looking at theirs properly (but the hashing in this new one does
look better than their linear search).  Though I know tmpfs, I
don't know NFS, so I'm glad this is coming from your direction.

But one anxiety, regarding i_ino.  That's an unsigned long originating
from last_inode in fs/inode.c, isn't it?  Here getting cast to a __u32
to make up one part of the file handle, which will then be cast back
to an unsigned long for ilookup later.

So on 64-bit arches, it'll only take one dedicated creator and
deleter of files to advance the last_inode count to the point where
the high int is non-zero, and shmem_get_dentry won't ever recognize
any inodes created thereafter, always reporting -ESTALE?  I'm on
unfamiliar territory, but it looks to me like we need another
__u32 in the file handle to cope with that?

Then there's the lesser but more tiresome problem, of i_ino collisions
on 32-bit arches.  tmpfs hasn't worried about that to date, just taken
whatever new_inode() has given it from last_inode: but perhaps these
file handles now make that more of a concern?

Hugh

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
