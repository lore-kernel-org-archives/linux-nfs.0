Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f172.google.com ([209.85.128.172]:51173 "EHLO
	mail-ve0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753011AbaDXKvE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Apr 2014 06:51:04 -0400
Received: by mail-ve0-f172.google.com with SMTP id jx11so2686083veb.31
        for <linux-nfs@vger.kernel.org>; Thu, 24 Apr 2014 03:51:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140424062516.GA8891@fieldses.org>
References: <20140424062516.GA8891@fieldses.org>
Date: Thu, 24 Apr 2014 06:51:03 -0400
Message-ID: <CAHQdGtRfybuqsxiS=Hd4Stkm1ex13f6SeEk5XbQcy35UZStHRA@mail.gmail.com>
Subject: Re: nfsd bug fixes for 3.15
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Layton Jeff <jlayton@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

On Thu, Apr 24, 2014 at 2:25 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> Please pull the following bug fixes for 3.15 from:
>
>   git://linux-nfs.org/~bfields/linux.git for-3.15
>
> Three small nfsd bugfixes (including one locks.c fix for a bug triggered
> only from nfsd).
>
> Jeff's patches are for long-existing problems that became easier to
> trigger since the addition of vfs delegation support.
>
> --b.
>
> ----------------------------------------------------------------
> J. Bruce Fields (1):
>       Revert "nfsd4: fix nfs4err_resource in 4.1 case"
>

Wait. Why? NFS4ERR_RESOURCE breaks the Linux client.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
