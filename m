Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f47.google.com ([209.85.219.47]:63850 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753817Ab3AGNUG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jan 2013 08:20:06 -0500
Received: by mail-oa0-f47.google.com with SMTP id h1so17511110oag.20
        for <linux-nfs@vger.kernel.org>; Mon, 07 Jan 2013 05:20:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1357296223-5796-1-git-send-email-ycnian@gmail.com>
References: <1357296223-5796-1-git-send-email-ycnian@gmail.com>
From: Benny Halevy <bhalevy@tonian.com>
Date: Mon, 7 Jan 2013 15:19:44 +0200
Message-ID: <CAEMWVhv9_hC9zbacdXoM-9m00dhtk-PJ-OqXnwgbh4YMqAm4Ow@mail.gmail.com>
Subject: Re: [PATCH] pnfsd: Correct the buffer size of ds_list in dlm_device_entry
To: ycnian@gmail.com
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 4, 2013 at 12:43 PM,  <ycnian@gmail.com> wrote:
> From: Yanchuan Nian <ycnian@gmail.com>
>
> In nfsd4_set_pnfs_dlm_device(), if there is a device with the same disk_name as
> the new device, pnfsd will clear the memory of ds_list, and then update it with
> ds list from the new device. The size of ds_list in struct dlm_device_entry is
> NFSD_DLM_DS_LIST_MAX, but not DISK_NAME_LEN.
>
> Signed-off-by: Yanchuan Nian <ycnian@gmail.com>

Thanks. committed

Benny

> ---
>  fs/nfsd/nfs4pnfsdlm.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
> index e8423e0..c138d41 100644
> --- a/fs/nfsd/nfs4pnfsdlm.c
> +++ b/fs/nfsd/nfs4pnfsdlm.c
> @@ -187,7 +187,7 @@ nfsd4_set_pnfs_dlm_device(char *pnfs_dlm_device, int len)
>                 dprintk("%s pnfs_dlm_device %s:%s already in cache "
>                         " replace ds_list with new ds_list %s\n", __func__,
>                         found->disk_name, found->ds_list, new->ds_list);
> -               memset(found->ds_list, 0, DISK_NAME_LEN);
> +               memset(found->ds_list, 0, NFSD_DLM_DS_LIST_MAX);
>                 memcpy(found->ds_list, new->ds_list, strlen(new->ds_list));
>                 found->num_ds = new->num_ds;
>                 kfree(new);
> --
> 1.7.4.4
>
