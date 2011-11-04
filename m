Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44603 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751926Ab1KDWKv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 18:10:51 -0400
Date: Fri, 4 Nov 2011 18:10:45 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH v3 0/3] SUNRPC: rcbind clients virtualization
Message-ID: <20111104221045.GL721@fieldses.org>
References: <20111027180824.20459.23219.stgit@localhost6.localdomain6>
 <20111027202514.GA31669@fieldses.org>
 <4EAA74DD.3070708@parallels.com>
 <20111028093036.GA2604@fieldses.org>
 <4EAA78DD.2000408@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4EAA78DD.2000408@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 28, 2011 at 01:41:49PM +0400, Stanislav Kinsbursky wrote:
> 28.10.2011 13:30, J. Bruce Fields пишет:
> >On Fri, Oct 28, 2011 at 01:24:45PM +0400, Stanislav Kinsbursky wrote:
> >>This patch-set was created before you've sent your NFSd plan and we
> >>disacussed Lockd per netns.
> >>So, this sentence: "NFSd service will be per netns too from my pow"
> >>is obsolete. And Lockd will be one for all.
> >
> >I believe lockd should be pert-netns--at least that's what the server
> >needs.
> >
> >(The single lockd thread may handle requests from all netns, but it
> >should behave like a different service depending on netns, so its data
> >structures, etc. will need to be per-ns.
> >
> 
> Sure. Looks like we have misunderstanding here. When I said, that
> Lockd should be one for all, I meaned, that we will have only one
> kthread for all ns (not one per ns). Private data will be per net
> ns, of course.
> 
> BTW, Bruce, please, have a brief look at my e-mail to
> linux-nfs@vger.kernel.org named "SUNRPC: non-exclusive pipe
> creation".
> I've done a lot in "RPC pipefs per net ns" task, and going to send
> first patches soon. But right now I'm really confused will this
> non-exclusive pipes creation and almost ready so remove this
> functionality. But I'm afraid, that I've missed something. Would be
> greatly appreciate for your opinion about my question.

Sorry for the delay--it looks reasonable to me on a quick skim, but I'm
assuming it's Trond that will need to review this.

--b.

> 
> >--b.
> >
> >>Or you are asking about something else?
> >>
> >>>--b.
> >>>
> >>>>And also we have NFSd file system, which
> >>>>is not virtualized yet.
> >>>>
> >>>>The following series consists of:
> >>>>
> >>>>---
> >>>>
> >>>>Stanislav Kinsbursky (3):
> >>>>       SUNRPC: move rpcbind internals to sunrpc part of network namespace context
> >>>>       SUNRPC: optimize net_ns dereferencing in rpcbind creation calls
> >>>>       SUNRPC: optimize net_ns dereferencing in rpcbind registering calls
> >>>>
> >>>>
> >>>>  net/sunrpc/netns.h     |    5 ++
> >>>>  net/sunrpc/rpcb_clnt.c |  103 ++++++++++++++++++++++++++----------------------
> >>>>  2 files changed, 61 insertions(+), 47 deletions(-)
> >>>>
> >>>>--
> >>>>Signature
> >>
> >>
> >>--
> >>Best regards,
> >>Stanislav Kinsbursky
> 
> 
> -- 
> Best regards,
> Stanislav Kinsbursky
