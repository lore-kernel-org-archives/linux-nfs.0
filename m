Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:32890 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752083AbcCQNUP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Mar 2016 09:20:15 -0400
Received: by mail-ob0-f170.google.com with SMTP id fz5so83854449obc.0
        for <linux-nfs@vger.kernel.org>; Thu, 17 Mar 2016 06:20:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160317141307.531709bf667a915973060eae@hyperplane.net>
References: <20160317141307.531709bf667a915973060eae@hyperplane.net>
Date: Thu, 17 Mar 2016 09:20:14 -0400
Message-ID: <CAHQdGtREL65zXvkdqJ8=hrSXWVyLBGCTAfdO02cXPsC6W26ZVQ@mail.gmail.com>
Subject: Re: nfs_super_set_maxbytes patch
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Alexey Dvoichenkov <xale@hyperplane.net>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, spender@grsecurity.net
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 17, 2016 at 7:13 AM, Alexey Dvoichenkov <xale@hyperplane.net> wrote:
> Hello. I've found a small bug in what appears to be the maximum file
> size handling code.
>
> The problem here, as far as I understand, is that casting from an
> unsigned type to a signed type, when the latter cannot represent the
> arithmetic value of the former, is UB. In practice, under the PaX size
> overflow protection, this code crashes when mounting from FreeBSD
> servers that send "all ones" in the size field.
>
> Not sure I'm doing things right with the list and I'm not subscribed, so
> please CC.
>
> The fix should look something like this:
>
> --- fs/nfs/internal.h.orig      2015-11-02 10:05:25.000000000 +1000
> +++ fs/nfs/internal.h   2016-01-02 03:19:04.599120855 +1000
> @@ -612,9 +612,9 @@
>  static inline
>  void nfs_super_set_maxbytes(struct super_block *sb, __u64 maxfilesize)
>  {
> +       if (maxfilesize > MAX_LFS_FILESIZE || maxfilesize == 0)
> +               maxfilesize = MAX_LFS_FILESIZE;
>         sb->s_maxbytes = (loff_t)maxfilesize;
> -       if (sb->s_maxbytes > MAX_LFS_FILESIZE || sb->s_maxbytes <= 0)
> -               sb->s_maxbytes = MAX_LFS_FILESIZE;
>  }
>

Why are we having to change _correct_ code in order to work with a
checking tool?

Trond
