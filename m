Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:38038 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755686Ab3ANPJz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jan 2013 10:09:55 -0500
Received: by mail-qc0-f173.google.com with SMTP id b12so2547394qca.18
        for <linux-nfs@vger.kernel.org>; Mon, 14 Jan 2013 07:09:55 -0800 (PST)
Date: Mon, 14 Jan 2013 10:09:48 -0500
From: Chris Perl <chris.perl@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Possible Race Condition on SIGKILL
Message-ID: <20130114150948.GH30872@nyc-qws-132.nyc.delacy.com>
References: <4FA345DA4F4AE44899BD2B03EEEC2FA911993A92@SACEXCMBX04-PRD.hq.netapp.com>
 <20130108212343.GC30872@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911993B82@SACEXCMBX04-PRD.hq.netapp.com>
 <20130108221651.GD30872@nyc-qws-132.nyc.delacy.com>
 <20130108221921.GE30872@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911993F1B@SACEXCMBX04-PRD.hq.netapp.com>
 <20130109175503.GF30872@nyc-qws-132.nyc.delacy.com>
 <1357764777.9862.1.camel@lade.trondhjem.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911997CA3@SACEXCMBX04-PRD.hq.netapp.com>
 <20130111161944.GG30872@nyc-qws-132.nyc.delacy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130111161944.GG30872@nyc-qws-132.nyc.delacy.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 11, 2013 at 11:19:44AM -0500, Chris Perl wrote:
> On Thu, Jan 10, 2013 at 09:30:58PM +0000, Myklebust, Trond wrote:
> > On Wed, 2013-01-09 at 15:52 -0500, Trond Myklebust wrote:
> > > On Wed, 2013-01-09 at 12:55 -0500, Chris Perl wrote:
> > > > > Hrm.  I guess I'm in over my head here. Apologoies if I'm just asking
> > > > > silly bumbling questions.  You can start ignoring me at any time. :)
> > > > 
> > > > I stared at the code for a while and more and now see why what I
> > > > outlined is not possible.  Thanks for helping to clarify!
> > > > 
> > > > I decided to pull your git repo and compile with HEAD at
> > > > 87ed50036b866db2ec2ba16b2a7aec4a2b0b7c39 (linux-next as of this
> > > > morning).  Using this kernel, I can no longer induce any hangs.
> > > > 
> > > > Interestingly, I tried recompiling the CentOS 6.3 kernel with
> > > > both the original patch (v4) and the last patch you sent about fixing
> > > > priority queues.  With both of those in place, I still run into a
> > > > problem.
> > > > 
> > > > echo 0 > /proc/sys/sunrpc/rpc_debug after the hang shows (I left in the
> > > > previous additional prints and added printing of the tasks pointer
> > > > itself):
> > > > 
> > > > <6>client: ffff88082896c200, xprt: ffff880829011000, snd_task: ffff880829a1aac0
> > > > <6>client: ffff8808282b5600, xprt: ffff880829011000, snd_task: ffff880829a1aac0
> > > > <6>--task-- -pid- flgs status -client- --rqstp- -timeout ---ops--
> > > > <6>ffff88082a463180 22007 0080    -11 ffff8808282b5600   (null)        0 ffffffffa027b7a0 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
> > > > <6>client: ffff88082838cc00, xprt: ffff88082b7c5800, snd_task:   (null)
> > > > <6>client: ffff8808283db400, xprt: ffff88082b7c5800, snd_task:   (null)
> > > > <6>client: ffff8808283db200, xprt: ffff880829011000, snd_task: ffff880829a1aac0
> > > > 
> > > > Any thoughts about other patches that might affect this?
> > > 
> > > Hmm... The only one that springs to mind is this one (see attachment)
> > > and then the 'connect' fixes that you helped us with previously.
> > 
> > Never mind. I suspect that the main reason why RHEL-6.3 is still
> > vulnerable is that it lacks commit
> > 961a828df64979d2a9faeeeee043391670a193b9 (SUNRPC: Fix potential races in
> > xprt_lock_write_next()).
> 
> Great, thanks!  I've add this on top of the others and am now testing.
> I'll let you know how it goes.

With all 4 patches in place, I am no longer able to hang my CentOS 6.3
system.  I have not tested all the various combinations of the 4
patches, but can definitely confirm that without either of:

961a828df64979d2a9faeeeee043391670a193b9 SUNRPC: Fix potential races in xprt_lock_write_next()
87ed50036b866db2ec2ba16b2a7aec4a2b0b7c39 SUNRPC: Ensure we release the socket write lock if the rpc_task exits early

I can hang the system using the test program I sent in my first email.

I'll follow up with Red Hat and ask that they include all 4 patches for
6.4 (some of the earlier ones they may already have).

Thanks so much for all the help!
