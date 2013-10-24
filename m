Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54869 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754939Ab3JXToP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Oct 2013 15:44:15 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r9OJiF33022884
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 24 Oct 2013 15:44:15 -0400
Message-ID: <526978BF.7020202@RedHat.com>
Date: Thu, 24 Oct 2013 15:45:03 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] mountd: disabling turning off TCP listeners (v2)
References: <1382638633-6710-1-git-send-email-steved@redhat.com> <20131024144507.72aa34a8@tlielax.poochiereds.net>
In-Reply-To: <20131024144507.72aa34a8@tlielax.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 24/10/13 14:45, Jeff Layton wrote:
> On Thu, 24 Oct 2013 14:17:10 -0400
> Steve Dickson <steved@redhat.com> wrote:
> 
>> [ Here is the second try for these patches incorporating the code review..]
>>
>> Recently it was pointed out to me that the [-n | --no-tcp] flags 
>> were broken in mountd. Sure enough they are and they broke 
>> when nfs-utils moved to using libtirpc, which was years ago.
>>
>> Obviously nobody is using these flags since has not been 
>> notice until now, but it seemed to me it no longer makes 
>> any sense to have flags. We really want people to use TCP 
>> so why should there be a way to turn it off? It should be
>> the opposite... They should be able to turn off UDP listeners
>> not TCP... 
>>
>>
>> Steve Dickson (3):
>>   mountd: Use protocol bit fields to turn protocols off.
>>   mountd: Deprecate the ability to disable TCP listeners.
>>   mountd: Add the ability to disable UDP listeners.
>>
>>  support/include/rpcmisc.h |  2 +-
>>  support/nfs/rpcmisc.c     | 19 ++++++++++++++-----
>>  support/nfs/svc_create.c  |  5 +++++
>>  utils/mountd/mountd.c     | 17 ++++++++++++-----
>>  utils/mountd/mountd.man   |  6 +++---
>>  5 files changed, 35 insertions(+), 14 deletions(-)
>>
> 
> Sorry I'm coming in late on this...
np... I was expecting more push back! ;-) 

> 
> I don't think we want to remove the ability to disable TCP listeners.
> 
> Why, you ask? We've been on a multi-year effort to move people to
> NFSv4, and with that, there's no reason to have mountd listen on the
> network at all.
True...

> 
> So personally, I think it would make sense to:
> 
> a) allow people to disable listening on UDP in addition to TCP
I see no reason whatsoever to turn off TCP listeners especially
since that is the protocol of choice... something we have 
be spouting about for years...  
 
> 
> ...or...
> 
> b) add an option that prevents it from listening on any sockets for a
>    v4-only configuration
In this case it would optimal to not even start mountd, unfortunately
due to exports reasons, it not possible... but it should be!! :-) 
  
> 
> In addition, we generally do want people to use UDP for the MNT
> protocol because it's less apt to cause issues with reserved port
> exhaustion. Given that it'll continue to listen on a UDP socket by
> default, that last point is less of an issue, but that might be a good
> reason to rethink this whole plan.
> 
I did think of this.... UDP is on by default... Is up the admin... 


steved.
