Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:33762 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421AbbLIU7a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Dec 2015 15:59:30 -0500
Received: by mail-ig0-f172.google.com with SMTP id mv3so1887950igc.0
        for <linux-nfs@vger.kernel.org>; Wed, 09 Dec 2015 12:59:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1448389782-99578-1-git-send-email-kolga@netapp.com>
References: <1448389782-99578-1-git-send-email-kolga@netapp.com>
Date: Wed, 9 Dec 2015 15:59:29 -0500
Message-ID: <CAN-5tyGozh3KhyHEfsh3QPA_YvW1++Kg7jLhz0RP8e0Niq4tUQ@mail.gmail.com>
Subject: Re: [PATCH Version 2 0/2] Adding to tracepoints
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond,

Any thoughts on the patches?

Thank you.

On Tue, Nov 24, 2015 at 1:29 PM, Olga Kornievskaia <kolga@netapp.com> wrote:
> First patch adds stateid information to tracepoints (openstateid, delegation
> stateid, and locking stateid). Version 2 of this patch fixes two things from
> the previous version: (1) typo in printout missing ":" in one stateid, (2)
> close tracepoint should take stateid from the args instead of the state passed
> in as state's stateid could be delegation stateid.
>
> Second patch adds a new tracepoint nfs_cached_open()
>
> Olga Kornievskaia (2):
>   Adding stateid information to tracepoints
>   Adding tracepoint to cached open
>
>  fs/nfs/internal.h  |   9 ++
>  fs/nfs/nfs4proc.c  |  15 +--
>  fs/nfs/nfs4trace.h | 294 ++++++++++++++++++++++++++++++++++++++++++++++++-----
>  3 files changed, 286 insertions(+), 32 deletions(-)
>
> --
> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
