From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/8] rpcbind v4 support in net/sunrpc/svc*
Date: Wed, 23 Jul 2008 17:53:36 -0400
Message-ID: <20080723215336.GC29065@fieldses.org>
References: <20080630224147.24887.18730.stgit@ellison.1015granger.net> <20080719010738.GA19106@fieldses.org> <20080720211744.GA32178@fieldses.org> <76bd70e30807211207q4fc509e0h4a1a560fe8097de7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:59143 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753570AbYGWVxm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jul 2008 17:53:42 -0400
In-Reply-To: <76bd70e30807211207q4fc509e0h4a1a560fe8097de7-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 21, 2008 at 03:07:48PM -0400, Chuck Lever wrote:
> On Sun, Jul 20, 2008 at 5:17 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Fri, Jul 18, 2008 at 09:07:38PM -0400, J. Bruce Fields wrote:
> >> On Mon, Jun 30, 2008 at 06:45:21PM -0400, Chuck Lever wrote:
> >> > Hi Bruce, Trond -
> >> >
> >> > These implement basic support in net/sunrpc/svc* for registering IPv6-
> >> > enabled kernel RPC services with the local user-space rpcbind.  These
> >> > all depend on the new rpcb_v4_register() API I just posted.
> >> >
> >> > The last patch enables IPv6 support for the NFSv4 callback service, even
> >> > though it doesn't register with rpcbind.
> >>
> >> There's some conflicts against my latest tree.  Would it be possible to
> >> rebase to
> >>
> >>       git://linux-nfs.org/~bfields/linux.git for-2.6.27
> >>
> >> sometime?
> >
> > Actually, never mind, I fixed up the conflicts in the first couple and
> > staged them here:
> >
> >        git://linux-nfs.org/~bfields/linux.git for-2.6.28
> >
> > (I think the rest'll still apply cleanly to that.)
> >
> > We could maybe still try to get the rest of this in at the end of the
> > 2.6.27 merge window, but I'm inclined to wait.  Apologies, partly my
> > fault for not getting around to these sooner.
> 
> Given the complexity and controversy of these changes, the number of
> other changes that went into .27 and will require us to rewrite some
> of these, and the pending holiday/travel for our team of maintainers,
> I think waiting for .28 is our only choice.

They don't seem as controversial as that!  But, OK, I guess .28 it is.
Please let me know as soon as there's another set ready.

--b.
