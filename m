From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 2/2] SQUASHME: pnfs-submit: clean up nfs_lock_alloc_layout
Date: Tue, 13 Jul 2010 10:22:22 -0400
Message-ID: <AANLkTilggIcSbrd6Jkv9WTDj21wEKC_t1noi2aX8gPar@mail.gmail.com>
References: <4C3B611C.1000208@panasas.com>
	<1278960015-32215-1-git-send-email-bhalevy@panasas.com>
	<AANLkTin5Wo-9paVQvfXZwDx5KZFkpSSspTCIN6vRCc8h@mail.gmail.com>
	<4C3C7200.9070508@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:35986 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011Ab0GMOWY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jul 2010 10:22:24 -0400
Received: by gwj18 with SMTP id 18so2721647gwj.19
        for <linux-nfs@vger.kernel.org>; Tue, 13 Jul 2010 07:22:24 -0700 (PDT)
In-Reply-To: <4C3C7200.9070508@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 13, 2010 at 10:02 AM, Benny Halevy <bhalevy@panasas.com> wr=
ote:
> On Jul. 13, 2010, 16:44 +0300, "William A. (Andy) Adamson" <androsada=
mson@gmail.com> wrote:
>> On Mon, Jul 12, 2010 at 2:40 PM, Benny Halevy <bhalevy@panasas.com> =
wrote:
>>> Fix a bug where the function returned without taking the i_lock
>>> if the layout hdr was already allocated.
>>> Simplify by moving inode locking to caller.
>>
>> No, the original function I sent had no such bug.
>>
>
> True. =A0It was my bad.
>
>>>
>>> Rename function as it no longer grabs the lock.
>>> Clean up the implementation so it's clearer what's going on
>>> and what are the likely cases vs. the unlikely ones.
>>
>> I do not think this is any clearer!
>>
>
> I think that getting the lock by the caller is simpler
> than having the callee take it, but it doesn't matter that much.
>
> My main problems with your patch were:
> a. usage of the 'new' variable, setting it to NULL if it was used
> rather than using simple if/else logic.
>
> b. if alloc_init_layout failed after releasing the lock
> the function always returned NULL, even if someone else
> was able to allocate it in parallel (very unlikely, but possible)

:)

>
> c. the fast path had to go through 2 unlikely if's

Absolutely not concerned with fast path as almost always occurs once
per inode until umount (unless server reboots, network partition,
migration or use of another replica)

OK, I guess it doesn't matter that much. It just seems like a
re-arrange for very little reason.

-->Andy

>
> Benny
>
>>>
>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>> ---
>>> =A0fs/nfs/pnfs.c | =A0 42 ++++++++++++++++++++++-------------------=
-
>>> =A01 files changed, 22 insertions(+), 20 deletions(-)
>>>
>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>> index 4ba7595..053a5c1 100644
>>> --- a/fs/nfs/pnfs.c
>>> +++ b/fs/nfs/pnfs.c
>>> @@ -938,36 +938,37 @@ alloc_init_layout(struct inode *ino)
>>> =A0}
>>>
>>> =A0/*
>>> - * Lock and possibly allocate the inode layout
>>> + * Retrieve and possibly allocate the inode layout
>>> =A0*
>>> - * If successful, ino->i_lock is taken, and the caller must unlock=
=2E
>>> + * ino->i_lock must be taken by the caller.
>>> =A0*/
>>> =A0static struct pnfs_layout_type *
>>> -nfs_lock_alloc_layout(struct inode *ino)
>>> +pnfs_alloc_layout(struct inode *ino)
>>> =A0{
>>> + =A0 =A0 =A0 struct nfs_inode *nfsi =3D NFS_I(ino);
>>> =A0 =A0 =A0 =A0struct pnfs_layout_type *new =3D NULL;
>>>
>>> - =A0 =A0 =A0 dprintk("%s Begin ino=3D%p layout=3D%p\n", __func__, =
ino, NFS_I(ino)->layout);
>>> + =A0 =A0 =A0 dprintk("%s Begin ino=3D%p layout=3D%p\n", __func__, =
ino, nfsi->layout);
>>>
>>> - =A0 =A0 =A0 if (NFS_I(ino)->layout =3D=3D NULL) {
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 new =3D alloc_init_layout(ino);
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (new =3D=3D NULL)
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&ino->i_lock);
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (NFS_I(ino)->layout =3D=3D NULL) {
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NFS_I(ino)->layout =3D=
 new;
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new =3D NULL;
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>> - =A0 =A0 =A0 }
>>> - =A0 =A0 =A0 if (new) {
>>> + =A0 =A0 =A0 BUG_ON(!spin_is_locked(&ino->i_lock));
>>> + =A0 =A0 =A0 if (likely(nfsi->layout))
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return nfsi->layout;
>>> +
>>> + =A0 =A0 =A0 spin_unlock(&ino->i_lock);
>>> + =A0 =A0 =A0 new =3D alloc_init_layout(ino);
>>> + =A0 =A0 =A0 spin_lock(&ino->i_lock);
>>> +
>>> + =A0 =A0 =A0 if (likely(nfsi->layout =3D=3D NULL)) { =A0 =A0 /* Wo=
n the race? */
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nfsi->layout =3D new;
>>> + =A0 =A0 =A0 } else if (new) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Reference the layout accross i_lo=
ck release and grab */
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 get_layout(NFS_I(ino)->layout);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 get_layout(nfsi->layout);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock(&ino->i_lock);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NFS_SERVER(ino)->pnfs_curr_ld->ld_io=
_ops->free_layout(new);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock(&ino->i_lock);
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_layout_locked(NFS_I(ino)->layout)=
;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_layout_locked(nfsi->layout);
>>> =A0 =A0 =A0 =A0}
>>> - =A0 =A0 =A0 return NFS_I(ino)->layout;
>>> + =A0 =A0 =A0 return nfsi->layout;
>>> =A0}
>>>
>>> =A0/*
>>> @@ -1055,10 +1056,11 @@ _pnfs_update_layout(struct inode *ino,
>>>
>>> =A0 =A0 =A0 =A0if (take_ref)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*lsegpp =3D NULL;
>>> - =A0 =A0 =A0 lo =3D nfs_lock_alloc_layout(ino);
>>> + =A0 =A0 =A0 spin_lock(&ino->i_lock);
>>> + =A0 =A0 =A0 lo =3D pnfs_alloc_layout(ino);
>>> =A0 =A0 =A0 =A0if (lo =3D=3D NULL) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dprintk("%s ERROR: can't get pnfs_la=
yout_type\n", __func__);
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_unlock;
>>> =A0 =A0 =A0 =A0}
>>>
>>> =A0 =A0 =A0 =A0/* Check to see if the layout for the given range al=
ready exists */
>>> --
>>> 1.7.1.1
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs=
" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.htm=
l
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"=
 in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
