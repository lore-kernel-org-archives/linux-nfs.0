From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch] fix statd -n
Date: Sun, 20 Apr 2008 20:02:14 -0400
Message-ID: <20080421000214.GA5453@fieldses.org>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com> <20080418173646.GC19038@fieldses.org> <480902CA.1070805@redhat.com> <48090356.9020703@redhat.com> <20080418203225.GD28277@fieldses.org> <24c1515f0804181346g5867fa1fqfbbcd13af25027cb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Staubach <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: Janne Karhunen <janne.karhunen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:43006 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751859AbYDUACR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 20 Apr 2008 20:02:17 -0400
In-Reply-To: <24c1515f0804181346g5867fa1fqfbbcd13af25027cb-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 18, 2008 at 04:46:02PM -0400, Janne Karhunen wrote:
> On Fri, Apr 18, 2008 at 4:32 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> >  > Sorry, not very clear.  Perhaps statd should bind to the loopback
> >  > interface in addition to any other interfaces if it doesn't bind
> >  > to INADDR_ANY.
> >
> >  Right, that's what would make the most sense to me.  Janne, is there any
> >  reason that wouldn't solve your problem?
> 
> I didn't get the idea. So the idea is to use multiple sockets,
> one bound to LOOPBACK and one to external interface?

I suppose so.  One socket would be for communication for the local
kernel nfsd, one for communication with statd peers.

> Complicated and unclean in my opinion: one address
> should suffice.

The advantage is that it would require no changes to the kernel or
kernel interfaces, and would also solve the problem for people that
don't want to upgrade their kernels.

The "rpc over lo" interface to the kernel's lockd is simple enough, and
I'd rather not replace it with "rpc over either lo or the interface
specified via sysctl" unless there's a really clear advantage.

(Also, would your patch mean lockd could accept requests that could have
spoofed source addresses?)

--b.
