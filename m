Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:39469 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619Ab2BMIZN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Feb 2012 03:25:13 -0500
Received: by eaah12 with SMTP id h12so1700255eaa.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Feb 2012 00:25:12 -0800 (PST)
Message-ID: <4F38C8E4.6080901@tonian.com>
Date: Mon, 13 Feb 2012 10:25:08 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Tigran Mkrtchyan <kofemann@googlemail.com>
CC: linux-nfs@vger.kernel.org, bfields@fieldses.org,
        Tigran Mkrtchyan <kofemann@gmail.com>
Subject: Re: [PATH v8 10/10] nfsd41: use current stateid by value
References: <1328461679-4108-1-git-send-email-tigran.mkrtchyan@desy.de> <1328461679-4108-11-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1328461679-4108-11-git-send-email-tigran.mkrtchyan@desy.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for the late response...
If not committed yet, please fix the macros below.

Otherwise

Benny

On 2012-02-05 19:07, Tigran Mkrtchyan wrote:
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index 2ae378e..4ee102a 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -43,6 +43,13 @@
>  #define NFSD4_MAX_TAGLEN	128
>  #define XDR_LEN(n)                     (((n) + 3) & ~3)
>  
> +#define CURRENT_STATE_ID_FLAG 1
> +#define SAVED_STATE_ID_FLAG 2

while at it, I'd rather define the flags as (1 << 0), (1 << 1)
to stress the fact they are bit values.

> +
> +#define SET_STATE_ID(c, f) (c->sid_flags |= f)
> +#define HAS_STATE_ID(c, f) (c->sid_flags & f)
> +#define CLEAR_STATE_ID(c, f) (c->sid_flags &=  ~f)

parenthesis must be used when using the macro arguments
(important mainly for the last one, using the unary operator on the arg)

+#define SET_STATE_ID(c, f) ((c)->sid_flags |= (f))
+#define HAS_STATE_ID(c, f) ((c)->sid_flags & (f))
+#define CLEAR_STATE_ID(c, f) ((c)->sid_flags &= ~(f))

or just use the set_bit() test_bit() clear_bit() interface :)

Benny
