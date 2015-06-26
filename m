Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:35147 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546AbbFZDGC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Jun 2015 23:06:02 -0400
Received: by iebrt9 with SMTP id rt9so67442181ieb.2
        for <linux-nfs@vger.kernel.org>; Thu, 25 Jun 2015 20:06:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1435162224-1184-1-git-send-email-jeff.layton@primarydata.com>
References: <1435162224-1184-1-git-send-email-jeff.layton@primarydata.com>
From: Peng Tao <bergwolf@primarydata.com>
Date: Fri, 26 Jun 2015 11:05:42 +0800
Message-ID: <CAKVebiVM6uYZyRo6S0zD3_Gt9grKZRgkfTJob6KprpVkAGUyaw@mail.gmail.com>
Subject: Re: [PATCH 0/2] nfs: fix credential handling problems in flexfiles code
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Thomas Haynes <thomas.haynes@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 25, 2015 at 12:10 AM, Jeff Layton <jlayton@poochiereds.net> wrote:
> Tom reported seeing some NFSv3 WRITE calls going to a mirror DS that
> were using the MDS credentials instead of the ones that were provided
> in the LAYOUTGET response.
>
> The problem turns out to be an issue in how mirror creds were being
> set up. Creds are associated with the mirror, not the DS, but we'd
> skip trying to set up the credentials in the mirror when we found that
> the DS was already connected.
>
> While I was in there, I spotted a potential credential leak too and
> fixed that as well.
>
> Jeff Layton (2):
>   nfs: fix potential credential leak in ff_layout_update_mirror_cred
>   nfs: always update creds in mirror, even when we have an already
>     connected ds
Both looks good. Thanks! And we can mark them for stable IMO.

Cheers,
Tao
>
>  fs/nfs/flexfilelayout/flexfilelayoutdev.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> --
> 2.4.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
