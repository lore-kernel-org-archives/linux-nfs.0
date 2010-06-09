From: Fred Isaman <iisaman@umich.edu>
Subject: Re: [PATCH 14/24] pnfs_submit: use fsdata to pass lseg
Date: Wed, 9 Jun 2010 08:08:40 -0400
Message-ID: <AANLkTillGAndgQoohtCV36csBH6CzxkZ3792H16nRV-S@mail.gmail.com>
References: <1275970761-31806-1-git-send-email-iisaman@netapp.com>
	<1275970761-31806-2-git-send-email-iisaman@netapp.com>
	<1275970761-31806-3-git-send-email-iisaman@netapp.com>
	<1275970761-31806-4-git-send-email-iisaman@netapp.com>
	<1275970761-31806-5-git-send-email-iisaman@netapp.com>
	<1275970761-31806-6-git-send-email-iisaman@netapp.com>
	<1275970761-31806-7-git-send-email-iisaman@netapp.com>
	<1275970761-31806-8-git-send-email-iisaman@netapp.com>
	<1275970761-31806-9-git-send-email-iisaman@netapp.com>
	<1275970761-31806-10-git-send-email-iisaman@netapp.com>
	<1275970761-31806-11-git-send-email-iisaman@netapp.com>
	<1275970761-31806-12-git-send-email-iisaman@netapp.com>
	<1275970761-31806-13-git-send-email-iisaman@netapp.com>
	<1275970761-31806-14-git-send-email-iisaman@netapp.com>
	<1275970761-31806-15-git-send-email-iisaman@netapp.com>
	<4C0F6F11.7050602@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55305 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753574Ab0FIMIm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jun 2010 08:08:42 -0400
Received: by fxm8 with SMTP id 8so3525053fxm.19
        for <linux-nfs@vger.kernel.org>; Wed, 09 Jun 2010 05:08:41 -0700 (PDT)
In-Reply-To: <4C0F6F11.7050602@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 9, 2010 at 6:38 AM, Benny Halevy <bhalevy@panasas.com> wrot=
e:
> Fred, how does that patch interact with
> 285052f pnfs_post_submit: Restore "pnfs: pnfs_do_flush"
> and the latter patches that depend on it?
>
> Benny
>

They will have to be modified.  I'll look at that today.

=46red

> On Jun. 08, 2010, 7:19 +0300, Fred Isaman <iisaman@netapp.com> wrote:
>> Preparing for LAYUTGET invocation in nfs_write_begin to be the
>> only invocation in the write path.
>>
>> It isn't used at all yet, but it should be properly referenced/deref=
erenced
>>
>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>> ---
>> =A0fs/nfs/file.c | =A0 16 +++++++++++++---
>> =A01 files changed, 13 insertions(+), 3 deletions(-)
>>
>> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
>> index 03601d2..fde6cb5 100644
>> --- a/fs/nfs/file.c
>> +++ b/fs/nfs/file.c
>> @@ -420,6 +420,8 @@ static int nfs_write_begin(struct file *file, st=
ruct address_space *mapping,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 file->f_path.dentry->d_name.name,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 mapping->host->i_ino, len, (long long) p=
os);
>>
>> + =A0 =A0 pnfs_update_layout(mapping->host, NULL, NFS4_MAX_UINT64, 0=
, IOMODE_RW,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(struct pnfs_layout=
_segment **) fsdata);
>> =A0start:
>> =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0* Prevent starvation issues if someone is doing a con=
sistency
>> @@ -428,11 +430,13 @@ start:
>> =A0 =A0 =A0 ret =3D wait_on_bit(&NFS_I(mapping->host)->flags, NFS_IN=
O_FLUSHING,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nfs_wait_bit_killable, T=
ASK_KILLABLE);
>> =A0 =A0 =A0 if (ret)
>> - =A0 =A0 =A0 =A0 =A0 =A0 return ret;
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>>
>> =A0 =A0 =A0 page =3D grab_cache_page_write_begin(mapping, index, fla=
gs);
>> - =A0 =A0 if (!page)
>> - =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
>> + =A0 =A0 if (!page) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENOMEM;
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 }
>> =A0 =A0 =A0 *pagep =3D page;
>>
>> =A0 =A0 =A0 ret =3D nfs_flush_incompatible(file, page);
>> @@ -447,6 +451,11 @@ start:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!ret)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto start;
>> =A0 =A0 =A0 }
>> + out:
>> + =A0 =A0 if (ret) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 put_lseg(*fsdata);
>> + =A0 =A0 =A0 =A0 =A0 =A0 *fsdata =3D NULL;
>> + =A0 =A0 }
>> =A0 =A0 =A0 return ret;
>> =A0}
>>
>> @@ -486,6 +495,7 @@ static int nfs_write_end(struct file *file, stru=
ct address_space *mapping,
>>
>> =A0 =A0 =A0 unlock_page(page);
>> =A0 =A0 =A0 page_cache_release(page);
>> + =A0 =A0 put_lseg(fsdata);
>>
>> =A0 =A0 =A0 if (status < 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return status;
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
