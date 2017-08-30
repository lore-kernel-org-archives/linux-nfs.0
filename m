Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f173.google.com ([209.85.216.173]:37546 "EHLO
        mail-qt0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750803AbdH3TvC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Aug 2017 15:51:02 -0400
Received: by mail-qt0-f173.google.com with SMTP id h15so16571877qta.4
        for <linux-nfs@vger.kernel.org>; Wed, 30 Aug 2017 12:51:02 -0700 (PDT)
Message-ID: <1504122659.2845.1.camel@redhat.com>
Subject: Re: [PATCH 1/3] fs: cleanup to hide some details of delegation logic
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>, NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Date: Wed, 30 Aug 2017 15:50:59 -0400
In-Reply-To: <20170829213731.GH8822@parsley.fieldses.org>
References: <1503697958-6122-1-git-send-email-bfields@redhat.com>
         <1503697958-6122-2-git-send-email-bfields@redhat.com>
         <87efrwibyz.fsf@notabene.neil.brown.name>
         <20170829213731.GH8822@parsley.fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2017-08-29 at 17:37 -0400, J. Bruce Fields wrote:
> On Mon, Aug 28, 2017 at 01:54:12PM +1000, NeilBrown wrote:
> > On Fri, Aug 25 2017, J. Bruce Fields wrote:
> > 
> > > From: "J. Bruce Fields" <bfields@redhat.com>
> > > 
> > > Pull the checks for delegated_inode into break_deleg_wait() to
> > > simplify
> > > the callers a little.
> > > 
> > > No change in behavior.
> > > 
> > > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > > ---
> > >  fs/namei.c         | 26 ++++++++++----------------
> > >  fs/open.c          | 16 ++++++----------
> > >  fs/utimes.c        |  8 +++-----
> > >  include/linux/fs.h | 12 +++++++-----
> > >  4 files changed, 26 insertions(+), 36 deletions(-)
> > > 
> > > diff --git a/fs/namei.c b/fs/namei.c
> > > index ddb6a7c2b3d4..5a93be7b2c9c 100644
> > > --- a/fs/namei.c
> > > +++ b/fs/namei.c
> > > @@ -4048,11 +4048,9 @@ static long do_unlinkat(int dfd, const
> > > char __user *pathname)
> > >  	if (inode)
> > >  		iput(inode);	/* truncate the inode here
> > > */
> > >  	inode = NULL;
> > > -	if (delegated_inode) {
> > > -		error = break_deleg_wait(&delegated_inode);
> > > -		if (!error)
> > > -			goto retry_deleg;
> > > -	}
> > > +	error = break_deleg_wait(&delegated_inode, error);
> > > +	if (error == DELEG_RETRY)
> > > +		goto retry_deleg;
> > 
> > <mode=bikeshed>
> > 
> > I don't like the "DELEG_RETRY".  You are comparing it against an
> > 'error', but it doesn't start with '-E', so I get confused (happens
> > often).
> > 
> > If this read:
> > 
> >      if (error > 0)
> >           goto retry_deleg;
> > 
> > it would be must more obvious to me what was happening.  Clearly
> > the
> > return value isn't an error, and it isn't "success" either.  This
> > is a
> > pattern I've seen elsewhere.
> > 
> > Alternately you could use "-EAGAIN", but I suspect there is a risk
> > of
> > unwanted side-effects if you re-use and existing code.
> 
> Yes.  OK, I think I like your suggestion.  The change would look like
> the following (untested).
> 
> --b.
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index 5a93be7b2c9c..e8688498aff7 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -4049,7 +4049,7 @@ static long do_unlinkat(int dfd, const char
> __user *pathname)
>  		iput(inode);	/* truncate the inode here */
>  	inode = NULL;
>  	error = break_deleg_wait(&delegated_inode, error);
> -	if (error == DELEG_RETRY)
> +	if (error > 0)
>  		goto retry_deleg;
>  	mnt_drop_write(path.mnt);
>  exit1:
> @@ -4282,7 +4282,7 @@ SYSCALL_DEFINE5(linkat, int, olddfd, const char
> __user *, oldname,
>  out_dput:
>  	done_path_create(&new_path, new_dentry);
>  	error = break_deleg_wait(&delegated_inode, error);
> -	if (error == DELEG_RETRY) {
> +	if (error > 0) {
>  		path_put(&old_path);
>  		goto retry;
>  	}
> @@ -4598,7 +4598,7 @@ SYSCALL_DEFINE5(renameat2, int, olddfd, const
> char __user *, oldname,
>  exit3:
>  	unlock_rename(new_path.dentry, old_path.dentry);
>  	error = break_deleg_wait(&delegated_inode, error);
> -	if (error == DELEG_RETRY)
> +	if (error > 0)
>  		goto retry_deleg;
>  	mnt_drop_write(old_path.mnt);
>  exit2:
> diff --git a/fs/open.c b/fs/open.c
> index d49e9385e45d..80975c4dd146 100644
> --- a/fs/open.c
> +++ b/fs/open.c
> @@ -533,7 +533,7 @@ static int chmod_common(const struct path *path,
> umode_t mode)
>  out_unlock:
>  	inode_unlock(inode);
>  	error = break_deleg_wait(&delegated_inode, error);
> -	if (error == DELEG_RETRY)
> +	if (error > 0)
>  		goto retry_deleg;
>  	mnt_drop_write(path->mnt);
>  	return error;
> @@ -610,7 +610,7 @@ static int chown_common(const struct path *path,
> uid_t user, gid_t group)
>  		error = notify_change(path->dentry, &newattrs,
> &delegated_inode);
>  	inode_unlock(inode);
>  	error = break_deleg_wait(&delegated_inode, error);
> -	if (error == DELEG_RETRY)
> +	if (error > 0)
>  		goto retry_deleg;
>  	return error;
>  }
> diff --git a/fs/utimes.c b/fs/utimes.c
> index 75467b7ebfce..4dc6717638e6 100644
> --- a/fs/utimes.c
> +++ b/fs/utimes.c
> @@ -90,7 +90,7 @@ static int utimes_common(const struct path *path,
> struct timespec *times)
>  	error = notify_change(path->dentry, &newattrs,
> &delegated_inode);
>  	inode_unlock(inode);
>  	error = break_deleg_wait(&delegated_inode, error);
> -	if (error == DELEG_RETRY)
> +	if (error > 0)
>  		goto retry_deleg;
>  
>  	mnt_drop_write(path->mnt);
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 1d0d2fde1766..1c7f7be3f26d 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2288,8 +2288,6 @@ static inline int try_break_deleg(struct inode
> *inode, struct inode **delegated_
>  	return ret;
>  }
>  
> -#define DELEG_RETRY 1
> -
>  static inline int break_deleg_wait(struct inode **delegated_inode,
> int error)
>  {
>  	if (!*delegated_inode)
> @@ -2297,7 +2295,13 @@ static inline int break_deleg_wait(struct
> inode **delegated_inode, int error)
>  	error = break_deleg(*delegated_inode, O_WRONLY);
>  	iput(*delegated_inode);
>  	*delegated_inode = NULL;
> -	return error ? error : DELEG_RETRY;
> +	if (error)
> +		return error;
> +	/*
> +	 * Signal to the caller that it can retry the original
> operation
> +	 * now that the delegation is broken:
> +	 */
> +	return 1;
>  }
>  
>  static inline int break_layout(struct inode *inode, bool wait)

ACK, I like that better too. I think a kerneldoc header is probably
warranted here too, since this is a bit of an odd return situation.
-- 
Jeff Layton <jlayton@redhat.com>
