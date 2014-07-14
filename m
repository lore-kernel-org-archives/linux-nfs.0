Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f175.google.com ([209.85.220.175]:55096 "EHLO
	mail-vc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962AbaGNCAO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Jul 2014 22:00:14 -0400
Received: by mail-vc0-f175.google.com with SMTP id hu12so891235vcb.20
        for <linux-nfs@vger.kernel.org>; Sun, 13 Jul 2014 19:00:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140714011630.12562.1940.stgit@notabene.brown>
References: <20140714011630.12562.1940.stgit@notabene.brown>
Date: Sun, 13 Jul 2014 22:00:12 -0400
Message-ID: <CAHQdGtS2XW=GeyxHddKKAb9a2tucO9kzxatPJ78qpMiDiOagiQ@mail.gmail.com>
Subject: Re: [PATCH 0/7] Add RCU-walk support to NFS.
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: NeilBrown <neilb@suse.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 13, 2014 at 9:28 PM, NeilBrown <neilb@suse.de> wrote:
> NFS current abort and attempt at filename lookup in RCU mode.
> This can have serious performance impact on a highly parallel load.
>
> The "Makefile" below generates just such a load.  On a 40-core
> machine "make -j 40" is about 6 times as fast at "make -j 5"
> when a local filesystem is used (e.g. XFS), but as much as half
> as fast when NFS is used.
> With this patch set, "make -j 40" is about 3 times as fast as
> "make -j 5" on NFS, and "perf" data doesn't show spinlocks to be a big
> problem any more.
>
> This is a re-submission with a few small improvements of a patch set
> posted in March.  Since then I have recieved confirmation that it
> definitely fixes the problem, when combined with a patch set which
> enhances autofs4 in a similar way.  So it has had quite a bit of
> testing.

Hi Neil,

What kind of tests have you personally (or SuSE if relevant) performed?
Have you run this under NFSometer in order to check for regressions,
and if so on what workloads?

The above are not requirements in order to get the patches into
mainline, I'm just curious.

Cheers
  Trond

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
