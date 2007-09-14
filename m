From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATH 04/19] ext2: new export ops
Date: Sat, 15 Sep 2007 00:58:03 +1000
Message-ID: <20070914145803.GH21965@sgi.com>
References: <20070830131609.GE6834@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
To: Christoph Hellwig <hch@lst.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IWCcD-0002CI-3c
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 07:57:53 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1IWCcG-0001hc-OJ
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 07:57:58 -0700
In-Reply-To: <20070830131609.GE6834@lst.de>
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

On Thu, Aug 30, 2007 at 03:16:09PM +0200, Christoph Hellwig wrote:
> +
> +static struct dentry *ext2_fh_to_dentry(struct super_block *sb, struct fid *fid,
> +		int fh_len, int fh_type)
> +{
> +	return generic_fh_to_dentry(sb, fid, fh_len, fh_type, ext2_nfs_get_inode);
> +}
> +
> +static struct dentry *ext2_fh_to_parent(struct super_block *sb, struct fid *fid,
> +		int fh_len, int fh_type)
> +{
> +	return generic_fh_to_parent(sb, fid, fh_len, fh_type, ext2_nfs_get_inode);
>  }
>  

These patches look good, and cleanup in this area is certainly a
good thing.  One small comment: the easy filesystems (ext[234], efs,
ntfs) might be cleaner if the per-fs get_inode function were a member
of export_ops instead of an extra argument to generic_fh_to_dentry().
That way you wouldn't need these two little helper functions in each
filesystem, because you could point export_ops.fh_to_dentry directly
at generic_fh_to_dentry.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
