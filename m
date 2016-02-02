Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from krichy.tvnetwork.hu ([109.61.101.194]:60746 "EHLO
	krichy.tvnetwork.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754291AbcBBOAo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Feb 2016 09:00:44 -0500
Received: from localhost (localhost [127.0.0.1])
	by krichy.tvnetwork.hu (Postfix) with ESMTP id 934797CBF9
	for <linux-nfs@vger.kernel.org>; Tue,  2 Feb 2016 15:00:40 +0100 (CET)
Date: Tue, 2 Feb 2016 15:00:40 +0100 (CET)
From: krichy@tvnetwork.hu
To: linux-nfs@vger.kernel.org
Subject: Re: nfs client hangs / repeating nfs requests
In-Reply-To: <20151030174823.GA4143@fieldses.org>
Message-ID: <alpine.DEB.2.20.1602021446100.20549@krichy.tvnetwork.hu>
References: <alpine.DEB.2.20.1510281158380.24492@krichy.tvnetwork.hu> <20151028135742.GC20682@fieldses.org> <alpine.DEB.2.20.1510281511070.25867@krichy.tvnetwork.hu> <alpine.DEB.2.20.1510290012060.5794@krichy.tvnetwork.hu> <20151029132247.GB28300@fieldses.org>
 <alpine.DEB.2.20.1510291524380.9150@krichy.tvnetwork.hu> <20151030174823.GA4143@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="1030603365-695249147-1454421640=:20549"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--1030603365-695249147-1454421640=:20549
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 8BIT

Dear all,

Unfortunately my issue is still there, just I had no time to play with it. 
So for now, I am attaching a tcpdump at the server and at the client side. 
What I see is some kind of tcp retransmissions/anomalities, which causes 
the whole nfs mount to block. The very strange thing is that I am 
reproducing this with the attached script, and it always stops at the very 
same file, after IMGP0731.JPG.

I hope someone could give some ideas, what can be wrong. Unfortunately I 
wont give my files for testing, but I can reproduce it anytime.

I have arount ~20 msec rtt to the nfs server. There are no packet losses, 
you will see in both capture files, but for some reason nfs hangs at the 
very same file. And after some time (few minutes) it passes through.

I've packed the test script and the two captures here:

http://krichy.web.nmdps.net/nfs/files.tar.gz

I am using debian jessie's backport kernel (4.3.3-7) right now on the 
client, and the server is a freebsd 10.2.

Many thanks in advance,
Kojedzinszky Richárd
Euronet Magyarorszag Informatika Zrt.

On Fri, 30 Oct 2015, J. Bruce Fields wrote:

> Date: Fri, 30 Oct 2015 13:48:23 -0400
> From: J. Bruce Fields <bfields@fieldses.org>
> To: krichy@tvnetwork.hu
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: nfs client hangs / repeating nfs requests
> 
> On Thu, Oct 29, 2015 at 03:27:25PM +0100, krichy@tvnetwork.hu wrote:
>> And do you have idea of what could be the repeating nfs client
>> requests after unmounting the nfs share? Could there be any cases
>> when a reply arrives in, but the kernel nfs code does not or can not
>> process it, thus not changing that request's state?
>
> I missed your description of what was happening with those requests,
> sorry.
>
> Also, I'm a little confused by your description of the hangs.  Do they
> last until you give up and power off the machine, or do they resolve
> themselves eventually?  If the latter then for all we know that might
> just be what happens over a network with some random packet loss.
>
> --b.
>
>>
>>
>> Kojedzinszky Richard
>> Euronet Magyarorszag Informatika Zrt.
>>
>> On Thu, 29 Oct 2015, J. Bruce Fields wrote:
>>
>>> Date: Thu, 29 Oct 2015 09:22:47 -0400
>>> From: J. Bruce Fields <bfields@fieldses.org>
>>> To: krichy@tvnetwork.hu
>>> Cc: linux-nfs@vger.kernel.org
>>> Subject: Re: nfs client hangs / repeating nfs requests
>>>
>>> On Thu, Oct 29, 2015 at 12:17:27AM +0100, krichy@tvnetwork.hu wrote:
>>>> I am trying to do more dbugging regarding my issue. Now I am at a
>>>> stage where the nfs mount is unmounted, and still the kernel log
>>>> shows periodic nfs messages, and also packets transmitted. The nfs
>>>> mount point is unmounted.
>>>>
>>>> Something strange is going here.
>>>>
>>>> The nfs was mounted over gre over ipsec over a WAN connection, which
>>>> may have random packet loss or high RTT. Can this cause the nfs
>>>> client to behave this way? I suppose it should no.
>>>
>>> I'd expect poor performance, but not an indefinite hang.
>>>
>>> One possible exception is that if the protocols depend on userspace
>>> helpers of some sort (e.g. for crypto setup), then there's a potential
>>> deadlock where the helper needs to allocate memory to make progress, but
>>> memory allocation is waiting on nfs to write out dirty pages.  Since
>>> you're not talking about a write-heavy workload that's unlikely in your
>>> case.
>>>
>>>> Please tell me what info should I collect for more debugging.
>>>
>>> Possible things to try:
>>>
>>> 	- ps to identify which process are hanging.
>>> 	- look at network traffic with wireshark or tcpdump--are client
>>> 	  and server still communicating, and if so what are they doing?
>>> 	- echo 0 >/proc/sys/sunrpc/rpc_debug will log information about
>>> 	  rpc tasks.
>>> 	- echo t >/proc/sysrq-trigger will dump information about tasks.
>>>
>>> And also check the server to see if it's logging anything or if nfsd is
>>> hung (but I'm not familiar with freebsd debugging).
>>>
>>> --b.
>>>
>>>>
>>>> Unfortunately I could not reproduce this in a virtualised network
>>>> environment even with netem qdisc to emulate the WAN
>>>> characteristics. But I am trying to do it so.
>>>>
>>>> Thanks in advance,
>>>>
>>>> Kojedzinszky Richard
>>>> Euronet Magyarorszag Informatika Zrt.
>>>>
>>>> On Wed, 28 Oct 2015, krichy@tvnetwork.hu wrote:
>>>>
>>>>> Date: Wed, 28 Oct 2015 16:19:50 +0100 (CET)
>>>>> From: krichy@tvnetwork.hu
>>>>> To: J. Bruce Fields <bfields@fieldses.org>
>>>>> Cc: linux-nfs@vger.kernel.org
>>>>> Subject: Re: nfs client hangs / repeating nfs requests
>>>>>
>>>>> Dear Bruce,
>>>>>
>>>>> That was an n-th experiment. Actually, with default settings the
>>>>> hang still happens, but I've just noticed the repeating packets
>>>>> with these settings. I've chosen 1024 sizes to fit the requests in
>>>>> one packets, to avoid any ip/udp fragmentation.
>>>>>
>>>>> The server is a freebsd nfs. I am struggling with this setup for a
>>>>> few months now, and I dont know, what is the cause of the hang. I
>>>>> could hardly believe that the nfs server is buggy, as many people
>>>>> around the world is using freebsd as an nfs server. The same for
>>>>> linux, I hardly can believe that the nfs client is faulty, as
>>>>> again many people is using it.
>>>>>
>>>>> But still I have the issue, hanging nfs mounts.
>>>>>
>>>>> I will report on any advance.
>>>>>
>>>>> Regards,
>>>>>
>>>>> Kojedzinszky Richard
>>>>> Euronet Magyarorszag Informatika Zrt.
>>>>>
>>>>> On Wed, 28 Oct 2015, J. Bruce Fields wrote:
>>>>>
>>>>>> Date: Wed, 28 Oct 2015 09:57:42 -0400
>>>>>> From: J. Bruce Fields <bfields@fieldses.org>
>>>>>> To: krichy@tvnetwork.hu
>>>>>> Cc: linux-nfs@vger.kernel.org
>>>>>> Subject: Re: nfs client hangs / repeating nfs requests
>>>>>>
>>>>>> On Wed, Oct 28, 2015 at 12:06:02PM +0100, krichy@tvnetwork.hu wrote:
>>>>>>> Dear all,
>>>>>>>
>>>>>>> I am again having some trouble with nfs client. Actually I am
>>>>>>> running minidlna over nfs over gre over ipsec configuration, but I
>>>>>>> suppose the latter two should not count.
>>>>>>>
>>>>>>> Minidlna scans the entire directory, reading all files (or just
>>>>>>> parts), and while doing it, sometimes the process hangs.
>>>>>>>
>>>>>>> I could emulate this with reading the first 16k off all files from
>>>>>>> nfs, and fortunately the effect is the same.
>>>>>>>
>>>>>>> After a hang/recovery, no userspace is accessing the nfs right now,
>>>>>>> but tcpdump shows repeating requests/replies (attached). Meanwhile
>>>>>>> the rpc debug also emits logs.
>>>>>>>
>>>>>>> # uname -a
>>>>>>> Linux k-desktop 4.1.0-2-amd64 #1 SMP Debian 4.1.6-1 (2015-08-23)
>>>>>>> x86_64 GNU/Linux
>>>>>>> # mount | grep nfs
>>>>>>> 10.0.0.2:/home/kh on /remote/kh type nfs (rw,relatime,vers=3,rsize=1024,wsize=1024,namlen=255,hard,nolock,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=10.0.0.2,mountvers=3,mountport=644,mountproto=udp,local_lock=all,addr=10.0.0.2)
>>>>>>
>>>>>> rsize=1024,wsize=1024,proto=udp is unusual and not normally what we'd
>>>>>> recommend.  Is there a reason for not sticking with defaults there?
>>>>>>
>>>>>> But I don't have any explanation for the hang.
>>>>>>
>>>>>> --b.
>>>>>>
>>>>>>> Any suggestions?
>>>>>>>
>>>>>>> Kojedzinszky Richard
>>>>>>> Euronet Magyarorszag Informatika Zrt.
>>>>>>
>>>>>>
>>>>>>> Oct 28 12:02:18 k-desktop kernel: [12237.516020] RPC: 54539
>>>>>>> xprt_prepare_transmit
>>>>>>> Oct 28 12:02:18 k-desktop kernel: [12237.516022] RPC: 54539
>>>>>>> xprt_cwnd_limited cong = 0 cwnd = 256
>>>>>>> Oct 28 12:02:18 k-desktop kernel: [12237.516027] RPC: 54539
>>>>>>> xprt_transmit(120)
>>>>>>> Oct 28 12:02:18 k-desktop kernel: [12237.516054] RPC: 54539 xmit complete
>>>>>>> Oct 28 12:02:22 k-desktop kernel: [12241.932011] RPC: 54539 xprt_timer
>>>>>>> Oct 28 12:02:22 k-desktop kernel: [12241.932016] RPC:
>>>>>>> cong 256, cwnd was 256, now 256
>>>>>>> Oct 28 12:02:22 k-desktop kernel: [12241.932020] RPC: 54539
>>>>>>> xprt_prepare_transmit
>>>>>>> Oct 28 12:02:22 k-desktop kernel: [12241.932022] RPC: 54539
>>>>>>> xprt_cwnd_limited cong = 0 cwnd = 256
>>>>>>> Oct 28 12:02:22 k-desktop kernel: [12241.932027] RPC: 54539
>>>>>>> xprt_transmit(120)
>>>>>>> Oct 28 12:02:22 k-desktop kernel: [12241.932054] RPC: 54539 xmit complete
>>>>>>> Oct 28 12:02:31 k-desktop kernel: [12250.748013] RPC: 54539 xprt_timer
>>>>>>> Oct 28 12:02:31 k-desktop kernel: [12250.748018] RPC:
>>>>>>> cong 256, cwnd was 256, now 256
>>>>>>> Oct 28 12:02:31 k-desktop kernel: [12250.748023] RPC: 54539
>>>>>>> xprt_prepare_transmit
>>>>>>> Oct 28 12:02:31 k-desktop kernel: [12250.748025] RPC: 54539
>>>>>>> xprt_cwnd_limited cong = 0 cwnd = 256
>>>>>>> Oct 28 12:02:31 k-desktop kernel: [12250.748029] RPC: 54539
>>>>>>> xprt_transmit(120)
>>>>>>> Oct 28 12:02:31 k-desktop kernel: [12250.748058] RPC: 54539 xmit complete
>>>>>>> Oct 28 12:02:32 k-desktop kernel: [12251.852014] RPC: 54539 xprt_timer
>>>>>>> Oct 28 12:02:32 k-desktop kernel: [12251.852018] RPC:
>>>>>>> cong 256, cwnd was 256, now 256
>>>>>>> Oct 28 12:02:32 k-desktop kernel: [12251.852021] RPC: 54539
>>>>>>> xprt_prepare_transmit
>>>>>>> Oct 28 12:02:32 k-desktop kernel: [12251.852023] RPC: 54539
>>>>>>> xprt_cwnd_limited cong = 0 cwnd = 256
>>>>>>> Oct 28 12:02:32 k-desktop kernel: [12251.852027] RPC: 54539
>>>>>>> xprt_transmit(120)
>>>>>>> Oct 28 12:02:32 k-desktop kernel: [12251.852048] RPC: 54539 xmit complete
>>>>>>> Oct 28 12:02:35 k-desktop kernel: [12254.060011] RPC: 54539 xprt_timer
>>>>>>> Oct 28 12:02:35 k-desktop kernel: [12254.060015] RPC:
>>>>>>> cong 256, cwnd was 256, now 256
>>>>>>> Oct 28 12:02:35 k-desktop kernel: [12254.060018] RPC: 54539
>>>>>>> xprt_prepare_transmit
>>>>>>> Oct 28 12:02:35 k-desktop kernel: [12254.060020] RPC: 54539
>>>>>>> xprt_cwnd_limited cong = 0 cwnd = 256
>>>>>>> Oct 28 12:02:35 k-desktop kernel: [12254.060023] RPC: 54539
>>>>>>> xprt_transmit(120)
>>>>>>> Oct 28 12:02:35 k-desktop kernel: [12254.060041] RPC: 54539 xmit complete
>>>>>>> Oct 28 12:02:39 k-desktop kernel: [12258.476012] RPC: 54539 xprt_timer
>>>>>>> Oct 28 12:02:39 k-desktop kernel: [12258.476016] RPC:
>>>>>>> cong 256, cwnd was 256, now 256
>>>>>>> Oct 28 12:02:39 k-desktop kernel: [12258.476020] RPC: 54539
>>>>>>> xprt_prepare_transmit
>>>>>>> Oct 28 12:02:39 k-desktop kernel: [12258.476022] RPC: 54539
>>>>>>> xprt_cwnd_limited cong = 0 cwnd = 256
>>>>>>> Oct 28 12:02:39 k-desktop kernel: [12258.476027] RPC: 54539
>>>>>>> xprt_transmit(120)
>>>>>>> Oct 28 12:02:39 k-desktop kernel: [12258.476052] RPC: 54539 xmit complete
>>>>>>
>>>>>> --
>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>>
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
--1030603365-695249147-1454421640=:20549--
