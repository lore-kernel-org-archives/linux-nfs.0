Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:36181 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752816AbdESN23 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 May 2017 09:28:29 -0400
Received: by mail-qk0-f195.google.com with SMTP id y128so10135245qka.3
        for <linux-nfs@vger.kernel.org>; Fri, 19 May 2017 06:28:28 -0700 (PDT)
Message-ID: <1495200505.2889.5.camel@poochiereds.net>
Subject: Re: [PATCH] locks: Set fl_nspid at file_lock allocation
From: Jeff Layton <jlayton@poochiereds.net>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, bfields@fieldses.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 19 May 2017 09:28:25 -0400
In-Reply-To: <6ED42F9C-F290-451C-89A9-4A7C3FFDEFA6@redhat.com>
References: <896e8ca302614f71f3030015ebf3befe2b40d3c4.1495122972.git.bcodding@redhat.com>
         <1495126525.3956.10.camel@poochiereds.net>
         <1069ECDA-D96D-495E-BB7B-128A926AD3DF@redhat.com>
         <1495140075.3956.13.camel@poochiereds.net>
         <6ED42F9C-F290-451C-89A9-4A7C3FFDEFA6@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-05-19 at 08:35 -0400, Benjamin Coddington wrote:
> On 18 May 2017, at 16:41, Jeff Layton wrote:
> 
> > On Thu, 2017-05-18 at 13:36 -0400, Benjamin Coddington wrote:
> > > > On Thu, 2017-05-18 at 12:02 -0400, Benjamin Coddington wrote:
> > > > > diff --git a/fs/locks.c b/fs/locks.c
> > > > > index af2031a1fcff..959b3f93f4bd 100644
> > > > > --- a/fs/locks.c
> > > > > +++ b/fs/locks.c
> > > > > @@ -249,7 +249,7 @@ locks_dump_ctx_list(struct list_head *list, char
> > > > > *list_type)
> > > > >  	struct file_lock *fl;
> > > > > 
> > > > >  	list_for_each_entry(fl, list, fl_list) {
> > > > > -		pr_warn("%s: fl_owner=%p fl_flags=0x%x fl_type=0x%x fl_pid=%u\n",
> > > > > list_type, fl->fl_owner, fl->fl_flags, fl->fl_type, fl->fl_pid);
> > > > > +		pr_warn("%s: fl_owner=%p fl_flags=0x%x fl_type=0x%x fl_pid=%u\n",
> > > > > list_type, fl->fl_owner, fl->fl_flags, fl->fl_type,
> > > > > pid_vnr(fl->fl_nspid));
> > > > >  	}
> > > > >  }
> > > > > 
> > > > 
> > > > Probably should change the format to say fl_nspid=%u here, just to be
> > > > clear. Might also want to keep fl_pid in there since the lock manager
> > > > could set it.
> > > 
> > > Yes, I thought about just spitting out both.  Let's do that.
> > > 
> > > > > @@ -2074,7 +2075,7 @@ static int posix_lock_to_flock(struct flock
> > > > > *flock, struct file_lock *fl)
> > > > >  #if BITS_PER_LONG == 32
> > > > >  static void posix_lock_to_flock64(struct flock64 *flock, struct
> > > > > file_lock *fl)
> > > > >  {
> > > > > -	flock->l_pid = IS_OFDLCK(fl) ? -1 : fl->fl_pid;
> > > > > +	flock->l_pid = IS_OFDLCK(fl) ? -1 : pid_vnr(fl->fl_nspid);
> > > > 
> > > > What about the lock managers that _do_ set fl->fl_pid. With nfsv2/3,
> > > > this is always going to give you back the pid of lockd, AFAICT.
> > > 
> > > But isn't this really what you want?  If a local process wants to know
> > > who
> > > holds a conflicting lock, the fl_pid of a remote system is really pretty
> > > useless.  Not only that, but there's no way for the local process to
> > > know
> > > when the pid is local or remote.  Better to be consistent and always
> > > return
> > > something that's useful.
> > > 
> > 
> > The l_pid field in struct flock (and by extension fl_pid) is pretty
> > poorly defined in the spec(s), especially when there is a remote host
> > involved. Programs that rely on it are insane, of course...but Linux has
> > always behaved this way.
> 
> But if it is completely useless today, then we can change it without
> worrying about breaking it because it is already broken.  There's no
> documentation anywhere that informs users of F_GETLK or /proc/locks that
> l_pid is completely unreliable.
> 

True...but again, that's how it currently works today and I haven't yet
heard a good reason for changing it. The argument so far is "because we
can and no one should care", but I don't think that's enough. AFAICT,
the current behavior is not really causing any problems, per-se.

If we want to change it, we need to have an explanation for the poor sap
who chimes in in two years that his application subtly stopped working
the same way when his kernel was upgraded. If we can say we did it to
solve a specific problem, then I'd be more inclined to change it.

> Do you know why linux hasn't picked up l_sysid?  I can't seem to find any
> previous discussion about it.
> 

Because it's not part of POSIX? The fcntl spec page says:

"The identification of a machine in a network environment is outside the
scope of this volume of POSIX.1-2008. Thus, an l_sysid member, such as
found in System V, is not included in the locking structure."

We could change that, but it's a userland ABI change and you'd need new
F_* command constants (at the very least)...and if we're going to go
there then I'd want to start thinking about an async locking API.

(cue the snowball effect)

> > In the absence of a compelling reason to change it, I think we should
> > keep the behavior in this respect as close as possible to what we have
> > now.
> 
> I think the reason would be l_pid should at least have some consistent
> meaning.  I think now that this patch probably shouldn't change it, but it
> should be changed.
> 
> > > > Do we want to present the pid value that the client sent here instead
> > > > in
> > > > that case? Maybe the lm could set a fl_flag to indicate that the pid
> > > > should be taken directly from fl_pid here? Then you could move the
> > > > above
> > > > logic to a static inline or something.
> > > > 
> > > > Alternately, you could add a new lm_present_pid operation to lock
> > > > managers to format the pid as they see fit.
> > > 
> > > Either works to solve the problem, but I still think that F_GETLK and
> > > /proc/locks should only return local pids.
> > > 
> > > > > @@ -2322,6 +2325,7 @@ int fcntl_getlk64(struct file *filp, unsigned
> > > > > int cmd, struct flock64 __user *l)
> > > > >  	int error;
> > > > > 
> > > > >  	error = -EFAULT;
> > > > > +	file_lock.fl_nspid = get_pid(task_tgid(current));
> > > > 
> > > > Might it be cleaner to create a FILE_LOCK(name) macro that does this
> > > > on
> > > > the stack (like LIST_HEAD()) ?
> > > 
> > > Yes, it would.  I'll do it.
> > > 
> > 
> > In some of those places it might not hurt to consider allocating and
> > freeing a file_lock instead. file_lock is not exactly small (208 bytes
> > on my latest build)...
> 
> Do you want that wrapped up with this patch?
> 
> Ben

-- 
Jeff Layton <jlayton@poochiereds.net>
