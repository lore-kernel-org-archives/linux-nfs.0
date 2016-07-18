Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35283 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751205AbcGRNhp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Jul 2016 09:37:45 -0400
Received: by mail-io0-f195.google.com with SMTP id q83so11003804iod.2
        for <linux-nfs@vger.kernel.org>; Mon, 18 Jul 2016 06:37:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1466623706-41389-1-git-send-email-kolga@netapp.com>
References: <1466623706-41389-1-git-send-email-kolga@netapp.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 18 Jul 2016 09:37:38 -0400
Message-ID: <CAN-5tyEbxMjCV7Rc5dDuOSBcQL_G+67SinHYtyGpad+0zy7=wg@mail.gmail.com>
Subject: Re: [PATCH 1/1] Fix SETATTR/DELEGRETURN race
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@primarydata.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 22, 2016 at 3:28 PM, Olga Kornievskaia <kolga@netapp.com> wrote:
> Hi Trond,
>
> In this version of the patch, we won't be retrying if
> BAD_STATEID was for zero stateid. If open stateid was
> used then the normal error handling kicks off recovery
> and retries. So I think this is the only case left.
>
> It's insufficient to only retry SETATTR if we have a delegation
> and got a bad_stateid-type error. A DELEGRETURN could be sent
> after SETATTR is sent and before reply comes back and thus no
> delegation would be found and SETATTR not retried with zero
> stateid and instead fail with EIO. Check if we sent SETATTR
> with a delegation stateid, received an error and no longer
> have a delegation, then retry.
>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/nfs4proc.c | 12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 406dd3e..63f7fd3 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2696,7 +2696,7 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
>         struct rpc_cred *delegation_cred = NULL;
>         unsigned long timestamp = jiffies;
>         fmode_t fmode;
> -       bool truncate;
> +       bool truncate, use_delegation = false;
>         int status;
>
>         arg.bitmask = nfs4_bitmask(server, ilabel);
> @@ -2711,6 +2711,7 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
>
>         if (nfs4_copy_delegation_stateid(inode, fmode, &arg.stateid, &delegation_cred)) {
>                 /* Use that stateid */
> +               use_delegation = true;
>         } else if (truncate && state != NULL) {
>                 struct nfs_lockowner lockowner = {
>                         .l_owner = current->files,
> @@ -2732,6 +2733,13 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
>         if (status == 0 && state != NULL)
>                 renew_lease(server, timestamp);
>         trace_nfs4_setattr(inode, &arg.stateid, status);
> +       switch (status) {
> +       case -NFS4ERR_DELEG_REVOKED:
> +       case -NFS4ERR_ADMIN_REVOKED:
> +       case -NFS4ERR_BAD_STATEID:
> +               if (use_delegation && !nfs4_have_delegation(inode, fmode))
> +                       status = -EAGAIN;
> +       }
>         return status;
>  }
>
> @@ -2765,6 +2773,8 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
>                         }
>                 }
>                 err = nfs4_handle_exception(server, err, &exception);
> +               if (err == -EAGAIN)
> +                       exception.retry = 1;
>         } while (exception.retry);
>  out:
>         return err;

Any comments on this patch?
