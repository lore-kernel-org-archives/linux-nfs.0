From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs_refresh_verifier / nfs_renew_times confusion
Date: Wed, 19 Sep 2007 16:57:54 -0400
Message-ID: <1190235474.6734.79.camel@heimdal.trondhjem.org>
References: <46F184A8.9050801@oracle.com>
	<1190234217.6734.57.camel@heimdal.trondhjem.org>
	<46F18B12.4000802@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IY6cW-0005XD-V7
	for nfs@lists.sourceforge.net; Wed, 19 Sep 2007 13:58:05 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IY6cX-0006vk-ET
	for nfs@lists.sourceforge.net; Wed, 19 Sep 2007 13:58:08 -0700
In-Reply-To: <46F18B12.4000802@oracle.com>
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

On Wed, 2007-09-19 at 16:48 -0400, Chuck Lever wrote:
> Trond Myklebust wrote:
> > Time to clean all that up. The legacy nfs_renew_times() has no meaning
> > now that we use d_time to cache the verifier. Would you like to send me
> > a patch removing them?
> 
> I can -- there are some minor nits.
> 
> In nfs_dentry_iput() we have this:
> 
> static void nfs_dentry_iput(struct dentry *dentry, struct inode *inode)
> {
>          nfs_inode_return_delegation(inode);
>          if (S_ISDIR(inode->i_mode))
>                  /* drop any readdir cache as it could easily be old */
>                  NFS_I(inode)->cache_validity |= NFS_INO_INVALID_DATA;
> 
>          if (dentry->d_flags & DCACHE_NFSFS_RENAMED) {
>                  lock_kernel();
>                  drop_nlink(inode);
>                  nfs_complete_unlink(dentry, inode);
>                  unlock_kernel();
>          }
>          /* When creating a negative dentry, we want to renew d_time */
>          nfs_renew_times(dentry);
>          ^^^^^^^^^^^^^^^^^^^^^^^^
>          iput(inode);
> }
> 
> This is the only instance of nfs_renew_times() by itself.  Seems like 
> this might break the behavior of negative dentry caching.  Should this 
> be removed entirely, or replaced somehow with nfs_refresh_verifier()?

Just remove it. Unfortunately I don't think that we can avoid
revalidating the resulting negative dentry since the UNLINK call is
asynchronous, and so the new verifier on the directory will only be
known a posteriori.

> It looks like nfs_set_verifier() and nfs_refresh_verifier() reduce to 
> exactly the same logic, but we have this at the end of nfs_readdir_lookup:
> 
>          nfs_renew_times(dentry);
>          nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
>          return dentry;
> out_renew:
>          nfs_renew_times(dentry);
>          nfs_refresh_verifier(dentry, nfs_save_change_attribute(dir));
>          return dentry;
> }
> 
> Both of which are exactly equivalent now.  I can address this as well.

Thanks.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
