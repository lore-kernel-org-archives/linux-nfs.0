Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:4537 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751730Ab2DRK73 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Apr 2012 06:59:29 -0400
Date: Wed, 18 Apr 2012 06:59:26 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Simo Sorce <simo@redhat.com>, bfields@redhat.com,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org
Subject: Re: [PATCH 4/5] SUNRPC: Add RPC based upcall mechanism for RPCGSS
 auth
Message-ID: <20120418065926.55d75ec2@tlielax.poochiereds.net>
In-Reply-To: <20120417222825.GA32619@fieldses.org>
References: <1334669948-4156-1-git-send-email-simo@redhat.com>
	<1334669948-4156-5-git-send-email-simo@redhat.com>
	<20120417222825.GA32619@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 17 Apr 2012 18:28:25 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Apr 17, 2012 at 09:39:07AM -0400, Simo Sorce wrote:
> > This patch implements a sunrpc client to use the services of the gssproxy
> > userspace daemon.
> > 
> > In particular it allows to perform calls in user space using an RPC
> > call instead of custom hand-coded upcall/downcall messages.
> 
> The "hand-coded" messages aren't really particularly hard to generate or
> parse.  Let's just drop that argument.
> 
> > Currently only accept_sec_context is implemented as that is all is needed for
> > the server case.
> > 
> > File server modules like NFS and CIFS can use full gssapi services this way,
> > once init_sec_context is also implemented.
> 
> What's the situation with CIFS, by the way?  (How does it currently do
> gssapi, and what are their plans?)
> 

Currently it has its own upcall that's done using the keys API. It's
pretty limited. It's stateless and so doesn't handle multistage
negotiation properly, for instance but it works well enough for our
purposes...

If there's common infrastructure in the kernel for handling GSSAPI then
we'd be interested in using that instead. I'm all for less code that we
have to maintain ourselves...

We would of course need to come up with a transition scheme to the new
daemon. We might need some small modifications too since CIFS expects
the blob to be wrapped in SPNEGO as well, but that's fairly easy to
manage and we could do that in kernel space if needed.

My only (minor) reservation is that moving to this would mean cifs
would be dependent to some degree on the sunrpc code. It's not a huge
problem. Most distros won't care, but some embedded ones might.

What we'll probably do is wait until this is more settled with nfs(d)
and then look at moving to it.

-- 
Jeff Layton <jlayton@redhat.com>
