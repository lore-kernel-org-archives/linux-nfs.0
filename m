From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/5] new statd [take 1]
Date: Mon, 17 Aug 2009 09:57:58 -0400
Message-ID: <C12F86D9-205F-4223-B66B-94897604470A@oracle.com>
References: <20090804180334.21944.64404.stgit@matisse.1015granger.net> <4A886D76.1040404@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:32005 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753458AbZHQN6T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Aug 2009 09:58:19 -0400
In-Reply-To: <4A886D76.1040404-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 16, 2009, at 4:35 PM, Steve Dickson wrote:
> On 08/04/2009 02:06 PM, Chuck Lever wrote:
>> Hi Steve-
>>
>> Here are some man page patches and the one big patch that adds the  
>> new
>> IPv6-capable statd.  I'd like to start socializing these changes to
>> expedite the new statd into mainline nfs-utils.
>>
>> ---
>>
>> Chuck Lever (5):
>>      nfs(5): update nfs(5) with details about IPv6 support
>>      nfs-utils: introduce new statd implementation
> I 'm waited on these to allow the new statd implementation to shake
> out a bit port...
>
>>      statd: change default state dir to /var/lib/nfs/statd
> I would like to get an 'ACK' from other distros on this one since
> they could depending on what happens today...

This one was purposely dropped in the second round of patches, not to  
be resubmitted.  You can ignore it.

>>      nfs(5): Remove trailing blanks
>>      nfs(5): Add description of lookupcache mount option
> I committed these


OK.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
