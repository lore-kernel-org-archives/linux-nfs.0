Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:34471 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752210AbaHROaQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Aug 2014 10:30:16 -0400
Received: by mail-ig0-f177.google.com with SMTP id hn18so7923269igb.4
        for <linux-nfs@vger.kernel.org>; Mon, 18 Aug 2014 07:30:16 -0700 (PDT)
Date: Mon, 18 Aug 2014 10:29:19 -0400
From: Tejun Heo <tj@kernel.org>
To: NeilBrown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        NFS <linux-nfs@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] NFS: state manager thread must stay running.
Message-ID: <20140818142919.GB17668@mtj.dyndns.org>
References: <20140813140831.22f3e9c7@notabene.brown>
 <20140817131156.GB7679@mtj.dyndns.org>
 <20140818071457.4b345727@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140818071457.4b345727@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Neil.

On Mon, Aug 18, 2014 at 07:14:57AM +1000, NeilBrown wrote:
> It does.  The manage will even continue after there are no mounts active if
> it is blocked on a non-responding server.
> 
> If there is an outstanding RPC request to a non-responsive server
> then the only way to abort that request is to send SIGKILL to the thread
> which is waiting for the request.
> So if we want things to clean up properly on shutdown it seems best for a
> sigkill to be able to abort that thread.

I see.  I'm not convinced SIGKILL is the right way to communicate
things like this tho.  If this is actually a thing which needs to be
exposed, we'd be a lot better off with an interface which is more to
the point rather than meddling with signals to the manager kernel
thread, which ultimately is an implementation detail.  Given the
requirement, I don't have objections to the patch but the requirement
seems rather lopsided.

Thanks.

-- 
tejun
