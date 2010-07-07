From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 2/5] SQUASHME pnfs-submit remove pnfs_alloc_init_inode
Date: Wed, 7 Jul 2010 13:03:20 -0400
Message-ID: <AANLkTinxnmBMmVlPjvj0Zb6Q23DFkFTPYACauj-SCqCi@mail.gmail.com>
References: <1278451022-2889-1-git-send-email-andros@netapp.com>
	<1278451022-2889-2-git-send-email-andros@netapp.com>
	<1278451022-2889-3-git-send-email-andros@netapp.com>
	<4C344866.1070600@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:54719 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757549Ab0GGRDX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jul 2010 13:03:23 -0400
Received: by ewy23 with SMTP id 23so2154004ewy.19
        for <linux-nfs@vger.kernel.org>; Wed, 07 Jul 2010 10:03:20 -0700 (PDT)
In-Reply-To: <4C344866.1070600@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 7, 2010 at 5:27 AM, Boaz Harrosh <bharrosh@panasas.com> wro=
te:
> On 07/07/2010 12:16 AM, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> Place all layout initialization in nfs4_init_once
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> =A0fs/nfs/inode.c | =A0 19 ++++++-------------
>> =A01 files changed, 6 insertions(+), 13 deletions(-)
>>
>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> index 231cfa3..fa310b1 100644
>> --- a/fs/nfs/inode.c
>> +++ b/fs/nfs/inode.c
>> @@ -1361,18 +1361,6 @@ void nfs4_clear_inode(struct inode *inode)
>> =A0}
>> =A0#endif
>>
>> -static void pnfs_alloc_init_inode(struct nfs_inode *nfsi)
>> -{
>> -#ifdef CONFIG_NFS_V4_1
>> - =A0 =A0 nfsi->layout.pnfs_layout_state =3D 0;
>> - =A0 =A0 memset(&nfsi->layout.stateid, 0, NFS4_STATEID_SIZE);
>> - =A0 =A0 nfsi->layout.roc_iomode =3D 0;
>> - =A0 =A0 nfsi->layout.lo_cred =3D NULL;
>> - =A0 =A0 nfsi->layout.pnfs_write_begin_pos =3D 0;
>> - =A0 =A0 nfsi->layout.pnfs_write_end_pos =3D 0;
>> -#endif /* CONFIG_NFS_V4_1 */
>> -}
>> -
>> =A0struct inode *nfs_alloc_inode(struct super_block *sb)
>> =A0{
>> =A0 =A0 =A0 struct nfs_inode *nfsi;
>> @@ -1388,7 +1376,6 @@ struct inode *nfs_alloc_inode(struct super_blo=
ck *sb)
>> =A0#ifdef CONFIG_NFS_V4
>> =A0 =A0 =A0 nfsi->nfs4_acl =3D NULL;
>> =A0#endif /* CONFIG_NFS_V4 */
>> - =A0 =A0 pnfs_alloc_init_inode(nfsi);
>> =A0 =A0 =A0 return &nfsi->vfs_inode;
>> =A0}
>>
>> @@ -1430,6 +1417,12 @@ static inline void nfs4_init_once(struct nfs_=
inode *nfsi)
>> =A0 =A0 =A0 INIT_LIST_HEAD(&nfsi->layout.segs);
>> =A0 =A0 =A0 nfsi->layout.refcount =3D 0;
>> =A0 =A0 =A0 nfsi->layout.ld_data =3D NULL;
>> + =A0 =A0 nfsi->layout.pnfs_layout_state =3D 0;
>> + =A0 =A0 memset(&nfsi->layout.stateid, 0, NFS4_STATEID_SIZE);
>> + =A0 =A0 nfsi->layout.roc_iomode =3D 0;
>> + =A0 =A0 nfsi->layout.lo_cred =3D NULL;
>> + =A0 =A0 nfsi->layout.pnfs_write_begin_pos =3D 0;
>> + =A0 =A0 nfsi->layout.pnfs_write_end_pos =3D 0;
>
> If we are already here. What are the rules with zeros? It is costume =
elsewhere in
> Kernel that at construction points all zeros are just not done, if a =
kzalloc or memset
> is guaranteed. Isn't nfs_inode zero_allocated? If not it should. Addi=
ng zero initialization
> to every new member, and an extra remove line to any member remove is=
 just maintenance
> nightmare.

Well, the next patch set will remove all but one zero assignment.
Second; no, nfs_alloc_inode does not zero out all nfs_inode fields.

>
> (This patch could be much more beautiful if it was "only removed line=
s")

The end result will be beautiful. I just wanted to break up all the cha=
nges.

-->Andy
>
> Boaz
>
>
>> =A0#endif /* CONFIG_NFS_V4_1 */
>> =A0#endif
>> =A0}
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
