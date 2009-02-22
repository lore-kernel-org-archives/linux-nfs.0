From: Ben Greear <greearb@candelatech.com>
Subject: Re: PATCH:  Support binding to a local IPv4 address when mounting
 a server.
Date: Sun, 22 Feb 2009 15:45:16 -0800
Message-ID: <49A1E38C.2050607@candelatech.com>
References: <4977C580.4040805@candelatech.com>	 <633CA802-DD5A-4082-B771-C524D367241F@oracle.com>	 <497805A7.4070205@candelatech.com>	 <A1D6FF17-95D6-4775-AF60-5D6CD2078B3E@oracle.com>	 <4978AD75.9090900@candelatech.com>	 <65D69956-DB67-43A7-9101-9AFB7EC55A9F@oracle.com>	 <499FB08B.1070200@candelatech.com>	 <EF45429F-0B16-47C7-89ED-7C14C44E6E5E@oracle.com>	 <49A0E802.9000209@candelatech.com>	 <1235329791.7331.75.camel@heimdal.trondhjem.org>	 <49A1DD24.9060801@candelatech.com> <1235346094.7331.111.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57892 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754102AbZBVXp2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Feb 2009 18:45:28 -0500
In-Reply-To: <1235346094.7331.111.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Sun, 2009-02-22 at 15:17 -0800, Ben Greear wrote:
>   
>> My specific application is a testing tool that emulates 1000+ unique NFS 
>> clients,
>> primarily for testing  & loading NFS servers.
>> I put each client on a mac-vlan and put them all on the same subnet so 
>> that I don't
>> need any routers between my box and the nfs server.  (We can also put
>> them on different subnets and use different routers, and the specific 
>> source-ip
>> also helps there...)
>>
>> I use routing tricks to enforce that a particular source-IP uses a 
>> specific routing
>> table, and that ties pkts to a specific mac-vlan interface.  The mount 
>> bindaddr
>> option then binds a mount to a specific local IP and thus to a specific 
>> mac-vlan.
>>
>> This shows 1000+ mounts on my test box, and the nfs server sees 1000
>> unique clients (all with different MACs, IPS, etc).
>>     
>
> Any reason why you couldn't multi-home the server too, and use the
> destination IP address to control the route on the clients?
>   
I'm trying to emulate 1000 NFS clients running against a 'normal' NFS 
server,
and in that case, the NFS server would have a single (or small number of IP
addrs), and each client would have a unique IP and MAC.

Thanks,
Ben

>   Trond
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


