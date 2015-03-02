Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f175.google.com ([209.85.220.175]:62686 "EHLO
	mail-vc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753784AbbCBWa0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Mar 2015 17:30:26 -0500
Received: by mail-vc0-f175.google.com with SMTP id hq12so12083037vcb.6
        for <linux-nfs@vger.kernel.org>; Mon, 02 Mar 2015 14:30:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1425332769-7047-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1425332769-7047-1-git-send-email-Anna.Schumaker@Netapp.com>
Date: Mon, 2 Mar 2015 17:30:25 -0500
Message-ID: <CAHQdGtTuvQ_yQY05dxK3J8UEpLmfa2pbge-AhtECsNHJ+ETApQ@mail.gmail.com>
Subject: Re: [PATCH] NFS: Fix stateid used for NFS v4 closes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Kornievskaia, Olga" <Olga.Kornievskaia@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 2, 2015 at 4:46 PM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> After 566fcec60 the client uses the "current stateid" from the
> nfs4_state structure to close a file.  This could potentially contain a
> delegation stateid, which is disallowed by the protocol and causes
> servers to return NFS4ERR_BAD_STATEID.  This patch restores the
> (correct) behavior of sending the open stateid to close a file.
>
> Reported-by: Olga Kornievskaia <kolga@netapp.com>
> Fixes: 566fcec60 (NFSv4: Fix an atomicity problem in CLOSE)
> Signed-off-by: Anna Schumaker <Anna.Schumaker@netapp.com>
> ---
>  fs/nfs/nfs4proc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index a211daf..7b409ff 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2691,7 +2691,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
>         is_rdwr = test_bit(NFS_O_RDWR_STATE, &state->flags);
>         is_rdonly = test_bit(NFS_O_RDONLY_STATE, &state->flags);
>         is_wronly = test_bit(NFS_O_WRONLY_STATE, &state->flags);
> -       nfs4_stateid_copy(&calldata->arg.stateid, &state->stateid);
> +       nfs4_stateid_copy(&calldata->arg.stateid, &state->open_stateid);
>         /* Calculate the change in open mode */
>         calldata->arg.fmode = 0;
>         if (state->n_rdwr == 0) {

Can you please also fix up nfs4_close_done().

Thanks!
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
