Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38192 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966398AbbJ1N5m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Oct 2015 09:57:42 -0400
Date: Wed, 28 Oct 2015 09:57:42 -0400
To: krichy@tvnetwork.hu
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfs client hangs / repeating nfs requests
Message-ID: <20151028135742.GC20682@fieldses.org>
References: <alpine.DEB.2.20.1510281158380.24492@krichy.tvnetwork.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.DEB.2.20.1510281158380.24492@krichy.tvnetwork.hu>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 28, 2015 at 12:06:02PM +0100, krichy@tvnetwork.hu wrote:
> Dear all,
> 
> I am again having some trouble with nfs client. Actually I am
> running minidlna over nfs over gre over ipsec configuration, but I
> suppose the latter two should not count.
> 
> Minidlna scans the entire directory, reading all files (or just
> parts), and while doing it, sometimes the process hangs.
> 
> I could emulate this with reading the first 16k off all files from
> nfs, and fortunately the effect is the same.
> 
> After a hang/recovery, no userspace is accessing the nfs right now,
> but tcpdump shows repeating requests/replies (attached). Meanwhile
> the rpc debug also emits logs.
> 
> # uname -a
> Linux k-desktop 4.1.0-2-amd64 #1 SMP Debian 4.1.6-1 (2015-08-23)
> x86_64 GNU/Linux
> # mount | grep nfs
> 10.0.0.2:/home/kh on /remote/kh type nfs (rw,relatime,vers=3,rsize=1024,wsize=1024,namlen=255,hard,nolock,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=10.0.0.2,mountvers=3,mountport=644,mountproto=udp,local_lock=all,addr=10.0.0.2)

rsize=1024,wsize=1024,proto=udp is unusual and not normally what we'd
recommend.  Is there a reason for not sticking with defaults there?

But I don't have any explanation for the hang.

--b.

> Any suggestions?
> 
> Kojedzinszky Richard
> Euronet Magyarorszag Informatika Zrt.


> Oct 28 12:02:18 k-desktop kernel: [12237.516020] RPC: 54539 xprt_prepare_transmit
> Oct 28 12:02:18 k-desktop kernel: [12237.516022] RPC: 54539 xprt_cwnd_limited cong = 0 cwnd = 256
> Oct 28 12:02:18 k-desktop kernel: [12237.516027] RPC: 54539 xprt_transmit(120)
> Oct 28 12:02:18 k-desktop kernel: [12237.516054] RPC: 54539 xmit complete
> Oct 28 12:02:22 k-desktop kernel: [12241.932011] RPC: 54539 xprt_timer
> Oct 28 12:02:22 k-desktop kernel: [12241.932016] RPC:       cong 256, cwnd was 256, now 256
> Oct 28 12:02:22 k-desktop kernel: [12241.932020] RPC: 54539 xprt_prepare_transmit
> Oct 28 12:02:22 k-desktop kernel: [12241.932022] RPC: 54539 xprt_cwnd_limited cong = 0 cwnd = 256
> Oct 28 12:02:22 k-desktop kernel: [12241.932027] RPC: 54539 xprt_transmit(120)
> Oct 28 12:02:22 k-desktop kernel: [12241.932054] RPC: 54539 xmit complete
> Oct 28 12:02:31 k-desktop kernel: [12250.748013] RPC: 54539 xprt_timer
> Oct 28 12:02:31 k-desktop kernel: [12250.748018] RPC:       cong 256, cwnd was 256, now 256
> Oct 28 12:02:31 k-desktop kernel: [12250.748023] RPC: 54539 xprt_prepare_transmit
> Oct 28 12:02:31 k-desktop kernel: [12250.748025] RPC: 54539 xprt_cwnd_limited cong = 0 cwnd = 256
> Oct 28 12:02:31 k-desktop kernel: [12250.748029] RPC: 54539 xprt_transmit(120)
> Oct 28 12:02:31 k-desktop kernel: [12250.748058] RPC: 54539 xmit complete
> Oct 28 12:02:32 k-desktop kernel: [12251.852014] RPC: 54539 xprt_timer
> Oct 28 12:02:32 k-desktop kernel: [12251.852018] RPC:       cong 256, cwnd was 256, now 256
> Oct 28 12:02:32 k-desktop kernel: [12251.852021] RPC: 54539 xprt_prepare_transmit
> Oct 28 12:02:32 k-desktop kernel: [12251.852023] RPC: 54539 xprt_cwnd_limited cong = 0 cwnd = 256
> Oct 28 12:02:32 k-desktop kernel: [12251.852027] RPC: 54539 xprt_transmit(120)
> Oct 28 12:02:32 k-desktop kernel: [12251.852048] RPC: 54539 xmit complete
> Oct 28 12:02:35 k-desktop kernel: [12254.060011] RPC: 54539 xprt_timer
> Oct 28 12:02:35 k-desktop kernel: [12254.060015] RPC:       cong 256, cwnd was 256, now 256
> Oct 28 12:02:35 k-desktop kernel: [12254.060018] RPC: 54539 xprt_prepare_transmit
> Oct 28 12:02:35 k-desktop kernel: [12254.060020] RPC: 54539 xprt_cwnd_limited cong = 0 cwnd = 256
> Oct 28 12:02:35 k-desktop kernel: [12254.060023] RPC: 54539 xprt_transmit(120)
> Oct 28 12:02:35 k-desktop kernel: [12254.060041] RPC: 54539 xmit complete
> Oct 28 12:02:39 k-desktop kernel: [12258.476012] RPC: 54539 xprt_timer
> Oct 28 12:02:39 k-desktop kernel: [12258.476016] RPC:       cong 256, cwnd was 256, now 256
> Oct 28 12:02:39 k-desktop kernel: [12258.476020] RPC: 54539 xprt_prepare_transmit
> Oct 28 12:02:39 k-desktop kernel: [12258.476022] RPC: 54539 xprt_cwnd_limited cong = 0 cwnd = 256
> Oct 28 12:02:39 k-desktop kernel: [12258.476027] RPC: 54539 xprt_transmit(120)
> Oct 28 12:02:39 k-desktop kernel: [12258.476052] RPC: 54539 xmit complete

