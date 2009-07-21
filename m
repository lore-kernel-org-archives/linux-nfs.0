From: Ben Greear <greearb@candelatech.com>
Subject: Re: Error mounting FC8 NFS server with 2.6.31-rc3 NFSv4 client.
Date: Tue, 21 Jul 2009 11:32:09 -0700
Message-ID: <4A6609A9.3000504@candelatech.com>
References: <4A64EB1F.4000602@candelatech.com>	 <1248178527.5222.0.camel@heimdal.trondhjem.org>	 <4A65F184.5060802@candelatech.com>	 <1248196339.21343.8.camel@heimdal.trondhjem.org>	 <4A65FCB2.6080903@candelatech.com>	 <1248199140.21343.17.camel@heimdal.trondhjem.org>	 <4A660295.9020807@candelatech.com> <1248200897.21343.19.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:41553 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753038AbZGUScN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jul 2009 14:32:13 -0400
In-Reply-To: <1248200897.21343.19.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/21/2009 11:28 AM, Trond Myklebust wrote:
> On Tue, 2009-07-21 at 11:01 -0700, Ben Greear wrote:
>> On 07/21/2009 10:59 AM, Trond Myklebust wrote:
>>> On Tue, 2009-07-21 at 10:36 -0700, Ben Greear wrote:
>>>> On 07/21/2009 10:12 AM, Trond Myklebust wrote:
>>>>> On Tue, 2009-07-21 at 09:49 -0700, Ben Greear wrote:
>>>>>> On 07/21/2009 05:15 AM, Trond Myklebust wrote:
>>>>>>
>>>>>>> What does /var/lib/nfs/v4recovery look like on the server?
>>>>>> The server was misconfigured, but I still think the client should
>>>>>> behave better in this case.  If you cannot reproduce it, let me know
>>>>>> and I can try to be more specific.  If you still want the v4recovery
>>>>>> information, let me know and I'll send it.
>>>>> So how should the client behave, when a screwed up server allows it to
>>>>> mount but starts returning illegal values for setclientid? The only
>>>>> thing I can see we could do is to tell the user EINSANESERVER...
>>>> Well, it could just fail the mount and give up and not overly spam
>>>> /var/log/messages in a tight loop perhaps?
>>> This doesn't happen at mount time. It happens when you open a file.
>> Not for me, and evidently not for the other person that reported
>> similar results.  All I had to do was attempt the mount (which never
>> completed).
>>
>> Thanks,
>> Ben
>
> Ah... You have NFS_V4_1 enabled despite the Kconfig warning... Does the
> bug occur when you turn this off too?

Yes, it did.

Thanks,
Ben

>
> Trond


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

