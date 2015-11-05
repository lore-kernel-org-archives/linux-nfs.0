Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:35611 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161299AbbKEO1I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Nov 2015 09:27:08 -0500
Received: by oifu63 with SMTP id u63so47870516oif.2
        for <linux-nfs@vger.kernel.org>; Thu, 05 Nov 2015 06:27:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1446684228-37765-1-git-send-email-aweits@rit.edu>
References: <1446684228-37765-1-git-send-email-aweits@rit.edu>
Date: Thu, 5 Nov 2015 09:27:06 -0500
Message-ID: <CAHQdGtQmYV9Aq+=CivbmPTjHMZVhd8BznpMsmXXD=cZwzOO0Uw@mail.gmail.com>
Subject: Re: [PATCH RFC v3] nfs: nfs_do_return_delegation() needs to send FREE_STATEID
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Andrew Elble <aweits@rit.edu>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Andrew,

On Wed, Nov 4, 2015 at 7:43 PM, Andrew Elble <aweits@rit.edu> wrote:
> In the NFS4.1 case, revoked delegations need to be processed via
> FREE_STATEID, not simply forgotten.
>
> Fixes: 869f9dfa4d6d ("NFSv4: Fix races between nfs_remove_bad_delegation() and delegation return")
> Signed-off-by: Andrew Elble <aweits@rit.edu>
> ---
>  fs/nfs/delegation.c |  6 ++++++
>  fs/nfs/nfs4_fs.h    |  2 ++
>  fs/nfs/nfs4proc.c   | 18 ++++++++++--------
>  3 files changed, 18 insertions(+), 8 deletions(-)
>
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index 5166adcfc0fb..dc971adb7af9 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -205,6 +205,12 @@ static int nfs_do_return_delegation(struct inode *inode, struct nfs_delegation *
>                                 delegation->cred,
>                                 &delegation->stateid,
>                                 issync);
> +#if defined(CONFIG_NFS_V4_1)
> +       else if (NFS_SERVER(inode)->nfs_client->cl_minorversion)
> +               res = nfs41_free_stateid(NFS_SERVER(inode),
> +                                       &delegation->stateid,
> +                                       delegation->cred, issync);
> +#endif /* CONFIG_NFS_V4_1 */
>         nfs_free_delegation(delegation);
>         return res;

If the server is revoking a delegation, then presumably it will also
set one or more of the SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED,
SEQ4_STATUS_ADMIN_STATE_REVOKED, SEQ4_STATUS_RECALLABLE_STATE_REVOKED,
which should start up a state manager thread to do the
test_stateid/free_stateid dance.

So instead of adding the free stateid call above, why can't we just
punt the freeing of the delegation to the state manager?

Cheers
  Trond
