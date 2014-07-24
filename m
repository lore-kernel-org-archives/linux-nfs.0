Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtprelay0217.hostedemail.com ([216.40.44.217]:43265 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S934118AbaGXDyE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jul 2014 23:54:04 -0400
Message-ID: <1406174039.2755.71.camel@joe-AO725>
Subject: Re: [PATCH 9/9] fs: dlm: lockd: Convert int result to unsigned char
 type
From: Joe Perches <joe@perches.com>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Al Viro <viro@ZenIV.linux.org.uk>,
        David Teigland <teigland@redhat.com>,
        Christine Caulfield <ccaulfie@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        cluster-devel@redhat.com, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Date: Wed, 23 Jul 2014 20:53:59 -0700
In-Reply-To: <20140723141139.2cf90cb0@tlielax.poochiereds.net>
References: <cover.1405879494.git.joe@perches.com>
	 <65b9ba0dba9c79a938267d5bed7ed0a8211e89ed.1405879494.git.joe@perches.com>
	 <20140723141139.2cf90cb0@tlielax.poochiereds.net>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2014-07-23 at 14:11 -0400, Jeff Layton wrote:
> On Sun, 20 Jul 2014 11:23:43 -0700 Joe Perches <joe@perches.com> wrote:
> > op->info.rv is an s32, but it's only used as a u8.
> I don't understand this patch. info.rv is s32 (and I assume that "rv"
> stands for "return value").

In this case it's not a return value but an input.

> What I don't get is why you think it's just
> used as a u8.

Because it's tested only in nlmsvc_grant_deferred
and nlmsvc_update_deferred_block against 0.

As far as I can tell, it's not possible to set it
to a negative value.

> It seems to be used more like a bool than anything else,
> and I'm not sure that "type" is really a good description for it. Maybe
> it should be a "bool" and named "conflict",

Maybe.  But it seemed likely and possible to expand
it from a single bool to a value.

> given the comments in dlm_posix_get ?

Maybe, though I don't see how the comments relate to
this change.  The rv value returned from that call
is either -ENOMEM or 0 and is unchanged by this patch.

> > diff --git a/include/linux/fs.h b/include/linux/fs.h
[]
> > @@ -842,7 +842,7 @@ struct lock_manager_operations {
> >  	int (*lm_compare_owner)(struct file_lock *fl1, struct file_lock *fl2);
> >  	unsigned long (*lm_owner_key)(struct file_lock *fl);
> >  	void (*lm_notify)(struct file_lock *fl);	/* unblock callback */
> > -	int (*lm_grant)(struct file_lock *fl, int result);
> > +	int (*lm_grant)(struct file_lock *fl, unsigned char type);
> >  	void (*lm_break)(struct file_lock *fl);
> >  	int (*lm_change)(struct file_lock **fl, int type);
> >  };

I used variable name "type" because that's what
lm_change uses.  No worries if you think a name
like conflict is better.

The only in-kernel setter of lm_grant is:

fs/lockd/svclock.c:     .lm_grant = nlmsvc_grant_deferred,

and for that, I think using a variable name of
"result" is misleading at best.

