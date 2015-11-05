Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:33735 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752296AbbKEWbj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Nov 2015 17:31:39 -0500
Received: by obbww6 with SMTP id ww6so52173348obb.0
        for <linux-nfs@vger.kernel.org>; Thu, 05 Nov 2015 14:31:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1446674837-4980-1-git-send-email-aweits@rit.edu>
References: <1446674837-4980-1-git-send-email-aweits@rit.edu>
Date: Thu, 5 Nov 2015 17:31:37 -0500
Message-ID: <CAHQdGtShZ=6J9h1hW00zPZ+TWzAYmfSiET-1mEdv1-H=JGEgcA@mail.gmail.com>
Subject: Re: [PATCH] nfsd: fix nfsd4_delegreturn to return correct error codes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Andrew Elble <aweits@rit.edu>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Bruce James Fields <bfields@fieldses.org>,
        Jeffrey Layton <jlayton@poochiereds.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 4, 2015 at 5:07 PM, Andrew Elble <aweits@rit.edu> wrote:
> When delegations are revoked:
>
> In the NFSv4 case, NFS4ERR_BAD_STATEID
> In the NFSv4.1 case, NFS4ERR_DELEG_REVOKED
>
> Signed-off-by: Andrew Elble <aweits@rit.edu>
> ---
>  fs/nfsd/nfs4state.c | 12 +++++++++---
>  1 file changed, 9 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 66df2903ab8e..0f0634ca4158 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -5147,15 +5147,21 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>         if ((status = fh_verify(rqstp, &cstate->current_fh, S_IFREG, 0)))
>                 return status;
>
> -       status = nfsd4_lookup_stateid(cstate, stateid, NFS4_DELEG_STID, &s, nn);
> +       status = nfsd4_lookup_stateid(cstate, stateid,
> +                               NFS4_DELEG_STID|NFS4_REVOKED_DELEG_STID,
> +                               &s, nn);
>         if (status)
>                 goto out;
>         dp = delegstateid(s);
>         status = check_stateid_generation(stateid, &dp->dl_stid.sc_stateid, nfsd4_has_session(cstate));
>         if (status)
>                 goto put_stateid;
> -
> -       destroy_delegation(dp);
> +       if (dp->dl_stid.sc_type == NFS4_DELEG_STID)
> +               destroy_delegation(dp);
> +       if (dp->dl_stid.sc_type == NFS4_REVOKED_DELEG_STID)
> +               status = nfserr_bad_stateid;
> +               if (cstate->minorversion)
> +                       status = nfserr_deleg_revoked;

Umm... If the client is sending delegreturn, then why not destroy the
delegation? What is the point of forcing the client to send
FREE_STATEID, when it is telling you that it is no longer caching any
locks or associated state and is no longer interested in keeping the
delegation?
