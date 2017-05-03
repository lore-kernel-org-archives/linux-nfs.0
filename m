Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36150 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752036AbdECQ4B (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 May 2017 12:56:01 -0400
Received: by mail-qk0-f193.google.com with SMTP id o4so3515246qkb.3
        for <linux-nfs@vger.kernel.org>; Wed, 03 May 2017 09:56:01 -0700 (PDT)
Message-ID: <1493830556.2699.7.camel@poochiereds.net>
Subject: Re: [PATCH 1/9] Provide a function to create a NUL-terminated
 string from unterminated data
From: Jeff Layton <jlayton@poochiereds.net>
To: David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, mszeredi@redhat.com
Date: Wed, 03 May 2017 12:55:56 -0400
In-Reply-To: <149382748241.30481.12971647975706869540.stgit@warthog.procyon.org.uk>
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
         <149382748241.30481.12971647975706869540.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2017-05-03 at 17:04 +0100, David Howells wrote:
> Provide a function, kstrcreate(), that will create a NUL-terminated string
> from an unterminated character array where the length is known in advance.
> 
> This is better than kstrndup() in situations where we already know the
> string length as the strnlen() in kstrndup() is superfluous.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
> 
>  include/linux/string.h |    1 +
>  mm/util.c              |   22 ++++++++++++++++++++++
>  2 files changed, 23 insertions(+)
> 
> diff --git a/include/linux/string.h b/include/linux/string.h
> index 26b6f6a66f83..5596ae56ce0a 100644
> --- a/include/linux/string.h
> +++ b/include/linux/string.h
> @@ -122,6 +122,7 @@ extern void kfree_const(const void *x);
>  extern char *kstrdup(const char *s, gfp_t gfp) __malloc;
>  extern const char *kstrdup_const(const char *s, gfp_t gfp);
>  extern char *kstrndup(const char *s, size_t len, gfp_t gfp);
> +extern char *kstrcreate(const char *s, size_t len, gfp_t gfp);
>  extern void *kmemdup(const void *src, size_t len, gfp_t gfp);
>  
>  extern char **argv_split(gfp_t gfp, const char *str, int *argcp);
> diff --git a/mm/util.c b/mm/util.c
> index 656dc5e37a87..01887bbdb11e 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -103,6 +103,28 @@ char *kstrndup(const char *s, size_t max, gfp_t gfp)
>  EXPORT_SYMBOL(kstrndup);
>  
>  /**
> + * kstrcreate - Create a NUL-terminated string from unterminated data
> + * @s: The data to stringify
> + * @len: The size of the data
> + * @gfp: the GFP mask used in the kmalloc() call when allocating memory
> + */
> +char *kstrcreate(const char *s, size_t len, gfp_t gfp)
> +{
> +	char *buf;
> +
> +	if (!s)
> +		return NULL;
> +
> +	buf = kmalloc_track_caller(len + 1, gfp);
> +	if (buf) {
> +		memcpy(buf, s, len);
> +		buf[len] = '\0';
> +	}
> +	return buf;
> +}
> +EXPORT_SYMBOL(kstrcreate);
> +
> +/**
>   * kmemdup - duplicate region of memory
>   *
>   * @src: memory region to duplicate
> 
> 

I haven't gotten to the part where this gets used yet, but it looks like
a nice helper.

Reviewed-by: Jeff Layton <jlayton@poochiereds.net>
