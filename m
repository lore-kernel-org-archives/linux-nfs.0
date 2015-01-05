Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f176.google.com ([209.85.192.176]:38944 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452AbbAEWII (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Jan 2015 17:08:08 -0500
Received: by mail-pd0-f176.google.com with SMTP id r10so29029062pdi.21
        for <linux-nfs@vger.kernel.org>; Mon, 05 Jan 2015 14:08:08 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 5 Jan 2015 14:08:04 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trondmy@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: schedule WARNING from nfs41_callback_svc
Message-ID: <20150105140804.0185ae17@synchrony.poochiereds.net>
In-Reply-To: <20150105140003.0ddd42a2@synchrony.poochiereds.net>
References: <20150105202026.GA12067@fieldses.org>
	<20150105140003.0ddd42a2@synchrony.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 5 Jan 2015 14:00:03 -0800
Jeff Layton <jlayton@primarydata.com> wrote:

> On Mon, 5 Jan 2015 15:20:26 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On 3.19-rc2 I'm getting:
> > 
> > 	[  426.715480] WARNING: CPU: 2 PID: 7920 at kernel/sched/core.c:7303 __might_sleep+0x92/0xa0()
> > 	[  426.715485] do not call blocking ops when !TASK_RUNNING; state=1 set at [<ffffffff810ad99f>] prepare_to_wait+0x2f/0x90
> > 	...
> > 	[  426.715613]  [<ffffffff81094eb4>] groups_alloc+0x34/0x110
> > 	[  426.715638]  [<ffffffffa00181da>] svcauth_unix_accept+0x14a/0x280 [sunrpc]
> > 	[  426.715659]  [<ffffffffa00170a8>] svc_authenticate+0xc8/0xe0 [sunrpc]
> > 	[  426.715683]  [<ffffffffa0012cf2>] svc_process_common+0x202/0x6d0 [sunrpc]
> > 	[  426.715703]  [<ffffffffa00135d8>] bc_svc_process+0x1c8/0x260 [sunrpc]
> > 	[  426.715725]  [<ffffffffa01da8e0>] nfs41_callback_svc+0x100/0x1b0 [nfsv4]
> > 	...
> > 
> > Looks like this is a new check added by 8eb23b9f35aa "sched: Debug
> > nested sleeps".  I don't *think* it's catching a real problem here, but
> > maybe I'm missing some subtlety.  I suppose nfs41_callback_svc() could
> > move the finish_wait() so it's done before the bc_svc_process()?
> > 
> 
> Yeah, the current code looks quite goofy. We really shouldn't be doing
> all of the bc_svc_process stuff while in TASK_INTERRUPTIBLE. Doing what
> you suggest looks like the right fix to me.
> 

...and while we're on the subject...

Why is nfs41_callback_svc sleeping in TASK_INTERRUPTIBLE anyway? Do we
expect that kthread to receive signals? If not, perhaps we should go
ahead and switch that over to TASK_UNINTERRUPTIBLE instead?

-- 
Jeff Layton <jlayton@primarydata.com>
