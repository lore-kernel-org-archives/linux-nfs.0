Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f181.google.com ([209.85.216.181]:47176 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753634Ab3AHWT1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jan 2013 17:19:27 -0500
Received: by mail-qc0-f181.google.com with SMTP id x40so1146584qcp.12
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jan 2013 14:19:26 -0800 (PST)
Date: Tue, 8 Jan 2013 17:19:21 -0500
From: Chris Perl <chris.perl@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Possible Race Condition on SIGKILL
Message-ID: <20130108221921.GE30872@nyc-qws-132.nyc.delacy.com>
References: <1357590561.28341.11.camel@lade.trondhjem.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911991BE9@SACEXCMBX04-PRD.hq.netapp.com>
 <20130107220047.GA30814@nyc-qws-132.nyc.delacy.com>
 <20130108184011.GA30872@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911993608@SACEXCMBX04-PRD.hq.netapp.com>
 <20130108210106.GB30872@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911993A92@SACEXCMBX04-PRD.hq.netapp.com>
 <20130108212343.GC30872@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911993B82@SACEXCMBX04-PRD.hq.netapp.com>
 <20130108221651.GD30872@nyc-qws-132.nyc.delacy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130108221651.GD30872@nyc-qws-132.nyc.delacy.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 08, 2013 at 05:16:51PM -0500, Chris Perl wrote:
> > The lock is associated with the rpc_task. Threads can normally only
> > access an rpc_task when it is on a wait queue (while holding the wait
> > queue lock) unless they are given ownership of the rpc_task.
> > 
> > IOW: the scenario you describe should not be possible, since it relies
> > on thread 1 assigning the lock to the rpc_task after it has been removed
> > from the wait queue.
> 
> Hrm.  I guess I'm in over my head here. Apologoies if I'm just asking
> silly bumbling questions.  You can start ignoring me at any time. :)
> 
> I was talking about setting (or leaving set) the XPRT_LOCKED bit in
> rpc_xprt->state.  By "assigning the lock" I really just mean that thread
> 1 leaves XPRT_LOCKED set in rpc_xprt->state and sets rpc_xprt->snd_task
> to thread 2.
> 
> > If you are recompiling the kernel, perhaps you can also add in a patch
> > to rpc_show_tasks() to display the current value of
> > clnt->cl_xprt->snd_task?
> 
> Sure.  This is what 'echo 0 > /proc/sys/sunrpc/rpc_debug' shows after
> the hang (with my extra prints):
> 
> # cat /proc/kmsg
> ...
> <6>client: ffff88082b6c9c00, xprt: ffff880824aef800, snd_task: ffff881029c63ec0
> <6>client: ffff88082b6c9e00, xprt: ffff880824aef800, snd_task: ffff881029c63ec0
> <6>-pid- flgs status -client- --rqstp- -timeout ---ops--
> <6>18091 0080    -11 ffff88082b6c9e00   (null)      ffff0770ns3 ACCESS a:call_reserveresult q:xprt_sending
> <6>client: ffff88082a244600, xprt: ffff88082a343000, snd_task:   (null)
> <6>client: ffff880829181600, xprt: ffff88082a343000, snd_task:   (null)
> <6>client: ffff880828170200, xprt: ffff880824aef800, snd_task: ffff881029c63ec0

Sorry, that output was a little messed up.  Here it is again:

<6>client: ffff88082b6c9c00, xprt: ffff880824aef800, snd_task: ffff881029c63ec0
<6>client: ffff88082b6c9e00, xprt: ffff880824aef800, snd_task: ffff881029c63ec0
<6>-pid- flgs status -client- --rqstp- -timeout ---ops--
<6>18091 0080    -11 ffff88082b6c9e00   (null)        0 ffffffffa027b7e0 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
<6>client: ffff88082a244600, xprt: ffff88082a343000, snd_task:   (null)
<6>client: ffff880829181600, xprt: ffff88082a343000, snd_task:   (null)
<6>client: ffff880828170200, xprt: ffff880824aef800, snd_task: ffff881029c63ec0
