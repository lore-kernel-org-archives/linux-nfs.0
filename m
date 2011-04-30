From: Jim Anderson <ezjab-EkmVulN54Sk@public.gmane.org>
Subject: Re: (k)ubuntu NFS bug
Date: Sat, 30 Apr 2011 14:53:20 -0400
Message-ID: <4DBC5AA0.5090407@ieee.org>
References: <4DBABE48.1050901@ieee.org> <20110429150214.GA10040@merit.edu>
Reply-To: ezjab-EkmVulN54Sk@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from vms173005pub.verizon.net ([206.46.173.5]:61842 "EHLO
	vms173005pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751638Ab1D3Sxf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Apr 2011 14:53:35 -0400
Received: from [192.168.0.9] ([unknown] [68.162.58.7])
 by vms173005.mailsrvcs.net
 (Sun Java(tm) System Messaging Server 7u2-7.02 32bit (built Apr 16 2009))
 with ESMTPA id <0LKH00G15B50SOG0-q7IJPNDOu5k+2AnmrIGM23L67TkHkek2@public.gmane.org> for
 linux-nfs@vger.kernel.org; Sat, 30 Apr 2011 13:53:30 -0500 (CDT)
In-reply-to: <20110429150214.GA10040-8f4Pc2RrbJmHXe+LvDLADg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Jim,

Thank you for the suggestions. If I understood right, I should try:

 >>> mount -t nfs duke:/mnt/myFiles /mnt/myFiles -O proto=udp

and

 >>> mount -t nfs duke:/mnt/myFiles /mnt/myFiles -O nfsvers=3


I tried both of these to mount the NFS files and got the same error message.


Jim Anderson
ezjab-EkmVulN54Sk@public.gmane.org

On 04/29/2011 11:02 AM, Jim Rees wrote:
> Jim Anderson wrote:
>
>    I did a search on the error message and I found the following Ubuntu
>    bug: https://bugs.launchpad.net/ubuntu/+source/nfs-utils/+bug/656889
>    According to this bug report, This is a bug and it is not fixed in
>    10.10 final release.
>
> That's unlikely to be your problem since your server does support tcp.  But
> maybe you have a firewall problem.  Try proto=udp and nfsvers=3 mount
> options (separately).  If proto=udp works, fix your firewall.
>
