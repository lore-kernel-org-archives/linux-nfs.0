From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] NFS: Stop sillyname renames and unmounts from
	racing
Date: Mon, 5 Nov 2007 21:06:36 -0800
Message-ID: <20071105210636.2fc72e14.akpm@linux-foundation.org>
References: <472C56E5.1040901@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Alexander Viro <aviro@redhat.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Christoph Hellwig <hch@infradead.org>, nfs@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpGex-0001kh-JU
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 21:07:31 -0800
Received: from smtp2.linux-foundation.org ([207.189.120.14])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IpGez-0004NV-6x
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 21:07:35 -0800
In-Reply-To: <472C56E5.1040901@RedHat.com>
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

On Sat, 03 Nov 2007 07:09:25 -0400 Steve Dickson <SteveD@redhat.com> wrote:

> The following patch stops NFS sillyname renames and umounts from racing.

(appropriate cc's added)

> I have a test script does the following:
>      1) start nfs server
>       2) mount loopback
>       3) open file in background
>       4) remove file
>       5) stop nfs server
>       6) kill -9 process which has file open
>       7) restart nfs server
>       8) umount looback mount.
> 
> After umount I got the "VFS: Busy inodes after unmount" message
> because the processing of the rename has not finished.
> 
> Below is a patch that the uses the new silly_count mechanism to
> synchronize sillyname processing and umounts. The patch introduces a
> nfs_put_super() routine that waits until the nfsi->silly_count count
> is zero.
> 
> A side-effect of finding and waiting for all the inode to
> find the sillyname processing, is I need to traverse
> the sb->s_inodes list in the supper block. To do that
> safely the inode_lock spin lock has to be held. So for
> modules to be able to "see" that lock I needed to
> EXPORT_SYMBOL_GPL() it.
> 
> Any objections to exporting the inode_lock spin lock?
> If so, how should modules _safely_ access the s_inode list?
> 
> steved.
> 
> 
> Author: Steve Dickson <steved@redhat.com>
> Date:   Wed Oct 31 12:19:26 2007 -0400
> 
>      Close a unlink/sillyname rename and umount race by added a
>      nfs_put_super routine that will run through all the inode
>      currently on the super block, waiting for those that are
>      in the middle of a sillyname rename or removal.
> 
>      This patch stop the infamous "VFS: Busy inodes after unmount... "
>      warning during umounts.
> 
>      Signed-off-by: Steve Dickson <steved@redhat.com>
> 
> diff --git a/fs/inode.c b/fs/inode.c
> index ed35383..da9034a 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -81,6 +81,7 @@ static struct hlist_head *inode_hashtable __read_mostly;
>    * the i_state of an inode while it is in use..
>    */
>   DEFINE_SPINLOCK(inode_lock);
> +EXPORT_SYMBOL_GPL(inode_lock);

That's going to make hch unhappy.

Your email client is performing space-stuffing.
See http://mbligh.org/linuxdocs/Email/Clients/Thunderbird

>   static struct file_system_type nfs_fs_type = {
>   	.owner		= THIS_MODULE,
> @@ -223,6 +225,7 @@ static const struct super_operations nfs_sops = {
>   	.alloc_inode	= nfs_alloc_inode,
>   	.destroy_inode	= nfs_destroy_inode,
>   	.write_inode	= nfs_write_inode,
> +	.put_super	= nfs_put_super,
>   	.statfs		= nfs_statfs,
>   	.clear_inode	= nfs_clear_inode,
>   	.umount_begin	= nfs_umount_begin,
> @@ -1767,6 +1770,30 @@ static void nfs4_kill_super(struct super_block *sb)
>   	nfs_free_server(server);
>   }
> 
> +void nfs_put_super(struct super_block *sb)

This was (correctly) declared to be static.  We should define it that way
too (I didn't know you could do this, actually).

> +{
> +	struct inode *inode;
> +	struct nfs_inode *nfsi;
> +	/*
> +	 * Make sure there are no outstanding renames
> +	 */
> +relock:
> +	spin_lock(&inode_lock);
> +	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
> +		nfsi = NFS_I(inode);
> +		if (atomic_read(&nfsi->silly_count) > 0) {
> +			/* Keep this inode around  during the wait */
> +			atomic_inc(&inode->i_count);
> +			spin_unlock(&inode_lock);
> +			wait_event(nfsi->waitqueue,
> +				atomic_read(&nfsi->silly_count) == 1);
> +			iput(inode);
> +			goto relock;
> +		}
> +	}
> +	spin_unlock(&inode_lock);
> +}

That's an O(n^2) search.  If it is at all possible to hit a catastrophic
slowdown in here, you can bet that someone out there will indeed hit it in
real life.

I'm too lazy to look, but we might need to check things like I_FREEING
and I_CLEAR before taking a ref on this inode.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
