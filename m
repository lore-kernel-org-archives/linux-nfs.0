From: Fred Isaman <iisaman@netapp.com>
Subject: Re: [PATCH 20/22] pnfs-submit: wave2: remove all LAYOUTRETURN code
Date: Thu, 16 Dec 2010 09:04:22 -0500
Message-ID: <AANLkTi=G8x9M9QmKRY3wzLPD-49O9VwxFZ8sUCEPDiHk@mail.gmail.com>
References: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
	<1291944177-7819-21-git-send-email-iisaman@netapp.com>
	<4D0A0A6D.5060807@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f45.google.com ([209.85.214.45]:43583 "EHLO
	mail-bw0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755914Ab0LPOEY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Dec 2010 09:04:24 -0500
Received: by bwz16 with SMTP id 16so3595550bwz.4
        for <linux-nfs@vger.kernel.org>; Thu, 16 Dec 2010 06:04:23 -0800 (PST)
In-Reply-To: <4D0A0A6D.5060807@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 16, 2010 at 7:47 AM, Boaz Harrosh <bharrosh@panasas.com> wr=
ote:
> On 12/10/2010 03:22 AM, Fred Isaman wrote:
>
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -599,55 +599,6 @@ void nfs4_asynch_forget_layouts(struct pnfs_lay=
out_hdr *lo,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0}
>>
>> -/* Return true if there is layout based io in progress in the given=
 range.
>> - * Assumes range has already been marked invalid, and layout marked=
 to
>> - * prevent any new lseg from being inserted.
>> - */
>> -bool
>> -pnfs_return_layout_barrier(struct nfs_inode *nfsi,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct pnfs_layout_=
range *range)
>> -{
>> - =A0 =A0 struct pnfs_layout_segment *lseg;
>> - =A0 =A0 bool ret =3D false;
>> -
>> - =A0 =A0 spin_lock(&nfsi->vfs_inode.i_lock);
>> - =A0 =A0 list_for_each_entry(lseg, &nfsi->layout->segs, fi_list)
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (should_free_lseg(&lseg->range, range))=
 {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D true;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> - =A0 =A0 =A0 =A0 =A0 =A0 }
>> - =A0 =A0 spin_unlock(&nfsi->vfs_inode.i_lock);
>> - =A0 =A0 dprintk("%s:Return %d\n", __func__, ret);
>> - =A0 =A0 return ret;
>> -}
>> -
>> -static int
>> -return_layout(struct inode *ino, struct pnfs_layout_range *range, b=
ool wait)
>> -{
>> - =A0 =A0 struct nfs4_layoutreturn *lrp;
>> - =A0 =A0 struct nfs_server *server =3D NFS_SERVER(ino);
>> - =A0 =A0 int status =3D -ENOMEM;
>> -
>> - =A0 =A0 dprintk("--> %s\n", __func__);
>> -
>> - =A0 =A0 lrp =3D kzalloc(sizeof(*lrp), GFP_KERNEL);
>> - =A0 =A0 if (lrp =3D=3D NULL) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 put_layout_hdr(ino);
>> - =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> - =A0 =A0 }
>> - =A0 =A0 lrp->args.reclaim =3D 0;
>> - =A0 =A0 lrp->args.layout_type =3D server->pnfs_curr_ld->id;
>> - =A0 =A0 lrp->args.return_type =3D RETURN_FILE;
>> - =A0 =A0 lrp->args.range =3D *range;
>> - =A0 =A0 lrp->args.inode =3D ino;
>> - =A0 =A0 lrp->clp =3D server->nfs_client;
>> -
>> - =A0 =A0 status =3D nfs4_proc_layoutreturn(lrp, wait);
>> -out:
>> - =A0 =A0 dprintk("<-- %s status: %d\n", __func__, status);
>> - =A0 =A0 return status;
>> -}
>> -
>> =A0/* Initiates a LAYOUTRETURN(FILE) */
>> =A0int
>> =A0_pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *=
range,
>> @@ -673,21 +624,10 @@ _pnfs_return_layout(struct inode *ino, struct =
pnfs_layout_range *range,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 lo->plh_block_lgets++;
>> - =A0 =A0 /* Reference matched in nfs4_layoutreturn_release */
>> - =A0 =A0 get_layout_hdr(lo);
>> =A0 =A0 =A0 spin_unlock(&ino->i_lock);
>> =A0 =A0 =A0 pnfs_free_lseg_list(&tmp_list);
>>
>> - =A0 =A0 if (layoutcommit_needed(nfsi)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 status =3D pnfs_layoutcommit_inode(ino, wa=
it);
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (status) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Return layout even if l=
ayoutcommit fails */
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s: layoutcommit =
failed, status=3D%d. "
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "Returning=
 layout anyway\n",
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__, =
status);
>> - =A0 =A0 =A0 =A0 =A0 =A0 }
>> - =A0 =A0 }
>> - =A0 =A0 status =3D return_layout(ino, &arg, wait);
>
>
> You are also removing the layoutcommit.
> 1. You have not stated it anywhere, and snacked it in silently
> 2. If you are removing layoutcommit please do that in a different
> =A0 patch with it's own comment and explanation.
> 3. How come? forgetful or not layoutcommits are a different issue
> =A0 and must be done correctly when writing !!!?!
>
> Boaz

You are right, that should have been a separate patch.

=46red

>> + =A0 =A0 /* Don't need to wait since this is followed by call to en=
d_writeback */
>> =A0out:
>> =A0 =A0 =A0 dprintk("<-- %s status: %d\n", __func__, status);
>> =A0 =A0 =A0 return status;
>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>> index d999e38..0ddab0d 100644
>> --- a/fs/nfs/pnfs.h
>> +++ b/fs/nfs/pnfs.h
>> @@ -183,7 +183,6 @@ extern int nfs4_proc_getdeviceinfo(struct nfs_se=
rver *server,
>> =A0extern int nfs4_proc_layoutget(struct nfs4_layoutget *lgp);
>> =A0extern int nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *=
data,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0i=
nt issync);
>> -extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bo=
ol wait);
>>
>> =A0/* pnfs.c */
>> =A0void get_layout_hdr(struct pnfs_layout_hdr *lo);
>> @@ -193,7 +192,6 @@ bool should_free_lseg(struct pnfs_layout_range *=
lseg_range,
>> =A0struct pnfs_layout_segment *
>> =A0pnfs_update_layout(struct inode *ino, struct nfs_open_context *ct=
x,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum pnfs_iomode access_type);
>> -bool pnfs_return_layout_barrier(struct nfs_inode *, struct pnfs_lay=
out_range *);
>> =A0int _pnfs_return_layout(struct inode *, struct pnfs_layout_range =
*, bool wait);
>> =A0void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
>> =A0void unset_pnfs_layoutdriver(struct nfs_server *);
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
