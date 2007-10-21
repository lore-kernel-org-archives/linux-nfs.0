From: Erez Zadok <ezk@cs.sunysb.edu>
Subject: Re: nfsv2 ref leak in 2.6.24?
Date: Sun, 21 Oct 2007 18:18:22 -0400
Message-ID: <200710212218.l9LMIMgj011206@agora.fsl.cs.sunysb.edu>
References: <1192985892.7505.32.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de,
	Erez Zadok <ezk@cs.sunysb.edu>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ijj8A-0008Dg-7B
	for nfs@lists.sourceforge.net; Sun, 21 Oct 2007 15:18:46 -0700
Received: from filer.fsl.cs.sunysb.edu ([130.245.126.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ijj8E-0002sH-Cc
	for nfs@lists.sourceforge.net; Sun, 21 Oct 2007 15:18:51 -0700
In-reply-to: Your message of "Sun, 21 Oct 2007 12:58:12 EDT."
	<1192985892.7505.32.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

In message <1192985892.7505.32.camel@heimdal.trondhjem.org>, Trond Myklebust writes:
> 
> On Sat, 2007-10-20 at 17:35 -0400, Erez Zadok wrote:
> 
> > Trond, I verified that w/ the above patch the problem is w/ nfs: the client
> > leaves .nfsXXX files behind for every file unlinked while open.  Let me know
> > when you get a fix and I'll test it.
> 
> Doh... Another typo.
> 
> Trond
> -------------------------- CUT HERE --------------------
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Sun, 21 Oct 2007 12:02:22 -0400
> NFS: Fix a typo in nfs_call_unlink()
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  fs/nfs/unlink.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
> index ce558c2..233ad38 100644
> --- a/fs/nfs/unlink.c
> +++ b/fs/nfs/unlink.c
> @@ -171,7 +171,7 @@ static int nfs_call_unlink(struct dentry *dentry, struct nfs_unlinkdata *data)
>  	if (parent == NULL)
>  		goto out_free;
>  	dir = parent->d_inode;
> -	if (nfs_copy_dname(dentry, data) == 0)
> +	if (nfs_copy_dname(dentry, data) != 0)
>  		goto out_dput;
>  	/* Non-exclusive lock protects against concurrent lookup() calls */
>  	spin_lock(&dir->i_lock);

With this patch, all my nfs2/3/4 tests passed just fine.

Thanks,
Erez.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
