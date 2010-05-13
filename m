From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: SQUASHME: missing from FIXME: async layout return
Date: Thu, 13 May 2010 10:19:40 -0400
Message-ID: <AANLkTind3eXmuPw5HrKqB6bHJSSXFL3g2cDSEyyYc1n8@mail.gmail.com>
References: <4BEBBAE9.8090605@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:43614 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756570Ab0EMOTn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 May 2010 10:19:43 -0400
Received: by gyg13 with SMTP id 13so575808gyg.19
        for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 07:19:42 -0700 (PDT)
In-Reply-To: <4BEBBAE9.8090605@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 13, 2010 at 4:40 AM, Boaz Harrosh <bharrosh@panasas.com> wr=
ote:
> I've tested the patch:
> =A0 =A0 =A0 =A0FIXME: async layout return
>
> And there is a missing small hunk
>
> I have tested with this patch and it is a very good patch
> that should also go into 2.6.33. It is necessary in the rare
> case when one inode have more then one open_context.

Do you mean more than one open context per open owner?

-->Andy

>
> (For some reason I see that happening much more in 2.6.34
> =A0I don't understand why)
>
> Boaz
> ---
> git diff --stat -p -M
> =A0fs/nfs/nfs4state.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 15c8bc8..6dbe893 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -590,7 +590,7 @@ static void __nfs4_close(struct path *path, struc=
t nfs4_state *state, fmode_t fm
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct nfs_inode *nfsi =3D NFS_I(state=
->inode);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (nfsi->layoutcommit_ctx)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pnfs_layoutcommit_inode=
(state->inode, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pnfs_layoutcommit_inode=
(state->inode, wait);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (has_layout(nfsi) && nfsi->layout.r=
oc_iomode) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct nfs4_pnfs_layou=
t_segment range;
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
