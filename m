Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:50758 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061Ab2BOPPl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 10:15:41 -0500
Received: by werb13 with SMTP id b13so685491wer.19
        for <linux-nfs@vger.kernel.org>; Wed, 15 Feb 2012 07:15:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1329256108-1535-1-git-send-email-gusev.vitaliy@nexenta.com>
References: <1329256108-1535-1-git-send-email-gusev.vitaliy@nexenta.com>
Date: Wed, 15 Feb 2012 10:15:40 -0500
Message-ID: <CAHVgHyUhaJnzNaoh_tYaAvXDwHTWCa4La1hLt_S3WYdt3BpG_w@mail.gmail.com>
Subject: Re: [PATCH] nfs41: Initialize slot->seq_nr at nfs4_init_slot_table()
From: Andy Adamson <androsadamson@gmail.com>
To: Vitaliy Gusev <gusev.vitaliy@gmail.com>
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org,
        Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This looks correct to me. This same bug - where the ivalue is ignored,
is in v2.6.39 and  v3.2.

-->Andy

On Tue, Feb 14, 2012 at 4:48 PM, Vitaliy Gusev <gusev.vitaliy@gmail.com> wrote:
> Uninitialized seq_nr causes sending first SESSION request
> with sa_sequenceid = 0.
>
> Signed-off-by: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
> ---
>  fs/nfs/nfs4proc.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index f0c849c..711a812 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5067,6 +5067,7 @@ static int nfs4_init_slot_table(struct nfs4_slot_table *tbl,
>                int max_slots, int ivalue)
>  {
>        struct nfs4_slot *slot;
> +       int i;
>        int ret = -ENOMEM;
>
>        BUG_ON(max_slots > NFS4_MAX_SLOT_TABLE);
> @@ -5082,6 +5083,8 @@ static int nfs4_init_slot_table(struct nfs4_slot_table *tbl,
>        tbl->max_slots = max_slots;
>        tbl->slots = slot;
>        tbl->highest_used_slotid = -1;  /* no slot is currently used */
> +       for (i = 0; i < tbl->max_slots; ++i)
> +               tbl->slots[i].seq_nr = ivalue;
>        spin_unlock(&tbl->slot_tbl_lock);
>        dprintk("%s: tbl=%p slots=%p max_slots=%d\n", __func__,
>                tbl, tbl->slots, tbl->max_slots);
> --
> 1.7.5.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
