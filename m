Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f52.google.com ([209.85.215.52]:33609 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755517Ab3GUOXi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Jul 2013 10:23:38 -0400
Received: by mail-la0-f52.google.com with SMTP id fo12so4589697lab.11
        for <linux-nfs@vger.kernel.org>; Sun, 21 Jul 2013 07:23:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130719102109.02c51b4d@tlielax.poochiereds.net>
References: <1373386605-18684-1-git-send-email-nadav@tonian.com>
	<20130711104918.589cefe7@tlielax.poochiereds.net>
	<20130719102109.02c51b4d@tlielax.poochiereds.net>
Date: Sun, 21 Jul 2013 17:23:36 +0300
Message-ID: <CADnca3sTH7XWOsKB1KihR5ig6_DPpZaOak=m75W+nL2JV7dsTw@mail.gmail.com>
Subject: Re: [PATCH] NFSv4: fix open(O_RDONLY|O_TRUNC) returning EBADF
From: Nadav Shemer <nadav@tonian.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 19, 2013 at 5:21 PM, Jeff Layton <jlayton@redhat.com> wrote:
> On Thu, 11 Jul 2013 10:49:18 -0400
> Jeff Layton <jlayton@redhat.com> wrote:
>
>> On Tue,  9 Jul 2013 19:16:45 +0300
>> Nadav Shemer <nadav@tonian.com> wrote:
>>
>> > Move ATTR_OPEN handling from nfs4_proc_setattr into nfs4_do_setattr
>> >
>> > Signed-off-by: Nadav Shemer <nadav@tonian.com>
>> > ---
>> > Hello.
>> >
>> > I've come across an oddity while testing filesystem coverage
>> > My test creates a non-empty file without write permissions and tries to open it with O_RDONLY|O_TRUNC
>> > It expects EACCES (and gets that for local filesystems and NFSv3) but gets EBADF on NFSv4 (and v4.1)
>> >
>> > I found some history on this: In a previous kernel it would just hang due to mishandling the NFS4ERR_OPENMODE exception
>> > http://www.spinics.net/lists/linux-nfs/msg28881.html
>> >
>> > A fix for this was introduced (it specifically tests for NFS4ERR_OPENMODE and returns EACCES for the open() case, EBADF otherwise)
>> > http://www.spinics.net/linux/fedora/fedora-kernel/msg03736.html
>> > but another patch was also introduced in the same set which seems to break it (it optimizes away the time modification and removes ATTR_OPEN in nfs4_proc_setattr)
>> > http://www.spinics.net/linux/fedora/fedora-kernel/msg03732.html
>> >
>> > By moving the 'Deal with open(O_TRUNC)' bit inside (into nfs4_do_setattr), I got it working again (with no other functional change, as far as I can see)
>> >
>> >  fs/nfs/nfs4proc.c | 10 +++++-----
>> >  1 file changed, 5 insertions(+), 5 deletions(-)
>> >
>> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> > index 8fbc100..17b9f32 100644
>> > --- a/fs/nfs/nfs4proc.c
>> > +++ b/fs/nfs/nfs4proc.c
>> > @@ -2180,6 +2180,10 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
>> >             .inode = inode,
>> >     };
>> >     int err;
>> > +   int is_o_trunc = sattr->ia_valid & ATTR_OPEN;
>> > +   /* Deal with open(O_TRUNC) */
>> > +   if (sattr->ia_valid & ATTR_OPEN)
>> > +           sattr->ia_valid &= ~(ATTR_MTIME|ATTR_CTIME|ATTR_OPEN);
>>
>> I'm not sure you really need to move the above if statement into this
>> function, do you? I think it'd be best to leave that where it is and
>> just add the is_o_trunc variable the special handling for it below.
>>
>
> Actually, disregard that comment. I was confused as to which function
> calls which here...
>
> Still, I think we'd do better to keep this logic consolidated in
> nfs4_proc_setattr instead of spreading it around. I'm a little
> concerned that this may change the behavior in the open codepath, which
> also calls nfs4_do_setattr. More below...
>
>> >     do {
>> >             err = _nfs4_do_setattr(inode, cred, fattr, sattr, state);
>> >             switch (err) {
>> > @@ -2193,7 +2197,7 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
>> >                     }
>> >                     if (state && !(state->state & FMODE_WRITE)) {
>> >                             err = -EBADF;
>> > -                           if (sattr->ia_valid & ATTR_OPEN)
>> > +                           if (is_o_trunc)
>> >                                     err = -EACCES;
>> >                             goto out;
>> >                     }
>> > @@ -2774,10 +2778,6 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
>> >
>> >     nfs_fattr_init(fattr);
>> >
>> > -   /* Deal with open(O_TRUNC) */
>> > -   if (sattr->ia_valid & ATTR_OPEN)
>> > -           sattr->ia_valid &= ~(ATTR_MTIME|ATTR_CTIME|ATTR_OPEN);
>> > -
>> >     /* Optimization: if the end result is no change, don't RPC */
>> >     if ((sattr->ia_valid & ~(ATTR_FILE)) == 0)
>> >             return 0;
>>
>
> It looks like we're just clearing ATTR_OPEN here in order to make the
> check that follows that happy. Would it make more sense to instead
> leave ATTR_OPEN set in this place and fix that check to ignore
> ATTR_OPEN?
Yes, it does :)
My patch broke that check, and your suggestion also makes the patch
much smaller (resending it)

This is also the same check that's in nfs/inode.c (which is the only
caller I could find), but this one happens after removing
ATTR_MTIME|ATTR_CTIME (nfs/inode.c only removed ATTR_SIZE and non-NFS
attributes)

>
> --
> Jeff Layton <jlayton@redhat.com>
