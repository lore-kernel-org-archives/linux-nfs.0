Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f45.google.com ([209.85.212.45]:50604 "EHLO
	mail-vb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753245Ab3GaU0E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Jul 2013 16:26:04 -0400
Received: by mail-vb0-f45.google.com with SMTP id e15so1241379vbg.4
        for <linux-nfs@vger.kernel.org>; Wed, 31 Jul 2013 13:26:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130731144657.7b94482b@tlielax.poochiereds.net>
References: <1362013834-29600-1-git-send-email-jlayton@redhat.com>
	<CAKjHkpAi_-jucPnFXg=3vMZg+pWSha3xR7KhjMPqN56K12SbCQ@mail.gmail.com>
	<20130731144657.7b94482b@tlielax.poochiereds.net>
Date: Wed, 31 Jul 2013 15:26:02 -0500
Message-ID: <CAKjHkpBGeQxy98osnJ4Q=NpqOjqC5uk32aYh+-bZ72ZBP3zmJQ@mail.gmail.com>
Subject: Re: [PATCH] nfs: don't allow nfs_find_actor to match inodes of the
 wrong type
From: Quentin Barnes <qbarnes@gmail.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 31, 2013 at 1:46 PM, Jeff Layton <jlayton@redhat.com> wrote:
> On Wed, 31 Jul 2013 13:36:21 -0500
> Quentin Barnes <qbarnes@gmail.com> wrote:
>
>> I was reviewing patches I was integrating into my NFS source base
>> and this one popped up (commit f6488c9b).  In reviewing it, it would
>> fix the problem, however, I think it's not the best fix for it.
>> Catching it in nfs_find_actor() is after the horse has left the
>> barn so to speak.
>>
>> I think the problem is in nfs_fhget() when constructing the new
>> inode (inside the if (inode->i_state & I_NEW) {...}) and should be
>> addressed there.
>>
>> The nfs module already has checks to ensure that the expression
>> "((S_IFMT & inode->i_mode) == (S_IFMT & fattr->mode))" is true
>> in nfs_update_inode() and nfs_check_inode_attributes().  I think
>> problem Benny hit was that the equivalent check is missing in
>> nfs_fhget() when constructing a new inode.  The same check that's
>> in those other two functions needs to be added to nfs_fhget()'s "if
>> (inode->i_state & I_NEW) {...}" conditional block to prevent the
>> problem of an inconsistent fattr/inode state from occurring in the
>> first place.
>>
>> I can come up with a patch if you'd like, but I wanted to make
>> sure my assertions were valid first.  Is removing a check from
>> nfs_find_actor() and adding the check to nfs_fhget() to prevent the
>> inconsistency in the first place a better approach?
>>
>> Quentin
>
> I don't think I agree. The whole problem was that we were allowing
> iget5_locked to match an existing inode even though (S_IFMT & mode) was
> different.

I assert that when an inconsistent state happens you don't want
nfs_find_actor() to be the one responsible for noticing it
(actually, ignoring the problem).  You want the existing consistency
and error recovery paths to handle it instead.

So one or two things are going on.  The existing error recovery
paths are inadequate or that there's a hole in the fattr/inode
consistency checking (or possibly both).  Your patch covers over
this underlying bug rather than addressing it and which also lets
the old inode not get flagged as invalid.  I would rather see the
real problem fixed and the old inode get flagged rather than just
ignoring it and creating another new inode.

Before your patch, if because of a server bug reusing a file
handle, nfs_find_actor(), would match and iget5_locked() would
return an inode that matched on its file handle but that didn't
necessarily match the fattr info.

If that inode returned by iget5_locked() was not I_NEW (the else
case), nfs_fhget() would invoke nfs_refresh_inode(), which would
call nfs_refresh_inode_locked().  It calls either nfs_update_inode()
or nfs_check_inode_attributes().  Both of those functions already
check for fattr/inode S_IFMT consistency catching bad states.

> Why would it be preferable to use the same struct inode even though
> it's clearly a different one on the server? inodes generally don't
> change their type after they've been created.

It's not preferable to have the same inode in a different state.
What you don't want is nfs_find_actor() as a side-effect to let the
problem go unnoticed.  You want let the normal, existing error
handling paths deal with it, or if they're not fully dealing with
it, fix them.

Since the I_NEW conditional false path (the else case) in nfs_fhget()
should catch the problem, I had thought that the problem must lay
with the I_NEW conditional true path.  Now I don't think so.

I see now that nfs_check_inode_attributes() is just returning an
error when the fattr and inode states are found to be inconsistent,
but is taking no action on the bad inode's state (i.e. flagging it
as invalid).  And upon return, nfs_fhget() is not doing anything with
the bad return state passed up to nfs_refresh_inode().  Now I'm
thinking that this is problematic hole because it is ignoring the
error state and that let Benny's panic happen.

It doesn't seem to me that it should be nfs_check_inode_attributes()
job to flag the inode as invalid.  That seems outside its role.  I
would think it should be nfs_refresh_inode_locked()'s job, but I'm
still reviewing the code.

Thoughts?

> That said, patches speak louder than words so if you have one to
> propose I can certainly take a look. Maybe it'll make sense to me
> then...

As you can see, I'm still trying to fully piece together the
underlying cause cause of the original bug.

The panic was against RHEL6.4.  Do you want a patch against that
code base or against the linux git?

> Jeff Layton <jlayton@redhat.com>
