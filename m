Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f180.google.com ([209.85.220.180]:43233 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789AbbAYV3l (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 25 Jan 2015 16:29:41 -0500
Received: by mail-vc0-f180.google.com with SMTP id hy10so1779596vcb.11
        for <linux-nfs@vger.kernel.org>; Sun, 25 Jan 2015 13:29:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1282FA7B-EE04-4EDE-A659-0697490CB9ED@oracle.com>
References: <1422145127-81838-1-git-send-email-trond.myklebust@primarydata.com>
	<1422145127-81838-2-git-send-email-trond.myklebust@primarydata.com>
	<1282FA7B-EE04-4EDE-A659-0697490CB9ED@oracle.com>
Date: Sun, 25 Jan 2015 16:29:40 -0500
Message-ID: <CAHQdGtTHhP3M6b3u3uCofcF4g2nGdOKUyMe92EZ5BFCoFFEUgA@mail.gmail.com>
Subject: Re: [PATCH 2/2] SUNRPC: Allow waiting on memory allocation
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 25, 2015 at 3:11 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
>
> On Jan 24, 2015, at 7:18 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>
> > We should be safe now, as long as we don't do GFP_IO or higher allocations
>
> Should the GFP flags in xprt_rdma_allocate() reflect this change
> as well? The non-swap case uses GFP_NOFS currently, and the

GFP_NOFS or GFP_NOWAIT? If the former, then that would be yet further
justification for PATCH 1/2.

> swap case does not include GFP_MEMALLOC. These choices might be
> out of date.
>
> If so I can submit a patch on top of my existing for-3.20 series
> that changes xprt_rdma_allocate() to use the same flags as
> rpc_malloc().

Yes. I think GFP_NOIO is the more conservative (and correct) approach
here, rather than GFP_NOFS. In particular it means that we won't
trigger any new swap-over-nfs activity.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
