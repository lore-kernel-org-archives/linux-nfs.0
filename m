From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] mount.nfs: Ignore vers=4
Date: Mon, 31 Aug 2009 14:20:01 -0400
Message-ID: <9C6BCC0C-AF81-4B2D-87C2-1BD94BD178AD@oracle.com>
References: <20090830163617.4608.48355.stgit@matisse.1015granger.net> <4A9BC593.4070405@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:43980 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbZHaSUT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Aug 2009 14:20:19 -0400
In-Reply-To: <4A9BC593.4070405-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 31, 2009, at 8:44 AM, Steve Dickson wrote:
> On 08/30/2009 12:37 PM, Chuck Lever wrote:
>> Since mount.nfs looks at the vers= option to determine pmap  
>> parameters when
>> negotiating, it throws EINVAL if "4" is specified, even if the kernel
>> supports vers=4 for "nfs" type file systems.
>>
>> Teach mount.nfs to ignore vers=4 and just pass the options to the  
>> kernel.
> How will mount.nfs know that the kernel now supports the "vers=4"  
> option?

The same way it knows after we add any new text-based feature... The  
option will be passed down, and if the kernel supports it, it will  
work.  If not, mount(2) will return EINVAL, and the mount.nfs command  
will report the problem.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



