Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:35570 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752026AbbL3OEv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Dec 2015 09:04:51 -0500
Received: by mail-ob0-f171.google.com with SMTP id 18so271445449obc.2
        for <linux-nfs@vger.kernel.org>; Wed, 30 Dec 2015 06:04:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5683BE9B.3000006@molgen.mpg.de>
References: <CAHQdGtR94XfHs0irDxx4PXjSmLEPBJY=GNjM63Xzx4S6_2Lhkg@mail.gmail.com>
	<1451433763-27093-1-git-send-email-trond.myklebust@primarydata.com>
	<5683BE9B.3000006@molgen.mpg.de>
Date: Wed, 30 Dec 2015 09:04:50 -0500
Message-ID: <CAHQdGtQ1NpvPh1L+CSqgY__q6ZkZbZ+8YcAgm49+Qw3KK=ORdw@mail.gmail.com>
Subject: Re: [PATCH] NFS: Fix attribute cache revalidation
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Donald Buczek <buczek@molgen.mpg.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 30, 2015 at 6:23 AM, Donald Buczek <buczek@molgen.mpg.de> wrote:
> Hi, Trond,
>
> your three patches
>
> [PATCH] NFSv4: Don't perform cached access checks before we've OPENed the
> file
> [PATCH] NFS: Ensure we revalidate attributes before using execute_ok()
> [PATCH] NFS: Fix attribute cache revalidation
>
> applied to your github master fix the user-visible problems (exec and access
> case). I currently don't have time to analyze the code or do more testing
> than running my test script, though. I hope I can apply these on our cluster
> nodes during the holiday and we'd have it on production systems in January.
>
> Btw: There is a little whitespace error in the last patch (space before tab
> at the "} else if (fattr->valid & NFS_ATTR_FATTR_BLOCKS_USED)" line).
>
> Thank you very much & Happy New Year

Thanks very much for the testing and analysis! Happy New Year to you too.

Cheers
  Trond
