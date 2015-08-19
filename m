Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:36385 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751056AbbHSNBW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Aug 2015 09:01:22 -0400
Received: by igxp17 with SMTP id p17so104546840igx.1
        for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2015 06:01:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1439961497-22176-1-git-send-email-trond.myklebust@primarydata.com>
References: <1439961497-22176-1-git-send-email-trond.myklebust@primarydata.com>
Date: Wed, 19 Aug 2015 09:01:21 -0400
Message-ID: <CAN-5tyFZPkK9F1HzRup1xNC841YJc3m5Zt-S4P6z1z+KPoH0HQ@mail.gmail.com>
Subject: Re: [PATCH] Revert "NFSv4: Remove incorrect check in can_open_delegated()"
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Alternatively, I think the following would fix the problem too. If
this open for CLAIM_PREVIOUS, we don't need to check if it can be open
delegated.

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3acb1eb..b53cb10 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1866,7 +1866,8 @@ static void nfs4_open_prepare(struct rpc_task *task, void
                        goto out_no_action;
                rcu_read_lock();
                delegation = rcu_dereference(NFS_I(data->state->inode)->delegati
-               if (data->o_arg.claim != NFS4_OPEN_CLAIM_DELEGATE_CUR &&
+               if (data->o_arg.claim != NFS4_OPEN_CLAIM_PREVIOUS &&
+                   data->o_arg.claim != NFS4_OPEN_CLAIM_DELEGATE_CUR &&
                    data->o_arg.claim != NFS4_OPEN_CLAIM_DELEG_CUR_FH &&
                    can_open_delegated(delegation, data->o_arg.fmode))
                        goto unlock_no_action;

On Wed, Aug 19, 2015 at 1:18 AM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> This reverts commit 4e379d36c050b0117b5d10048be63a44f5036115.
>
> This commit opens up a race between the recovery code and the open code.
>
> Reported-by: Olga Kornievskaia <aglo@umich.edu>
> Cc: stable@vger.kernel # v4.0+
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs4proc.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 9e9f7816cf24..95c5e8d39bef 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -1156,6 +1156,8 @@ static int can_open_delegated(struct nfs_delegation *delegation, fmode_t fmode)
>                 return 0;
>         if ((delegation->type & fmode) != fmode)
>                 return 0;
> +       if (test_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags))
> +               return 0;
>         if (test_bit(NFS_DELEGATION_RETURNING, &delegation->flags))
>                 return 0;
>         nfs_mark_delegation_referenced(delegation);
> --
> 2.4.3
>
