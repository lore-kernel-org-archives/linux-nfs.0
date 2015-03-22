Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yh0-f41.google.com ([209.85.213.41]:34035 "EHLO
	mail-yh0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742AbbCVTOw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Mar 2015 15:14:52 -0400
Received: by yhch68 with SMTP id h68so59837041yhc.1
        for <linux-nfs@vger.kernel.org>; Sun, 22 Mar 2015 12:14:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <550BDAE0.2070409@gmail.com>
References: <550BDAE0.2070409@gmail.com>
Date: Sun, 22 Mar 2015 15:14:51 -0400
Message-ID: <CAHQdGtSJ8GtC5DL2wh5BjyBBEEV_53pjvX-_CD4vCGkzHWY=2g@mail.gmail.com>
Subject: Re: [PATCH] NFS4: Retry destroy session when getting -NFS4ERR_DELAY
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 20, 2015 at 4:31 AM, Kinglong Mee <kinglongmee@gmail.com> wrote:
> When umounting a client, it cost near ten seconds.
> Dump the request, got
>    client                     server
> DELEGRETURN              ---->
> DESTROY_SESSION          ---->
>           NFS4ERR_DELAY  <----  DESTROY_SESSION reply
>                 NFS4_OK  <----  DELEGRETURN reply
> DESTROY_CLIENTID          ---->
>   NFS4ERR_CLIENTID_BUSY  <----  DESTROY_CLIENTID reply
> DESTROY_CLIENTID          ---->
>   NFS4ERR_CLIENTID_BUSY  <----  DESTROY_CLIENTID reply
>          ... ....                  ... ...
> There are ten DESTROY_CLIENTID requests.
> This patch retry DESTROY_SESSION when getting NFS4ERR_DELAY,
> try the best to destroy the session as destroy clientid.
>
> With this patch, only cost more than 1 seconds, as,
>    client                     server
> DELEGRETURN          ---->
> DESTROY_SESSION      ---->
>      NFS4ERR_DELAY  <----  DESTROY_SESSION reply
>            NFS4_OK  <----  DELEGRETURN reply
> DESTROY_SESSION      ---->
>            NFS4_OK  <----  DESTROY_SESSION reply
> DESTROY_CLIENTID     ---->
>            NFS4_OK  <----  DESTROY_CLIENTID reply
>
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfs/nfs4proc.c | 26 +++++++++++++++++++++-----
>  1 file changed, 21 insertions(+), 5 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 627f37c..2631dc2 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -7320,7 +7320,7 @@ out:
>   * Issue the over-the-wire RPC DESTROY_SESSION.
>   * The caller must serialize access to this routine.
>   */
> -int nfs4_proc_destroy_session(struct nfs4_session *session,
> +static int _nfs4_proc_destroy_session(struct nfs4_session *session,
>                 struct rpc_cred *cred)
>  {
>         struct rpc_message msg = {
> @@ -7332,10 +7332,6 @@ int nfs4_proc_destroy_session(struct nfs4_session *session,
>
>         dprintk("--> nfs4_proc_destroy_session\n");
>
> -       /* session is still being setup */
> -       if (!test_and_clear_bit(NFS4_SESSION_ESTABLISHED, &session->session_state))
> -               return 0;
> -
>         status = rpc_call_sync(session->clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
>         trace_nfs4_destroy_session(session->clp, status);
>
> @@ -7347,6 +7343,26 @@ int nfs4_proc_destroy_session(struct nfs4_session *session,
>         return status;
>  }
>
> +int nfs4_proc_destroy_session(struct nfs4_session *session,
> +               struct rpc_cred *cred)
> +{
> +       unsigned int loop;
> +       int ret;
> +
> +       /* session is still being setup */
> +       if (!test_and_clear_bit(NFS4_SESSION_ESTABLISHED, &session->session_state))
> +               return 0;
> +
> +       for (loop = NFS4_MAX_LOOP_ON_RECOVER; loop != 0; loop--) {
> +               ret = _nfs4_proc_destroy_session(session, cred);
> +               if (ret != -NFS4ERR_DELAY)
> +                       break;
> +               ssleep(1);
> +       }
> +
> +       return ret;
> +}
> +
>  /*
>   * Renew the cl_session lease.
>   */
> --
> 2.3.3
>

I don't understand. All you've done is paper over the problem AFAICS.
How is that useful?


-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
