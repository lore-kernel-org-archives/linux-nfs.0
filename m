Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2043 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751047Ab2GBTIF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Jul 2012 15:08:05 -0400
Date: Mon, 2 Jul 2012 15:07:58 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Andreas Heinlein <aheinlein@gmx.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kernel NFSd CPU hog?
Message-ID: <20120702150758.66893d08@tlielax.poochiereds.net>
In-Reply-To: <4FF16D54.6090200@gmx.com>
References: <4FF16D54.6090200@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 02 Jul 2012 11:43:48 +0200
Andreas Heinlein <aheinlein@gmx.com> wrote:

> Hello,
> 
> we have a strange NFS problem with a newly setup Linux server, and I 
> hope someone here can help.
> 
> The symptom is that, slowly over time (speaking of several days up to 2 
> weeks), the kernel nfsd processes/threads consume more and more CPU 
> until the system finally becomes unresponsive. We recorded system 
> activity with sar, which shows that CPU (system) usage slowly rises 
> after reboot from about 1% to nearly 100% over the course of several 
> days. Load averages stay around 0.1-0.3 until 100% are reached, up to 
> this point the problem is almost not noticable from the clients. Then 
> load averages climb up to 30.0; at this point the system becomes more or 
> less unusable and has to be restarted. 'top' output shows the CPU usage 
> evenly distributed across all nfsd threads.
> 
> The system is a fairly recent, though entry level server with a Core i3 
> and 4G RAM, hosting the home directories for about 15-20 clients. CPU 
> activity does not drop at night, when no clients are connected. It is 
> running Debian 6.0 with linux 3.2.0 (from the backports repository), 
> with nfs-utils 1.2.5 (also from the backports repository). I suspect 
> that these backports might be the culprit, but since we need this kernel 
> for other purposes, and I cannot reboot that machine during office 
> hours, I'd rather not try going back to the official Debian kernel 
> without good reasons. If there are known problems, I'd give it a try.
> 

Find the pid of one of the nfsd threads that's spinning, then get a
stack trace from it:

    # cat /proc/<pidofnfsd>/stack

...that should give us some idea of what it's doing.

--
Jeff Layton <jlayton@redhat.com>
