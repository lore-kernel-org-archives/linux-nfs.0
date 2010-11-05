Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34756 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013Ab0KELna convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Nov 2010 07:43:30 -0400
Received: by wyb36 with SMTP id 36so976994wyb.19
        for <linux-nfs@vger.kernel.org>; Fri, 05 Nov 2010 04:43:29 -0700 (PDT)
In-Reply-To: <4CD26CC5.80805@gluster.com>
References: <766909857.700951.1288807081999.JavaMail.root@mb2>
	<4CD1AAE2.3020003@gmail.com>
	<AANLkTimxDBwjOZ+jmSap+-qDsGZpSGOewYtbfUk60D=G@mail.gmail.com>
	<4CD26CC5.80805@gluster.com>
Date: Fri, 5 Nov 2010 04:43:29 -0700
Message-ID: <AANLkTim4iinmxtV9p1HE11qHQTNuEVH4NmtRPO5uwXyK@mail.gmail.com>
Subject: Re: Streaming perf problem on 10g
From: "fibreraid@gmail.com" <fibreraid@gmail.com>
To: Shehjar Tikoo <shehjart@gluster.com>
Cc: Joe Landman <joe.landman@gmail.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Shehjar,

Have you tested with another file system besides ext4, like XFS or ReiserFS?

How many SSD's in the configuration? What is the storage controller
(SAS, SATA, PCIe direct-connect)? 1.5GB/sec a lot of speed...seems
like at least 8 SSDs but please confirm.

Also, you are not copying enough data in this test....how much DRAM in
the server with the SSD? I would run dd with an IO amount at least
double or triple the the amount of memory in the system. 1GB is not
enough.

-Tommy

On Thu, Nov 4, 2010 at 1:20 AM, Shehjar Tikoo <shehjart@gluster.com> wrote:
> fibreraid@gmail.com wrote:
>>
>> Hi Shehjar,
>>
>> Can you provide the exact dd command you are running both locally and
>> for the NFS mount?
>
> on the ssd:
>
> # dd if=/dev/zero of=bigfile4 bs=1M count=1000
> 1000+0 records in
> 1000+0 records out
> 1048576000 bytes (1.0 GB) copied, 0.690624 s, 1.5 GB/s
> # dd if=/dev/zero of=bigfile4 bs=1M count=1000 oflag=direct
> 1000+0 records in
> 1000+0 records out
> 1048576000 bytes (1.0 GB) copied, 1.72764 s, 607 MB/s
>
> The ssd file system is ext4 mounted as
> (rw,noatime,nodiratime,data=writeback)
>
> Here is another strangeness, using oflag=direct gives better performance:
>
> On nfs mount:
> # dd if=/dev/zero of=/tmp/testmount/bigfile3 bs=1M count=1000 oflag=direct
> 1000+0 records in
> 1000+0 records out
> 1048576000 bytes (1.0 GB) copied, 3.7063 s, 283 MB/s
> # rm /tmp/testmount/bigfile3
> # dd if=/dev/zero of=/tmp/testmount/bigfile3 bs=1M count=1000
> 1000+0 records in
> 1000+0 records out
> 1048576000 bytes (1.0 GB) copied, 9.66876 s, 108 MB/s
>
> The kernel on both server and client is 2.6.32-23, so I think this
> regression might be in play.
>
> http://thread.gmane.org/gmane.comp.file-systems.ext4/20360
>
> Thanks
> -Shehjar
>
>>
>> -Tommy
>>
>> On Wed, Nov 3, 2010 at 11:33 AM, Joe Landman <joe.landman@gmail.com>
>> wrote:
>>>
>>> On 11/03/2010 01:58 PM, Shehjar Tikoo wrote:
>>>>
>>>> Hi All,
>>>>
>>>> I am running into a performance problem with 2.6.32-23 Ubuntu lucid on
>>>> both client and server.
>>>>
>>>> The disk is an SSD performing at 1.4 - 1.6Gbps for a dd of a 6gb file in
>>>> 64k blocks.
>>>>
>>> If the size of this file is comparable to or smaller than the client or
>>> server ram, this number is meaningless.
>>>
>>>> The network is performing fine with many Gbps of iperf throughput.
>>>>
>>> GbE gets you 1 Gbps.  10GbE may get you from 3-10 Gbps, depending upon
>>> many
>>> things.  What are  your numbers?
>>>
>>>> Yet, the dd write performance over the nfs mount point ranges from
>>>> 96-105
>>>> Mbps for a 6gb file in 64k blocks.
>>>>
>>> Sounds like you are writing over the gigabit, and not the 10GbE
>>> interface.
>>>
>>>> I've tried changing the tcp_slot_table_entries and the wsize but there
>>>> is
>>>> negligible gain from these.
>>>>
>>>> Does it sound like a client side inefficiency?
>>>>
>>> Nope.
>>>
>>> --
>>> Joseph Landman, Ph.D
>>> Founder and CEO
>>> Scalable Informatics Inc.
>>> email: landman@scalableinformatics.com
>>> web : http://scalableinformatics.com
>>> phone: +1 734 786 8423 x121
>>> fax : +1 866 888 3112
>>> cell : +1 734 612 4615
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>
>
