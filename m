From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: RESTRICTED_STATD
Date: Tue, 2 Sep 2008 18:17:21 -0400
Message-ID: <EB1B1F05-65DA-4A18-80F6-13DE4FCB387C@oracle.com>
References: <6972A199-D332-4E74-9D47-70EC2CA381FE@oracle.com> <48B5332B.2040800@RedHat.com> <76bd70e30808270714p4342c8c3k8d1b98763cc95aef@mail.gmail.com> <EB4BA6CC-B023-49DC-9FE6-BD478DA5CB9F@oracle.com> <3400963b9465552abb83ecefede125bc.squirrel@neil.brown.name>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Steve Dickson <steved@redhat.com>, Olaf Kirch <okir@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:48409 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664AbYIBWX1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Sep 2008 18:23:27 -0400
In-Reply-To: <3400963b9465552abb83ecefede125bc.squirrel-eq65iwfR9nKIECXXMXunQA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 29, 2008, at Aug 29, 2008, 5:31 PM, NeilBrown wrote:
> On Sat, August 30, 2008 6:56 am, Chuck Lever wrote:
>> A little follow-up here.
>>
>> Steve and I looked at the nfs-utils-1.1.3 RPM for Fedora today.  I  
>> did
>> an "rpmbuild -bc" and looked at it's config.h, and RESTRICTED_STATD  
>> is
>> defined as 1.  So it uses the default.
>>
>> Looking at the code, it appears that when RESTRICTED_STATD is set,
>> NL_ADDR() is always going to be the loopback address.  Neil, is that
>> your understanding of this code?
>>
> Nearly.
> If RESTRICTED_STATD is defined (to anything), MON, UNMON, UNMON_ALL
> and SIMU_CRASH are only honour if they come from 127.0.0.1, so the
> callback address (NL_ADDR) for any service that statd is monitoring
> will always be local.

The value of NL_ADDR is determined only by sm_mon_1_svc() as far as I  
can tell.  If RESTRICTED_STATD is defined, NL_ADDR is always set to  
127.0.0.1.

For IPv6, we would need to check the incoming address for both  
127.0.0.1 or ::1.  Outgoing we can always use 127.0.0.1 for the time  
being.  I was hoping to eliminate NL_ADDR, and just use a constant  
127.0.0.1 where needed.

> Only NOTIFY can come from other hosts (to tell us they rebooted).

Right.  sm_notify_1_svc() grabs the callers IP address with

    svc_getcaller(rqstp->rq_xprt)->sin_addr

It converts this to a string and checks this against lp->dns_name, in  
addition to checking the mon_name that was originally registered to be  
monitored.  Shouldn't statd check only mon_name against dns_name?  Why  
does it check both?

This would need IPv6 support.  It would be easier just to eliminate it  
if possible, and just check mon_name.  It then wouldn't need any IPv6- 
specific logic.

> Also, only the lockd callback service is recognised.  If any service
> other than lockd registers a callback it will be ignored, even if it
> is from localhost.
>
> This last point is the only bit that could conceivably cause a  
> problem.
>
> However we don't really want any user to be able to request a callback
> to any random service....
> I wonder if anyone uses for statd for anything but lockd, and how
> could we know?

I think the real question is whether we should continue to support  
this "off-label" use.  It adds complexity and security problems, and  
the code paths that support this aren't ever tested these days, I'm  
willing to bet.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
