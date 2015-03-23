Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:33070 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752167AbbCWOJb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Mar 2015 10:09:31 -0400
Received: by iecvj10 with SMTP id vj10so36381362iec.0
        for <linux-nfs@vger.kernel.org>; Mon, 23 Mar 2015 07:09:30 -0700 (PDT)
Message-ID: <1427119769.16955.6.camel@primarydata.com>
Subject: Re: [PATCH] NFS4: Retry destroy session when getting -NFS4ERR_DELAY
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Mon, 23 Mar 2015 10:09:29 -0400
In-Reply-To: <550F6964.4030005@gmail.com>
References: <550BDAE0.2070409@gmail.com>
	 <CAHQdGtSJ8GtC5DL2wh5BjyBBEEV_53pjvX-_CD4vCGkzHWY=2g@mail.gmail.com>
	 <550F6964.4030005@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2015-03-23 at 09:16 +0800, Kinglong Mee wrote:
> On 2015/3/23 3:14, Trond Myklebust wrote:
> > On Fri, Mar 20, 2015 at 4:31 AM, Kinglong Mee <kinglongmee@gmail.com> wrote:
> >> When umounting a client, it cost near ten seconds.
> >> Dump the request, got
> >>    client                     server
> >> DELEGRETURN              ---->
> >> DESTROY_SESSION          ---->
> >>           NFS4ERR_DELAY  <----  DESTROY_SESSION reply
> >>                 NFS4_OK  <----  DELEGRETURN reply
> >> DESTROY_CLIENTID          ---->
> >>   NFS4ERR_CLIENTID_BUSY  <----  DESTROY_CLIENTID reply
> >> DESTROY_CLIENTID          ---->
> >>   NFS4ERR_CLIENTID_BUSY  <----  DESTROY_CLIENTID reply
> >>          ... ....                  ... ...
> >> There are ten DESTROY_CLIENTID requests.
> >> This patch retry DESTROY_SESSION when getting NFS4ERR_DELAY,
> >> try the best to destroy the session as destroy clientid.
> >>
> >> With this patch, only cost more than 1 seconds, as,
> >>    client                     server
> >> DELEGRETURN          ---->
> >> DESTROY_SESSION      ---->
> >>      NFS4ERR_DELAY  <----  DESTROY_SESSION reply
> >>            NFS4_OK  <----  DELEGRETURN reply
> >> DESTROY_SESSION      ---->
> >>            NFS4_OK  <----  DESTROY_SESSION reply
> >> DESTROY_CLIENTID     ---->
> >>            NFS4_OK  <----  DESTROY_CLIENTID reply
> >>
> >> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> >> ---
> >>  fs/nfs/nfs4proc.c | 26 +++++++++++++++++++++-----
> >>  1 file changed, 21 insertions(+), 5 deletions(-)
> >>
> >> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> >> index 627f37c..2631dc2 100644
> >> --- a/fs/nfs/nfs4proc.c
> >> +++ b/fs/nfs/nfs4proc.c
> >> @@ -7320,7 +7320,7 @@ out:
> >>   * Issue the over-the-wire RPC DESTROY_SESSION.
> >>   * The caller must serialize access to this routine.
> >>   */
> >> -int nfs4_proc_destroy_session(struct nfs4_session *session,
> >> +static int _nfs4_proc_destroy_session(struct nfs4_session *session,
> >>                 struct rpc_cred *cred)
> >>  {
> >>         struct rpc_message msg = {
> >> @@ -7332,10 +7332,6 @@ int nfs4_proc_destroy_session(struct nfs4_session *session,
> >>
> >>         dprintk("--> nfs4_proc_destroy_session\n");
> >>
> >> -       /* session is still being setup */
> >> -       if (!test_and_clear_bit(NFS4_SESSION_ESTABLISHED, &session->session_state))
> >> -               return 0;
> >> -
> >>         status = rpc_call_sync(session->clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
> >>         trace_nfs4_destroy_session(session->clp, status);
> >>
> >> @@ -7347,6 +7343,26 @@ int nfs4_proc_destroy_session(struct nfs4_session *session,
> >>         return status;
> >>  }
> >>
> >> +int nfs4_proc_destroy_session(struct nfs4_session *session,
> >> +               struct rpc_cred *cred)
> >> +{
> >> +       unsigned int loop;
> >> +       int ret;
> >> +
> >> +       /* session is still being setup */
> >> +       if (!test_and_clear_bit(NFS4_SESSION_ESTABLISHED, &session->session_state))
> >> +               return 0;
> >> +
> >> +       for (loop = NFS4_MAX_LOOP_ON_RECOVER; loop != 0; loop--) {
> >> +               ret = _nfs4_proc_destroy_session(session, cred);
> >> +               if (ret != -NFS4ERR_DELAY)
> >> +                       break;
> >> +               ssleep(1);
> >> +       }
> >> +
> >> +       return ret;
> >> +}
> >> +
> >>  /*
> >>   * Renew the cl_session lease.
> >>   */
> >> --
> >> 2.3.3
> >>
> > 
> > I don't understand. All you've done is paper over the problem AFAICS.
> > How is that useful?
> 
> Sorry for missing more comments.
> When unmounting nfs with delegation, client will return delegation first,
> then call nfs41_shutdown_client() destory session and clientid.
> 
> DELEGRETURN using asynchronous RPC，destroy session will be send immediately.
> If sever processes DELEGRETUEN slowly, destory session maybe processed before.
> so that, destory session will be denied with NFS4ERR_DELAY.
> 
> NFS client don't care the return value of DESTROY_SESSION,
> and call DESTROY_CLIENTID directly, so that, all DESTROY_CLIENTID will fail
> with NFS4ERR_CLIENTID_BUSY, retry DESTROY_CLIENTID is usefulness. 
> 
> After that, nfs client have destroy all information about nfs server,
> but nfs server also records client's information for DESTORY_CLIENTID and 
> DESTROY_SESSION failed.
> 
> This patch make sure the DESTROY_SESSION/DESTORY_CLIENTID success,
> first, cut down the cost of umount as I said above.
> second, make sure server clean the recording of client not until expired.

Hi Kinglong,

Ultimately, what you are saying above is that we need to drain the
session before destroying it. I agree with that goal, however not the
method that you choose to achieve it.

Please consider the following patch instead.

Cheers,
 Trond

8<---------------------------------------------------------------
