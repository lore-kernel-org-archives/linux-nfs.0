Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f177.google.com ([209.85.220.177]:54365 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932170AbaICMWW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Sep 2014 08:22:22 -0400
Received: by mail-vc0-f177.google.com with SMTP id hq11so8665149vcb.36
        for <linux-nfs@vger.kernel.org>; Wed, 03 Sep 2014 05:22:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALXu0Ue8mn5ERuDM0J7YNYcubm9NDf-bHKqvYXZgTn7Uz7LEDA@mail.gmail.com>
References: <CALXu0Ue8mn5ERuDM0J7YNYcubm9NDf-bHKqvYXZgTn7Uz7LEDA@mail.gmail.com>
Date: Wed, 3 Sep 2014 08:22:20 -0400
Message-ID: <CAHQdGtTU_ZDtQ0Y=1RuG3TbqNSgvBSVmg8Fm_77X6oZcJY4J8w@mail.gmail.com>
Subject: Re: Accessing alternate data streams on NFSv4 server?
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Cedric Blancher <cedric.blancher@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 3, 2014 at 5:14 AM, Cedric Blancher
<cedric.blancher@gmail.com> wrote:
> is there any utility which can be used to access alternate data
> streams (which can be accessed on Solaris via O_XATTR or newer
> bash/ksh versions via cd -@) on Linux?
>
> Ced

No.

> --
> Cedric Blancher <cedric.blancher@gmail.com>
> Institute Pasteur
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
