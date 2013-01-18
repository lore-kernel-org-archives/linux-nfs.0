Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:46323 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753381Ab3ARV7S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2013 16:59:18 -0500
Message-ID: <50F9C5B4.5020000@candelatech.com>
Date: Fri, 18 Jan 2013 13:59:16 -0800
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Question on nfs40_discover_server_trunking.
References: <50F9BE66.6080608@candelatech.com> <0F001F0E-229D-4314-A42E-84402E4F1FC7@oracle.com>
In-Reply-To: <0F001F0E-229D-4314-A42E-84402E4F1FC7@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/18/2013 01:33 PM, Chuck Lever wrote:
>
> On Jan 18, 2013, at 4:28 PM, Ben Greear <greearb@candelatech.com> wrote:
>
>> Any chance the STALE_CLIENTID case needs a 'break'?
>
> I don't think so.  LEASE_CONFIRM is set, and we want to wake the state renewal thread.
>
>>
>> Twice I've seen kernel crashes after the nfs40_walk_client_list
>> failed (though code comments say it should never fail).
>
> nfs40_walk_client_list() is looking for an nfs_client that is supposed to already be in the nfs_client list.  If the search fails, that's a bug.
>
> Eyeball the contents of your nfs_client list.  You should find an appropriate nfs_client in there, and then figure out why the search doesn't find it.

Ok, I think I found another issue.

nfs4_client_init does not initialize 'old', but passes it to nfs4_discover_server_trunking.

That gets passed to the detect_trunking operation, which is nfs40_discover_server_trunking
or nfs41_discover_server_trunking.

This will call walk_client_list, which also may not ever assign a value to
'result'.

The code in walk_client_list always dereferences result, however.

So, that is probably why my system blows up shortly after the 'impossible'
error message...

Maybe initialize result to NULL in nfs4[10]_walk_client_list and properly check
for null result in calling code?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

