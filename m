Return-Path: <olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Sender: olga.kornievskaia@gmail.com
In-Reply-To: <efe6d26f-d1e9-bf16-e608-a2595e4fdbdf@nwra.com>
References: <a6548640-bc0c-3bdd-7a0c-b1996978a26d@nwra.com>
 <A5B6EFB3-239C-420C-91F4-2B8D1BCBA85A@redhat.com> <efe6d26f-d1e9-bf16-e608-a2595e4fdbdf@nwra.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 4 Apr 2018 10:08:07 -0400
Message-ID: <CAN-5tyE6RxfbGhMv1AzPMSomwKoxUNFEyZgAQYB=Du6HG-iisQ@mail.gmail.com>
Subject: Re: NFS troubles
To: Orion Poplawski <orion@nwra.com>
Cc: Benjamin Coddington <bcodding@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
List-ID: <linux-nfs.vger.kernel.org>

I wonder if this is the issue we ran into during the NFS bakeathon
testing last week. Problem was that a previous NFS4.0 mount left state
so that umount didn't actually unmount. Next mount only did a
PUTROOTFH and there was no SETCLIENTID, then any operations that tried
to use the clientid got ERR_EXPIRED. We will be trying to reproduce it
again and trying to fix it.

On Tue, Apr 3, 2018 at 11:44 AM, Orion Poplawski <orion@nwra.com> wrote:
> Kernel is 3.10.0-693.21.1.el7.x86_64  I don't have Red Hat support for th=
ese
> systems.
>
> I discovered that I'd been forcing vers=3D4.0 mounts in order to work aro=
und a
> mounting issue.  I'm moving back to the default 4.1 mounts as it seems to=
 work
> better for this issue.  If the issue returns I'll try to grab a longer tr=
ace.
>
> Thanks.
>
> On 04/02/2018 12:30 PM, Benjamin Coddington wrote:
>> NFS4ERR_EXPIRED means the client is trying to use state that the server
>> believes to have expired or that has been supplanted by newer state.  Ca=
n we
>> get kernel versions for the client and server?  Have you talked to your =
Red
>> Hat support channel about this?
>>
>> This capture doesn't appear to show any bugs or bad behaviors, but a lon=
ger
>> capture may..
>>
>> Ben
>>
>> On 2 Apr 2018, at 13:50, Orion Poplawski wrote:
>>
>>> I'm having a lot of trouble with NFS going out to lunch between my RHEL=
7
>>> machines.  Users cannot access files, and get errors like:
>>>
>>> $ touch blah
>>> touch: cannot touch =E2=80=98blah=E2=80=99: Input/output error
>>>
>>> I'm attaching a pcap trace of the above touch during the problem.  It s=
eems
>>> that the server is returning NFS4ERR_EXPIRED.
>>>
>>> Reboots/restarts of nfs help for a bit but then the problems return.
>>>
>>> Other symptoms of trouble are messages like:
>>>
>>> RPC: fragment too large: 613351424
>>>
>>> on the client.
>>>
>>> Any help with trying to track this down would be greatly appreciated.
>>>
>>> --
>>> Orion Poplawski
>>> Manager of NWRA Technical Systems          720-772-5637
>>> NWRA, Boulder/CoRA Office             FAX: 303-415-9702
>>> 3380 Mitchell Lane                       orion@nwra.com
>>> Boulder, CO 80301                 https://www.nwra.com/
>
>
> --
> Orion Poplawski
> Manager of NWRA Technical Systems          720-772-5637
> NWRA, Boulder/CoRA Office             FAX: 303-415-9702
> 3380 Mitchell Lane                       orion@nwra.com
> Boulder, CO 80301                 https://www.nwra.com/
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
