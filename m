Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:37239 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752192AbZBTSYA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Feb 2009 13:24:00 -0500
Date: Fri, 20 Feb 2009 13:23:50 -0500
To: Neil Brown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, linux-nfs@vger.kernel.org
Subject: Re: Thoughts about cache consistency and directories in particular.
Message-ID: <20090220182350.GB1104@fieldses.org>
References: <18846.4842.625445.980681@notabene.brown>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <18846.4842.625445.980681@notabene.brown>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Feb 20, 2009 at 01:18:18PM +1100, Neil Brown wrote:
> 
> Hi,
>  I've been thinking about cache consistency, particularly of
>  directories, in response to a customer who's NFS was getting confused
>  by their usage of "rsync -a" without the "--omit-dir-times" flag:
>  A client would see an old copy of a directory and never get a more
>  up-to-date copy because the mtime appeared not to change.
> 
>  This results in a situation where a directory has wrong data cache
>  and there is no way to force that cache to be flushed.
> 
>  This contrasts with files where you can always flush the file
>  contents by taking a read lock on the file.
> 
>  I also came up with a simple way to demonstrate a related caching
>  anomaly:
> 
>   - Create a localhost mount
>   - create a directory
>   - "ls -l" the directory via NFS
>   - create a file directly

(And do this within a second (or a jiffy, depending on filesystem) of
the directory creation?)

>   - look again via NFS.

> 
>   The directory will appear empty via NFS but it is not.  And this
>   cache anomily does not time out (though memory pressure could
>   eventually remove it).
> 
>   There is a script below which reproduces both anomalies (providing
>   /export is exported and /mnt is available).
>  
> 
>  Can anything be done about this?
> 
> 
>  1/ The client could flush the cache for a directory when ctime
>     changes as well as when mtime or size change.
>     This would help solve the "rsync -a without --omit-dir-times"
>     problem (and also another weird problem I had reported that
>     involved strange behaviour from an NetApp filer).
>     It might increase the number of READDIR requests in some cases.
>     Would that be enough of an increase to be a real problem?
>     It would be no worse than NFSv4 which - as the Linux NFS server
>     uses ctime to produce the changeattr - refreshes both directories
>     and files when the ctime changes.

This has come up before, but I can't remember what the argument was
against it....

>  2/ The server could lie about the mtime.
>     In particular, if the mtime for a file was the same as the current
>     time - to the granularity of the filesystem storing the file -
>     then reduce the mtime that is reported by the smallest difference that
>     can be reported by the protocol.
>     That would be one microsecond for v2, and one nanosecond for v3
>     and v4.

Assume for simplicity's sake the time granularity is a second, and
measure time in seconds in the following examples:

Your proposal offers an improvement in this example (currently,
subsequent getattrs will not reflect the final modification):

	t=0.1 modify
	t=0.2 getattr
	t=0.3 modify

Your proposal causes a regression in the following example:

	t=0.1 modify
	t=0.2 getattr
	t=1.1 modify 
	t=1.2 modify

I think the argument you'd like to make is that the regressions are
rarer than the improvements.  One way to make that argument would be to
completely characterize the two sets of cases (cases where you get an
improvement, and cases where you get a regression), and then somehow
convince us of their relative probabilities.  I think that will be
difficult, and the result may not be what you expect.

Also, the proposed behavior is more complicated (hence harder to
explain to users seeing the bug, and perhaps harder to work around?), so
the bar for the improvement should be set pretty high....

By the way, I have one sadly neglected todo here: ext4 has a real nfsv4
changeattribute, which needs to be hooked up to the nfsd code.

--b.

