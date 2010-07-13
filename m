From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 12/16] SQUASHME pnfs-submit: reference layout across
	layoutcommit
Date: Tue, 13 Jul 2010 09:50:00 -0400
Message-ID: <AANLkTinVZ3t5KMD-BAKFAhLTQ49eX06eA16psXKeDiXl@mail.gmail.com>
References: <1278542063-4009-1-git-send-email-andros@netapp.com>
	<1278542063-4009-2-git-send-email-andros@netapp.com>
	<1278542063-4009-3-git-send-email-andros@netapp.com>
	<1278542063-4009-4-git-send-email-andros@netapp.com>
	<1278542063-4009-5-git-send-email-andros@netapp.com>
	<1278542063-4009-6-git-send-email-andros@netapp.com>
	<1278542063-4009-7-git-send-email-andros@netapp.com>
	<1278542063-4009-8-git-send-email-andros@netapp.com>
	<1278542063-4009-9-git-send-email-andros@netapp.com>
	<1278542063-4009-10-git-send-email-andros@netapp.com>
	<1278542063-4009-11-git-send-email-andros@netapp.com>
	<1278542063-4009-12-git-send-email-andros@netapp.com>
	<1278542063-4009-13-git-send-email-andros@netapp.com>
	<4C3B4EAD.7070404@panasas.com>
	<AANLkTil1wUQUTht0QP7_Ttaagw0-LXef2J8wU6wSFUWG@mail.gmail.com>
	<4C3B5F26.1080100@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:53239 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253Ab0GMNuC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jul 2010 09:50:02 -0400
Received: by gwj18 with SMTP id 18so2697016gwj.19
        for <linux-nfs@vger.kernel.org>; Tue, 13 Jul 2010 06:50:00 -0700 (PDT)
In-Reply-To: <4C3B5F26.1080100@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 12, 2010 at 2:29 PM, Benny Halevy <bhalevy@panasas.com> wro=
te:
> On Jul. 12, 2010, 21:27 +0300, "William A. (Andy) Adamson" <androsada=
mson@gmail.com> wrote:
>> On Mon, Jul 12, 2010 at 1:19 PM, Benny Halevy <bhalevy@panasas.com> =
wrote:
>>> On Jul. 08, 2010, 1:34 +0300, andros@netapp.com wrote:
>>>> From: Andy Adamson <andros@netapp.com>
>>>>
>>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>>> ---
>>>> =A0fs/nfs/nfs4proc.c | =A0 =A02 ++
>>>> =A0fs/nfs/pnfs.c =A0 =A0 | =A0 13 +++++++++++++
>>>> =A0fs/nfs/pnfs.h =A0 =A0 | =A0 =A01 +
>>>> =A03 files changed, 16 insertions(+), 0 deletions(-)
>>>>
>>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>>> index 6acebc3..f763746 100644
>>>> --- a/fs/nfs/nfs4proc.c
>>>> +++ b/fs/nfs/nfs4proc.c
>>>> @@ -5565,6 +5565,8 @@ static void pnfs_layoutcommit_release(void *=
lcdata)
>>>> =A0 =A0 =A0 struct pnfs_layoutcommit_data *data =3D
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 (struct pnfs_layoutcommit_data *)lcdat=
a;
>>>>
>>>> + =A0 =A0 /* Matched by get_layout in pnfs_layoutcommit_inode */
>>>> + =A0 =A0 put_layout(data->args.inode);
>>>> =A0 =A0 =A0 put_rpccred(data->cred);
>>>> =A0 =A0 =A0 pnfs_layoutcommit_free(lcdata);
>>>> =A0}
>>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>>> index aa16e5d..d42c5da 100644
>>>> --- a/fs/nfs/pnfs.c
>>>> +++ b/fs/nfs/pnfs.c
>>>> @@ -354,6 +354,15 @@ put_layout_locked(struct pnfs_layout_type *lo=
)
>>>> =A0}
>>>>
>>>> =A0void
>>>> +put_layout(struct inode *inode)
>>>> +{
>>>> + =A0 =A0 spin_lock(&inode->i_lock);
>>>> + =A0 =A0 put_layout_locked(NFS_I(inode)->layout);
>>>> + =A0 =A0 spin_unlock(&inode->i_lock);
>>>> +
>>>> +}
>>>> +
>>>> +void
>>>> =A0pnfs_layout_release(struct pnfs_layout_type *lo,
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct nfs4_pnfs_layout_segmen=
t *range)
>>>> =A0{
>>>> @@ -1598,6 +1607,9 @@ pnfs_layoutcommit_inode(struct inode *inode,=
 int sync)
>>>> =A0 =A0 =A0 __clear_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->layout->pnfs_=
layout_state);
>>>> =A0 =A0 =A0 pnfs_get_layout_stateid(&data->args.stateid, nfsi->lay=
out);
>>>>
>>>> + =A0 =A0 /* Reference for layoutcommit matched in pnfs_layoutcomm=
it_release */
>>>> + =A0 =A0 get_layout(NFS_I(inode)->layout);
>>>> +
>>>
>>> So from the 30000 foot level, I need to remind myself what do
>>> we need the refcount on the layout hdr (pnfs_layout_type) for?
>>
>>> Can we really use it detached from the inode? NO
>>> Is it only for debugging to make catch the case that the inode
>>> is released while there are references to the layout?
>>
>> When we migrate the filesystem, we need to reap the nfs_inode->layou=
t
>> while keeping the nfs_inode.
>>
>
> But how does the refcount help us with that?
> Don't we have to do this synchronously before reusing the nfs_inode?

We need to drain all slots which could have async LAYOUTCOMMITs or
async LAYOUTRETURNs still on the wire.  The refcount keeps the
nfs_inode->layout allocated for the LAYOUTCOMMIT return.


-->Andy

>
> Benny
>
>> Same with server reboot, network partition, and use of a different r=
eplica.
>>
>> -->Andy
>>
>>>
>>> Benny
>>>
>>>> =A0 =A0 =A0 spin_unlock(&inode->i_lock);
>>>>
>>>> =A0 =A0 =A0 /* Set up layout commit args */
>>>> @@ -1606,6 +1618,7 @@ pnfs_layoutcommit_inode(struct inode *inode,=
 int sync)
>>>> =A0 =A0 =A0 if (status) {
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* The layout driver failed to setup t=
he layoutcommit */
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_rpccred(data->cred);
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 put_layout(inode);
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_free;
>>>> =A0 =A0 =A0 }
>>>> =A0 =A0 =A0 status =3D pnfs4_proc_layoutcommit(data, sync);
>>>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>>>> index 9b0fed4..e04b9d4 100644
>>>> --- a/fs/nfs/pnfs.h
>>>> +++ b/fs/nfs/pnfs.h
>>>> @@ -64,6 +64,7 @@ void pnfs_layout_release(struct pnfs_layout_type=
 *, struct nfs4_pnfs_layout_segm
>>>> =A0void pnfs_set_layout_stateid(struct pnfs_layout_type *lo,
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const nfs4_=
stateid *stateid);
>>>> =A0void pnfs_destroy_layout(struct nfs_inode *);
>>>> +void put_layout(struct inode *inode);
>>>>
>>>> =A0#define PNFS_EXISTS_LDIO_OP(srv, opname) ((srv)->pnfs_curr_ld &=
& =A0 =A0 \
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0(srv)->pnfs_curr_ld->ld_io_ops && =A0\
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs=
" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.htm=
l
>>>
>
