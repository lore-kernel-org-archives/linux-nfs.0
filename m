Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f176.google.com ([209.85.220.176]:39390 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012AbaIXWYG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Sep 2014 18:24:06 -0400
Received: by mail-vc0-f176.google.com with SMTP id la4so5396699vcb.7
        for <linux-nfs@vger.kernel.org>; Wed, 24 Sep 2014 15:24:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1411596688-21347-1-git-send-email-kolga@netapp.com>
References: <1411596688-21347-1-git-send-email-kolga@netapp.com>
Date: Wed, 24 Sep 2014 18:24:05 -0400
Message-ID: <CAHQdGtRtm_9BSjegZfsD+1vrJ1m8jc8xvzfmwKW_=2TEjX+4mg@mail.gmail.com>
Subject: Re: [PATCH 1/1] Fixing lease renewal
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 24, 2014 at 6:11 PM, Olga Kornievskaia <kolga@netapp.com> wrote:
> Commit c9fdeb28 removed a 'continue' after checking if the lease needs
> to be renewed. However, if client hasn't moved, the code falls down to
> starting reboot recovery erroneously (ie., sends open reclaim and gets
> back stale_clientid error) before recovering from getting stale_clientid
> on the renew operation.
>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/nfs4state.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 22fe351..6678769 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -2345,6 +2345,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
>                         status = nfs4_check_lease(clp);
>                         if (status < 0)
>                                 goto out_error;
> +                       continue;
>                 }
>
>                 if (test_and_clear_bit(NFS4CLNT_MOVED, &clp->cl_state)) {
> --
> 1.8.5.2 (Apple Git-48)

Thanks Olga! Will apply.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
