Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49201 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752781AbbEHNrp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 May 2015 09:47:45 -0400
Date: Fri, 8 May 2015 09:47:44 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Kinglong Mee <kinglongmee@gmail.com>, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 4/4] nfsd: Pin to vfsmnt instead of mntget
Message-ID: <20150508134744.GA23753@fieldses.org>
References: <554A149B.5060102@gmail.com>
 <554A154B.6040103@gmail.com>
 <20150508144031.6f0d3cda@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150508144031.6f0d3cda@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 08, 2015 at 02:40:31PM +1000, NeilBrown wrote:
> Thanks for this patch.  It looks good!
> 
> My only comment on the code is that I would really like to see a
> "path_get_pin()" and "path_put_unpin()" rather than open coding:
> 
> > +	dget(item->ek_path.dentry);
> > +	pin_insert_group(&new->ek_pin, item->ek_path.mnt, NULL);
> 
> and 
> 
> > +		dput(key->ek_path.dentry);
> > +		pin_remove(&key->ek_pin);
> 
> 
> But the question you raise is an important one:  Exactly which filesystems
> should be allowed to be unmounted?
> This is a change in behaviour - is it one that people uniformly would want?
> 
> The kernel doesn't currently know which file systems were explicitly listed
> in /etc/exports, and which were found by following a 'crossmnt'.
> It could guess and allow the unmounting of anything below a 'crossmnt', but I
> wouldn't be comfortable with that - it is error prone.
> 
> mountd does know what is in /etc/exports, and could tell the kernel.
> For the expkey cache, we could always use path_get_pin.
> For the export cache (where flags are available) we could use path_get
> or path_get_pin depending on some new flag.
> 
> I'm not really sure it is worth it.  I would rather the filesystems could
> always be unmounted.  But doing that could possibly break someone's work
> flow.  Maybe.
> 
> Or maybe I'm seeing problems where there aren't any.
> 
> Anyone else have an opinion?

The undisputed bug here was negative cache entries preventing unmount.
So most conservative might be just to purge negative entries.

Otherwise, the only guarantees I think we've really had is that we won't
allow unmount if you hold any actual state on the filesystem (NLM locks,
NFSv4 locks, opens, or delegations).

If a filesystem is exported but no clients hold state on it, then it's
currently mostly chance whether the unmount succeeds or not.  So we're
probably free to change the behavior in this case.  I'd be inclined to
allow the unmount, but haven't thought this through carefully.

It could also be useful to have the ability to force an unmount even in
the presence of locks.  That's not a safe default, but an
"allow_force_unmount" export option might be useful.

We might similarly be able to add some way for the kernel to distinguish
explicit exports from crossmnt-found exports, but I'm not seeing the use
case for that.

--b.
