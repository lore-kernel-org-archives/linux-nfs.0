Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:49619 "EHLO
        mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965157AbdIZLPL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Sep 2017 07:15:11 -0400
Received: by mail-qk0-f171.google.com with SMTP id u67so9607570qkg.6
        for <linux-nfs@vger.kernel.org>; Tue, 26 Sep 2017 04:15:11 -0700 (PDT)
Message-ID: <1506424509.3182.0.camel@redhat.com>
Subject: Re: [PATCH 0/3] nfs_common: misc patchs
From: Jeff Layton <jlayton@redhat.com>
To: Corentin Labbe <clabbe.montjoie@gmail.com>,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        bfields@fieldses.org, viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Date: Tue, 26 Sep 2017 07:15:09 -0400
In-Reply-To: <20170926071407.31719-1-clabbe.montjoie@gmail.com>
References: <20170926071407.31719-1-clabbe.montjoie@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2017-09-26 at 09:14 +0200, Corentin Labbe wrote:
> Hello
> 
> The origin of this series is a build warning fix.
> But reading the code show me two other possible patch.
> 
> Regards
> 
> Corentin Labbe (3):
>   nfs_common: fix build warning in grace.c
>   nfs_common: move locks_in_grace comment at the right place
>   nfs_common: convert int to bool
> 
>  fs/nfs_common/grace.c | 24 ++++++++++++------------
>  include/linux/fs.h    |  4 ++--
>  2 files changed, 14 insertions(+), 14 deletions(-)
> 

Looks like a reasonable set of cleanups. Probably fine for v4.15?

Reviewed-by: Jeff Layton <jlayton@redhat.com>
