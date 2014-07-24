Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:57124 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759037AbaGXQYu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Jul 2014 12:24:50 -0400
Received: by mail-qg0-f53.google.com with SMTP id q107so3447845qgd.26
        for <linux-nfs@vger.kernel.org>; Thu, 24 Jul 2014 09:24:50 -0700 (PDT)
Date: Thu, 24 Jul 2014 12:24:45 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Al Viro <viro@ZenIV.linux.org.uk>,
        David Teigland <teigland@redhat.com>,
        Christine Caulfield <ccaulfie@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        cluster-devel@redhat.com, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 9/9] fs: dlm: lockd: Convert int result to unsigned char
 type
Message-ID: <20140724122445.2ebd1b23@tlielax.poochiereds.net>
In-Reply-To: <1406174039.2755.71.camel@joe-AO725>
References: <cover.1405879494.git.joe@perches.com>
	<65b9ba0dba9c79a938267d5bed7ed0a8211e89ed.1405879494.git.joe@perches.com>
	<20140723141139.2cf90cb0@tlielax.poochiereds.net>
	<1406174039.2755.71.camel@joe-AO725>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 23 Jul 2014 20:53:59 -0700
Joe Perches <joe@perches.com> wrote:

> On Wed, 2014-07-23 at 14:11 -0400, Jeff Layton wrote:
> > On Sun, 20 Jul 2014 11:23:43 -0700 Joe Perches <joe@perches.com> wrote:
> > > op->info.rv is an s32, but it's only used as a u8.
> > I don't understand this patch. info.rv is s32 (and I assume that "rv"
> > stands for "return value").
> 
> In this case it's not a return value but an input.
> 

Well, it's an input into the lm_grant callback, but it originally comes
in the downcall from userland (AFAICT). In this case, I'm referring to
the field in the downcall.

> > What I don't get is why you think it's just
> > used as a u8.
> 
> Because it's tested only in nlmsvc_grant_deferred
> and nlmsvc_update_deferred_block against 0.
> 
> As far as I can tell, it's not possible to set it
> to a negative value.
> 

It's been a while since I've looked over the lockd code, but I believe
it's just a flag that indicates whether there is still a conflict
between the block and the lock on the file.

> > It seems to be used more like a bool than anything else,
> > and I'm not sure that "type" is really a good description for it. Maybe
> > it should be a "bool" and named "conflict",
> 
> Maybe.  But it seemed likely and possible to expand
> it from a single bool to a value.
> 
> > given the comments in dlm_posix_get ?
> 
> Maybe, though I don't see how the comments relate to
> this change.  The rv value returned from that call
> is either -ENOMEM or 0 and is unchanged by this patch.
> 

I don't think that patch will break anything. I just don't see it as an
improvement on what's already there.

The rationale for this is lost in antiquity, but I think the basic idea
was that you're either granting or updating the block based on the
_result_ from some check for a lock conflict. While "result" as a name
is a little confusing, "type" is even more so, IMO.

If you're hell-bent on changing this, then my suggestion would be
to turn it into a bool and call it "conflict" or something similar. If
you do decide to do that, adding some helpful kerneldoc comments would
be a nice improvement too.

> > > diff --git a/include/linux/fs.h b/include/linux/fs.h
> []
> > > @@ -842,7 +842,7 @@ struct lock_manager_operations {
> > >  	int (*lm_compare_owner)(struct file_lock *fl1, struct file_lock *fl2);
> > >  	unsigned long (*lm_owner_key)(struct file_lock *fl);
> > >  	void (*lm_notify)(struct file_lock *fl);	/* unblock callback */
> > > -	int (*lm_grant)(struct file_lock *fl, int result);
> > > +	int (*lm_grant)(struct file_lock *fl, unsigned char type);
> > >  	void (*lm_break)(struct file_lock *fl);
> > >  	int (*lm_change)(struct file_lock **fl, int type);
> > >  };
> 
> I used variable name "type" because that's what
> lm_change uses.  No worries if you think a name
> like conflict is better.
> 
> The only in-kernel setter of lm_grant is:
> 
> fs/lockd/svclock.c:     .lm_grant = nlmsvc_grant_deferred,
> 
> and for that, I think using a variable name of
> "result" is misleading at best.
> 


-- 
Jeff Layton <jlayton@poochiereds.net>
