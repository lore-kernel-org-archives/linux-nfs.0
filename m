From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] nfsd: permit unauthenticated stat of export root
Date: Fri, 08 Aug 2008 16:32:17 -0400
Message-ID: <489CAD51.6080106@redhat.com>
References: <20080807181148.GK18904@fieldses.org> <489B3DAC.5060004@redhat.com> <20080807191656.GL18904@fieldses.org> <489B4F81.8000204@redhat.com> <20080807204154.GR18904@fieldses.org> <20080808202106.GR15265@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59471 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753471AbYHHUcf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Aug 2008 16:32:35 -0400
In-Reply-To: <20080808202106.GR15265@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Thu, Aug 07, 2008 at 04:41:54PM -0400, J. Bruce Fields wrote:
>   
>> On Thu, Aug 07, 2008 at 03:39:45PM -0400, Peter Staubach wrote:
>>     
>>> J. Bruce Fields wrote:
>>>       
>>>> On Thu, Aug 07, 2008 at 02:23:40PM -0400, Peter Staubach wrote:
>>>>         
>>>>> I would think that you might want to have nfsd3_proc_getattr()
>>>>> in this list too.  Some clients may need to generate a GETATTR
>>>>> if they need the attributes for the root node.
>>>>>     
>>>>>           
>>>> Do you know of any? rfc 2623 makes it sound like those clients are out
>>>> of luck.  And testing confirms that this patch is sufficient for the
>>>> linux client, at least.
>>>>         
>>> I believe that the Solaris client may.  I think that it may
>>> use the attributes returned from the FSINFO call, if there
>>> are any, to prevent the additional GETATTR, but this should
>>> be tested.  It might also be interesting to test out a
>>> readonly failover mount on the Solaris client to see what
>>> behavior that that exhibits.
>>>       
>> OK, could be.  Volunteers to test that welcomed--for now I think I'll
>> stick to the list in the RFC.
>>     
>
> By the way, I don't mean to brush off the idea, it's just that this
> satisfies my immediate problem, and it would be extremely easy for
> someone else to test:
>
> 	- Apply this patch to a linux nfs server, export a filesystem with
> 		/export	*(sec=krb5)
> 	- mount -osec=krb5 server:/export from a solaris client.
> 	- report whether it works, and get a packet capture if not.
>
> ... If someone gets a chance to figure out the Solaris client behavior,
> that'd be great.

I will try it when I can, but I was thinking of just watching
the traffic generated during the mount.  It shouldn't matter
whether the mount is done with krb5 or not, the sequence of
NFS operations should be the same.

    Thanx...

       ps
