Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37542 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751206Ab0GTP5h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Jul 2010 11:57:37 -0400
Date: Tue, 20 Jul 2010 11:56:56 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/5] nfsd: fix error handling in write_ports interfaces
 (resend)
Message-ID: <20100720155656.GD28972@fieldses.org>
References: <1279572608-7234-1-git-send-email-jlayton@redhat.com>
 <20100720145540.GA28972@fieldses.org>
 <20100720114313.78509cbb@tlielax.poochiereds.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100720114313.78509cbb@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jul 20, 2010 at 11:43:13AM -0400, Jeff Layton wrote:
> On Tue, 20 Jul 2010 10:55:40 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Mon, Jul 19, 2010 at 04:50:03PM -0400, Jeff Layton wrote:
> > As a first exercise, maybe we should figure out how the interface would
> > look if we had the opportunity to start over from scratch.
> > 
> 
> I wholeheartedly agree. This set is essentially a bandaid and I think
> it helps the basic problems but there are plenty of others.
> 
> I'm all for redesigning the innards for better fault tolerance, but I
> think we ought to shoot for not changing the userspace interface unless
> there's just no other way, or it provides a substantial "win".

Yeah, agreed--that's why I said "as a first exercise".  Sometimes once
you figure out what you want, it also becomes easier to figure out how
to get there in a backwards-compatible way.

> I think we could fix this in a much better way by not creating the
> nfsd_serv until threads need to be started. 
> 
> Basically just have write_ports add socket info to a global list rather
> than to the nfsd_serv itself. When nfsd_serv is created, we'd walk that
> list and add those sockets to the nfsd_serv.
> 
> Any time that the portlist file is written to, we'd check to see if
> nfsd is up. If it is then sync up the nfsd sockets with the contents of
> the list.

If the problem with creating nfsd_server earlier is just that it
prevents things like versions or leasetime from being changed, perhaps
we should just relax that rule.

--b.
