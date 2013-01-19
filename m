Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:32530 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755727Ab3ASB1r convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2013 20:27:47 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: Question on nfs40_discover_server_trunking.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA915C0721A@sacexcmbx05-prd.hq.netapp.com>
Date: Fri, 18 Jan 2013 20:27:39 -0500
Cc: Ben Greear <greearb@candelatech.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <A4F82546-02DA-4CB6-A2FB-D7A380E8D263@oracle.com>
References: <50F9BE66.6080608@candelatech.com> <0F001F0E-229D-4314-A42E-84402E4F1FC7@oracle.com> <1358546604.2872.6.camel@leira.trondhjem.org> <4FA345DA4F4AE44899BD2B03EEEC2FA915C04FE5@sacexcmbx05-prd.hq.netapp.com> <C11ACA70-EC3A-4FAD-8ADC-572F9B6B4CFE@oracle.com> <1358556248.2835.10.camel@leira.trondhjem.org> <4FA345DA4F4AE44899BD2B03EEEC2FA915C0721A@sacexcmbx05-prd.hq.netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 18, 2013, at 8:01 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Fri, 2013-01-18 at 19:44 -0500, Trond Myklebust wrote:
>> On Fri, 2013-01-18 at 18:14 -0500, Chuck Lever wrote:
>>> On Jan 18, 2013, at 5:59 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
>>> 
>>>> On Fri, 2013-01-18 at 17:03 -0500, an unknown sender wrote:
>>>>> On Fri, 2013-01-18 at 16:33 -0500, Chuck Lever wrote:
>>>>>> On Jan 18, 2013, at 4:28 PM, Ben Greear <greearb@candelatech.com> wrote:
>>>>>> 
>>>>>>> Any chance the STALE_CLIENTID case needs a 'break'?
>>>>>> 
>>>>>> I don't think so.  LEASE_CONFIRM is set, and we want to wake the state renewal thread.
>>>>>> 
>>>>>>> 
>>>>>>> Twice I've seen kernel crashes after the nfs40_walk_client_list
>>>>>>> failed (though code comments say it should never fail).
>>>>>> 
>>>>>> nfs40_walk_client_list() is looking for an nfs_client that is supposed to already be in the nfs_client list.  If the search fails, that's a bug.
>>>>>> 
>>>>>> Eyeball the contents of your nfs_client list.  You should find an appropriate nfs_client in there, and then figure out why the search doesn't find it.
>>>>> 
>>>>> You have considered the fact that the call to
>>>>> nfs4_proc_setclientid_confirm can potentially return
>>>>> NFS4ERR_STALE_CLIENTID if the server rebooted while the client was
>>>>> walking the list?
>>>> 
>>>> In fact, as far as I can see, the correct behaviour in
>>>> nfs40_discover_server_trunking() should be to re-issue the setclientid
>>>> call, and then walk the list again if nfs40_walk_client_list() returns
>>>> NFS4ERR_STALE_CLIENTID.
>>> 
>>> When I wrote the server trunking detection logic, I think we hadn't clearly decided what needed to be done in the STALE_CLIENTID case.
>>> 
>>>> Something like the attached patch:
>>> 
>>> A couple of comments:
>>> 
>>> o  nfs_get_client() already sticks the new client on the tail of the nfs_client list
>> 
>> OK. That allows us to get rid of 5-6 lines of code.
>> 
>>> o  We don't want to get stuck in a loop here.  Should the "do {}" loop in nfs40_discover_server_trunking() be bounded by a retry count?
>> 
>> Not a number of retries, but possibly a timeout value.
>> 
>>> However, I haven't heard Ben say "oh, yes, my server had rebooted."  I'd like some confirmation that the match failed for an explainable and expected reason.
>> 
>> The spec allows the server to discard unconfirmed clientids, so our code
>> should take that into account.
>> 
>> 
>> BTW: I'm going insane trying to figure out how the refcounting in that
>> code is supposed to work. The assumption that we can somehow safely
>> return a non-referenced pointer from nfs4_discover_server_trunking and
>> then bump the reference count in nfs4_init_client() drives me nuts...
> 
> Attached is v2 of the patch that addresses all of the above.

At first glance, it looks plausible.  Well done.  Perhaps the reference counting fix should be split into a separate patch.

This:

"If walking the list in nfs40_walk_client_list fails, then the most
likely explanation is that the server rebooted."

I think in Ben's case the server may be dropping the unconfirmed client ID because it is so busy and the client is probably dealing with a thousand or more mount points, which causes trunking detection to take a lot of time.  I'd still like to see real evidence of this, but I can't think of any easy way for Ben to provide it.

The "No match found." comment is good.

Then:

"Ensure that we catch that case by testing our new nfs_client last."

"testing the new nfs_client last" is the way it's supposed to work -- that's why nfs_get_client() uses list_add_tail() now to insert the new client.  Adding the new client to the client list is supposed to guarantee that walk_client_list always finds an appropriate nfs_client on the list.

So you're not actually changing the order of the tests.  What you're really changing is the recovery behavior in the "our new clientid is already stale" case.  The patch description is probably inaccurate in this regard.

Do we need a similar change for STALE_CLIENTID in the NFSv4.1 path?

Finally, because you are replacing that bogus switch statement in nfs40_discover_server_trunking(), you are fixing Ben's crash.  His GPF back trace should be included in your patch description if you are sending this to stable.

I can test this a little more deeply in a week or two when I get back to the migration work.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




