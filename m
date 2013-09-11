Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:37017 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752813Ab3IKNCJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Sep 2013 09:02:09 -0400
Received: by mail-wg0-f44.google.com with SMTP id b12so6861191wgh.35
        for <linux-nfs@vger.kernel.org>; Wed, 11 Sep 2013 06:02:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1378853073-13256-4-git-send-email-dros@netapp.com>
References: <1378853073-13256-1-git-send-email-dros@netapp.com> <1378853073-13256-4-git-send-email-dros@netapp.com>
From: Anna Schumaker <schumaker.anna@gmail.com>
Date: Wed, 11 Sep 2013 09:01:48 -0400
Message-ID: <CAFX2Jf=0v0=uKyWPM+fU3W_FQGvP6xAVJMQn9xQdPtaeDhbYwA@mail.gmail.com>
Subject: Re: [PATCH 3/4] NFSv4.1: sp4_mach_cred: no need to ref count creds
To: Weston Andros Adamson <dros@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Do we need to do a get_rpccred() after looking up the machine cred in
nfs_alloc_client()?  Where does our guaranteed reference come from?

On Tue, Sep 10, 2013 at 6:44 PM, Weston Andros Adamson <dros@netapp.com> wrote:
> The cl_machine_cred doesn't need to be reference counted here -
> a reference is held is for the lifetime of the struct nfs_client.
> Also, no need to put_rpccred the rpc_message.rpc_cred.
>
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
>  fs/nfs/nfs4_fs.h | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index f520a11..07a8aa9 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -279,10 +279,10 @@ _nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_mode,
>         if (test_bit(sp4_mode, &clp->cl_sp4_flags)) {
>                 spin_lock(&clp->cl_lock);
>                 if (clp->cl_machine_cred != NULL)
> -                       newcred = get_rpccred(clp->cl_machine_cred);
> +                       /* don't call get_rpccred on the machine cred -
> +                        * a reference will be held for life of clp */
> +                       newcred = clp->cl_machine_cred;
>                 spin_unlock(&clp->cl_lock);
> -               if (msg->rpc_cred)
> -                       put_rpccred(msg->rpc_cred);
>                 msg->rpc_cred = newcred;
>
>                 flavor = clp->cl_rpcclient->cl_auth->au_flavor;
> --
> 1.7.12.4 (Apple Git-37)
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
