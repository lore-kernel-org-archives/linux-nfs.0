Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:35285 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338AbcBOT5m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Feb 2016 14:57:42 -0500
Received: by mail-ob0-f181.google.com with SMTP id xk3so226218031obc.2
        for <linux-nfs@vger.kernel.org>; Mon, 15 Feb 2016 11:57:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1455564521-21927-1-git-send-email-smayhew@redhat.com>
References: <1455564521-21927-1-git-send-email-smayhew@redhat.com>
Date: Mon, 15 Feb 2016 14:57:42 -0500
Message-ID: <CAHQdGtRcC_58yGnb55us9E=rKNw+__HuPN_PFgYsZfukLDSxzQ@mail.gmail.com>
Subject: Re: [PATCH] auth_gss: fix panic in gss_pipe_downcall() in fips mode
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Scott Mayhew <smayhew@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Scott,

On Mon, Feb 15, 2016 at 2:28 PM, Scott Mayhew <smayhew@redhat.com> wrote:
> md5 is disabled in fips mode, and attempting to import a gss context
> using md5 while in fips mode will result in crypto_alg_mod_lookup()
> returning -ENOENT, which will make its way back up to
> gss_pipe_downcall(), where the BUG() is triggered.  Handling the -ENOENT
> allows for a more graceful failure.
>
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  net/sunrpc/auth_gss/auth_gss.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index 799e65b..c30fc3b 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -737,6 +737,9 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
>                 case -ENOSYS:
>                         gss_msg->msg.errno = -EAGAIN;
>                         break;
> +               case -ENOENT:
> +                       gss_msg->msg.errno = -EPROTONOSUPPORT;
> +                       break;
>                 default:
>                         printk(KERN_CRIT "%s: bad return from "
>                                 "gss_fill_context: %zd\n", __func__, err);
> --
> 2.4.3
>

Well debugged, but I unfortunately do have to ask if this patch is
sufficient? In addition to -ENOENT, and -ENOMEM, it looks to me as if
crypto_alg_mod_lookup() can also fail with -EINTR, -ETIMEDOUT, and
-EAGAIN. Don't we also want to handle those?

In fact, peering into the rats nest that is
gss_import_sec_context_kerberos(), it looks as if that is just a tiny
subset of all the errors that we might run into. Perhaps the right
thing to do here is to get rid of the BUG() (but keep the above
printk) and just return a generic error?

Cheers
  Trond
