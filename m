Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:1241 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750802AbaIXNq5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Sep 2014 09:46:57 -0400
Message-ID: <5422CB4E.1070000@Netapp.com>
Date: Wed, 24 Sep 2014 09:46:54 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Olga Kornievskaia <aglo@umich.edu>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] Fixing lease renewal
References: <CAN-5tyFQihuK22n_bzsO0LtqQBM+KW6vELt7H_DPEF0RFdoDQQ@mail.gmail.com>
In-Reply-To: <CAN-5tyFQihuK22n_bzsO0LtqQBM+KW6vELt7H_DPEF0RFdoDQQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Olga,

Your patch is using spaces instead of tabs, so it won't apply to the existing code.  Did you use `git format-patch` to generate it?

Anna

On 09/24/2014 09:11 AM, Olga Kornievskaia wrote:
> Commit c9fdeb28 removed a 'continue' after checking if the lease needs
> to be renewed. However, if client hasn't moved, the code falls down to
> starting reboot recovery erroneously (ie., sends open reclaim and gets
> back stale_clientid error) before recovering from getting stale_clientid
> on the renew operation.
>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/nfs4state.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
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

