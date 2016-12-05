Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35936 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751798AbcLER3I (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2016 12:29:08 -0500
Received: by mail-io0-f196.google.com with SMTP id s82so1228698ioi.3
        for <linux-nfs@vger.kernel.org>; Mon, 05 Dec 2016 09:29:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <87oa0r584c.fsf@notabene.neil.brown.name>
References: <87oa0r584c.fsf@notabene.neil.brown.name>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 5 Dec 2016 12:29:07 -0500
Message-ID: <CAN-5tyHrWMj54cvj3PVO+8Yxk+0NK9ey=X7VU6WXKv-mswh-xw@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: fix refcounting problems with auth_gss messages.
To: NeilBrown <neilb@suse.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Olga Kornievskaia <kolga@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 4, 2016 at 11:10 PM, NeilBrown <neilb@suse.com> wrote:
>
> There are two problems with refcounting of auth_gss messages.
>
> First, the reference on the pipe->pipe list (taken by a call
> to rpc_queue_upcall()) is not counted.  It seems to be
> assumed that a message in pipe->pipe will always also be in
> pipe->in_downcall, where it is correctly reference counted.
>
> However there is no guaranty of this.  I have a report of a
> NULL dereferences in rpc_pipe_read() which suggests a msg
> that has been freed is still on the pipe->pipe list.
>
> One way I imagine this might happen is:
> - message is queued for uid=U and auth->service=S1
> - rpc.gssd reads this message and starts processing.
>   This removes the message from pipe->pipe
> - message is queued for uid=U and auth->service=S2
> - rpc.gssd replies to the first message. gss_pipe_downcall()
>   calls __gss_find_upcall(pipe, U, NULL) and it finds the
>   *second* message, as new messages are placed at the head
>   of ->in_downcall, and the service type is not checked.

Correct "service" was/is not a part of the protocol between the kernel
and gssd. So that's why the kernel can't match what's coming from gssd
to a particular waiting upcall.

> - This second message is removed from ->in_downcall and freed
>   by gss_release_msg() (even though it is still on pipe->pipe)
> - rpc.gssd tries to read another message, and dereferences a pointer
>   to this message that has just been freed.

Agreed. This is a problem.

Doesn't the problem still exist even with this patch because
gss_add_msg() adds the msg onto the in_downcall() list? So gssd in
__gss_fin_upcall() can find the 2nd upcall even before the 2nd msg is
added to the pipe->pipe()?

In the perfect world, the real solution (even for the initial problem)
would have been changing the gssd-kernel protocol to include "service"
as a part of the upcall. But that's not going to happen...

The solution I can thinking of is something where the message is not
on "in_downcall" list until it's consumed by the rpc_pipe. I'd need to
some time to figure out how to do that...

> I fix this by incrementing the reference count before calling
> rpc_queue_upcall(), and decrementing it if that fails, or normally in
> gss_pipe_destroy_msg().
> It seems strange that the reply doesn't target the message more
> precisely, but I don't know all the details.  In any case, I think the
> reference counting irregularity became a measureable bug when the
> extra arg was added to __gss_find_upcall(), hence the Fixes: line
> below.
>
> The second problem is that if rpc_queue_upcall() fails, the new
> message is not freed. gss_alloc_msg() set the ->count to 1,
> gss_add_msg() increments this to 2, gss_unhash_msg() decrements to 1,
> then the pointer is discarded so the memory never gets freed.
>
> Fixes: 9130b8dbc6ac ("SUNRPC: allow for upcalls for same uid but different gss service")
> Cc: stable@vger.kernel.org
> Link: https://bugzilla.opensuse.org/show_bug.cgi?id=1011250
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  net/sunrpc/auth_gss/auth_gss.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
>
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index 3dfd769dc5b5..16cea00c959b 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -541,9 +541,13 @@ gss_setup_upcall(struct gss_auth *gss_auth, struct rpc_cred *cred)
>                 return gss_new;
>         gss_msg = gss_add_msg(gss_new);
>         if (gss_msg == gss_new) {
> -               int res = rpc_queue_upcall(gss_new->pipe, &gss_new->msg);
> +               int res;
> +               atomic_inc(&gss_msg->count);
> +               res = rpc_queue_upcall(gss_new->pipe, &gss_new->msg);
>                 if (res) {
>                         gss_unhash_msg(gss_new);
> +                       atomic_dec(&gss_msg->count);
> +                       gss_release_msg(gss_new);
>                         gss_msg = ERR_PTR(res);
>                 }
>         } else
> @@ -836,6 +840,7 @@ gss_pipe_destroy_msg(struct rpc_pipe_msg *msg)
>                         warn_gssd();
>                 gss_release_msg(gss_msg);
>         }
> +       gss_release_msg(gss_msg);
>  }
>
>  static void gss_pipe_dentry_destroy(struct dentry *dir,
> --
> 2.10.2
>
