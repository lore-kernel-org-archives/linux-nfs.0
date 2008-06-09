From: "Weathers, Norman R." <Norman.R.Weathers-496aOtIFJR1B+Kdf37RAV9BPR1lH4CV8@public.gmane.org>
Subject: RE: Problems with large number of clients and reads
Date: Mon, 9 Jun 2008 08:56:58 -0500
Message-ID: <0122F800A3B64C449565A9E8C2977010155586@hoexmb9.conoco.net>
References: <1212519001.24900.14.camel@hololw58>	 <76bd70e30806040649h53ab5d66x8c3423c551e94f77@mail.gmail.com>	 <1212588796.27117.4.camel@hololw58> <1212692072.25393.6.camel@hololw58> <48494D5E.9000501@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Chuck Lever" <chucklever@gmail.com>, <linux-nfs@vger.kernel.org>
To: <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailman2.ppco.com ([138.32.41.14]:48721 "EHLO mailman2.ppco.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750928AbYFIN5H convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jun 2008 09:57:07 -0400
Received: from bvlextrd3.conoco.net (bvlextrd3.conoco.net [138.32.41.15])
	by mailman2.ppco.com (Switch-3.2.7/Switch-3.2.7) with ESMTP id m59Dv4WT006421
	for <linux-nfs@vger.kernel.org>; Mon, 9 Jun 2008 08:57:04 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>




-----Original Message-----
From: Chuck Lever [mailto:chuck.lever@oracle.com]
Sent: Fri 6/6/2008 9:44 AM
To: Weathers, Norman R.
Cc: Chuck Lever; linux-nfs@vger.kernel.org
Subject: Re: Problems with large number of clients and reads
 
Norman Weathers wrote:
> On Wed, 2008-06-04 at 09:13 -0500, Norman Weathers wrote:
>> On Wed, 2008-06-04 at 09:49 -0400, Chuck Lever wrote:
>>> Hi Norman-
>>>
>>> On Tue, Jun 3, 2008 at 2:50 PM, Norman Weathers
>>> <norman.r.weathers-496aOtIFJR1B+Kdf37RAV9BPR1lH4CV8@public.gmane.org> wrote:
>>>> Hello all,
>>>>
>>>> We are having some issues with some high throughput servers of ours.
>>>>
>>>> Here is the issue, we are using a vanilla 2.6.22.14 kernel on a node
>>>> with 2 Dual Core Intels (3 GHz) and 16 GB of ram.  The files that are
>>>> being served are around 2 GB each, and there are usually 3 to 5 of them
>>>> being read, so once read they fit into memory nicely, and when all is
>>>> working correctly, we have a perfectly filled cache, with almost no disk
>>>> activity.
>>>>
>>>> When we have large NFS activity (say, 600 to 1200 clients) connecting to
>>>> the server(s), they can get into a state where they are using up all of
>>>> memory, but they are dropping cache.  slabtop is showing 13 GB of memory
>>>> being used by the size-4096 slab object.  We have two ethernet channels
>>>> bonded, so we see in excess of 240 MB/s of data flowing out of the box,
>>>> and all of the sudden, disk activity has risen to 185 MB/s.  This
>>>> happens if we are using 8 or more nfs threads.  If we limit the threads
>>>> to 6 or less, this doesn't happen.  Of course, we are starving clients,
>>>> but at least the jobs that my customers are throwing out there are
>>>> progressing.  The question becomes, what is causing the memory to be
>>>> used up by the slab size-4096 object?  Why when all of the sudden a
>>>> bunch of clients ask for data does this object grow from 100 MB to 13
>>>> GB?  I have set the memory settings to something that I thought was
>>>> reasonable.
>>>>
>>>> Here is some more of the particulars:
>>>>
>>>> sysctl.conf tcp memory settings:
>>>>
>>>> # NFS Tuning Parameters
>>>> sunrpc.udp_slot_table_entries = 128
>>>> sunrpc.tcp_slot_table_entries = 128
>>> I don't have an answer to your size-4096 question, but I do want to
>>> note that setting the slot table entries sysctls has no effect on NFS
>>> servers.  It's a client-only setting.
>>>
>>
>> Ok.
>>
>>> Have you tried this experiment on a server where there are no special
>>> memory tuning sysctls?
>> Unfortunately, no.  I can try it today.
>>
> 
> 
> I tried the test with no special memory settings, and I still see the
> same issue.  I also have noticed that even with only 3 threads running,
> I can still have times where 11 GB of memory is being used for buffer
> and not for disk cache.  It just seems like memory is being used up if
> we have a lot of requests from a lot of clients at once...

>I'm at a loss... but I have another question or two.  Is it just memory 
>utilization issues that you see on the server, or are there noticeable 
>performance problems that crop up when you see this?

We are seeing both, but the performance problem is odd in that we have 20 of these systems
and they slow down a lot whenever one of the other systems has this issue.  It is like one
system really starts to load up on connections and requests, but at the same time it pushes
out network wise every last little bit of network packets that it can (2 1 Gb connections pushing
245 MB/s).  What else is weird is that if I restart NFS during that time, it generally causes the
memory to settle down and allows connections to move on. (Data is basically striped across these
20 nodes).  When a node has "the issue" happen, the other 19 servers slow down from 150 or 180 MB/s
to 50 MB/s or less.

>Did you mention what your physical file system is on the server?  Are 
>you running it on an LVM or software or hardware RAID?

The file system is XFS, it is on a hardware RAID (HP cciss), running RAID 5, 64 k stripe.  I can
push from the file system itself on a linear read ~ 180 MB/s, and with a cached file, I can
easily push out the data.
