From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Virtual IPs and blocking locks
Date: Mon, 18 May 2009 09:46:43 -0400
Message-ID: <1242654403.5855.3.camel@heimdal.trondhjem.org>
References: <4A0D80B6.4070101@redhat.com> <4A0D9D63.1090102@hp.com>
	 <4A11657B.4070002@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rob Gardner <rob.gardner@hp.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: "Sachin S. Prabhu" <sprabhu@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:41734 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751096AbZERNqs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 May 2009 09:46:48 -0400
In-Reply-To: <4A11657B.4070002@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-05-18 at 14:41 +0100, Sachin S. Prabhu wrote:
> Rob Gardner wrote:
> > It looks to me like recent kernels have added a "h_srcaddr" filed to the 
> > nlm_host structure, and this should be set to the server's virtual ip 
> > address. Then when the server sends the GRANTED_MSG call to the client, 
> > it should appear to be coming from the virtual ip address, not the 
> > server's primary ip address. So either h_srcaddr isn't getting set up 
> > correctly with your virtual ip address, or rpc_create() isn't binding it 
> > as the source address as it should. In our (older kernel) code, we 
> > explicitly call xprt_set_bindaddr() with the virtual ip address to make 
> > this happen, but I don't immediately see where this happens in the 
> > latest kernel source.
> 
> You are right, I cannot reproduce this issue with nfs servers based on later 
> versions on the kernel containing the patches for
> 'NLM: fix source address in server callbacks'
> 
> However this still leaves the question of the client handling such a situation 
> where a callback is made from a different ip address. Should the client accept 
> such callbacks or is the current behaviour of rejecting these callbacks correct?

The decision to reject callbacks from other ip addresses was deliberate.
There is no good justification for a server to send callbacks or replies
using an address that won't be recognised by the client.

  Trond

