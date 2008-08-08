From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: permit unauthenticated stat of export root
Date: Fri, 8 Aug 2008 16:39:56 -0400
Message-ID: <20080808203956.GA23865@fieldses.org>
References: <20080807181148.GK18904@fieldses.org> <489B3DAC.5060004@redhat.com> <20080807191656.GL18904@fieldses.org> <489B4F81.8000204@redhat.com> <20080807204154.GR18904@fieldses.org> <20080808202106.GR15265@fieldses.org> <489CAD51.6080106@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:44562 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751011AbYHHUj6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Aug 2008 16:39:58 -0400
In-Reply-To: <489CAD51.6080106@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 08, 2008 at 04:32:17PM -0400, Peter Staubach wrote:
> J. Bruce Fields wrote:
>> On Thu, Aug 07, 2008 at 04:41:54PM -0400, J. Bruce Fields wrote:
>>   
>>> On Thu, Aug 07, 2008 at 03:39:45PM -0400, Peter Staubach wrote:
>>>     
>>>> J. Bruce Fields wrote:
>>>>       
>>>>> On Thu, Aug 07, 2008 at 02:23:40PM -0400, Peter Staubach wrote:
>>>>>         
>>>>>> I would think that you might want to have nfsd3_proc_getattr()
>>>>>> in this list too.  Some clients may need to generate a GETATTR
>>>>>> if they need the attributes for the root node.
>>>>>>               
>>>>> Do you know of any? rfc 2623 makes it sound like those clients are out
>>>>> of luck.  And testing confirms that this patch is sufficient for the
>>>>> linux client, at least.
>>>>>         
>>>> I believe that the Solaris client may.  I think that it may
>>>> use the attributes returned from the FSINFO call, if there
>>>> are any, to prevent the additional GETATTR, but this should
>>>> be tested.  It might also be interesting to test out a
>>>> readonly failover mount on the Solaris client to see what
>>>> behavior that that exhibits.
>>>>       
>>> OK, could be.  Volunteers to test that welcomed--for now I think I'll
>>> stick to the list in the RFC.
>>>     
>>
>> By the way, I don't mean to brush off the idea, it's just that this
>> satisfies my immediate problem, and it would be extremely easy for
>> someone else to test:
>>
>> 	- Apply this patch to a linux nfs server, export a filesystem with
>> 		/export	*(sec=krb5)
>> 	- mount -osec=krb5 server:/export from a solaris client.
>> 	- report whether it works, and get a packet capture if not.
>>
>> ... If someone gets a chance to figure out the Solaris client behavior,
>> that'd be great.
>
> I will try it when I can, but I was thinking of just watching
> the traffic generated during the mount.  It shouldn't matter
> whether the mount is done with krb5 or not, the sequence of
> NFS operations should be the same.

Sure, yep.  Oh, and of course I forgot to mention that test should be
with v3....

--b.
