Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39504 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752629Ab0IHQ5i convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Sep 2010 12:57:38 -0400
Subject: Re: [RFC][PATCH] nfs: support legacy NFS flock behavior via mount
 option
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Suresh Jayaraman <sjayaraman@suse.de>
Cc: Neil Brown <neilb@suse.de>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>
In-Reply-To: <4C879F81.6000500@suse.de>
References: <4C84DFA7.7050507@suse.de>
	 <1283869039.4291.16.camel@heimdal.trondhjem.org> <4C869D00.8030604@suse.de>
	 <1283892577.2788.104.camel@heimdal.trondhjem.org>
	 <4C879F81.6000500@suse.de>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 08 Sep 2010 12:50:00 -0400
Message-ID: <1283964600.2910.10.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-09-08 at 20:06 +0530, Suresh Jayaraman wrote:
> On 09/08/2010 02:19 AM, Trond Myklebust wrote:
> > On Wed, 2010-09-08 at 01:43 +0530, Suresh Jayaraman wrote:
> 
> >> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> >> index eb51bd6..a13a83e 100644
> >> --- a/fs/nfs/file.c
> >> +++ b/fs/nfs/file.c
> >> @@ -800,8 +800,13 @@ static int nfs_lock(struct file *filp, int cmd, struct file_lock *fl)
> >>  
> >>  	nfs_inc_stats(inode, NFSIOS_VFSLOCK);
> >>  
> >> -	/* No mandatory locks over NFS */
> >> -	if (__mandatory_lock(inode) && fl->fl_type != F_UNLCK)
> >> +	/*
> >> +	 * No mandatory locks over NFS.
> >> +	 * fcntl lock is local if mounted with "-o llock=fcntl" or
> >> +	 * "-o llock=posix"
> >> +	 */
> >> +	if ((__mandatory_lock(inode) && fl->fl_type != F_UNLCK) ||
> >> +			(NFS_SERVER(inode)->flags & NFS_MOUNT_LOCAL_FCNTL))
> >>  		goto out_err;
> >>  
> >>  	if (NFS_PROTO(inode)->lock_check_bounds != NULL) {
> >> @@ -825,12 +830,16 @@ out_err:
> >>   */
> >>  static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
> >>  {
> >> +	struct inode *inode = filp->f_mapping->host;
> >> +
> >>  	dprintk("NFS: flock(%s/%s, t=%x, fl=%x)\n",
> >>  			filp->f_path.dentry->d_parent->d_name.name,
> >>  			filp->f_path.dentry->d_name.name,
> >>  			fl->fl_type, fl->fl_flags);
> >>  
> >> -	if (!(fl->fl_flags & FL_FLOCK))
> >> +	/* flock is local if mounted with "-o llock=flock" */
> >> +	if ((NFS_SERVER(inode)->flags & NFS_MOUNT_LOCAL_FLOCK) ||
> >> +			(!(fl->fl_flags & FL_FLOCK)))
> >>  		return -ENOLCK;
> > 
> > Is this really what we want to do? Shouldn't we rather default to
> > treating this as if NFS_MOUNT_NONLM were set?
> > 
> 
> ah, yes, you're right.
> 
> >>  
> >>  static void nfs_umount_begin(struct super_block *);
> >>  static int  nfs_statfs(struct dentry *, struct kstatfs *);
> >> @@ -1412,6 +1429,33 @@ static int nfs_parse_mount_options(char *raw,
> >>  			mnt->fscache_uniq = string;
> >>  			mnt->options |= NFS_OPTION_FSCACHE;
> >>  			break;
> >> +		case Opt_llock:
> >> +			string = match_strdup(args);
> >> +			if (string == NULL)
> >> +				goto out_nomem;
> >> +			token = match_token(string, nfs_llock_tokens, args);
> >> +			kfree(string);
> >> +			switch (token) {
> >> +			case Opt_llock_all:
> >> +				mnt->flags |= (NFS_MOUNT_LOCAL_FLOCK |
> >> +					       NFS_MOUNT_LOCAL_FCNTL);
> >> +				break;
> >> +			case Opt_llock_flock:
> >> +				mnt->flags |= NFS_MOUNT_LOCAL_FLOCK;
> >> +				break;
> >> +			case Opt_llock_fcntl:
> >> +				mnt->flags |= NFS_MOUNT_LOCAL_FCNTL;
> >> +				break;
> >> +			case Opt_llock_none:
> >> +				mnt->flags &= ~(NFS_MOUNT_LOCAL_FLOCK |
> >> +						NFS_MOUNT_LOCAL_FCNTL);
> >> +				break;
> >> +			default:
> >> +				dfprintk(MOUNT, "NFS:	invalid	"
> >> +						"llock argument\n");
> >> +				return 0;
> >> +			};
> >> +			break;
> > 
> > Could we perhaps also convert Opt_nolock so that it just sets
> > NFS_MOUNT_LOCAL_FLOCK|NFS_MOUNT_LOCAL_FCNTL (and ditto for the legacy
> > NFS_MOUNT_NONLM).
> > 
> 
> Did you mean defining NFS_MOUNT_NONLM as
> 
> #define NFS_MOUNT_NONLM         (NFS_MOUNT_LOCAL_FLOCK|NFS_MOUNT_LOCAL_FCNTL) ?
> 
> This would be problematic when we want to say make flock local but
> fcntl NLM lock.. or make fcntl local but flock NLM lock.. i.e
> when we setup lockd, we check
> 
>  if (server->flags & NFS_MOUNT_NONLM)
> 
> which will succeed and nlmclnt would remain uninitialized..

Agreed, you do need to replace NFS_MOUNT_NONLM in comparisons like the
above, but it seems to me that we need to do that anyway.

I think the easiest is to add a parameter to
do_setlk()/do_getlk()/do_unlck() to indicate whether or not this should
be treated as a local lock, and then set that parameter accordingly in
the calls from nfs_flock() (if NFS_MOUNT_LOCAL_FLOCK) and
nfs_file_lock() (if NFS_MOUNT_LOCAL_FCNTL).

Note also that there might be issues with NFSv4 and lock recovery (this
was IIRC why we disallow -onolock with NFSv4). IIRC, we were getting
Oopses because the struct file_lock wasn't initialised as expected by
the recovery routines.

Cheers
  Trond
