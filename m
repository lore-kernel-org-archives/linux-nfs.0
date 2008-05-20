From: Peter Leckie <pleckie@sgi.com>
Subject: Re: [PATCH 00/04]  NFS/RDMA client stall patches
Date: Tue, 20 May 2008 10:30:27 +1000
Message-ID: <48321BA3.5010704@sgi.com>
References: <4830D7B1.6050107@sgi.com> <RTPCLUEXC1-PRD33HFn00000100@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:37433 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755798AbYETAan (ORCPT
	<rfc822;@relay.sgi.com:linux-nfs@vger.kernel.org>);
	Mon, 19 May 2008 20:30:43 -0400
In-Reply-To: <RTPCLUEXC1-PRD33HFn00000100-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Talpey, Thomas wrote:
> At 09:28 PM 5/18/2008, Peter Leckie wrote:
>   
>> Hi here are a few patches that prevent the NFS/RDMA client from
>> stalling during xprt disconnect.
>>     
>
> Thanks! I have some patches from Connectathon that I hope to send
> this week, I'll take a look shortly. (There are some server patches on
> the way from Tom Tucker as well.)
>
> I noticed the SGI client was offering up to 1MB rsize/wsize. Is that
> work perhaps ready for review? I'm working to increase these sizes
> to at least 128KB, and if taking them to 1MB is not overly resource-
> intensive under RDMA, that would be great.
>   

Yeah I was hoping on reworking that patch before I send it out, it's a 
little hard coded for 1M mount.
I'll try and sent it out by the weekend.

Pete

