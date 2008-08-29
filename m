From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: RESTRICTED_STATD
Date: Fri, 29 Aug 2008 16:56:36 -0400
Message-ID: <EB4BA6CC-B023-49DC-9FE6-BD478DA5CB9F@oracle.com>
References: <6972A199-D332-4E74-9D47-70EC2CA381FE@oracle.com> <48B5332B.2040800@RedHat.com> <76bd70e30808270714p4342c8c3k8d1b98763cc95aef@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:57702 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842AbYH2U6v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Aug 2008 16:58:51 -0400
In-Reply-To: <76bd70e30808270714p4342c8c3k8d1b98763cc95aef-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 27, 2008, at Aug 27, 2008, 10:14 AM, Chuck Lever wrote:
> On Wed, Aug 27, 2008 at 6:57 AM, Steve Dickson <SteveD@redhat.com>  
> wrote:
>>
>>
>> Chuck Lever wrote:
>>> Hi guys-
>>>
>>> I was wondering if anyone ever builds nfs-utils with  
>>> RESTRICTED_STATD
>>> undefined these days.  It seems totally insecure to do.  Is it still
>>> necessary to keep this?
>>>
>>> It would be easier to understand, update, and test the logic in
>>> utils/statd/monitor.c (IPv6-wise) if we could remove the unused  
>>> parts of
>>> this code.
>>>
>>> I propose removing RESTRICTED_STATD, leaving in the secure version  
>>> of
>>> the code permanently and removing the insecure parts that are left  
>>> out
>>> when RESTRICTED_STATD is undefined.
>>>
>>> Thoughts?
>> I seem to remember enabling RESTRICTED_STATD cause problems with
>> portmapper and kernel interactions which causes me to turn it off...
>> So if we do permanently turn on the code, let make sure lock recover
>> and such still work...
>
> Enabling RESTRICTED_STATD is the current default.
>
> Disabling RESTRICTED_STATD allows remote hosts to register
> notification requests with rpc.statd.  It's called out in a 1999 CERT
> advisory.  I don't think any distribution would ever want to allow
> this.
>
> However, there may be some folks who build rpc.statd themselves for
> specialized applications may miss it if we pull it out.


A little follow-up here.

Steve and I looked at the nfs-utils-1.1.3 RPM for Fedora today.  I did  
an "rpmbuild -bc" and looked at it's config.h, and RESTRICTED_STATD is  
defined as 1.  So it uses the default.

Looking at the code, it appears that when RESTRICTED_STATD is set,  
NL_ADDR() is always going to be the loopback address.  Neil, is that  
your understanding of this code?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
