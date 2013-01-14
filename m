Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:45093 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757156Ab3ANTNA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jan 2013 14:13:00 -0500
Received: by mail-qc0-f171.google.com with SMTP id d1so2746179qca.30
        for <linux-nfs@vger.kernel.org>; Mon, 14 Jan 2013 11:12:59 -0800 (PST)
Date: Mon, 14 Jan 2013 14:12:53 -0500
From: Chris Perl <chris.perl@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Possible Race Condition on SIGKILL
Message-ID: <20130114191253.GI30872@nyc-qws-132.nyc.delacy.com>
References: <4FA345DA4F4AE44899BD2B03EEEC2FA911993B82@SACEXCMBX04-PRD.hq.netapp.com>
 <20130108221651.GD30872@nyc-qws-132.nyc.delacy.com>
 <20130108221921.GE30872@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911993F1B@SACEXCMBX04-PRD.hq.netapp.com>
 <20130109175503.GF30872@nyc-qws-132.nyc.delacy.com>
 <1357764777.9862.1.camel@lade.trondhjem.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911997CA3@SACEXCMBX04-PRD.hq.netapp.com>
 <20130111161944.GG30872@nyc-qws-132.nyc.delacy.com>
 <20130114150948.GH30872@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9119B307F@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9119B307F@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 14, 2013 at 03:25:50PM +0000, Myklebust, Trond wrote:
> On Mon, 2013-01-14 at 10:09 -0500, Chris Perl wrote:
> > On Fri, Jan 11, 2013 at 11:19:44AM -0500, Chris Perl wrote:
> > > On Thu, Jan 10, 2013 at 09:30:58PM +0000, Myklebust, Trond wrote:
> > > > On Wed, 2013-01-09 at 15:52 -0500, Trond Myklebust wrote:
> > > > > On Wed, 2013-01-09 at 12:55 -0500, Chris Perl wrote:
> > > > > > > Hrm.  I guess I'm in over my head here. Apologoies if I'm just asking
> > > > > > > silly bumbling questions.  You can start ignoring me at any time. :)
> > > > > > 
> > > > > > I stared at the code for a while and more and now see why what I
> > > > > > outlined is not possible.  Thanks for helping to clarify!
> > > > > > 
> > > > > > I decided to pull your git repo and compile with HEAD at
> > > > > > 87ed50036b866db2ec2ba16b2a7aec4a2b0b7c39 (linux-next as of this
> > > > > > morning).  Using this kernel, I can no longer induce any hangs.
> > > > > > 
> > > > > > Interestingly, I tried recompiling the CentOS 6.3 kernel with
> > > > > > both the original patch (v4) and the last patch you sent about fixing
> > > > > > priority queues.  With both of those in place, I still run into a
> > > > > > problem.
> > > > > > 
> > > > > > echo 0 > /proc/sys/sunrpc/rpc_debug after the hang shows (I left in the
> > > > > > previous additional prints and added printing of the tasks pointer
> > > > > > itself):
> > > > > > 
> > > > > > <6>client: ffff88082896c200, xprt: ffff880829011000, snd_task: ffff880829a1aac0
> > > > > > <6>client: ffff8808282b5600, xprt: ffff880829011000, snd_task: ffff880829a1aac0
> > > > > > <6>--task-- -pid- flgs status -client- --rqstp- -timeout ---ops--
> > > > > > <6>ffff88082a463180 22007 0080    -11 ffff8808282b5600   (null)        0 ffffffffa027b7a0 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
> > > > > > <6>client: ffff88082838cc00, xprt: ffff88082b7c5800, snd_task:   (null)
> > > > > > <6>client: ffff8808283db400, xprt: ffff88082b7c5800, snd_task:   (null)
> > > > > > <6>client: ffff8808283db200, xprt: ffff880829011000, snd_task: ffff880829a1aac0
> > > > > > 
> > > > > > Any thoughts about other patches that might affect this?
> > > > > 
> > > > > Hmm... The only one that springs to mind is this one (see attachment)
> > > > > and then the 'connect' fixes that you helped us with previously.
> > > > 
> > > > Never mind. I suspect that the main reason why RHEL-6.3 is still
> > > > vulnerable is that it lacks commit
> > > > 961a828df64979d2a9faeeeee043391670a193b9 (SUNRPC: Fix potential races in
> > > > xprt_lock_write_next()).
> > > 
> > > Great, thanks!  I've add this on top of the others and am now testing.
> > > I'll let you know how it goes.
> > 
> > With all 4 patches in place, I am no longer able to hang my CentOS 6.3
> > system.  I have not tested all the various combinations of the 4
> > patches, but can definitely confirm that without either of:
> > 
> > 961a828df64979d2a9faeeeee043391670a193b9 SUNRPC: Fix potential races in xprt_lock_write_next()
> > 87ed50036b866db2ec2ba16b2a7aec4a2b0b7c39 SUNRPC: Ensure we release the socket write lock if the rpc_task exits early
> > 
> > I can hang the system using the test program I sent in my first email.
> > 
> > I'll follow up with Red Hat and ask that they include all 4 patches for
> > 6.4 (some of the earlier ones they may already have).
> > 
> > Thanks so much for all the help!
> 
> Likewise. Thank you for all the work you did in debugging and testing.
> It is much appreciated.

Oh, I had just one other question about the final version of the patch
you created.  In xprt_release, is it safe to access xprt->snd_task
without the transport_lock because of the rcu_lock()/rcu_unlock() stuff,
or because all architectures can atomically read pointer sized values
that are aligned in certain ways, or something else?
