Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:18011 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932357Ab1COQyq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Mar 2011 12:54:46 -0400
Subject: Re: [PATCH] SUNRPC: svc_register error overwritten in next iteration
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110315161301.GA32635@fieldses.org>
Date: Tue, 15 Mar 2011 12:54:01 -0400
Cc: roel <roel.kluin@gmail.com>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>
Message-Id: <C9DC5C29-0641-4B34-A6CD-1BD148ACB26D@oracle.com>
References: <4D7B74C7.7060506@gmail.com> <20110314223645.GL25442@fieldses.org> <13D041DB-A26D-4EC1-A585-7DBA266CF18A@oracle.com> <20110315161301.GA32635@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Mar 15, 2011, at 12:13 PM, J. Bruce Fields wrote:

> On Tue, Mar 15, 2011 at 11:43:32AM -0400, Chuck Lever wrote:
>> 
>> On Mar 14, 2011, at 6:36 PM, J. Bruce Fields wrote:
>> 
>>> On Sat, Mar 12, 2011 at 02:27:35PM +0100, roel wrote:
>>>> The break is in the inner loop, the svc_register() error is overwritten
>>>> in the next iteration. Only the error in the last iteration is returned.
>>>> 
>>>> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
>>>> ---
>>>> net/sunrpc/svc.c |    2 ++
>>>> 1 files changed, 2 insertions(+), 0 deletions(-)
>>>> 
>>>> Is this needed?
>>>> 
>>>> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
>>>> index 08e05a8..5fd08c0 100644
>>>> --- a/net/sunrpc/svc.c
>>>> +++ b/net/sunrpc/svc.c
>>>> @@ -889,6 +889,8 @@ int svc_register(const struct svc_serv *serv, const int family,
>>>> 			if (error < 0)
>>>> 				break;
>>> 
>>> May as well just "goto out" or "return error" here?
>>> 
>>> But: aren't we missing some cleanup?  If we succesfully register one
>>> program then fail at a second one, don't we need to unregister the
>>> first?
>> 
>> Right.  I don't understand what is the intended effect here (of the original code):  Best effort registration, or "all or none"?
> 
> The current code was failing iff the last registration returns an error.
> We list the nfs program before the acl program in this list, so nfsd
> registration was failing iff the acl program failed, which makes no
> sense whatsoever.
> 
> I think "all or none" would be cleanest.
> 
> If people start complaining that they don't want to run rpcbind/portmap
> then we could give them some way of requesting that instead of just
> depending on allowing the registration to fail.

I thought vs_hidden was set for NFSACL... but maybe I was wrong about that.

> For cleanup, we can just unregister everything, right?  (No harm in
> possibly unregistering something who's registration just failed?)

Yes.  As a simple hard-headed approach, probably you should walk the passed-in sv_program list again and unregister each item in the list.  The downside to this is if the upcall is taking a long time (for instance, if networking is not available).  It would double the amount of time for svc_register() to return a failure.

However, be prepared: I bet such a change could expose bugs in the NFSD start up stack.  :-(  Maybe it deserves some soak-time in linux-next.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




