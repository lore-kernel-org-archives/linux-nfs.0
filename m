Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55604 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933261Ab2HXUaA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Aug 2012 16:30:00 -0400
Date: Fri, 24 Aug 2012 16:29:56 -0400
To: Andreas Heinlein <aheinlein@gmx.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: Kernel NFSd CPU hog?
Message-ID: <20120824202956.GA21832@fieldses.org>
References: <4FF16D54.6090200@gmx.com>
 <20120702150758.66893d08@tlielax.poochiereds.net>
 <4FF2E710.5010804@gmx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FF2E710.5010804@gmx.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

By the way if possible it would also be worth testing

	git://linux-nfs.org/~bfields/linux.git for-3.6

(which will probably also be included in 3.6-rc4).  I suspect this bug
is fixed....--b.

On Tue, Jul 03, 2012 at 02:35:28PM +0200, Andreas Heinlein wrote:
> On 02.07.2012 21:07, Jeff Layton wrote:
> >On Mon, 02 Jul 2012 11:43:48 +0200
> >Andreas Heinlein <aheinlein@gmx.com> wrote:
> >
> >>Hello,
> >>
> >>we have a strange NFS problem with a newly setup Linux server, and I
> >>hope someone here can help.
> >>
> >>The symptom is that, slowly over time (speaking of several days up to 2
> >>weeks), the kernel nfsd processes/threads consume more and more CPU
> >>until the system finally becomes unresponsive. We recorded system
> >>activity with sar, which shows that CPU (system) usage slowly rises
> >>after reboot from about 1% to nearly 100% over the course of several
> >>days. Load averages stay around 0.1-0.3 until 100% are reached, up to
> >>this point the problem is almost not noticable from the clients. Then
> >>load averages climb up to 30.0; at this point the system becomes more or
> >>less unusable and has to be restarted. 'top' output shows the CPU usage
> >>evenly distributed across all nfsd threads.
> >>
> >>The system is a fairly recent, though entry level server with a Core i3
> >>and 4G RAM, hosting the home directories for about 15-20 clients. CPU
> >>activity does not drop at night, when no clients are connected. It is
> >>running Debian 6.0 with linux 3.2.0 (from the backports repository),
> >>with nfs-utils 1.2.5 (also from the backports repository). I suspect
> >>that these backports might be the culprit, but since we need this kernel
> >>for other purposes, and I cannot reboot that machine during office
> >>hours, I'd rather not try going back to the official Debian kernel
> >>without good reasons. If there are known problems, I'd give it a try.
> >>
> >Find the pid of one of the nfsd threads that's spinning, then get a
> >stack trace from it:
> >
> >     # cat /proc/<pidofnfsd>/stack
> >
> >...that should give us some idea of what it's doing.
> >
> >--
> >Jeff Layton <jlayton@redhat.com>
> >--
> >To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Hello,
> 
> I've run into the problem again, and did a 'watch cat
> /proc/<pidofnfsd>/stack'. It actually seems to be doing something,
> because the stack trace changes every now and then, but mostly looks
> like
> 
> [<c1038be2>] try_to_wake_up+0x144/0x14d
> [<c1045d26>] lock_timer_base+0x19/0x34
> [<c10462fd>] __mod_timer+0x10c/0x116
> [<c1045d41>] process_timeout+0x0/0x5
> [<f858a243>] svc_recv+0x2e2/0x698 [sunrpc]
> [<c1038beb>] default_wake_function+0x0/0x8
> [<f8640748>] nfsd+0x90/0x108 [nfsd]
> [<f86406b8>] nfsd+0x0/0x108 [nfsd]
> [<c105176b>] kthread+0x63/0x68
> [<c1051708>] kthread+0x0/0x68
> [<c12dadbe>] kernel_thread_helper+0x6/0x10
> [<ffffffff>] 0xffffffff
> 
> Meanwhile, I've found a quite recent thread on this list named "3.0+
> NFS issues", and within two links to Ubuntu bug reports
> (https://bugs.launchpad.net/ubuntu/+source/nfs-utils/+bug/879334 and
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1006446) and
> again to a kernel bug
> (https://bugzilla.kernel.org/show_bug.cgi?id=40912), all suggesting
> that this is indeed a kernel 3.0 problem.
> 
> So I will try going back to 2.6.32 and hope this issue gets fixed soon.
> 
> Thanks for your help!
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
