Return-Path: <orion@nwra.com>
Subject: Re: NFS troubles
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <a6548640-bc0c-3bdd-7a0c-b1996978a26d@nwra.com>
 <A5B6EFB3-239C-420C-91F4-2B8D1BCBA85A@redhat.com>
From: Orion Poplawski <orion@nwra.com>
Message-ID: <efe6d26f-d1e9-bf16-e608-a2595e4fdbdf@nwra.com>
Date: Tue, 3 Apr 2018 09:44:07 -0600
MIME-Version: 1.0
In-Reply-To: <A5B6EFB3-239C-420C-91F4-2B8D1BCBA85A@redhat.com>
Content-Type: text/plain; charset=utf-8
List-ID: <linux-nfs.vger.kernel.org>

Kernel is 3.10.0-693.21.1.el7.x86_64  I don't have Red Hat support for these
systems.

I discovered that I'd been forcing vers=4.0 mounts in order to work around a
mounting issue.  I'm moving back to the default 4.1 mounts as it seems to work
better for this issue.  If the issue returns I'll try to grab a longer trace.

Thanks.

On 04/02/2018 12:30 PM, Benjamin Coddington wrote:
> NFS4ERR_EXPIRED means the client is trying to use state that the server
> believes to have expired or that has been supplanted by newer state.  Can we
> get kernel versions for the client and server?  Have you talked to your Red
> Hat support channel about this?
> 
> This capture doesn't appear to show any bugs or bad behaviors, but a longer
> capture may..
> 
> Ben
> 
> On 2 Apr 2018, at 13:50, Orion Poplawski wrote:
> 
>> I'm having a lot of trouble with NFS going out to lunch between my RHEL7
>> machines.  Users cannot access files, and get errors like:
>>
>> $ touch blah
>> touch: cannot touch ‘blah’: Input/output error
>>
>> I'm attaching a pcap trace of the above touch during the problem.  It seems
>> that the server is returning NFS4ERR_EXPIRED.
>>
>> Reboots/restarts of nfs help for a bit but then the problems return.
>>
>> Other symptoms of trouble are messages like:
>>
>> RPC: fragment too large: 613351424
>>
>> on the client.
>>
>> Any help with trying to track this down would be greatly appreciated.
>>
>> -- 
>> Orion Poplawski
>> Manager of NWRA Technical Systems          720-772-5637
>> NWRA, Boulder/CoRA Office             FAX: 303-415-9702
>> 3380 Mitchell Lane                       orion@nwra.com
>> Boulder, CO 80301                 https://www.nwra.com/


-- 
Orion Poplawski
Manager of NWRA Technical Systems          720-772-5637
NWRA, Boulder/CoRA Office             FAX: 303-415-9702
3380 Mitchell Lane                       orion@nwra.com
Boulder, CO 80301                 https://www.nwra.com/
