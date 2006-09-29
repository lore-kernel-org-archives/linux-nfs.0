From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 001 of 8] knfsd: Add nfs-export support to tmpfs
Date: Fri, 29 Sep 2006 16:48:37 +1000
Message-ID: <17692.49605.248998.607609@cse.unsw.edu.au>
References: <20060929130518.23919.patches@notabene>
	<1060929030839.24024@suse.de>
	<20060928232953.6da08f19.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Gilad Ben-Yossef <gilad@codefidence.com>,
	"David M. Grimes" <dgrimes@navisite.com>,
	linux-kernel@vger.kernel.org,
	Atal Shargorodsky <atal@codefidence.com>, nfs@lists.sourceforge.net,
	Hugh Dickins <hugh@veritas.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GTCBG-0000Xb-NP
	for nfs@lists.sourceforge.net; Thu, 28 Sep 2006 23:49:06 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GTCBF-00029L-T0
	for nfs@lists.sourceforge.net; Thu, 28 Sep 2006 23:49:07 -0700
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: message from Andrew Morton on Thursday September 28
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

On Thursday September 28, akpm@osdl.org wrote:
> On Fri, 29 Sep 2006 13:08:39 +1000
> NeilBrown <neilb@suse.de> wrote:
> 
> > +static int shmem_encode_fh(struct dentry *dentry, __u32 *fh, int *len, int connectable)
> > +{
> > +	struct inode *inode = dentry->d_inode;
> > +
> > +	if (*len < 2)
> > +		return 255;
> > +
> > +	if (hlist_unhashed(&inode->i_hash)) {
> > +		/* Unfortunately insert_inode_hash is not idempotent,
> > +		 * so as we hash inodes here rather than at creation
> > +		 * time, we need a lock to ensure we only try
> > +		 * to do it once
> > +		 */
> > +		static DEFINE_SPINLOCK(lock);
> > +		spin_lock(&lock);
> > +		if (hlist_unhashed(&inode->i_hash))
> > +			insert_inode_hash(inode);
> > +		spin_unlock(&lock);
> > +	}
> 
> This looks fishy.
> 
> How do we get two callers in here at the same time for the same inode?

Probably not very easily.
But imagine a file has two hard links in different directories.
And two clients issue LOOKUP requests, one for each link.
They could conceivably be processed at exactly the same time and so
shmem_encode_fh could be running on two different CPU's at the same
time for the same inode.

> 
> Why don't other filesystems have the same problem?
> 

Because most filesystems that hash their inodes do so at the point
where the 'struct inode' is initialised, and that has suitable locking
(I_NEW).  Here in shmem, we are hashing the inode later, the first
time we need an NFS file handle for it.  We no longer have I_NEW to
ensure only one thread tries to add it to the hash table.

The comment tries to explain this, but obviously isn't completely
successful.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
