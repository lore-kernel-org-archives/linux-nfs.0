From: Michel Lespinasse <walken-Y93EPB1FQwg@public.gmane.org>
Subject: Re: NFS hangs with 2.6.25/2.6.26 despite server being reachable
Date: Sun, 20 Jul 2008 19:14:08 -0700
Message-ID: <20080721021408.GA7949@zoy.org>
References: <20080716054053.GE6159@zoy.org> <20080716191553.GG20298@fieldses.org> <20080718060405.GD12135@zoy.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from server.lespinasse.org ([64.142.28.226]:42557 "EHLO
	server.lespinasse.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758696AbYGUCOJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Jul 2008 22:14:09 -0400
In-Reply-To: <20080718060405.GD12135-Y93EPB1FQwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 17, 2008 at 11:04:05PM -0700, Michel Lespinasse wrote:
> On Wed, Jul 16, 2008 at 03:15:53PM -0400, J. Bruce Fields wrote:
> > On Tue, Jul 15, 2008 at 10:40:53PM -0700, Michel Lespinasse wrote:
> > > I'm getting frequent NFS hangs when running 2.6.25 or 2.6.26 on my
> > > NFS clients, while 2.6.24 seems to work fine.
> > > [...]
> > > Any ideas about what might be going wrong and/or what additional
> > > information I should try to collect about the hangs ?
> >
> > A sysrq-T trace showing where the clients were hung might help.  (So,
> > "echo T >/proc/sysrq-trigger", then look at the logs.)
> 
> Thanks for the reply. I'm now running 2.6.25.11 with sysrq enabled.
> Have not captured the failure yet, but then again it's been only one night.
> I prefer to go with 2.6.25 instead of 2.6.26 because 2.6.25 generally
> recovers from the failure after a few minutes - so there is a higher chance
> that I'll actually get something useful logged.

It took me a while, as for some reason I could not get things to fail
this week (It's probably that I don't know all the factors that trigger
the NFS hangs, yet). Then today I got two NFS hangs in a row, running
kernel version 2.6.25.11 on my K7 based client.

In both cases I captured information using alt-sysreq-t, the system
hung there for a few minutes, I double checked that the machine was
pingable from the server, and I got the dumps out of kern.log after
the machine recovered. The logs are incomplete, given that syslog
could not run well with the rootfs hung. I'm not sure if a larger
dmesg buffer would help ? Anyway, please get the logs from

http://lespinasse.org/kern.log
http://lespinasse.org/kern.log.2nd

In both cases I see a lot of nfs_wait_schedule, wait_on_bit_lock,
nfs_revalidate_inode, nfs_check_verifier. Not sure if that's expected,
but that's what I get, and the machine is pingable from the server side.

Hope this helps. Let me know if you want me to try something else.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.
