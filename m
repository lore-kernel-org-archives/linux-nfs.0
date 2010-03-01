From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] gssd: By default, don't spam syslog when users' credentials
 	expire (redux)
Date: Mon, 01 Mar 2010 08:24:58 -0500
Message-ID: <4B8BC02A.5020702@RedHat.com>
References: <39d46ab51002221033n78035811y959fdd30b155b174@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Andrew Pollock <apollock@google.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28119 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751686Ab0CAN0Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Mar 2010 08:26:16 -0500
In-Reply-To: <39d46ab51002221033n78035811y959fdd30b155b174-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/22/2010 01:33 PM, Andrew Pollock wrote:
> This is a continuation of commit 09c7ad1cd9c5ca2fc46631a0057d47309abc8706,
> adding a couple more cases that can spam syslog
> ---
>  utils/gssd/gss_util.c  |    2 +-
>  utils/gssd/gssd_proc.c |    6 +++---
>  2 files changed, 4 insertions(+), 4 deletions(-)
> diff --git a/utils/gssd/gss_util.c b/utils/gssd/gss_util.c
> index 99aceb3..64dddf1 100644
> --- a/utils/gssd/gss_util.c
> +++ b/utils/gssd/gss_util.c
> @@ -126,7 +126,7 @@ display_status_1(char *m, u_int32_t code, int
> type, const gss_OID mech)
>   "gss_display_status called from %s\n", m);
>   break;
>   } else {
> - printerr(0, "ERROR: GSS-API: (%s) error in %s(): %s\n",
> + printerr(2, "ERROR: GSS-API: (%s) error in %s(): %s\n",
>      typestr, m, (char *)msg.value);
>   }
> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index be4fb11..5629d97 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -638,7 +638,7 @@ do_error_downcall(int k5_fd, uid_t uid, int err)
>   unsigned int timeout = 0;
>   int zero = 0;
> 
> - printerr(1, "doing error downcall\n");
> + printerr(2, "doing error downcall\n");
> 
>   if (WRITE_BYTES(&p, end, uid)) goto out_err;
>   if (WRITE_BYTES(&p, end, timeout)) goto out_err;
> @@ -906,7 +906,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t
> uid, int fd, char *tgtname,
>   int create_resp = -1;
>   int err, downcall_err = -EACCES;
> 
> - printerr(1, "handling krb5 upcall (%s)\n", clp->dirname);
> + printerr(2, "handling krb5 upcall (%s)\n", clp->dirname);
> 
>   if (tgtname) {
>   if (clp->servicename) {
> @@ -1066,7 +1066,7 @@ process_spkm3_upcall(struct clnt_info *clp,
> uid_t uid, int fd)
>   }
> 
>   if (!authgss_get_private_data(auth, &pd)) {
> - printerr(0, "WARNING: Failed to obtain authentication "
> + printerr(2, "WARNING: Failed to obtain authentication "
>      "data for user with uid %d for server %s\n",
>   uid, clp->servername);
>   goto out_return_error;
The only one I'm concern with is this one. How offend does this pop
and how are people going know (without a restart) the reason the
are getting deined access is because of obscure error like the 
gss private data can't be accessed?

steved.


