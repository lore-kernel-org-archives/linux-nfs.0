From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 001 of 8] knfsd: Add nfs-export support to tmpfs
Date: Thu, 28 Sep 2006 23:29:53 -0700
Message-ID: <20060928232953.6da08f19.akpm@osdl.org>
References: <20060929130518.23919.patches@notabene>
	<1060929030839.24024@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Hugh Dickins <hugh@veritas.com>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GTBsn-0007Jg-9K
	for nfs@lists.sourceforge.net; Thu, 28 Sep 2006 23:30:01 -0700
Received: from smtp.osdl.org ([65.172.181.4])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1GTBsl-0001j1-Pc
	for nfs@lists.sourceforge.net; Thu, 28 Sep 2006 23:30:02 -0700
To: NeilBrown <neilb@suse.de>,
	"David M. Grimes" <dgrimes@navisite.com>,
	Atal Shargorodsky <atal@codefidence.com>,
	Gilad Ben-Yossef <gilad@codefidence.com>
In-Reply-To: <1060929030839.24024@suse.de>
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

On Fri, 29 Sep 2006 13:08:39 +1000
NeilBrown <neilb@suse.de> wrote:

> +static int shmem_encode_fh(struct dentry *dentry, __u32 *fh, int *len, int connectable)
> +{
> +	struct inode *inode = dentry->d_inode;
> +
> +	if (*len < 2)
> +		return 255;
> +
> +	if (hlist_unhashed(&inode->i_hash)) {
> +		/* Unfortunately insert_inode_hash is not idempotent,
> +		 * so as we hash inodes here rather than at creation
> +		 * time, we need a lock to ensure we only try
> +		 * to do it once
> +		 */
> +		static DEFINE_SPINLOCK(lock);
> +		spin_lock(&lock);
> +		if (hlist_unhashed(&inode->i_hash))
> +			insert_inode_hash(inode);
> +		spin_unlock(&lock);
> +	}

This looks fishy.

How do we get two callers in here at the same time for the same inode?

Why don't other filesystems have the same problem?



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
