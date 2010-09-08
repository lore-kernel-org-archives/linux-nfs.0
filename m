Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.tpi.com ([70.99.223.143]:1821 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751405Ab0IHQxJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Sep 2010 12:53:09 -0400
Message-ID: <4C87BF63.3070808@canonical.com>
Date: Wed, 08 Sep 2010 10:52:51 -0600
From: Tim Gardner <tim.gardner@canonical.com>
Reply-To: tim.gardner@canonical.com
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Trond.Myklebust@netapp.com
Subject: Re: nfsd deadlock, 2.6.36-rc3
References: <4C7E73CB.7030603@canonical.com> <20100901165400.GB1201@fieldses.org> <20100902065551.079e297c@notabene> <4C7EC17B.6070509@canonical.com> <20100901211321.GC10507@fieldses.org> <4C7FBF26.3090203@canonical.com>
In-Reply-To: <4C7FBF26.3090203@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/02/2010 09:13 AM, Tim Gardner wrote:
> On 09/01/2010 03:13 PM, J. Bruce Fields wrote:
>> On Wed, Sep 01, 2010 at 03:11:23PM -0600, Tim Gardner wrote:
>>> On 09/01/2010 02:55 PM, Neil Brown wrote:
>>>> On Wed, 1 Sep 2010 12:54:01 -0400
>>>> "J. Bruce Fields"<bfields@fieldses.org> wrote:
>>>>
>>>>> On Wed, Sep 01, 2010 at 09:39:55AM -0600, Tim Gardner wrote:
>>>>>> I've been pursuing a simple reproducer for an NFS lockup that shows
>>>>>> up under stress. There is a bunch of info (some of it extraneous) in
>>>>>> http://bugs.launchpad.net/bugs/561210. I can reproduce it by writing
>>>>>> loop mounted NFS exports:
>>>>>>
>>>>>> /etc/fstab: 127.0.0.1:/srv /mnt/srv nfs rw 0 2
>>>>>> /etc/exports: /srv 127.0.0.1(rw,insecure,no_subtree_check)
>>>>>>
>>>>>> See the attached scripts test_master.sh and test_client.sh. I simply
>>>>>> repeat './test_master.sh wait' until nfsd locks up, typically within
>>>>>> 1-3 cycles, e.g.,
>>>>>
>>>>> Without looking at the dmesg and scripts carefully to confirm, one
>>>>> possible explanation is a deadlock when the server can't allocate
>>>>> memory
>>>>> required to service client requests, memory which the client itself
>>>>> needs to free by writing back dirty pages, but can't because the
>>>>> server
>>>>> isn't processing its writes.
>>>>
>>>> Having looked closely I'd say it is almost certainly this issue.
>>>> nfsd thread 1266 is in zone_reclaim waiting on a page to be written
>>>> out so
>>>> the memory can be reused.
>>>> The other nfsd threads are blocking on a mutex held by 1266.
>>>> The dd processes are waiting for pages to be written to the server
>>>>
>>>> The particular page that 1266 is waiting on is almost certainly a
>>>> page on an
>>>> NFS file, so you have a cyclic deadlock.
>>>>
>>>>>
>>>>> For that reason we just don't support loopback mounts--they're OK for
>>>>> light testing, but it would be difficult to make them completely
>>>>> robust
>>>>> under load.
>>>>
>>>> I wonder if we could use 'containers' to partition available memory
>>>> between
>>>> 'nfsd threads' and 'everything else'?? Probably not worth the effort.
>>>>
>>>> NeilBrown
>>>>
>>>
>>> I'm currently working with my support folks to reproduce this using
>>> the exact same configuration as the customer, e.g., an NFS server
>>> (running as a guest on a VMWare ESX host) serving multiple gigabit
>>> clients.
>>>
>>> I assume that is a reasonable scenario?
>>
>> Assuming no VMWare problem (which I know nothing about), sure.
>>
>> --b.
>>
>
> The support folks were able to reproduce the failure using external
> clients after about 6 hours. We're thinking that its the same symptom as
> seen in https://bugzilla.kernel.org/show_bug.cgi?id=16056. That
> backported patch b608b283a962caaa280756bc8563016a71712acf from Trond was
> just incorporated into the Ubuntu 10.04 kernel, so they'll retest to see
> if its a bona-fide fix.
>
> rtg

The solution appears to be to twiddle with /proc/sys/vm/min_free_kbytes 
and /proc/sys/vm/drop_caches, though I'm not sure this addresses the 
root cause. Perhaps low memory really is the root cause.

At any rate, their solution was to set min_free_kbytes to 4GB, and to 
'echo 1 > /proc/sys/vm/drop_caches' whenever free memory fell below 8GB. 
Not particularly elegant, but it appears to have stopped their server 
from wedging.

rtg

-- 
Tim Gardner tim.gardner@canonical.com
