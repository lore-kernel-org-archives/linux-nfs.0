Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:33996 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbbFYDSQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Jun 2015 23:18:16 -0400
Received: by pdbep18 with SMTP id ep18so21759110pdb.1
        for <linux-nfs@vger.kernel.org>; Wed, 24 Jun 2015 20:18:16 -0700 (PDT)
Message-ID: <558B72E9.1040005@gmail.com>
Date: Thu, 25 Jun 2015 11:18:01 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Benjamin Coddington <bcodding@redhat.com>, linux-nfs@vger.kernel.org,
        kinglongmee@gmail.com
Subject: Re: [PATCH pynfs 1/3] Fix default arg order error on swig > 1.x
References: <cover.1432749206.git.bcodding@redhat.com> <72bd55393455ddd1cfba7902e9136b92b87b9a7b.1432749206.git.bcodding@redhat.com>
In-Reply-To: <72bd55393455ddd1cfba7902e9136b92b87b9a7b.1432749206.git.bcodding@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/28/2015 2:01 AM, Benjamin Coddington wrote:
> The gssapi.py module ends up with
> def initSecContext(name, context=None, INPUT=0, cred=0, mech, flags=2, time=0, chan=0):
> 
> which creates the error "SyntaxError: non-default argument follows default
> argument" on import.  Revert to earlier swig behavior of using compact
> default args.
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>

Anyway this one is useful.

Acked-by: Kinglong Mee <kinglongmee@gmail.com>

thanks,
Kinglong Mee

> ---
>  gssapi/gssapi.i |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/gssapi/gssapi.i b/gssapi/gssapi.i
> index 5b66ce0..28656c7 100644
> --- a/gssapi/gssapi.i
> +++ b/gssapi/gssapi.i
> @@ -487,6 +487,7 @@ OM_uint32 reordered_init_sec_context
>  %apply gss_buffer_t OUTPUT {gss_buffer_t token};
>  %apply OM_uint32 *OUTPUT {OM_uint32 *flags, OM_uint32 *time};
>  %feature("autodoc", "initSecContext(gss_name_t name, gss_ctx_id_t *context=None, string token=None, gss_cred_id_t cred=None, gss_OID mech=krb5oid, int flags=0, int time=0, gss_channel_bindings_t chan=None) -> context, mech, token, flags, time");
> +%feature("compactdefaultargs");
>  OM_uint32 reordered_init_sec_context
>  	        (OM_uint32 *minor,		/* minor_status */
>  		 gss_name_t name,			/* target_name IN*/
> @@ -507,6 +508,7 @@ OM_uint32 reordered_init_sec_context
>  %clear gss_OID *mech;
>  %clear gss_buffer_t token;
>  %clear OM_uint32 *flags, OM_uint32 *time;
> +%feature("compactdefaultargs", 0);
>  
>  /********/
>  
> 
