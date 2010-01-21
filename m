From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 1/2] nfs41: fix nfs4_callback_recallslot
Date: Thu, 21 Jan 2010 14:58:26 -0500
Message-ID: <89c397151001211158q790fef68t74753683268c9b54@mail.gmail.com>
References: <1264101557-6619-1-git-send-email-andros@netapp.com>
	 <1264103242.3721.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f198.google.com ([209.85.211.198]:51842 "EHLO
	mail-yw0-f198.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753256Ab0AUT6g convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jan 2010 14:58:36 -0500
Received: by ywh36 with SMTP id 36so112222ywh.15
        for <linux-nfs@vger.kernel.org>; Thu, 21 Jan 2010 11:58:36 -0800 (PST)
In-Reply-To: <1264103242.3721.12.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 21, 2010 at 2:47 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Thu, 2010-01-21 at 14:19 -0500, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> Return NFS4_OK if target high slotid equals enforced high slotid.
>> Fix nfs_client reference leak.
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> =A0fs/nfs/callback_proc.c | =A0 10 +++++++---
>> =A01 files changed, 7 insertions(+), 3 deletions(-)
>>
>> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
>> index e5155d9..c79e18c 100644
>> --- a/fs/nfs/callback_proc.c
>> +++ b/fs/nfs/callback_proc.c
>> @@ -381,13 +381,17 @@ unsigned nfs4_callback_recallslot(struct cb_re=
callslotargs *args, void *dummy)
>> =A0 =A0 =A0 fc_tbl =3D &clp->cl_session->fc_slot_table;
>>
>> =A0 =A0 =A0 status =3D htonl(NFS4ERR_BAD_HIGH_SLOT);
>
> This is not related directly to your patch, but "sparse" is going to
> have a field day with all these scattered around the place. Are there
> any plans to clean all this up, and replace those 'int' and 'unsigned=
'
> declarations that are being assigned big ended values with the correc=
t
> '__be32' type?

I could do that.

-->Andy

>
>> - =A0 =A0 if (args->crsa_target_max_slots >=3D fc_tbl->max_slots ||
>> + =A0 =A0 if (args->crsa_target_max_slots > fc_tbl->max_slots ||
>> =A0 =A0 =A0 =A0 =A0 args->crsa_target_max_slots < 1)
>> - =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out_putclient;
>> +
>> + =A0 =A0 status =3D htonl(NFS4_OK);
>> + =A0 =A0 if (args->crsa_target_max_slots =3D=3D fc_tbl->max_slots)
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out_putclient;
>>
>> =A0 =A0 =A0 fc_tbl->target_max_slots =3D args->crsa_target_max_slots=
;
>> =A0 =A0 =A0 nfs41_handle_recall_slot(clp);
>> - =A0 =A0 status =3D htonl(NFS4_OK);
>> +out_putclient:
>> =A0 =A0 =A0 nfs_put_client(clp); =A0 =A0/* balance nfs_find_client *=
/
>> =A0out:
>> =A0 =A0 =A0 dprintk("%s: exit with status =3D %d\n", __func__, ntohl=
(status));
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