>     This is something I've thought about (and probably muttered about)
>     in various forms at various times over the years, but this time I
>     think I am actually happy with the formulation of the solution and
>     want to push forward with it.
> 
> 
> 
>  Option 1, by itself, would mostly resolve the rsync issue and have
>  no effect on my little test case.
>  Option 2 by itself would have no effect on the rsync issue but would
>  nicely resolve my little test cache.
>  Together they should significantly reduce the number of caching
>  anomalies.
> 
>  Below is the test script, then two patches, one for NFS and one for
>  NFSD.  These can also be pulled from 
>      git://neil.brown.name/linux-2.6 nfs-devel
> 
> 
>  Thoughts?
> 
> 
> Thanks,
> NeilBrown
> 
> 
> ------------------------------------------------
> mount localhost:/export /mnt
> rm -rf /export/adir
> mkdir /export/adir
> 
> for i in `seq 1 100`
> do mkdir /export/adir/$i 
>      ls -l /mnt/adir/$i  > /dev/null 2>&1
>      echo hello > /export/adir/$i/afile ;
> done
> echo -n "Files in directory: "
> find /export/adir | wc -l
> echo -n "Files visible to NFS: "
> find /mnt/adir | wc -l
> 
> echo ; echo 
> rm -rf /export/bdir
> mkdir /export/bdir
> > /export/bfile
> touch -r /export/bfile /export/bdir
> sleep 2
> ls -l /mnt/bdir > /dev/null
> sleep 2
> > /export/bdir/bfile
> touch -r /export/bfile /export/bdir
> echo "Files in directory:"
> ls -l /export/bdir
> echo "Files visible to NFS:"
> ls -l /mnt/bdir
> umount /mnt
> ------------------------------------------------
> 
> 
> From: NeilBrown <neilb@suse.de>
> Subject: [PATCH 1/2] nfs: flush cached directory information slightly more
> 	readily.
> Date: Fri, 20 Feb 2009 12:57:07 +1100
> Message-ID: <20090220015706.12400.98909.stgit@notabene.brown>
> User-Agent: StGIT/0.14.2
> MIME-Version: 1.0
> Content-Type: text/plain; charset="utf-8"
> Content-Transfer-Encoding: 7bit
> 
> If cached directory contents becomes incorrect, there is no way to
> flush the contents.  This contrasts with files where file locking is
> the recommended way to ensure cache consistency between multiple
> applications (a read-lock always flushes the cache).
> 
> Also while changes to files often change the size of the file (thus
> triggering a cache flush), changes to directories often do not change
> the apparent size (as the size is often rounded to a block size).
> 
> So it is particularly important with directories to avoid the
> possibility of an incorrect cache wherever possible.
> 
> When the link count on a directory changes it implies (or should
> imply) a change in the number of child directories, and so a change
> the contents of this directory.  So use that as a trigger to flush
> cached contents.
> 
> When the ctime changes but the mtime does not, there are two possible
> reasons.
>  1/ The owner/mode information has been changed.
>  2/ utimes has been used to set the mtime backwards.
> 
> In the first case, a data-cache flush is not required.
> In the second case it is.
> 
> So on th basis that correctness trumps performance, flush the
> directory contents cache in this case also.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
> 
>  fs/nfs/inode.c |   13 +++++++++++--
>  1 files changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 0c38168..09c1300 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1116,8 +1116,14 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
>  				nfs_force_lookup_revalidate(inode);
>  		}
>  		/* If ctime has changed we should definitely clear access+acl caches */
> -		if (!timespec_equal(&inode->i_ctime, &fattr->ctime))
> +		if (!timespec_equal(&inode->i_ctime, &fattr->ctime)) {
>  			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
> +			/* and probably clear data for a directory too as utimes can cause
> +			 * havoc with our cache.
> +			 */
> +			if (S_ISDIR(inode->i_mode))
> +				invalid |= NFS_INO_INVALID_DATA;
> +		}
>  	} else if (nfsi->change_attr != fattr->change_attr) {
>  		dprintk("NFS: change_attr change on server for file %s/%ld\n",
>  				inode->i_sb->s_id, inode->i_ino);
> @@ -1151,8 +1157,11 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
>  	    inode->i_gid != fattr->gid)
>  		invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
>  
> -	if (inode->i_nlink != fattr->nlink)
> +	if (inode->i_nlink != fattr->nlink) {
>  		invalid |= NFS_INO_INVALID_ATTR;
> +		if (S_ISDIR(inode->i_mode))
> +			invalid |= NFS_INO_INVALID_DATA;
> +	}
>  
>  	inode->i_mode = fattr->mode;
>  	inode->i_nlink = fattr->nlink;
> 
> 
> From: NeilBrown <neilb@suse.de>
> Subject: [PATCH 2/2] nfsd: be creative with 'mtime' so that NFS client can
> 	reliably discover changes
> Date: Fri, 20 Feb 2009 12:57:07 +1100
> Message-ID: <20090220015707.12400.80500.stgit@notabene.brown>
> In-Reply-To: <20090220015706.12400.98909.stgit@notabene.brown>
> References: <20090220015706.12400.98909.stgit@notabene.brown>
> User-Agent: StGIT/0.14.2
> MIME-Version: 1.0
> Content-Type: text/plain; charset="utf-8"
> Content-Transfer-Encoding: 7bit
> 
> For NFSv2 and v3, mtime is used as the main mechanism for cache
> flushing - when mtime changes, we flush the cache.
> 
> However with many filesystems the granularity of mtime is one second,
> and multiple changes can occur in one second.
> 
> This make it unwise to ever return "now" for the mtime of a file, as
> quite some time later there may have been a change since that mtime
> was returned, but the mtime will still be the same.
> 
> So if the mtime is "now" - to the granularity of the filesystem,
> adjust it backwards the smallest possible amount.   This when a
> subsequent GETATTR checks the mtime, it will no longer be 'now', so
> the correct mtime will be returned, and the client will notice that
> the file could have changed.
> 
> For NFSv4 we do a similar thing, but rather change the 'changeid'
> attribute which is based on 'ctime'.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
> 
>  fs/nfsd/nfs3xdr.c         |    2 +-
>  fs/nfsd/nfs4xdr.c         |    1 +
>  fs/nfsd/nfsxdr.c          |    2 +-
>  include/linux/nfsd/xdr.h  |   25 +++++++++++++++++++++++++
>  include/linux/nfsd/xdr4.h |   26 ++++++++++++++++++++++++++
>  5 files changed, 54 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
> index 17d0dd9..139500b 100644
> --- a/fs/nfsd/nfs3xdr.c
> +++ b/fs/nfsd/nfs3xdr.c
> @@ -221,7 +221,7 @@ encode_post_op_attr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp)
>  		err = vfs_getattr(fhp->fh_export->ex_path.mnt, dentry, &stat);
>  		if (!err) {
>  			*p++ = xdr_one;		/* attributes follow */
> -			lease_get_mtime(dentry->d_inode, &stat.mtime);
> +			nfsd_get_mtime(dentry->d_inode, &stat.mtime, 1);
>  			return encode_fattr3(rqstp, p, fhp, &stat);
>  		}
>  	}
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index f65953b..6bd7339 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1518,6 +1518,7 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
>  		 */
>  		if ((buflen -= 8) < 0)
>  			goto out_resource;
> +		nfs4svc_adjust_mtime(fhp, &stat.ctime);
>  		WRITE32(stat.ctime.tv_sec);
>  		WRITE32(stat.ctime.tv_nsec);
>  	}
> diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
> index afd08e2..e266d42 100644
> --- a/fs/nfsd/nfsxdr.c
> +++ b/fs/nfsd/nfsxdr.c
> @@ -194,7 +194,7 @@ encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp,
>  	*p++ = htonl((u32) stat->ino);
>  	*p++ = htonl((u32) stat->atime.tv_sec);
>  	*p++ = htonl(stat->atime.tv_nsec ? stat->atime.tv_nsec / 1000 : 0);
> -	lease_get_mtime(dentry->d_inode, &time); 
> +	nfsd_get_mtime(dentry->d_inode, &time, 1000); 
>  	*p++ = htonl((u32) time.tv_sec);
>  	*p++ = htonl(time.tv_nsec ? time.tv_nsec / 1000 : 0); 
>  	*p++ = htonl((u32) stat->ctime.tv_sec);
> diff --git a/include/linux/nfsd/xdr.h b/include/linux/nfsd/xdr.h
> index a0132ef..b1a0f5d 100644
> --- a/include/linux/nfsd/xdr.h
> +++ b/include/linux/nfsd/xdr.h
> @@ -174,4 +174,29 @@ int nfssvc_release_fhandle(struct svc_rqst *, __be32 *, struct nfsd_fhandle *);
>  __be32 *nfs2svc_encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp);
>  __be32 *nfs2svc_decode_fh(__be32 *p, struct svc_fh *fhp);
>  
> +/* NFSv3 and v2 use mtime to guide caching of file/directory contents.
> + * If a client asks for the mtime of a file and the answer is "now",
> + * then subsequent changes to the file could happen but never be reflected
> + * in a changed mtime.
> + * So in that case, reduce mtime by the smallest value representable in
> + * the protocol.  A subsequent GETATTR will show the mtime having changed
> + * slightly so the client will refresh its cache and be sure to get any
> + * changes.
> + */
> +static inline void nfsd_get_mtime(struct inode *inode, struct timespec *time, int nanoseconds)
> +{
> +	struct timespec now;
> +	lease_get_mtime(inode, time);
> +	now = current_fs_time(inode->i_sb);
> +	if (time->tv_sec == now.tv_sec &&
> +	    time->tv_nsec == now.tv_nsec) {
> +		if (time->tv_nsec >= nanoseconds)
> +			time->tv_nsec -= nanoseconds;
> +		else {
> +			time->tv_nsec += 1000000000 - nanoseconds;
> +			time->tv_sec -= 1;
> +		}
> +	}
> +}
> +	
>  #endif /* LINUX_NFSD_H */
> diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
> index 27bd3e3..7d2be49 100644
> --- a/include/linux/nfsd/xdr4.h
> +++ b/include/linux/nfsd/xdr4.h
> @@ -422,10 +422,36 @@ struct nfsd4_compoundres {
>  #define NFS4_SVC_XDRSIZE		sizeof(struct nfsd4_compoundargs)
>  
>  static inline void
> +nfs4svc_adjust_mtime(struct svc_fh *fhp, struct timespec *time)
> +{
> +	/* because we use ctime for caching, and because the granularity
> +	 * of ctime might be fairly large (e.g. 1 second) it is unsafe
> +	 * to ever report 'now' as the changeid - as then we might report
> +	 * two change ids that are the same despite there being a change
> +	 * to the file between them, and then continue to report that
> +	 * same change-id for a long time.
> +	 * So if the changeid would correspond to 'now', change it to
> +	 * one nanosecond ago so that after 'now' as moved on, the client
> +	 * will be able to see a new changeid and will update its cache.
> +	 */
> +	struct timespec now;
> +	now = current_fs_time(fhp->fh_dentry->d_inode->i_sb);
> +	if (time->tv_sec == now.tv_sec &&
> +	    time->tv_nsec == now.tv_nsec) {
> +		if (time->tv_nsec)
> +			time->tv_nsec--;
> +		else {
> +			time->tv_nsec = 999999999;
> +			time->tv_sec --;
> +		}
> +	}
> +}
> +static inline void
>  set_change_info(struct nfsd4_change_info *cinfo, struct svc_fh *fhp)
>  {
>  	BUG_ON(!fhp->fh_pre_saved || !fhp->fh_post_saved);
>  	cinfo->atomic = 1;
> +	nfs4svc_adjust_mtime(fhp, &fhp->fh_pre_ctime);
>  	cinfo->before_ctime_sec = fhp->fh_pre_ctime.tv_sec;
>  	cinfo->before_ctime_nsec = fhp->fh_pre_ctime.tv_nsec;
>  	cinfo->after_ctime_sec = fhp->fh_post_attr.ctime.tv_sec;
> 
> 
