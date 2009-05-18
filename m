From: "Sachin S. Prabhu" <sprabhu@redhat.com>
Subject: Re: Virtual IPs and blocking locks
Date: Mon, 18 May 2009 14:41:15 +0100
Message-ID: <4A11657B.4070002@redhat.com>
References: <4A0D80B6.4070101@redhat.com> <4A0D9D63.1090102@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Rob Gardner <rob.gardner@hp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:47161 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752502AbZERNlQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 May 2009 09:41:16 -0400
In-Reply-To: <4A0D9D63.1090102@hp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rob Gardner wrote:
> It looks to me like recent kernels have added a "h_srcaddr" filed to the 
> nlm_host structure, and this should be set to the server's virtual ip 
> address. Then when the server sends the GRANTED_MSG call to the client, 
> it should appear to be coming from the virtual ip address, not the 
> server's primary ip address. So either h_srcaddr isn't getting set up 
> correctly with your virtual ip address, or rpc_create() isn't binding it 
> as the source address as it should. In our (older kernel) code, we 
> explicitly call xprt_set_bindaddr() with the virtual ip address to make 
> this happen, but I don't immediately see where this happens in the 
> latest kernel source.

You are right, I cannot reproduce this issue with nfs servers based on later 
versions on the kernel containing the patches for
'NLM: fix source address in server callbacks'

However this still leaves the question of the client handling such a situation 
where a callback is made from a different ip address. Should the client accept 
such callbacks or is the current behaviour of rejecting these callbacks correct?

Sachin Prabhu
