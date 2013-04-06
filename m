Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f170.google.com ([209.85.128.170]:58532 "EHLO
	mail-ve0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422867Ab3DFNL1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Apr 2013 09:11:27 -0400
Received: by mail-ve0-f170.google.com with SMTP id 15so4375281vea.29
        for <linux-nfs@vger.kernel.org>; Sat, 06 Apr 2013 06:11:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1365196588-25403-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1365196588-25403-1-git-send-email-Trond.Myklebust@netapp.com>
From: William Dauchy <wdauchy@gmail.com>
Date: Sat, 6 Apr 2013 15:11:06 +0200
Message-ID: <CAJ75kXY-Yt_DNrKz7VfQPudw-1DkcKaK5dr3Wz7KmByyxwMSCQ@mail.gmail.com>
Subject: Re: [PATCH 0/2] Stable patches for NFSv4/4.1 trunking
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Bryan Schumaker <bjschuma@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On Fri, Apr 5, 2013 at 11:16 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> The following two sets of issues for the stable kernel were found when
> debugging the rpcsec_gss patches.
> Thanks to Bryan for helping with testing.
>
> Trond Myklebust (2):
>   NFSv4: Fix a memory leak in nfs4_discover_server_trunking
>   NFSv4/4.1: Fix bugs in nfs4[01]_walk_client_list
>
>  fs/nfs/nfs4client.c | 44 ++++++++++++++++++++++++++++----------------
>  fs/nfs/nfs4state.c  |  8 +++++++-
>  2 files changed, 35 insertions(+), 17 deletions(-)

I was wondering why this commit is not tagged to go in stable as well:

commit f05c124a70a4953a66acbd6d6c601ea1eb5d0fa7
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 5 14:13:21 2013 -0400

    SUNRPC: Fix a potential memory leak in rpc_new_client

    If the call to rpciod_up() fails, we currently leak a reference to the
    struct rpc_xprt.
    As part of the fix, we also remove the redundant check for xprt!=NULL.
    This is already taken care of by the callers.

    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=commit;h=f05c124a70a4953a66acbd6d6c601ea1eb5d0fa7

Regards,

--
William
