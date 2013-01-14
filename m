Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:16026 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755348Ab3ANPZw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jan 2013 10:25:52 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chris Perl <chris.perl@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Possible Race Condition on SIGKILL
Date: Mon, 14 Jan 2013 15:25:50 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9119B307F@SACEXCMBX04-PRD.hq.netapp.com>
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
	 <20130114150948.GH30872@nyc-qws-132.nyc.delacy.com>
In-Reply-To: <20130114150948.GH30872@nyc-qws-132.nyc.delacy.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-01-14 at 10:09 -0500, Chris Perl wrote:
+AD4- On Fri, Jan 11, 2013 at 11:19:44AM -0500, Chris Perl wrote:
+AD4- +AD4- On Thu, Jan 10, 2013 at 09:30:58PM +-0000, Myklebust, Trond wrote:
+AD4- +AD4- +AD4- On Wed, 2013-01-09 at 15:52 -0500, Trond Myklebust wrote:
+AD4- +AD4- +AD4- +AD4- On Wed, 2013-01-09 at 12:55 -0500, Chris Perl wrote:
+AD4- +AD4- +AD4- +AD4- +AD4- +AD4- Hrm.  I guess I'm in over my head here. Apologoies if I'm just asking
+AD4- +AD4- +AD4- +AD4- +AD4- +AD4- silly bumbling questions.  You can start ignoring me at any time. :)
+AD4- +AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- +AD4- I stared at the code for a while and more and now see why what I
+AD4- +AD4- +AD4- +AD4- +AD4- outlined is not possible.  Thanks for helping to clarify+ACE-
+AD4- +AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- +AD4- I decided to pull your git repo and compile with HEAD at
+AD4- +AD4- +AD4- +AD4- +AD4- 87ed50036b866db2ec2ba16b2a7aec4a2b0b7c39 (linux-next as of this
+AD4- +AD4- +AD4- +AD4- +AD4- morning).  Using this kernel, I can no longer induce any hangs.
+AD4- +AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- +AD4- Interestingly, I tried recompiling the CentOS 6.3 kernel with
+AD4- +AD4- +AD4- +AD4- +AD4- both the original patch (v4) and the last patch you sent about fixing
+AD4- +AD4- +AD4- +AD4- +AD4- priority queues.  With both of those in place, I still run into a
+AD4- +AD4- +AD4- +AD4- +AD4- problem.
+AD4- +AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- +AD4- echo 0 +AD4- /proc/sys/sunrpc/rpc+AF8-debug after the hang shows (I left in the
+AD4- +AD4- +AD4- +AD4- +AD4- previous additional prints and added printing of the tasks pointer
+AD4- +AD4- +AD4- +AD4- +AD4- itself):
+AD4- +AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- +AD4- +ADw-6+AD4-client: ffff88082896c200, xprt: ffff880829011000, snd+AF8-task: ffff880829a1aac0
+AD4- +AD4- +AD4- +AD4- +AD4- +ADw-6+AD4-client: ffff8808282b5600, xprt: ffff880829011000, snd+AF8-task: ffff880829a1aac0
+AD4- +AD4- +AD4- +AD4- +AD4- +ADw-6+AD4---task-- -pid- flgs status -client- --rqstp- -timeout ---ops--
+AD4- +AD4- +AD4- +AD4- +AD4- +ADw-6+AD4-ffff88082a463180 22007 0080    -11 ffff8808282b5600   (null)        0 ffffffffa027b7a0 nfsv3 ACCESS a:call+AF8-reserveresult q:xprt+AF8-sending
+AD4- +AD4- +AD4- +AD4- +AD4- +ADw-6+AD4-client: ffff88082838cc00, xprt: ffff88082b7c5800, snd+AF8-task:   (null)
+AD4- +AD4- +AD4- +AD4- +AD4- +ADw-6+AD4-client: ffff8808283db400, xprt: ffff88082b7c5800, snd+AF8-task:   (null)
+AD4- +AD4- +AD4- +AD4- +AD4- +ADw-6+AD4-client: ffff8808283db200, xprt: ffff880829011000, snd+AF8-task: ffff880829a1aac0
+AD4- +AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- +AD4- Any thoughts about other patches that might affect this?
+AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- Hmm... The only one that springs to mind is this one (see attachment)
+AD4- +AD4- +AD4- +AD4- and then the 'connect' fixes that you helped us with previously.
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- Never mind. I suspect that the main reason why RHEL-6.3 is still
+AD4- +AD4- +AD4- vulnerable is that it lacks commit
+AD4- +AD4- +AD4- 961a828df64979d2a9faeeeee043391670a193b9 (SUNRPC: Fix potential races in
+AD4- +AD4- +AD4- xprt+AF8-lock+AF8-write+AF8-next()).
+AD4- +AD4- 
+AD4- +AD4- Great, thanks+ACE-  I've add this on top of the others and am now testing.
+AD4- +AD4- I'll let you know how it goes.
+AD4- 
+AD4- With all 4 patches in place, I am no longer able to hang my CentOS 6.3
+AD4- system.  I have not tested all the various combinations of the 4
+AD4- patches, but can definitely confirm that without either of:
+AD4- 
+AD4- 961a828df64979d2a9faeeeee043391670a193b9 SUNRPC: Fix potential races in xprt+AF8-lock+AF8-write+AF8-next()
+AD4- 87ed50036b866db2ec2ba16b2a7aec4a2b0b7c39 SUNRPC: Ensure we release the socket write lock if the rpc+AF8-task exits early
+AD4- 
+AD4- I can hang the system using the test program I sent in my first email.
+AD4- 
+AD4- I'll follow up with Red Hat and ask that they include all 4 patches for
+AD4- 6.4 (some of the earlier ones they may already have).
+AD4- 
+AD4- Thanks so much for all the help+ACE-

Likewise. Thank you for all the work you did in debugging and testing.
It is much appreciated.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
