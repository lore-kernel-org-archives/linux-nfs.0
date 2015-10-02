Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:34810 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010AbbJBTxf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Oct 2015 15:53:35 -0400
Received: by obbda8 with SMTP id da8so90147018obb.1
        for <linux-nfs@vger.kernel.org>; Fri, 02 Oct 2015 12:53:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1443806077-27148-1-git-send-email-jeff.layton@primarydata.com>
References: <1443784739-8565-1-git-send-email-jeff.layton@primarydata.com>
	<1443806077-27148-1-git-send-email-jeff.layton@primarydata.com>
Date: Fri, 2 Oct 2015 15:53:35 -0400
Message-ID: <CAHQdGtQ-8oA-FxMx9BwdzgNgp0Et5fCTjiqT8xgfk6is7meApw@mail.gmail.com>
Subject: Re: [PATCH v2] nfs4: reset states to use open_stateid when returning
 delegation voluntarily
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 2, 2015 at 1:14 PM, Jeff Layton <jlayton@poochiereds.net> wrote:
> When the client goes to return a delegation, it should always update any
> nfs4_state currently set up to use that delegation stateid to instead
> use the open stateid. It already does do this in some cases,
> particularly in the state recovery code, but not currently when the
> delegation is voluntarily returned (e.g. in advance of a RENAME).  This
> causes the client to try to continue using the delegation stateid after
> the DELEGRETURN, e.g. in LAYOUTGET.
>
> Set the nfs4_state back to using the open stateid in
> nfs4_open_delegation_recall, just before clearing the
> NFS_DELEGATED_STATE bit.
>
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
>  fs/nfs/nfs4proc.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index f93b9cdb4934..246753e1d19d 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -1771,6 +1771,9 @@ int nfs4_open_delegation_recall(struct nfs_open_context *ctx,
>         if (IS_ERR(opendata))
>                 return PTR_ERR(opendata);
>         nfs4_stateid_copy(&opendata->o_arg.u.delegation, stateid);
> +       write_seqlock(&state->seqlock);
> +       nfs4_stateid_copy(&state->stateid, &state->open_stateid);
> +       write_sequnlock(&state->seqlock);
>         clear_bit(NFS_DELEGATED_STATE, &state->flags);
>         switch (type & (FMODE_READ|FMODE_WRITE)) {
>         case FMODE_READ|FMODE_WRITE:
> --

Looks good. Thanks!
