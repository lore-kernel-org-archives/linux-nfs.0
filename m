Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:34565 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534AbbFFCWE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Jun 2015 22:22:04 -0400
Date: Sat, 6 Jun 2015 03:21:58 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 5/5] nfsd: allows user un-mounting filesystem where nfsd
 exports base on
Message-ID: <20150606022158.GZ7232@ZenIV.linux.org.uk>
References: <5561E7E4.50604@gmail.com>
 <5561E9FA.4050808@gmail.com>
 <20150605150213.GV7232@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150605150213.GV7232@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 05, 2015 at 04:02:13PM +0100, Al Viro wrote:
> On Sun, May 24, 2015 at 11:10:50PM +0800, Kinglong Mee wrote:
> > --- a/fs/nfsd/export.c
> > +++ b/fs/nfsd/export.c
> > @@ -43,9 +43,9 @@ static void expkey_put(struct kref *ref)
> >  
> >  	if (test_bit(CACHE_VALID, &key->h.flags) &&
> >  	    !test_bit(CACHE_NEGATIVE, &key->h.flags))
> > -		path_put(&key->ek_path);
> > +		path_put_unpin(&key->ek_path, &key->ek_pin);
> >  	auth_domain_put(key->ek_client);
> > -	kfree(key);
> > +	kfree_rcu(key, rcu_head);
> >  }
> 
> That looks wrong.  OK, so you want umount() to proceed; fine, no problem
> with that.  However, what happens if the final mntput() hits while you
> are just approaching that path_put_unpin()?  ->kill() will be triggered,
> and it would bloody better
> 	a) make sure that expkey_put() is called for that key if it hadn't
> already been done and
> 	b) do not return until such expkey_put() completes.  Including the
> ones that might have been already entered by the time we'd got to ->kill().
> 
> Am I missing something subtle here?

Having looked through that code...  It *is* wrong.  Note that the normal
approach is to have pin_remove() called via pin_kill(), directly or triggered
from group_pin_kill() and/or cleanup_mnt() on the mount it's attached to.
pin_remove() should never be called outside of ->kill() callbacks.  It should
be called at the point where you are OK with fs being shut down.

The fundamental reason why it's broken is different, though - you *can't*
grab a reference if all you've got is a pin.  By the time the callback is
called, the mount in question is already irretrievably committed to being
killed.  There's one hell of a wide window between the point of no return
and the point where you are notified of anything, and that's by design -
you might very well have had several mounts doomed by a syscall and they
all get through cleanup_mnt() just before return to userland.  One by one.
So between the point where this puppy is doomed and the call of your callback
there might have been several filesystems going through shutdown, with tons
of IO, waiting for remote servers, etc.

We could add a primitive that would _try_ to grab a reference - that can
be done (lock_mount_hash(), check if it has MNT_DOOMED or MNT_SYNC_UMOUNT,
fail if it does, otherwise mnt_add_count(mnt, 1) and succeed, doing
unlock_mount_hash() on both exit paths).  HOWEVER, you'll need to think
very carefully where to use that primitive - unlike mntget() it _can_
fail and lock_mount_hash() can inflict quite a bit of cacheline pingpong
if used heavily.

Could you give details on lifecycle of those objects, including the stages
at which we might try to grab references?  Combination of such primitive with
a pin (doing just "NULL the references to vfsmount/dentry, do dput() on
what that dentry used to be and call pin_remove()") might work, if the
lifecycle is good enough.
