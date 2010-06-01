Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:34347 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756008Ab0FAMl1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jun 2010 08:41:27 -0400
Received: by gye5 with SMTP id 5so1038870gye.19
        for <linux-nfs@vger.kernel.org>; Tue, 01 Jun 2010 05:41:26 -0700 (PDT)
In-Reply-To: <20100531101234.GQ5483@bicker>
References: <20100531101234.GQ5483@bicker>
Date: Tue, 1 Jun 2010 08:41:25 -0400
Message-ID: <AANLkTinMMejkx34oC57Uyx2jUzUGexX4AhO6LJBRFzBf@mail.gmail.com>
Subject: Re: question about gss_verify_mic_v2()
From: Kevin Coffman <kwc@citi.umich.edu>
To: Dan Carpenter <error27@gmail.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I think it would be good to add sequence checks, but I don't have the
cycles to work on it.

On Mon, May 31, 2010 at 6:12 AM, Dan Carpenter <error27@gmail.com> wrote:
> Hi Kevin,
>
> Are we planning to add the sequencing checks later or can I remove the
> comment?
>
> net/sunrpc/auth_gss/gss_krb5_unseal.c +202 gss_verify_mic_v2()
>         warn: unused return: seqnum = __be64_to_cpup()
>
>   200          /* do sequencing checks */
>   201
>   202          seqnum = be64_to_cpup((__be64 *)ptr + 8);
>   203
>   204          return GSS_S_COMPLETE;
>   205  }
>
> regards,
> dan carpenter
>
>
