From: Fred Isaman <iisaman@umich.edu>
Subject: Re: [PATCH 3/8] SQUASHME pnfs-submit: tell commit to use the MDS
Date: Wed, 23 Jun 2010 09:34:01 -0400
Message-ID: <AANLkTimh37nfPbw5CZmBJv1XhIqrlogV_0nUVSDaxZJ3@mail.gmail.com>
References: <1277243798-8181-1-git-send-email-andros@netapp.com>
	<1277243798-8181-2-git-send-email-andros@netapp.com>
	<1277243798-8181-3-git-send-email-andros@netapp.com>
	<1277243798-8181-4-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44289 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751351Ab0FWNeE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jun 2010 09:34:04 -0400
Received: by fxm10 with SMTP id 10so3091734fxm.19
        for <linux-nfs@vger.kernel.org>; Wed, 23 Jun 2010 06:34:02 -0700 (PDT)
In-Reply-To: <1277243798-8181-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 22, 2010 at 5:56 PM,  <andros@netapp.com> wrote:
> From: Andy Adamson <andros@netapp.com>
>
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
> =A0fs/nfs/pnfs.c | =A0 =A01 +
> =A01 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 9a295cf..c1a8066 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1454,6 +1454,7 @@ pnfs_writepages(struct nfs_write_data *wdata, i=
nt how)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0wdata);
>
> =A0 =A0 =A0 =A0if (trypnfs =3D=3D PNFS_NOT_ATTEMPTED) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 wdata->req->wb_lseg =3D NULL;

This is wrong.  It will be taken care of by
_pnfs_clear_lseg_from_pages called by pnfs_try_to_write_data.

=46red

> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0wdata->pdata.lseg =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0put_lseg(lseg);
> =A0 =A0 =A0 =A0}
> --
> 1.6.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
