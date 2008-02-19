From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] sunrpc: GSS integrity and decryption failures should
	return GARBAGE_ARGS
Date: Tue, 19 Feb 2008 12:44:13 -0500
Message-ID: <20080219174413.GB31066@fieldses.org>
References: <1203412781.10159.95.camel@serendib.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Harshula <harshula@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:51708 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753945AbYBSRoO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Feb 2008 12:44:14 -0500
In-Reply-To: <1203412781.10159.95.camel-2WabGjdRN2LRvmHwrWB8BmjR7Gm6iKkz0E9HWUfgJXw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 19, 2008 at 08:19:41PM +1100, Harshula wrote:
> Hi,
> 
> In function svcauth_gss_accept() (net/sunrpc/auth_gss/svcauth_gss.c) the
> code that handles GSS integrity and decryption failures should be
> returning GARBAGE_ARGS as specified in RFC 2203. Is there a reason why
> this is not the case?

Nope!

> If not, here's a patch.

Thanks for the patch and the rfc citation!

However:

> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -1146,7 +1146,7 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32
> *authp)

Your mailer seems to be wrapping long lines?  This makes the patch not
apply.

>                 case RPC_GSS_SVC_INTEGRITY:
>                         if (unwrap_integ_data(&rqstp->rq_arg,
>                                         gc->gc_seq, rsci->mechctx))
> -                               goto auth_err;
> +                               goto garbage_args;

And tabs are getting changed to spaces everywhere too....

Would it be possible to fix those problems and resend?

--b.
