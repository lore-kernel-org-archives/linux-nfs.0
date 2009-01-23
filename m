From: Ben Greear <greearb@candelatech.com>
Subject: Re: PATCH:  Support binding to a local IPv4 address when mounting
 a server.
Date: Fri, 23 Jan 2009 09:39:21 -0800
Message-ID: <497A00C9.4010907@candelatech.com>
References: <4977C580.4040805@candelatech.com> <633CA802-DD5A-4082-B771-C524D367241F@oracle.com> <497805A7.4070205@candelatech.com> <A1D6FF17-95D6-4775-AF60-5D6CD2078B3E@oracle.com> <4978AD75.9090900@candelatech.com> <65D69956-DB67-43A7-9101-9AFB7EC55A9F@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:52873 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbZAWRja (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jan 2009 12:39:30 -0500
In-Reply-To: <65D69956-DB67-43A7-9101-9AFB7EC55A9F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:

>> Why not clientaddr?  That is already used for NFS version 4, and it works
>> just fine for version 3 as well.  I can't think of any reason to have
>> a new variable.
> 
> That may make sense for NFSv2/v3, but nfs(5) documents the clientaddr 
> specifically as the client's NFSv4 callback server address.  Is there 
> ever a case where we want to specify a NFSv4 callback address that's 
> different from the source address of your NFSv4 forward channel?  Are we 
> sure these will always be the same?
> 
> Conversely, do we always want to limit our NFSv4 traffic to a single 
> bind address when clientaddr= is specified?
> 
> IMO the coding and documentation overhead for reusing clientaddr would 
> be the same or greater than creating a new mount option, and the result 
> would be more confusing.  These two options do different things.  I'd be 
> interested to hear opinions from others on the list.
> 
> "bindaddr=" might be more clear than "localaddr=".  I checked Solaris 
> 10, but it doesn't seem to have a similar capability.  So, no guidance 
> there...

Either way is fine with me.  I'll change it to be bindaddr unless
I hear another opinion.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

