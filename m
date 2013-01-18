Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:43161 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753252Ab3ARXGx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2013 18:06:53 -0500
Message-ID: <50F9D589.7090902@candelatech.com>
Date: Fri, 18 Jan 2013 15:06:49 -0800
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Question on nfs40_discover_server_trunking.
References: <50F9BE66.6080608@candelatech.com>  <0F001F0E-229D-4314-A42E-84402E4F1FC7@oracle.com>  <1358546604.2872.6.camel@leira.trondhjem.org> <4FA345DA4F4AE44899BD2B03EEEC2FA915C04FE5@sacexcmbx05-prd.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA915C04FE5@sacexcmbx05-prd.hq.netapp.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/18/2013 02:59 PM, Myklebust, Trond wrote:
> On Fri, 2013-01-18 at 17:03 -0500, an unknown sender wrote:
>> On Fri, 2013-01-18 at 16:33 -0500, Chuck Lever wrote:
>>> On Jan 18, 2013, at 4:28 PM, Ben Greear <greearb@candelatech.com> wrote:
>>>
>>>> Any chance the STALE_CLIENTID case needs a 'break'?
>>>
>>> I don't think so.  LEASE_CONFIRM is set, and we want to wake the state renewal thread.
>>>
>>>>
>>>> Twice I've seen kernel crashes after the nfs40_walk_client_list
>>>> failed (though code comments say it should never fail).
>>>
>>> nfs40_walk_client_list() is looking for an nfs_client that is supposed to already be in the nfs_client list.  If the search fails, that's a bug.
>>>
>>> Eyeball the contents of your nfs_client list.  You should find an appropriate nfs_client in there, and then figure out why the search doesn't find it.
>>
>> You have considered the fact that the call to
>> nfs4_proc_setclientid_confirm can potentially return
>> NFS4ERR_STALE_CLIENTID if the server rebooted while the client was
>> walking the list?
>
> In fact, as far as I can see, the correct behaviour in
> nfs40_discover_server_trunking() should be to re-issue the setclientid
> call, and then walk the list again if nfs40_walk_client_list() returns
> NFS4ERR_STALE_CLIENTID.

Thanks for the patch.  I'll add that to my tree as well.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

