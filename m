From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS hangs with 2.6.25/2.6.26 despite server being reachable
Date: Wed, 23 Jul 2008 17:52:10 -0400
Message-ID: <20080723215210.GB29065@fieldses.org>
References: <20080716054053.GE6159@zoy.org> <20080716191553.GG20298@fieldses.org> <20080718060405.GD12135@zoy.org> <20080721021408.GA7949@zoy.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Michel Lespinasse <walken-Y93EPB1FQwg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:59140 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751914AbYGWVwM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jul 2008 17:52:12 -0400
In-Reply-To: <20080721021408.GA7949-Y93EPB1FQwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 20, 2008 at 07:14:08PM -0700, Michel Lespinasse wrote:
> On Thu, Jul 17, 2008 at 11:04:05PM -0700, Michel Lespinasse wrote:
> > On Wed, Jul 16, 2008 at 03:15:53PM -0400, J. Bruce Fields wrote:
> > > On Tue, Jul 15, 2008 at 10:40:53PM -0700, Michel Lespinasse wrote:
> > > > I'm getting frequent NFS hangs when running 2.6.25 or 2.6.26 on my
> > > > NFS clients, while 2.6.24 seems to work fine.
> > > > [...]
> > > > Any ideas about what might be going wrong and/or what additional
> > > > information I should try to collect about the hangs ?
> > >
> > > A sysrq-T trace showing where the clients were hung might help.  (So,
> > > "echo T >/proc/sysrq-trigger", then look at the logs.)
> > 
> > Thanks for the reply. I'm now running 2.6.25.11 with sysrq enabled.
> > Have not captured the failure yet, but then again it's been only one night.
> > I prefer to go with 2.6.25 instead of 2.6.26 because 2.6.25 generally
> > recovers from the failure after a few minutes - so there is a higher chance
> > that I'll actually get something useful logged.
> 
> It took me a while, as for some reason I could not get things to fail
> this week (It's probably that I don't know all the factors that trigger
> the NFS hangs, yet). Then today I got two NFS hangs in a row, running
> kernel version 2.6.25.11 on my K7 based client.
> 
> In both cases I captured information using alt-sysreq-t, the system
> hung there for a few minutes, I double checked that the machine was
> pingable from the server, and I got the dumps out of kern.log after
> the machine recovered. The logs are incomplete, given that syslog
> could not run well with the rootfs hung. I'm not sure if a larger
> dmesg buffer would help ? Anyway, please get the logs from
> 
> http://lespinasse.org/kern.log
> http://lespinasse.org/kern.log.2nd

Oh, sorry, I think I overlooked the note in your original message that
this happened after suspend-to-ram.  That's interesting!  You really
need someone with more experience debugging the rpc client.... It might
also be worth turning on rpc debugging during the hang just to get the
dump of rpc task states.  (So

	echo 0 >/proc/sys/sunrpc/rpc_debug

and capture the first table it dumps to the log.  Or Trond or Chuck
might have some better idea.)

--b.

> 
> In both cases I see a lot of nfs_wait_schedule, wait_on_bit_lock,
> nfs_revalidate_inode, nfs_check_verifier. Not sure if that's expected,
> but that's what I get, and the machine is pingable from the server side.
> 
> Hope this helps. Let me know if you want me to try something else.
> 
> -- 
> Michel "Walken" Lespinasse
> A program is never fully debugged until the last user dies.
