From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Possible bug in nfs-utils source.
Date: Wed, 21 Jan 2009 17:37:33 -0500
Message-ID: <2055BE67-5060-4D4E-BB0A-A8E61152A2EC@oracle.com>
References: <4977A0EC.3050103@candelatech.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:61866 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239AbZAUWhl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jan 2009 17:37:41 -0500
In-Reply-To: <4977A0EC.3050103@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 21, 2009, at Jan 21, 2009, 5:25 PM, Ben Greear wrote:
> I'm working on adding support to bind to local addresses, and
> I noticed this code in nfs/getport.c
>
> I believe the sizeof should probably be sizeof(*lb_addr) ?

Yes.  Can you submit a patch to Steve and copy the list?

> unsigned short nfs_getlocalport(const rpcprot_t program,
> 				const rpcvers_t version,
> 				const unsigned short protocol)
> {
> 	struct sockaddr_storage address;
> 	struct sockaddr *lb_addr = (struct sockaddr *)&address;
> 	socklen_t lb_len = sizeof(lb_addr);
> 	unsigned short port = 0;
>
> Thanks,
> Ben
>
> --  
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




