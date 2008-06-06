From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Problems with large number of clients and reads
Date: Fri, 06 Jun 2008 10:44:46 -0400
Message-ID: <48494D5E.9000501@oracle.com>
References: <1212519001.24900.14.camel@hololw58>	 <76bd70e30806040649h53ab5d66x8c3423c551e94f77@mail.gmail.com>	 <1212588796.27117.4.camel@hololw58> <1212692072.25393.6.camel@hololw58>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060303010303080207050202"
Cc: Chuck Lever <chucklever@gmail.com>, linux-nfs@vger.kernel.org
To: Norman Weathers <norman.r.weathers-496aOtIFJR1B+Kdf37RAV9BPR1lH4CV8@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:58639 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755063AbYFFOpK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jun 2008 10:45:10 -0400
In-Reply-To: <1212692072.25393.6.camel@hololw58>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060303010303080207050202
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

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

I'm at a loss... but I have another question or two.  Is it just memory 
utilization issues that you see on the server, or are there noticeable 
performance problems that crop up when you see this?

Did you mention what your physical file system is on the server?  Are 
you running it on an LVM or software or hardware RAID?

--------------060303010303080207050202
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck_lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck_lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------060303010303080207050202--
