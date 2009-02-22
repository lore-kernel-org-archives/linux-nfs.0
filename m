From: Ben Greear <greearb@candelatech.com>
Subject: Re: PATCH:  Support binding to a local IPv4 address when mounting
 a server.
Date: Sat, 21 Feb 2009 22:24:41 -0800
Message-ID: <49A0EFA9.6010602@candelatech.com>
References: <4977C580.4040805@candelatech.com> <633CA802-DD5A-4082-B771-C524D367241F@oracle.com> <497805A7.4070205@candelatech.com> <A1D6FF17-95D6-4775-AF60-5D6CD2078B3E@oracle.com> <4978AD75.9090900@candelatech.com> <65D69956-DB67-43A7-9101-9AFB7EC55A9F@oracle.com> <499FB08B.1070200@candelatech.com> <EF45429F-0B16-47C7-89ED-7C14C44E6E5E@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:47829 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbZBVGYs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Feb 2009 01:24:48 -0500
In-Reply-To: <EF45429F-0B16-47C7-89ED-7C14C44E6E5E@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
>
> Would lockd also need to have this information too (passed in via 
> nlmclnt_inet)?
I found an fs/lockd directory, but cannot find 'nlmclnt_inet' anywhere 
in the kernel or nfs-utils.

>
> Would we also want kernel rpcbind requests to be sensitive to the 
> passed-in bind address?

It seems from searching net/sunrpc dir that kernel_bind is called 
appropriately which should
bind the a local addr if correct information is passed in, at least.   
This must be working
(assuming NFS calls this code eventually) since I *am* getting at least 
most of the NFS traffic
correctly bound to the specified bindaddr.

I wouldn't be surprised if the binaddr isn't being configured in the 
lockd properly,
but I'm not yet sure of how to get that information to lockd since I 
just started looking
at that code...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


