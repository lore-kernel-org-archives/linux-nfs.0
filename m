Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:52899 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756043Ab2FNOx0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jun 2012 10:53:26 -0400
Received: by weyu7 with SMTP id u7so1317216wey.19
        for <linux-nfs@vger.kernel.org>; Thu, 14 Jun 2012 07:53:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FD8AF15.5010909@oracle.com>
References: <4FBBBD26.2090203@oracle.com>
	<CAHVgHyX3rXzWEgJwL2cHLQ4aZn9G0Vbz_kHU8ax-EHObEtYf1g@mail.gmail.com>
	<4FD8AF15.5010909@oracle.com>
Date: Thu, 14 Jun 2012 10:53:23 -0400
Message-ID: <CAHVgHyU-HntWo6e_nByeV1q0L2e2vkV0dwR=rn+7NeU9Lix8=Q@mail.gmail.com>
Subject: Re: Help with NFS over 10GbE performance - possible NFS client to TCP bottleneck
From: Andy Adamson <androsadamson@gmail.com>
To: Jeff Wright <jeff.wright@oracle.com>
Cc: linux-nfs@vger.kernel.org, Craig Flaskerud <Craig.flaskerud@oracle.com>,
        Donna Harland <donna.harland@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 13, 2012 at 11:17 AM, Jeff Wright <jeff.wright@oracle.com> wrote:
> Andy,
>
> We did not check the RPC statistics on the client, but on the target the
> queue is nearly empty.  What is the command to check to see the RPC backlog
> on the Linux client?

Hi Jeff

The command is

# mountstats <mountpoint>

The RPC statistics 'average backlog queue length'

Have you tried iperf?

-->Andy

>
> Thanks,
>
> Jeff
>
>
> On 06/13/12 09:08, Andy Adamson wrote:
>>
>> Chuck recently brought this to my attention:
>>
>> Have you tried looking at the RPC statistics average backlog queue
>> length in mountstats? The backlog queue gets filled with NFS requests
>> that do not get an RPC slot.
>>
>> I assume that jumbo frames are turned on throughout the connection.
>>
>> I would try some iperf runs.  This will check the throughput of the
>> memory<->  network<->  memory path and provide an upper bound on what
>> to expect from NFS as well as displaying the MTU to check for jumbo
>> frame compliance.
>>
>> I would then try some iozone tests, including the O_DIRECT tests. This
>> will give some more data on the issue by separating throughput from
>> the application specifics.
>>
>> -->Andy
>>
>> On Tue, May 22, 2012 at 12:21 PM, Jeff Wright<jeff.wright@oracle.com>
>>  wrote:
>>>
>>> Team,
>>>
>>> I am working on a team implementing a configuration with an OEL kernel
>>> (2.6.32-300.3.1.el6uek.x86_64) and kernel NFS accessing an NFS server
>>> over
>>> 10GbE a Solaris 10.  We are trying to resolve what appears to be a
>>> bottleneck between the Linux kernel NFS client and the TCP stack.
>>>  Specifically, the TCP send queue on the Linux client is empty (save a
>>> couple of bursts) when we are running write I/O from the file system, the
>>> TCP receive queue on the Solaris 10 NFS server is empty, and the RPC
>>> pending
>>> request queue on the Solaris 10 NFS server is zero.   If we dial the
>>> network
>>> to 1GbE we get a nice deep TCP send queue on the client, which is the
>>> bottleneck I was hoping to get to with 10GbE.  At this point, we am
>>> pretty
>>> sure the S10 NFS server can run to at least 1000 MBPS.
>>>
>>> So far, we have implemented the following Linux kernel tunes:
>>>
>>> sunrpc.tcp_slot_table_entries = 128
>>> net.core.rmem_default = 4194304
>>> net.core.wmem_default = 4194304
>>> net.core.rmem_max = 4194304
>>> net.core.wmem_max = 4194304
>>> net.ipv4.tcp_rmem = 4096 1048576 4194304
>>> net.ipv4.tcp_wmem = 4096 1048576 4194304
>>> net.ipv4.tcp_timestamps = 0
>>> net.ipv4.tcp_syncookies = 1
>>> net.core.netdev_max_backlog = 300000
>>>
>>> In addition, we am running jumbo frames on the 10GbE NIC and we have
>>> cpuspeed and irqbalance disabled (no noticeable changes when we did
>>> this).
>>>  The mount options on the client side are as follows:
>>>
>>> 192.168.44.51:/export/share on /export/share type nfs
>>>
>>> (rw,nointr,bg,hard,rsize=1048576,wsize=1048576,proto=tcp,vers=3,addr=192.168.44.51)
>>>
>>> In this configuration we get about 330 MBPS of write throughput with 16
>>> pending stable (open with O_DIRECT) synchronous (no kernel aio in the I/O
>>> application) writes.  If we scale beyond 16 pending I/O response time
>>> increases but throughput remains fixed.  It feels like there is a problem
>>> with getting more than 16 pending I/O out to TCP, but we can't tell for
>>> sure
>>> based on our observations so far.  We did notice that tuning the wsize
>>> down
>>> to 32kB increased throughput to 400 MBPS, but we could not identify the
>>> root
>>> cause of this change.
>>>
>>> Please let us know if you have any suggestions for either diagnosing the
>>> bottleneck more accurately or relieving the bottleneck.  Thank you in
>>> advance.
>>>
>>> Sincerely,
>>>
>>> Jeff
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
