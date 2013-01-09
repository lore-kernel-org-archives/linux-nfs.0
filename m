Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f47.google.com ([209.85.212.47]:58630 "EHLO
	mail-vb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758023Ab3AIRzJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jan 2013 12:55:09 -0500
Received: by mail-vb0-f47.google.com with SMTP id e21so1811504vbm.20
        for <linux-nfs@vger.kernel.org>; Wed, 09 Jan 2013 09:55:08 -0800 (PST)
Date: Wed, 9 Jan 2013 12:55:03 -0500
From: Chris Perl <chris.perl@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Possible Race Condition on SIGKILL
Message-ID: <20130109175503.GF30872@nyc-qws-132.nyc.delacy.com>
References: <20130107220047.GA30814@nyc-qws-132.nyc.delacy.com>
 <20130108184011.GA30872@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911993608@SACEXCMBX04-PRD.hq.netapp.com>
 <20130108210106.GB30872@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911993A92@SACEXCMBX04-PRD.hq.netapp.com>
 <20130108212343.GC30872@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911993B82@SACEXCMBX04-PRD.hq.netapp.com>
 <20130108221651.GD30872@nyc-qws-132.nyc.delacy.com>
 <20130108221921.GE30872@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911993F1B@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA911993F1B@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Hrm.  I guess I'm in over my head here. Apologoies if I'm just asking
> silly bumbling questions.  You can start ignoring me at any time. :)

I stared at the code for a while and more and now see why what I
outlined is not possible.  Thanks for helping to clarify!

I decided to pull your git repo and compile with HEAD at
87ed50036b866db2ec2ba16b2a7aec4a2b0b7c39 (linux-next as of this
morning).  Using this kernel, I can no longer induce any hangs.

Interestingly, I tried recompiling the CentOS 6.3 kernel with
both the original patch (v4) and the last patch you sent about fixing
priority queues.  With both of those in place, I still run into a
problem.

echo 0 > /proc/sys/sunrpc/rpc_debug after the hang shows (I left in the
previous additional prints and added printing of the tasks pointer
itself):

<6>client: ffff88082896c200, xprt: ffff880829011000, snd_task: ffff880829a1aac0
<6>client: ffff8808282b5600, xprt: ffff880829011000, snd_task: ffff880829a1aac0
<6>--task-- -pid- flgs status -client- --rqstp- -timeout ---ops--
<6>ffff88082a463180 22007 0080    -11 ffff8808282b5600   (null)        0 ffffffffa027b7a0 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
<6>client: ffff88082838cc00, xprt: ffff88082b7c5800, snd_task:   (null)
<6>client: ffff8808283db400, xprt: ffff88082b7c5800, snd_task:   (null)
<6>client: ffff8808283db200, xprt: ffff880829011000, snd_task: ffff880829a1aac0

Any thoughts about other patches that might affect this?
