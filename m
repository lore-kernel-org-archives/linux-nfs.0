Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:62558 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864Ab1FMPpR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 11:45:17 -0400
Received: by vxi39 with SMTP id 39so3700225vxi.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jun 2011 08:45:16 -0700 (PDT)
In-Reply-To: <tsl8vtbyt74.fsf@mit.edu>
References: <tsl1uz57fa1.fsf@mit.edu>
	<20110609013756.GA5304@master.debian.org>
	<BANLkTikKC5jdJG0KtrKxONmnSWSTm-9iyA@mail.gmail.com>
	<tsl8vtbyt74.fsf@mit.edu>
Date: Mon, 13 Jun 2011 11:45:14 -0400
Message-ID: <BANLkTin42TV27xWd=4UwPT6Af6hQ_g76iQ@mail.gmail.com>
Subject: Re: libgssglue: incompatible with krb5 1.9
From: Kevin Coffman <kwc@citi.umich.edu>
To: Sam Hartman <hartmans@debian.org>
Cc: Didier Raboud <odyx@debian.org>, linux-nfs@vger.kernel.org,
        629553@bugs.debian.org, 629692@bugs.debian.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,
Here is a patch that fixed the compile and seems to run fine.  I'll be
putting out a new version of libgssglue, but it may take a few days
for me to get around to that.  Meanwhile, hopefully this fixes your
immediate issue.

K.C.

diff --git a/src/gssglue/gssapi/gssapi.h.in b/src/gssglue/gssapi/gssapi.h.in
index 8d3fe99..81df675 100644
--- a/src/gssglue/gssapi/gssapi.h.in
+++ b/src/gssglue/gssapi/gssapi.h.in
@@ -850,4 +850,15 @@ PROTOTYPE( (OM_uint32  *,          /* minor_status */
 /* XXXX This is a necessary evil until the spec is fixed */
 #define GSS_S_CRED_UNAVAIL GSS_S_FAILURE

+/*
+ * RFC 5587
+ */
+typedef const gss_buffer_desc *gss_const_buffer_t;
+typedef const struct gss_channel_bindings_struct *gss_const_channel_bindings_t;
+typedef const struct gss_ctx_id_struct gss_const_ctx_id_t;
+typedef const struct gss_cred_id_struct gss_const_cred_id_t;
+typedef const struct gss_name_struct gss_const_name_t;
+typedef const gss_OID_desc *gss_const_OID;
+typedef const gss_OID_set_desc *gss_const_OID_set;
+
 #endif /* _GSSAPI_H_GLUE_ */


On Thu, Jun 9, 2011 at 10:29 AM, Sam Hartman <hartmans@debian.org> wrote:
> Here's the MIT diff that introduces the types:
> commit 21479bb4df589793a4fc25aedb59d599043eb95b
> Author: lhoward <lhoward@dc483132-0cff-0310-8789-dd5450dbe970>
> Date:   Sun Apr 3 08:02:53 2011 +0000
>
>    Use RFC 5587 const types for draft-josefsson-gss-capsulate APIs
>
>    git-svn-id: svn://anonsvn.mit.edu/svn/krb5/trunk@24821 dc483132-0cff-0310-8789-dd5450dbe970
>    (cherry picked from commit 4a46936a36f47e54134b24d7083cfd45a2d009bc)
>
> diff --git a/src/lib/gssapi/generic/gssapi_ext.h b/src/lib/gssapi/generic/gssapi_ext.h
> index a2a8bcd..31d972b 100644
> --- a/src/lib/gssapi/generic/gssapi_ext.h
> +++ b/src/lib/gssapi/generic/gssapi_ext.h
> @@ -387,22 +387,22 @@ OM_uint32 KRB5_CALLCONV gss_release_any_name_mapping
>  /* draft-josefsson-gss-capsulate */
>  OM_uint32 KRB5_CALLCONV gss_encapsulate_token
>  (
> -    const gss_buffer_t, /* input_token */
> -    const gss_OID,      /* token_oid */
> -    const gss_buffer_t  /* output_token */
> +    gss_const_buffer_t, /* input_token */
> +    gss_const_OID,      /* token_oid */
> +    gss_buffer_t        /* output_token */
>  );
>
>  OM_uint32 KRB5_CALLCONV gss_decapsulate_token
>  (
> -    const gss_buffer_t, /* input_token */
> -    const gss_OID,      /* token_oid */
> +    gss_const_buffer_t, /* input_token */
> +    gss_const_OID,      /* token_oid */
>     gss_buffer_t        /* output_token */
>  );
>
>  int KRB5_CALLCONV gss_oid_equal
>  (
> -    const gss_OID,      /* first_oid */
> -    const gss_OID       /* second_oid */
> +    gss_const_OID,      /* first_oid */
> +    gss_const_OID       /* second_oid */
>  );
>
>  #ifdef __cplusplus
> diff --git a/src/lib/gssapi/mechglue/g_decapsulate_token.c b/src/lib/gssapi/mechglue/g_decapsulate_token.c
> index a12d8f7..42b9e07 100644
> --- a/src/lib/gssapi/mechglue/g_decapsulate_token.c
> +++ b/src/lib/gssapi/mechglue/g_decapsulate_token.c
> @@ -33,8 +33,8 @@
>  #include "mglueP.h"
>
>  OM_uint32
> -gss_decapsulate_token(const gss_buffer_t input_token,
> -                      const gss_OID token_oid,
> +gss_decapsulate_token(gss_const_buffer_t input_token,
> +                      gss_const_OID token_oid,
>                       gss_buffer_t output_token)
>  {
>     OM_uint32 minor;
> diff --git a/src/lib/gssapi/mechglue/g_encapsulate_token.c b/src/lib/gssapi/mechglue/g_encapsulate_token.c
> index a60c796..b26e147 100644
> --- a/src/lib/gssapi/mechglue/g_encapsulate_token.c
> +++ b/src/lib/gssapi/mechglue/g_encapsulate_token.c
> @@ -33,8 +33,8 @@
>  #include "mglueP.h"
>
>  OM_uint32
> -gss_encapsulate_token(const gss_buffer_t input_token,
> -                      const gss_OID token_oid,
> +gss_encapsulate_token(gss_const_buffer_t input_token,
> +                      gss_const_OID token_oid,
>                       gss_buffer_t output_token)
>  {
>     unsigned int tokenSize;
> diff --git a/src/lib/gssapi/mechglue/g_oid_ops.c b/src/lib/gssapi/mechglue/g_oid_ops.c
> index aa6d807..db3cd78 100644
> --- a/src/lib/gssapi/mechglue/g_oid_ops.c
> +++ b/src/lib/gssapi/mechglue/g_oid_ops.c
> @@ -111,8 +111,8 @@ gssint_copy_oid_set(
>
>  int
>  gss_oid_equal(
> -    const gss_OID first_oid,
> -    const gss_OID second_oid)
> +    gss_const_OID first_oid,
> +    gss_const_OID second_oid)
>  {
>     return g_OID_equal(first_oid, second_oid);
>  }
>
>
