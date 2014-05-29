Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yk0-f178.google.com ([209.85.160.178]:39328 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889AbaE2DWy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2014 23:22:54 -0400
Received: by mail-yk0-f178.google.com with SMTP id 20so9175652yks.37
        for <linux-nfs@vger.kernel.org>; Wed, 28 May 2014 20:22:53 -0700 (PDT)
Message-ID: <5386A803.4080703@gmail.com>
Date: Thu, 29 May 2014 11:22:43 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Dr James Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: remove KERN_DEFAULT kernel loglevel from dfprintk
References: <5386A183.5030405@gmail.com> <CAHQdGtR4cwdnta0WmfEysfVQTEcsje0xzfM4wx=BWz-sr-JCXQ@mail.gmail.com>
In-Reply-To: <CAHQdGtR4cwdnta0WmfEysfVQTEcsje0xzfM4wx=BWz-sr-JCXQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/29/2014 11:15, Trond Myklebust wrote:
> Nack. This is an api change...

API change ? printk ? dprintk?

> 
> On May 28, 2014 10:55 PM, "Kinglong Mee" <kinglongmee@gmail.com <mailto:kinglongmee@gmail.com>> wrote:
> 
>     When debugging, rpc prints messages for dprintk(KERN_WARNING ...) as,
> 
>     [ 2780.339988] ^A4nfsd: connect from unprivileged port: 0000:0000:0000:0000:0000:0000:0000:0001, port=35316
> 
>     Because, it expends as printk(KERN_DEFAULT KERN_WARNING ...).

net/sunrpc/svcsock.c:852, and fs/nfsd/nfsfh.c:91 call dprintk as,
dprintk(KERN_WARNING ...) ---> printk(KERN_DEFAULT KERN_WARNING ...)

so that, "^A4" will be prefixed before the debugging message.

thanks,
Kinglong Mee

> 
>     Signed-off-by: Kinglong Mee <kinglongmee@gmail.com <mailto:kinglongmee@gmail.com>>
>     ---
>      include/linux/sunrpc/debug.h | 4 ++--
>      1 file changed, 2 insertions(+), 2 deletions(-)
> 
>     diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
>     index 9385bd7..742e2ac 100644
>     --- a/include/linux/sunrpc/debug.h
>     +++ b/include/linux/sunrpc/debug.h
>     @@ -42,14 +42,14 @@ extern unsigned int         nlm_debug;
>      # define dfprintk(fac, args...)        \
>             do { \
>                     ifdebug(fac) \
>     -                       printk(KERN_DEFAULT args); \
>     +                       printk(args); \
>             } while (0)
> 
>      # define dfprintk_rcu(fac, args...)    \
>             do { \
>                     ifdebug(fac) { \
>                             rcu_read_lock(); \
>     -                       printk(KERN_DEFAULT args); \
>     +                       printk(args); \
>                             rcu_read_unlock(); \
>                     } \
>             } while (0)
>     --
>     1.9.3
> 
