Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52687 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753501Ab2GJP7o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jul 2012 11:59:44 -0400
Date: Tue, 10 Jul 2012 11:59:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH] [RFC] nfsd: fix possible dereference of static NULL
 nfsd_serv pointer
Message-ID: <20120710155943.GB1947@fieldses.org>
References: <20120706134548.7307.1133.stgit@localhost.localdomain>
 <20120706172630.GA11193@fieldses.org>
 <4FF7C8C2.8070203@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4FF7C8C2.8070203@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jul 07, 2012 at 09:27:30AM +0400, Stanislav Kinsbursky wrote:
> 06.07.2012 21:26, J. Bruce Fields пишет:
> >On Fri, Jul 06, 2012 at 05:45:56PM +0400, Stanislav Kinsbursky wrote:
> >>This is a bug fix for 3.5 kernel.
> >>In case on NFSd service start failure svc_shutdown_net() will call svc_destroy
> >>callback and zeroize global nfsd_serv pointer, this in turn will lead to Oops
> >>in svc_destroy().
> >>
> >>This patch is marked as RFC, because to many lines were changed. It can be
> >>easely simplified if requested.
> >>Moreover, NFSd service shutdown is going to be converted into csomething on
> >>per-net basis.
> >Doesn't this leave error paths in e.g. __write_ports_addfd() and
> >__write_ports_addxprt() unfixed?
> 
> Yes, sure it does...
> 
> >I'm inclined to just submit your original fix (split up as in the last
> >version I sent) for 3.5 if you don't object.
> 
> Not at all.
> Thanks, Bruce.

OK.  Actually, Linus is making noise about a release in the next week or
two, so given that this is about error paths, I'm going to queue it up
for the 3.6 and cc it to stable.  It'll end up in 3.5.x pretty quickly
that way anyway.

--b.
