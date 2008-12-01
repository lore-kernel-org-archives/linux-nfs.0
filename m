From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: ipv6 status
Date: Mon, 1 Dec 2008 13:33:25 -0500
Message-ID: <D9F679A4-0664-4977-9DAF-5EC0AF2BADD8@oracle.com>
References: <1228092016.7394.521.camel@pc.interlinx.bc.ca>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:35894 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751455AbYLASdg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Dec 2008 13:33:36 -0500
In-Reply-To: <1228092016.7394.521.camel-lA68w17JHpfIgqYUaR6mlLDks+cytr/Z@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 30, 2008, at Nov 30, 2008, 7:40 PM, Brian J. Murrell wrote:
> So what exactly is the status of NFS and IPv6 in the most recent (say,
> 2.6.24-28) kernels?  Is it present and if so, working?  Feel free to
> simply point me to a roadmap that shows where we are if you like.

There isn't a published roadmap.  Linux developers tend to eschew  
deadlines.

The NFS client in 2.6.28 (and maybe 2.6.27) should support NFSv4 over  
IPv6.  Use the latest nfs-utils.

I'm hoping 2.6.29 will see all the kernel pieces we need for NFSv2/v3  
client and server, and NFSv4 server support for IPv6.

Support for NFSv2/v3 over IPv6, and server-side support for NFSv4 over  
IPv6, requires user space changes.  We are pushing those into nfs- 
utils over time, but I don't expect that work to be complete until  
sometime in 1H2009.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
