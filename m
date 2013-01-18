Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:59350 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754259Ab3ARXVP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2013 18:21:15 -0500
Message-ID: <50F9D8E8.6080803@candelatech.com>
Date: Fri, 18 Jan 2013 15:21:12 -0800
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Question on nfs40_discover_server_trunking.
References: <50F9BE66.6080608@candelatech.com> <0F001F0E-229D-4314-A42E-84402E4F1FC7@oracle.com> <1358546604.2872.6.camel@leira.trondhjem.org> <4FA345DA4F4AE44899BD2B03EEEC2FA915C04FE5@sacexcmbx05-prd.hq.netapp.com> <C11ACA70-EC3A-4FAD-8ADC-572F9B6B4CFE@oracle.com>
In-Reply-To: <C11ACA70-EC3A-4FAD-8ADC-572F9B6B4CFE@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/18/2013 03:14 PM, Chuck Lever wrote:
>
> On Jan 18, 2013, at 5:59 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
>
>> On Fri, 2013-01-18 at 17:03 -0500, an unknown sender wrote:
>>> On Fri, 2013-01-18 at 16:33 -0500, Chuck Lever wrote:
>>>> On Jan 18, 2013, at 4:28 PM, Ben Greear <greearb@candelatech.com> wrote:
>>>>
>>>>> Any chance the STALE_CLIENTID case needs a 'break'?
>>>>
>>>> I don't think so.  LEASE_CONFIRM is set, and we want to wake the state renewal thread.
>>>>
>>>>>
>>>>> Twice I've seen kernel crashes after the nfs40_walk_client_list
>>>>> failed (though code comments say it should never fail).
>>>>
>>>> nfs40_walk_client_list() is looking for an nfs_client that is supposed to already be in the nfs_client list.  If the search fails, that's a bug.
>>>>
>>>> Eyeball the contents of your nfs_client list.  You should find an appropriate nfs_client in there, and then figure out why the search doesn't find it.
>>>
>>> You have considered the fact that the call to
>>> nfs4_proc_setclientid_confirm can potentially return
>>> NFS4ERR_STALE_CLIENTID if the server rebooted while the client was
>>> walking the list?
>>
>> In fact, as far as I can see, the correct behaviour in
>> nfs40_discover_server_trunking() should be to re-issue the setclientid
>> call, and then walk the list again if nfs40_walk_client_list() returns
>> NFS4ERR_STALE_CLIENTID.
>
> When I wrote the server trunking detection logic, I think we hadn't clearly decided what needed to be done in the STALE_CLIENTID case.
>
>> Something like the attached patch:
>
> A couple of comments:
>
>   o  nfs_get_client() already sticks the new client on the tail of the nfs_client list
>
>   o  We don't want to get stuck in a loop here.  Should the "do {}" loop in nfs40_discover_server_trunking() be bounded by a retry count?
>
> However, I haven't heard Ben say "oh, yes, my server had rebooted."  I'd like some confirmation that the match failed for an explainable and expected reason.

The server machine did not reboot, but it's badly overloaded,
trying to serve 3000 mount points that are
constantly being brought up and torn down while
NFS write traffic is going on.

Even with all this, I've seen this particular problem only twice in
around 2 days of solid testing (I've been optimizing my user-space
app, and the better it gets, the more kernel bugs I find!)

If you have some particular debug info you want printed in
the failure cause, I'll be happy to run with that.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

