From: Michel Lespinasse <walken-Y93EPB1FQwg@public.gmane.org>
Subject: Re: NFS hangs with 2.6.25/2.6.26 despite server being reachable
Date: Thu, 17 Jul 2008 23:04:05 -0700
Message-ID: <20080718060405.GD12135@zoy.org>
References: <20080716054053.GE6159@zoy.org> <20080716191553.GG20298@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from server.lespinasse.org ([64.142.28.226]:44098 "EHLO
	server.lespinasse.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751614AbYGRGEH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jul 2008 02:04:07 -0400
In-Reply-To: <20080716191553.GG20298@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 16, 2008 at 03:15:53PM -0400, J. Bruce Fields wrote:
> On Tue, Jul 15, 2008 at 10:40:53PM -0700, Michel Lespinasse wrote:
> > I'm getting frequent NFS hangs when running 2.6.25 or 2.6.26 on my
> > NFS clients, while 2.6.24 seems to work fine.
> > [...]
> > Any ideas about what might be going wrong and/or what additional
> > information I should try to collect about the hangs ?
>
> A sysrq-T trace showing where the clients were hung might help.  (So,
> "echo T >/proc/sysrq-trigger", then look at the logs.)

Thanks for the reply. I'm now running 2.6.25.11 with sysrq enabled.
Have not captured the failure yet, but then again it's been only one night.
I prefer to go with 2.6.25 instead of 2.6.26 because 2.6.25 generally
recovers from the failure after a few minutes - so there is a higher chance
that I'll actually get something useful logged.

> If it were possible to get it down to a simple test case, then we'd
> probably learn something from a git-bisect to figure out exactly when
> the problem was first introduced.

I wish I had a better way to reproduce this... as it is it happens only
every 2 or 3 days (with 2.6.25.4, but I suppose 2.6.25.11 will be the same)

I'll let you know when I capture a good trace.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.
