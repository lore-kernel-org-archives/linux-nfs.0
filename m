From: Jim Anderson <ezjab-EkmVulN54Sk@public.gmane.org>
Subject: Re: (k)ubuntu NFS bug
Date: Sat, 30 Apr 2011 16:19:30 -0400
Message-ID: <4DBC6ED2.9050702@ieee.org>
References: <4DBABE48.1050901@ieee.org> <20110429150214.GA10040@merit.edu>
 <4DBC5AA0.5090407@ieee.org> <20110430192038.GA2081@merit.edu>
Reply-To: ezjab-EkmVulN54Sk@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from vms173005pub.verizon.net ([206.46.173.5]:43434 "EHLO
	vms173005pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754584Ab1D3UTn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Apr 2011 16:19:43 -0400
Received: from [192.168.0.9] ([unknown] [68.162.58.7])
 by vms173005.mailsrvcs.net
 (Sun Java(tm) System Messaging Server 7u2-7.02 32bit (built Apr 16 2009))
 with ESMTPA id <0LKH00583F4NXAL0-q7IJPNDOu5k+2AnmrIGM23L67TkHkek2@public.gmane.org> for
 linux-nfs@vger.kernel.org; Sat, 30 Apr 2011 15:19:38 -0500 (CDT)
In-reply-to: <20110430192038.GA2081-8f4Pc2RrbJmHXe+LvDLADg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Thanks again for the suggestions. I'm not sure what solution would work, 
if anything, but my problem is fixed.

I upgraded all of my systems to Kubuntu 10.10 and NFS is working again.
I assume there is some type of compatibility bug, but it is not work
tracing the root problem now. This took a bit of time, but it is 
probably for the better that the other systems are all upgraded now.

Jim Anderson
ezjab-EkmVulN54Sk@public.gmane.org
(908)329-0586

On 04/30/2011 03:20 PM, Jim Rees wrote:
> Jim Anderson wrote:
>
>    Thank you for the suggestions. If I understood right, I should try:
>
>    >>>  mount -t nfs duke:/mnt/myFiles /mnt/myFiles -O proto=udp
>    and
>    >>>  mount -t nfs duke:/mnt/myFiles /mnt/myFiles -O nfsvers=3
>
> I'm not sure what that will do but I don't think it's what you want.  Try
> these:
>
> mount -o proto=udp duke:/mnt/myFiles /mnt/myFiles
> mount -o nfsvers=3 duke:/mnt/myFiles /mnt/myFiles
>
