Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:7054 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751111Ab2EVNWu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 May 2012 09:22:50 -0400
Subject: Re: [PATCH 3/4] SUNRPC: Add RPC based upcall mechanism for RPCGSS
 auth
From: Simo Sorce <simo@redhat.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "bfields@redhat.com" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <4FBB91EE.3010307@parallels.com>
References: <1337087550-9821-1-git-send-email-simo@redhat.com>
	 <1337087550-9821-4-git-send-email-simo@redhat.com>
	 <20120522124728.GB891@fieldses.org>
	 <1337691607.16840.178.camel@willson.li.ssimo.org>
	 <4FBB91EE.3010307@parallels.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 22 May 2012 09:22:46 -0400
Message-ID: <1337692966.16840.181.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2012-05-22 at 17:17 +0400, Stanislav Kinsbursky wrote:
> On 22.05.2012 17:00, Simo Sorce wrote:
> > On Tue, 2012-05-22 at 08:47 -0400, J. Bruce Fields wrote:
> >> Have you and Stanislav talked about fitting this with the ongoing
> >> container work?
> >
> > No, I wanted to make it work for the normal case first, I assume it will
> > be simple enough to change the code to work with containers later.
> > Main reason is that I have no way to test containerized stuff.
> >
> 
> 
> It's not that hard to "containerize" this code.
> All you need is to bypass rqstp->rq_xprt->xpt_net to gssp_rpc_create().
> I.e. either add net as a parameter to 
> gssp_accept_sec_context_upcall()->gssp_call()->get_clnt()->gssp_rpc_create() 
> prototypes or pass it as a part of gssp_upcall_data structure and then pass as a 
> parameter to gssp_call()->get_clnt()->gssp_rpc_create().
> 
> This will suits you. I.e. I'm sure that you'll not experience any changes 
> comparing to current behavior.

This should be easy enough.

> > If I understand it correctly, all is needed is to allow attaching to
> > different sockets for different containers ?
> >
> 
> Sorry, but I don't understand the sentence.
> Starting from kernel 3.3 SUNRPC layer if fully containerized. I.e. all network 
> related resources now carefully allocated and destroyed per and with network 
> namespace.
> And it would be really great, if the layer will remain containerized in future.

I need guidance here. I need to know what it means to 'remain
containerized', does it mean I need to do something special for the
socket handling ?

Keep in mind I started working on these patches before any
containerization code was added to SUNRPC, and I have no knowledge
whatsoever of containers and what are their constraints.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

