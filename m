Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f180.google.com ([209.85.220.180]:37822 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751284AbaIXSFz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Sep 2014 14:05:55 -0400
Received: by mail-vc0-f180.google.com with SMTP id hq11so6930649vcb.39
        for <linux-nfs@vger.kernel.org>; Wed, 24 Sep 2014 11:05:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1411574911-19269-1-git-send-email-kolga@netapp.com>
References: <1411574911-19269-1-git-send-email-kolga@netapp.com>
Date: Wed, 24 Sep 2014 14:05:53 -0400
Message-ID: <CAHQdGtTfUYoU+0LRqS6eao5Z-uVqHoGkXO9HcU+Wmo=vZobvew@mail.gmail.com>
Subject: Re: [PATCH 1/1] Fixing lease renewal
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga,

On Wed, Sep 24, 2014 at 12:08 PM, Olga Kornievskaia <kolga@netapp.com> wrote:
> Commit c9fdeb28 removed a 'continue' after checking if the lease needs
> to be renewed. However, if client hasn't moved, the code falls down to
> starting reboot recovery erroneously (ie., sends open reclaim and gets
> back stale_clientid error) before recovering from getting stale_clientid
> on the renew operation.
>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/nfs4state.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 22fe351..4616598 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -2340,11 +2340,13 @@ static void nfs4_state_manager(struct nfs_client *clp)
>                         continue;
>                 }
>
> -               if (test_and_clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state)) {
> +               if (!test_bit(NFS4CLNT_MOVED, &clp->cl_state) &&
> +                    test_and_clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state)) {
>                         section = "check lease";
>                         status = nfs4_check_lease(clp);
>                         if (status < 0)
>                                 goto out_error;
> +                       continue;
>                 }
>
>                 if (test_and_clear_bit(NFS4CLNT_MOVED, &clp->cl_state)) {
> --
> 1.8.5.2 (Apple Git-48)
>

I think you misunderstood me. I was proposing that we move the entire
code section that currently reads

                if (test_and_clear_bit(NFS4CLNT_MOVED, &clp->cl_state)) {
                        section = "migration";
                        status = nfs4_handle_migration(clp);
                        if (status < 0)
                                goto out_error;
                }

so that it occurs before the section

                if (test_and_clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state)) {
                        section = "check lease";
                        status = nfs4_check_lease(clp);
                        if (status < 0)
                                goto out_error;
+                      continue;
                }

That way we only need to test once for NFS4CLNT_MOVED.

Cheers
  Trond
-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
