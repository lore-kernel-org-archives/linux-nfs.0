From: Harshula <harshula@redhat.com>
Subject: Re: [RFC V2 0/1] SUNRPC: dynamic rpc_slot allocator
Date: Wed, 28 Sep 2011 13:08:13 +1000
Message-ID: <1317179295.2609.2.camel@serendib>
References: <1305059200-412-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: trond.myklebust@netapp.com, jlayton@redhat.com,
	linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54766 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751558Ab1I1DIR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Sep 2011 23:08:17 -0400
In-Reply-To: <1305059200-412-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Andy,

What's the status of your dynamic slot allocator patch?

cya,
#

On Tue, 2011-05-10 at 16:26 -0400, andros@netapp.com wrote:
> Second version. Responded to comments. 
> As for the first version, I would appreciate comments on this patch.
> 
> Changes:
> 
> - kmalloc instead of mempools
> - same dynamic allocator used by all interested transports.
> - used GFP_ATOMIC for rpc_xprt and initial slot allocation
> - UDP also uses dynamic allocation, but not in response to write_space callback.
> - BC_TCP slots reduced to RPC_MIN_SLOT_TABLE. (could add dynamic if so desired)
> 
> See patch comments for more description.
>  
> The 10G test bed is not yet configured. I did test with VMs, copying a large
> file over NFSv3/v4. For tcp, started with 2 slots, ended with 7. for udp (same
> file), started with 2 slots, ended with 3.
> 
> -->Andy
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

