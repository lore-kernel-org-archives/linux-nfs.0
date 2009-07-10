From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Security negotiation
Date: Fri, 10 Jul 2009 16:11:05 -0400
Message-ID: <F2FB7FDE-00D9-4623-964D-3C632AD64C68@oracle.com>
References: <4A578372.1020005@excfb.com> <D8976FEC-39F9-4FF4-8FCE-AB3D5B047DFB@oracle.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Tom Haynes <tdh-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:49071 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756102AbZGJULR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2009 16:11:17 -0400
In-Reply-To: <D8976FEC-39F9-4FF4-8FCE-AB3D5B047DFB@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 10, 2009, at 2:57 PM, Chuck Lever wrote:

>
> On Jul 10, 2009, at 2:07 PM, Tom Haynes wrote:
>
>> During a NFSv3 mount request, the server returns an array of  
>> supported security flavors.
>>
>> With a Linux server, exports(5) states:
>>
>> For the purposes of security  flavor  negotiation, order counts:  
>> preferred flavors should be listed first.
>>
>> And the Solaris client states in mount_nfs(1M):
>>
>>   NFS Version 3 mounts negotiate a security mode when the server  
>> returns an array of security modes. The
>>   client picks the first mode in the array that is supported on the  
>> client. In negotiations, an NFS Version 3 client
>>   is limited to the security flavors listed in /etc/nfssec.conf.
>>
>> The Linux nfs(5) states:
>>
>>   If the sec option is not specified, or if sec=sys is specified,  
>> the NFS client uses the AUTH_SYS
>>   security flavor for  all  NFS  requests on this mount point.
>>
>> So, I'm trying to understand what the Linux client would do if the  
>> export does not support AUTH_SYS and
>> there is no sec= supplied.
>>
>> Does the Linux client traverse the array in order until it finds a  
>> match or does it consider which flavor is strongest?
>
> The legacy mount command does this (kernels earlier than 2.6.23) but  
> the kernel mount client does not yet.  I intend to submit patches  
> for this (today, actually) for 2.6.32.
>
> The patches will walk the auth_list returned by mountd.  By default  
> it will look for AUTH_SYS, otherwise it will look for the flavor  
> specified by the sec= mount option.
>
> If mountd does not provide AUTH_SYS a mount request with no sec=  
> will fail.  Should it try the first one in the list instead?  What  
> if the first one is AUTH_NULL?

In other words, I'm not sure what is the right behavior here.  What it  
does now is probably suboptimal.  I've browsed 2623 a bit, but it's  
not hitting me.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
