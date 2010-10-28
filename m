Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44424 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933147Ab0J1OAi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Oct 2010 10:00:38 -0400
Subject: Re: rpc.gssd still spammed in 2.6.35
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Brian De Wolf <bldewolf@csupomona.edu>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <20101027172452.68b944ec@csupomona.edu>
References: <20101027172452.68b944ec@csupomona.edu>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Oct 2010 10:00:19 -0400
Message-ID: <1288274419.3194.33.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-10-27 at 17:24 -0700, Brian De Wolf wrote:
> Greetings,
> 
> I recently started testing a build of 2.6.35 to hopefully relieve some
> issues we have on our login boxes.  Specifically, I was after this
> commit:
> http://git.kernel.org/?p=linux/kernel/git/next/linux-next.git;a=commit;h=126e216a8730532dfb685205309275f87e3d133e
> 
> The issue we've run into is that some user loses their credentials,
> but has a process looping on a read/write of their Kerberized NFSv4 home
> directory without checking the return value.  Not only did this spam
> logs, but it also prevents rpc.gssd from handling anyone else's logins,
> effectively taking down the service for anyone not already connected.
> 
> I was hoping this commit would protect rpc.gssd from any potential
> flooding of requests, but it all depends on how the user loses their
> credentials. If their credentials have expired or their caches become
> corrupt, rpc.gssd returns EKEYEXPIRED and the kernel rate limits the
> requests to rpc.gssd via negative caching.
> 
> If the user's credential cache gets destroyed, however, rpc.gssd
> returns EACCES, and the user process can cause the kernel to hammer
> rpc.gssd. The kicker here is that pam_krb5 destroys credentials on
> logout by default, so if someone's using screen or long background
> processes in their home directory, it's a ticking time bomb waiting to
> destroy rpc.gssd.
> 
> That's assuming a benign user, as well.  A malicious user could easily
> kdestroy, wait for their credentials to expire from the cache in the
> kernel, and start tying up rpc.gssd with failed requests.
> 
> 
> With this in mind, I initially patched the kernel to negative cache
> entries with EACCES errors, in addition to EKEYEXPIRED errors.  But the
> more that I thought about it, the more it seemed appropriate to subject
> all possible errors to negative caching.  The underlying question is,
> is there any possible error from rpc.gssd where it would be appropriate
> to allow a process to cause another request to rpc.gssd immediately?
> If there isn't, negative caching all errors seems reasonable.
> 
> Here's a simple patch implementing the behavior of negative caching of
> every failed request, as a proof of concept, I guess.  With it applied,
> I have yet to produce a scenario where rpc.gssd becomes unresponsive.
> 
> Let me know what you think.  I'd love to see a fix for this behavior
> enter the kernel at some point, as it's been rather disruptive on our
> login boxes lately.
> 
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index 3835ce3..38bdf90 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -362,7 +362,7 @@ gss_handle_downcall_result(struct gss_cred *gss_cred, struct gss_upcall_msg *gss
>                 clear_bit(RPCAUTH_CRED_NEGATIVE, &gss_cred->gc_base.cr_flags);
>                 gss_cred_set_ctx(&gss_cred->gc_base, gss_msg->ctx);
>                 break;
> -       case -EKEYEXPIRED:
> +       default:
>                 set_bit(RPCAUTH_CRED_NEGATIVE, &gss_cred->gc_base.cr_flags);
>         }
>         gss_cred->gc_upcall_timestamp = jiffies;

What about the rpc_pipefs errors, EAGAIN, EPIPE and ETIMEDOUT? Why
should they result in the cred being marked as negative?

rpc.gssd itself will only pass down 3 errors: 0, EKEYEXPIRED and EACCES.

Trond
