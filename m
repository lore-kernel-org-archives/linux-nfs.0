Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f177.google.com ([209.85.220.177]:60521 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751735AbaIWVvM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Sep 2014 17:51:12 -0400
Received: by mail-vc0-f177.google.com with SMTP id im17so5702355vcb.22
        for <linux-nfs@vger.kernel.org>; Tue, 23 Sep 2014 14:51:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyGn0mLHrk+C+a9CU22YD3MXJm5j3k=2ZrGz5XnyhT-+Uw@mail.gmail.com>
References: <CAN-5tyGn0mLHrk+C+a9CU22YD3MXJm5j3k=2ZrGz5XnyhT-+Uw@mail.gmail.com>
Date: Tue, 23 Sep 2014 17:51:11 -0400
Message-ID: <CAHQdGtRu2xb=gv7GGgD2oL_T9Y5McYKcrWOCg0cTOQyAEFwg6g@mail.gmail.com>
Subject: Re: [PATCH 1/1] Fixing lease renewal
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga,

On Tue, Sep 23, 2014 at 5:36 PM, Olga Kornievskaia
<olga.kornievskaia@gmail.com> wrote:
> Commit c9fdeb28 removed a 'continue' after checking if the lease needs
> to be renewed. However, if client hasn't moved, the code falls down to
> starting reboot recovery erroneously (ie., sends open reclaim and gets
> back stale_clientid error) before recovering from getting stale_clientid
> on the renew operation.
>
> ---
>  fs/nfs/nfs4state.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 22fe351..790aed3 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -2345,6 +2345,8 @@ static void nfs4_state_manager(struct nfs_client *clp)
>                         status = nfs4_check_lease(clp);
>                         if (status < 0)
>                                 goto out_error;
> +                       if (!test_bit(NFS4CLNT_MOVED, &clp->cl_state))
> +                               continue;
>                 }
>
>                 if (test_and_clear_bit(NFS4CLNT_MOVED, &clp->cl_state)) {
>

What say we just move the "if (test_and_clear_bit(NFS4CLNT_MOVED,
&clp->cl_state)) { ... }" section so that it comes immediately before
the NFS4CLNT_CHECK_LEASE test?
That way we can just reinstate the original 'continue' without the
extra test above, and ensure that the NFS4CLNT_MOVED is always handled
before trying the check lease.

Also, please do remember to add a "Signed-off-by:" line when submitting patches.

Thanks
  Trond
-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
