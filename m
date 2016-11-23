Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35506 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933122AbcKWSVt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 23 Nov 2016 13:21:49 -0500
Subject: Re: [PATCH 2/2] mount: RPC_PROGNOTREGISTERED should not be a
 permanent error
To: NeilBrown <neilb@suse.com>
References: <147157095612.26568.14161646901346011334.stgit@noble>
 <147157115640.26568.2934329194247787636.stgit@noble>
 <2a0955df-2fcd-05f1-9e6f-d8a549321177@RedHat.com>
 <87bmx7cezt.fsf@notabene.neil.brown.name>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Martin Pitt <martin.pitt@ubuntu.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <34768ca3-0aa1-eb00-01c9-922e3bbcb51f@RedHat.com>
Date: Wed, 23 Nov 2016 13:21:48 -0500
MIME-Version: 1.0
In-Reply-To: <87bmx7cezt.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/22/2016 05:43 PM, NeilBrown wrote:
> On Wed, Nov 23 2016, Steve Dickson wrote:
> 
>> [Resent due to mailman rejecting the HTML subpart]
> (and the resend included HTML too ... how embarrassing :-)
Yeah... :-) I guess an upgrade turned it on.. 

> 
>>
>> Hey Neil,
>>
>>
>> On 08/18/2016 09:45 PM, NeilBrown wrote:
>>> Commit: bf66c9facb8e ("mounts.nfs: v2 and v3 background mounts should retry when server is down.")
>>>
>>> changed the behaviour of "bg" mounts so that RPC_PROGNOTREGISTERED,
>>> which maps to EOPNOTSUPP, is not a permanent error.
>>> This useful because when an NFS server starts up there is a small window between
>>> the moment that rpcbind (or portmap) starts responding to lookup requests,
>>> and the moment when nfsd registers with rpcbind.  During that window
>>> rpcbind will reply with RPC_PROGNOTREGISTERED, but mount should not give up.
>>>
>>> This same reasoning applies to foreground mounts.  They don't wait for
>>> as long, but could still hit the window and fail prematurely.
>>>
>>> So revert the above patch and instead add EOPNOTSUPP to the list of
>>> temporary errors known to nfs_is_permanent_error.
>>>
>>> Signed-off-by: NeilBrown <neilb@suse.com>
>>> ---
>>>  utils/mount/stropts.c |    7 +++----
>>>  1 file changed, 3 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>> index 9de6794c6177..d5dfb5e4a669 100644
>>> --- a/utils/mount/stropts.c
>>> +++ b/utils/mount/stropts.c
>>> @@ -948,6 +948,7 @@ static int nfs_is_permanent_error(int error)
>>>  	case ETIMEDOUT:
>>>  	case ECONNREFUSED:
>>>  	case EHOSTUNREACH:
>>> +	case EOPNOTSUPP:	/* aka RPC_PROGNOTREGISTERED */
>> I think this introduced a regression... When the server does not support
>> a protocol, say UDP, this patch cause the mount to hang forever,
>> which I don't think we want.
> 
> 
> I think we do want it to wait a while so that the nfs server has a
> chance to start up.  We have no guarantee that the NFS server will be
> registered with rpcbind before rpcbind responds to requests.
I do see this race but there it has to be a small window. With
Fedora its under seconds between the time rpcbind started
and the NFS server.

> 
> I disagree with the "hang forever" description.  I just tested after
> disabling UDP on an nfs server, and the delay was 2 minutes, 5 seconds
> before a failure was reported.  It might be longer when trying TCP on a
> server that only supports UDP.
Yeah I did not wait that long... You are much more of a patient man than I ;-) 
I do think this is a regression. Going an from an instant failure to one
that takes over 2min is not a good thing... IMHO.

> 
> So I think the current behavior is correct.  You might be able to argue
> that certain error codes should trigger a shorter timeout, but it would
> need a strong argument.
Going with the theory the window is very small, how about 
a retry with a timeout then a failure? 

> 
> Or maybe you mean that a "bg" mount would "hang forever" in the
> background?  I think that behavior is correct too.
I agreed... "bg" mounts should hang longer than fg mounts
but they shouldn't for something that will never happen
like the non-support of a protocol.

steved.
