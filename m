From: Fred Isaman <iisaman@umich.edu>
Subject: Re: [PATCH 07/10] pnfs-submit: avoid race handling return on close
Date: Tue, 15 Jun 2010 13:32:22 -0400
Message-ID: <AANLkTilDj2Ua_t77kk5Gj_t0vqEcOJFKlqODAj18KQnm@mail.gmail.com>
References: <1276566375-24566-1-git-send-email-iisaman@netapp.com>
	<1276566375-24566-2-git-send-email-iisaman@netapp.com>
	<1276566375-24566-3-git-send-email-iisaman@netapp.com>
	<1276566375-24566-4-git-send-email-iisaman@netapp.com>
	<1276566375-24566-5-git-send-email-iisaman@netapp.com>
	<1276566375-24566-6-git-send-email-iisaman@netapp.com>
	<1276566375-24566-7-git-send-email-iisaman@netapp.com>
	<1276566375-24566-8-git-send-email-iisaman@netapp.com>
	<4C17B304.4070308@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:36373 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754298Ab0FORcY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jun 2010 13:32:24 -0400
Received: by bwz7 with SMTP id 7so2819576bwz.19
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jun 2010 10:32:22 -0700 (PDT)
In-Reply-To: <4C17B304.4070308@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 15, 2010 at 1:06 PM, Benny Halevy <bhalevy@panasas.com> wro=
te:
> On Jun. 14, 2010, 21:46 -0400, Fred Isaman <iisaman@netapp.com> wrote=
:
>> This prepares for the next patch.
>>
>> NOTE this doesn't really fix any current race, since
>> layout going to NULL is OK. =A0But layout changing from NULL to nonN=
ULL
>> is a real race that is not fixed
>>
>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>> ---
>> =A0fs/nfs/nfs4state.c =A0 =A0 =A0 =A0| =A0 =A05 +++--
>> =A0fs/nfs/pnfs.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 11 +++++++++++
>> =A0include/linux/nfs4_pnfs.h | =A0 =A02 ++
>> =A03 files changed, 16 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index d5144bd..8a7a64c 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -594,11 +594,12 @@ static void __nfs4_close(struct path *path, st=
ruct nfs4_state *state,
>> =A0 =A0 =A0 } else {
>> =A0#ifdef CONFIG_NFS_V4_1
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct nfs_inode *nfsi =3D NFS_I(state->=
inode);
>> + =A0 =A0 =A0 =A0 =A0 =A0 int roc =3D nfs4_roc_iomode(nfsi);
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (has_layout(nfsi) && nfsi->layout.roc_i=
omode) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (roc) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct nfs4_pnfs_layout_=
segment range;
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 range.iomode =3D nfsi->lay=
out.roc_iomode;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 range.iomode =3D roc;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 range.offset =3D 0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 range.length =3D NFS4_MA=
X_UINT64;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pnfs_return_layout(state=
->inode, &range, NULL,
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 6def09c..bd11ec7 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -321,6 +321,17 @@ pnfs_unregister_layoutdriver(struct pnfs_layout=
driver_type *ld_type)
>> =A0#define BUG_ON_UNLOCKED_LO(lo) do {} while (0)
>> =A0#endif /* CONFIG_SMP */
>>
>> +int nfs4_roc_iomode(struct nfs_inode *nfsi)
>> +{
>> + =A0 =A0 int rv =3D 0;
>> +
>> + =A0 =A0 spin_lock(&pnfs_spinlock);
>
> Why take the global lock rather than nfsi->lo_lock?
>
> Benny

You are right. That would be a copy-paste error.

=46red

>
>> + =A0 =A0 if (has_layout(nfsi))
>> + =A0 =A0 =A0 =A0 =A0 =A0 rv =3D nfsi->layout.roc_iomode;
>> + =A0 =A0 spin_unlock(&pnfs_spinlock);
>> + =A0 =A0 return rv;
>> +}
>> +
>> =A0static inline void
>> =A0get_layout(struct pnfs_layout_type *lo)
>> =A0{
>> diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
>> index 0eb9b16..2ea131f 100644
>> --- a/include/linux/nfs4_pnfs.h
>> +++ b/include/linux/nfs4_pnfs.h
>> @@ -86,6 +86,8 @@ layoutcommit_needed(struct nfs_inode *nfsi)
>> =A0 =A0 =A0 return test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->pnfs_layout=
_state);
>> =A0}
>>
>> +int nfs4_roc_iomode(struct nfs_inode *nfs);
>> +
>> =A0#else /* CONFIG_NFS_V4_1 */
>>
>> =A0static inline bool
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
