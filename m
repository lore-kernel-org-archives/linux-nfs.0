Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:45136 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759630Ab3DFU36 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Apr 2013 16:29:58 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: William Dauchy <wdauchy@gmail.com>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
Subject: Re: [PATCH 0/2] Stable patches for NFSv4/4.1 trunking
Date: Sat, 6 Apr 2013 20:29:49 +0000
Message-ID: <1365280195.3651.4.camel@leira.trondhjem.org>
References: <1365196588-25403-1-git-send-email-Trond.Myklebust@netapp.com>
	 <CAJ75kXY-Yt_DNrKz7VfQPudw-1DkcKaK5dr3Wz7KmByyxwMSCQ@mail.gmail.com>
In-Reply-To: <CAJ75kXY-Yt_DNrKz7VfQPudw-1DkcKaK5dr3Wz7KmByyxwMSCQ@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2013-04-06 at 15:11 +0200, William Dauchy wrote:
> Hi Trond,
> 
> On Fri, Apr 5, 2013 at 11:16 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> > The following two sets of issues for the stable kernel were found when
> > debugging the rpcsec_gss patches.
> > Thanks to Bryan for helping with testing.
> >
> > Trond Myklebust (2):
> >   NFSv4: Fix a memory leak in nfs4_discover_server_trunking
> >   NFSv4/4.1: Fix bugs in nfs4[01]_walk_client_list
> >
> >  fs/nfs/nfs4client.c | 44 ++++++++++++++++++++++++++++----------------
> >  fs/nfs/nfs4state.c  |  8 +++++++-
> >  2 files changed, 35 insertions(+), 17 deletions(-)
> 
> I was wondering why this commit is not tagged to go in stable as well:
> 
> commit f05c124a70a4953a66acbd6d6c601ea1eb5d0fa7
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Fri Apr 5 14:13:21 2013 -0400
> 
>     SUNRPC: Fix a potential memory leak in rpc_new_client
> 
>     If the call to rpciod_up() fails, we currently leak a reference to the
>     struct rpc_xprt.
>     As part of the fix, we also remove the redundant check for xprt!=NULL.
>     This is already taken care of by the callers.
> 
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=commit;h=f05c124a70a4953a66acbd6d6c601ea1eb5d0fa7

The main reason is that it should be a _very_ rare event, since it
requires a call to try_to_get_module(THIS) to fail, and so I can't see
that it could ever cause a huge leakage.
If someone can show that it is more of a problem than I suggest above,
then I'm happy to reconsider.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
