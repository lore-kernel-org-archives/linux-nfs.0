Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39865 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932283Ab2KZWvS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 17:51:18 -0500
Date: Mon, 26 Nov 2012 17:51:16 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Revert "mountd: handle allocation failures in
 auth_unix_ip upcall"
Message-ID: <20121126225116.GE18186@fieldses.org>
References: <20121126220343.GA18140@fieldses.org>
 <73EFE585-98D4-40BE-9EDF-15CC6B14BDB2@oracle.com>
 <20121126221535.GB18186@fieldses.org>
 <A954A569-E030-4119-A349-6CB888979738@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <A954A569-E030-4119-A349-6CB888979738@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 26, 2012 at 05:38:49PM -0500, Chuck Lever wrote:
> 
> On Nov 26, 2012, at 5:15 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Mon, Nov 26, 2012 at 05:05:22PM -0500, Chuck Lever wrote:
> >> 
> >> On Nov 26, 2012, at 5:03 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> >> 
> >>> From: "J. Bruce Fields" <bfields@redhat.com>
> >>> 
> >>> This reverts commit 485f7a21e1649797f29317b865cbb094c1f6a71d.  The
> >>> failures handled there could be any sort of name resolution failure, not
> >>> just an allocation, and failing to downcall (hence leaving the client
> >>> hanging) is not the correct thing to do in those cases.
> >> 
> >> The problem is in the kernel, then: a downcall should be allowed to fail, IMO.
> > 
> > In this case, after a revert, a failure here will result in the downcall
> > passing down a client named "DEFAULT".  Presumably that won't be
> > permitted access to the export, so the client will end up getting an
> > error.
> 
> "A failure here" can mean either malloc() returned NULL in client_resolve() or client_compose(), or . . . ?

Looks like it'd also fail if we couldn't map the client's ip address to
a name.

> > But I may not understand your objection.
> 
> The main problem is I don't understand your patch description.  :-)
> 
> I don't seem to have commit 485f7a21 in my nfs-utils git tree (it's
> helpful to include the short description for such a case).

Ah, crap, sorry, looks like I reverted a local commit of that patch....
The upstream commit is bf6a4febaa78bf188896b7b5b02c46562dd08b70 (and
the short description is in the subject line above).

> What exactly is the problem with the current code?
> 
> client_resolve() can return a NULL in some cases.  Why is it OK to
> pass a NULL "ai" to client_compose() ?  Looks like that can result in
> a mountd segfault.

Bah, I thought I'd checked this and found it was prepared to handle
that, but no:

	client_check->check_wildcard()

looks like it can oops.

OK, I'll take another look.

> The kernel won't get any downcall reply in that
> case!  Is that what you are trying to fix?
> 
> WRT my original objection: In general I don't see how to make it
> impossible for mountd to fail.

Sure, but mountd is required for the server to function, so it's just a
question of how we fail.

> Thus the kernel needs to be better about recovering when mountd
> suddenly disappears.

Currently it drops and lets the client retry.  I suspect that's the
correct thing to do, but alternatives are welcomed.

--b.
