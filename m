Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f181.google.com ([209.85.212.181]:54182 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754594Ab3LPPoH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Dec 2013 10:44:07 -0500
Received: by mail-wi0-f181.google.com with SMTP id hq4so2296389wib.8
        for <linux-nfs@vger.kernel.org>; Mon, 16 Dec 2013 07:44:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1387122710-23603-1-git-send-email-bhalevy@primarydata.com>
References: <52ADCFC2.7060504@gmail.com> <1387122710-23603-1-git-send-email-bhalevy@primarydata.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Mon, 16 Dec 2013 23:43:46 +0800
Message-ID: <CA+a=Yy6PeAZ_3Sbb4aHVMHTEOevkGzMmevTbKqxZ8K0dVpqFRg@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] nfsd4: break from inner lookup loop in
 nfsd4_release_lockowner on first match
To: Benny Halevy <bhalevy@primarydata.com>
Cc: bfields@redhat.com, linuxnfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Benny,

On Sun, Dec 15, 2013 at 11:51 PM, Benny Halevy <bhalevy@primarydata.com> wrote:
> Otherwise the lockowner may by added to "matches" more than once.
>
> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 17 +++++++++++------
>  1 file changed, 11 insertions(+), 6 deletions(-)
>
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 0874998..b04f765 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4192,6 +4192,7 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
>         /* It is the openowner seqid that will be incremented in encode in the
>          * case of new lockowners; so increment the lock seqid manually: */
>         lo->lo_owner.so_seqid = lock->lk_new_lock_seqid + 1;
> +       INIT_LIST_HEAD(&lo->lo_list);
>         hash_lockowner(lo, strhashval, clp, open_stp);
>         return lo;
>  }
> @@ -4646,7 +4647,6 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
>         if (status)
>                 goto out;
>
> -       status = nfserr_locks_held;
>         INIT_LIST_HEAD(&matches);
>
>         list_for_each_entry(sop, &nn->ownerstr_hashtbl[hashval], so_strhash) {
> @@ -4654,25 +4654,30 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
>                         continue;
>                 if (!same_owner_str(sop, owner, clid))
>                         continue;
> +               lo = lockowner(sop);
>                 list_for_each_entry(stp, &sop->so_stateids,
>                                 st_perstateowner) {
> -                       lo = lockowner(sop);
> -                       if (check_for_locks(stp->st_file, lo))
> -                               goto out;
> +                       if (check_for_locks(stp->st_file, lo)) {
> +                               status = nfserr_locks_held;
> +                               goto locks_held;
> +                       }
>                         list_add(&lo->lo_list, &matches);
> +                       break;
If so_stateids is empty, lockowner is skipped. It was skipped before
the patch as well but I guess that need to be fixed, right?

Thanks,
Tao
