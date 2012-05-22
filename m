Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:53371 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754117Ab2EVNRl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2012 09:17:41 -0400
Message-ID: <4FBB91EE.3010307@parallels.com>
Date: Tue, 22 May 2012 17:17:34 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Simo Sorce <simo@redhat.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "bfields@redhat.com" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/4] SUNRPC: Add RPC based upcall mechanism for RPCGSS
 auth
References: <1337087550-9821-1-git-send-email-simo@redhat.com>  <1337087550-9821-4-git-send-email-simo@redhat.com>  <20120522124728.GB891@fieldses.org> <1337691607.16840.178.camel@willson.li.ssimo.org>
In-Reply-To: <1337691607.16840.178.camel@willson.li.ssimo.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 22.05.2012 17:00, Simo Sorce wrote:
> On Tue, 2012-05-22 at 08:47 -0400, J. Bruce Fields wrote:
>> Have you and Stanislav talked about fitting this with the ongoing
>> container work?
>
> No, I wanted to make it work for the normal case first, I assume it will
> be simple enough to change the code to work with containers later.
> Main reason is that I have no way to test containerized stuff.
>


It's not that hard to "containerize" this code.
All you need is to bypass rqstp->rq_xprt->xpt_net to gssp_rpc_create().
I.e. either add net as a parameter to 
gssp_accept_sec_context_upcall()->gssp_call()->get_clnt()->gssp_rpc_create() 
prototypes or pass it as a part of gssp_upcall_data structure and then pass as a 
parameter to gssp_call()->get_clnt()->gssp_rpc_create().

This will suits you. I.e. I'm sure that you'll not experience any changes 
comparing to current behavior.

> If I understand it correctly, all is needed is to allow attaching to
> different sockets for different containers ?
>

Sorry, but I don't understand the sentence.
Starting from kernel 3.3 SUNRPC layer if fully containerized. I.e. all network 
related resources now carefully allocated and destroyed per and with network 
namespace.
And it would be really great, if the layer will remain containerized in future.

> Simo.
>


-- 
Best regards,
Stanislav Kinsbursky
