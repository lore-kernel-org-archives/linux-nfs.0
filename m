Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from krichy.tvnetwork.hu ([109.61.101.194]:41364 "EHLO
	krichy.tvnetwork.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487AbbJ1PTy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Oct 2015 11:19:54 -0400
Date: Wed, 28 Oct 2015 16:19:50 +0100 (CET)
From: krichy@tvnetwork.hu
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: linux-nfs@vger.kernel.org
Subject: Re: nfs client hangs / repeating nfs requests
In-Reply-To: <20151028135742.GC20682@fieldses.org>
Message-ID: <alpine.DEB.2.20.1510281511070.25867@krichy.tvnetwork.hu>
References: <alpine.DEB.2.20.1510281158380.24492@krichy.tvnetwork.hu> <20151028135742.GC20682@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear Bruce,

That was an n-th experiment. Actually, with default settings the hang 
still happens, but I've just noticed the repeating packets with these 
settings. I've chosen 1024 sizes to fit the requests in one packets, 
to avoid any ip/udp fragmentation.

The server is a freebsd nfs. I am struggling with this setup for a few 
months now, and I dont know, what is the cause of the hang. I could hardly 
believe that the nfs server is buggy, as many people around the world is 
using freebsd as an nfs server. The same for linux, I hardly can believe 
that the nfs client is faulty, as again many people is using it.

But still I have the issue, hanging nfs mounts.

I will report on any advance.

Regards,

Kojedzinszky Richard
Euronet Magyarorszag Informatika Zrt.

On Wed, 28 Oct 2015, J. Bruce Fields wrote:

> Date: Wed, 28 Oct 2015 09:57:42 -0400
> From: J. Bruce Fields <bfields@fieldses.org>
> To: krichy@tvnetwork.hu
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: nfs client hangs / repeating nfs requests
> 
> On Wed, Oct 28, 2015 at 12:06:02PM +0100, krichy@tvnetwork.hu wrote:
>> Dear all,
>>
>> I am again having some trouble with nfs client. Actually I am
>> running minidlna over nfs over gre over ipsec configuration, but I
>> suppose the latter two should not count.
>>
>> Minidlna scans the entire directory, reading all files (or just
>> parts), and while doing it, sometimes the process hangs.
>>
>> I could emulate this with reading the first 16k off all files from
>> nfs, and fortunately the effect is the same.
>>
>> After a hang/recovery, no userspace is accessing the nfs right now,
>> but tcpdump shows repeating requests/replies (attached). Meanwhile
>> the rpc debug also emits logs.
>>
>> # uname -a
>> Linux k-desktop 4.1.0-2-amd64 #1 SMP Debian 4.1.6-1 (2015-08-23)
>> x86_64 GNU/Linux
>> # mount | grep nfs
>> 10.0.0.2:/home/kh on /remote/kh type nfs (rw,relatime,vers=3,rsize=1024,wsize=1024,namlen=255,hard,nolock,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=10.0.0.2,mountvers=3,mountport=644,mountproto=udp,local_lock=all,addr=10.0.0.2)
>
> rsize=1024,wsize=1024,proto=udp is unusual and not normally what we'd
> recommend.  Is there a reason for not sticking with defaults there?
>
> But I don't have any explanation for the hang.
>
> --b.
>
>> Any suggestions?
>>
>> Kojedzinszky Richard
>> Euronet Magyarorszag Informatika Zrt.
>
>
>> Oct 28 12:02:18 k-desktop kernel: [12237.516020] RPC: 54539 xprt_prepare_transmit
>> Oct 28 12:02:18 k-desktop kernel: [12237.516022] RPC: 54539 xprt_cwnd_limited cong = 0 cwnd = 256
>> Oct 28 12:02:18 k-desktop kernel: [12237.516027] RPC: 54539 xprt_transmit(120)
>> Oct 28 12:02:18 k-desktop kernel: [12237.516054] RPC: 54539 xmit complete
>> Oct 28 12:02:22 k-desktop kernel: [12241.932011] RPC: 54539 xprt_timer
>> Oct 28 12:02:22 k-desktop kernel: [12241.932016] RPC:       cong 256, cwnd was 256, now 256
>> Oct 28 12:02:22 k-desktop kernel: [12241.932020] RPC: 54539 xprt_prepare_transmit
>> Oct 28 12:02:22 k-desktop kernel: [12241.932022] RPC: 54539 xprt_cwnd_limited cong = 0 cwnd = 256
>> Oct 28 12:02:22 k-desktop kernel: [12241.932027] RPC: 54539 xprt_transmit(120)
>> Oct 28 12:02:22 k-desktop kernel: [12241.932054] RPC: 54539 xmit complete
>> Oct 28 12:02:31 k-desktop kernel: [12250.748013] RPC: 54539 xprt_timer
>> Oct 28 12:02:31 k-desktop kernel: [12250.748018] RPC:       cong 256, cwnd was 256, now 256
>> Oct 28 12:02:31 k-desktop kernel: [12250.748023] RPC: 54539 xprt_prepare_transmit
>> Oct 28 12:02:31 k-desktop kernel: [12250.748025] RPC: 54539 xprt_cwnd_limited cong = 0 cwnd = 256
>> Oct 28 12:02:31 k-desktop kernel: [12250.748029] RPC: 54539 xprt_transmit(120)
>> Oct 28 12:02:31 k-desktop kernel: [12250.748058] RPC: 54539 xmit complete
>> Oct 28 12:02:32 k-desktop kernel: [12251.852014] RPC: 54539 xprt_timer
>> Oct 28 12:02:32 k-desktop kernel: [12251.852018] RPC:       cong 256, cwnd was 256, now 256
>> Oct 28 12:02:32 k-desktop kernel: [12251.852021] RPC: 54539 xprt_prepare_transmit
>> Oct 28 12:02:32 k-desktop kernel: [12251.852023] RPC: 54539 xprt_cwnd_limited cong = 0 cwnd = 256
>> Oct 28 12:02:32 k-desktop kernel: [12251.852027] RPC: 54539 xprt_transmit(120)
>> Oct 28 12:02:32 k-desktop kernel: [12251.852048] RPC: 54539 xmit complete
>> Oct 28 12:02:35 k-desktop kernel: [12254.060011] RPC: 54539 xprt_timer
>> Oct 28 12:02:35 k-desktop kernel: [12254.060015] RPC:       cong 256, cwnd was 256, now 256
>> Oct 28 12:02:35 k-desktop kernel: [12254.060018] RPC: 54539 xprt_prepare_transmit
>> Oct 28 12:02:35 k-desktop kernel: [12254.060020] RPC: 54539 xprt_cwnd_limited cong = 0 cwnd = 256
>> Oct 28 12:02:35 k-desktop kernel: [12254.060023] RPC: 54539 xprt_transmit(120)
>> Oct 28 12:02:35 k-desktop kernel: [12254.060041] RPC: 54539 xmit complete
>> Oct 28 12:02:39 k-desktop kernel: [12258.476012] RPC: 54539 xprt_timer
>> Oct 28 12:02:39 k-desktop kernel: [12258.476016] RPC:       cong 256, cwnd was 256, now 256
>> Oct 28 12:02:39 k-desktop kernel: [12258.476020] RPC: 54539 xprt_prepare_transmit
>> Oct 28 12:02:39 k-desktop kernel: [12258.476022] RPC: 54539 xprt_cwnd_limited cong = 0 cwnd = 256
>> Oct 28 12:02:39 k-desktop kernel: [12258.476027] RPC: 54539 xprt_transmit(120)
>> Oct 28 12:02:39 k-desktop kernel: [12258.476052] RPC: 54539 xmit complete
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
