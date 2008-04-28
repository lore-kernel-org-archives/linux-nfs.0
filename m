From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Text-based mount interface breaking non-UDP mounts
Date: Mon, 28 Apr 2008 14:44:35 -0400
Message-ID: <2C8DA783-FB7C-40E5-B0B5-94D9067EBC9C@oracle.com>
References: <20080423214929.GA24387@uio.no> <48134C77.9090700@kingswood-consulting.co.uk> <2AA81EE8-74A9-42A5-8ACF-E01BBB6F2280@oracle.com> <48161671.2070508@kingswood-consulting.co.uk>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org,
	public-linux-nfs-u79uwXL29TY76Z2rM5mHXA-8ByrlEUxsivZ+VzJOa5vwg@public.gmane.org
To: "Frank A. Kingswood" <frank-YzJE6wl5KmBjuoFY8sQqqY5Lr7LD32fptUK59QYPAWc@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:23069 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765906AbYD1Spo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Apr 2008 14:45:44 -0400
In-Reply-To: <48161671.2070508-YzJE6wl5KmBjuoFY8sQqqY5Lr7LD32fptUK59QYPAWc@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 28, 2008, at 2:24 PM, Frank A. Kingswood wrote:
> Chuck Lever wrote:
>>>
>>> The NFS client code (nfs-utils-1.1.2) tests for
>>> if (kernel_version > MAKE_VERSION(2, 6, 22))
>>>
>>> yet the kernel patch for NFS did not go un until 2.6.25-rc2
>>> So the test should at least be > MAKE_VERSION(2, 6, 24).
>> The original NFS text-based mount support was added in 2.6.23.
> OK.
>> New features will be added only to the text-based mount interface,  
>> however, so eventually everyone will need to use the text-based  
>> mount interface on new kernels.
> That sounds like a good idea.
>> Because we have little documented history and only a handful of use  
>> cases and unit tests for the mount command, it's important for  
>> everyone to test the new API and report problems here so we can  
>> address them.  NFS mount is complex and has many subtle and hidden  
>> historical behaviors.
> My system fails with 2.6.23 and 2.6.25 kernels. As I described in my  
> original mail, I only have TCP access to the server, and only  
> through an ssh tunnel.
>
> Would you like me to try and produce some debug traces, or do you  
> think you can find the problem with the information you have  
> already? I've seen quite a few reports of this now.

Thanks for the offer.  I tested against a server configuration that  
dropped UDP packets, but I never tested through an ssh tunnel.

Network traces might be a little hard with a tunnel, but give it a  
shot.  The best information comes from a full-packet raw trace.  Use  
the "-s0" option on tcpdump.

You can also trace NFS mount processing with:

# sysctl -w sunrpc.nfs_debug = 128

Or trace all RPC activity (including rpcbind and RPC network transport  
errors) with:

# sysctl -w sunrpc.rpc_debug = 32767

You can set both of these at the same time.  Trace output will appear  
in /var/log/messages.  To disable tracing when you're done, set these  
sysctls to zero.

You can post these to me privately.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
