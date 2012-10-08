Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:12779 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750733Ab2JHLKy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Oct 2012 07:10:54 -0400
Message-ID: <5072B4BC.9050006@RedHat.com>
Date: Mon, 08 Oct 2012 07:10:52 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Quentin Barnes <qbarnes@gmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Long-standing NFSv3 UDP client performance problem, probably
 due to RPC?
References: <CAKjHkpC4yQRHJK1e66dg20t_AL3oy+vu_yue2vKEAxKRvd75gQ@mail.gmail.com>
In-Reply-To: <CAKjHkpC4yQRHJK1e66dg20t_AL3oy+vu_yue2vKEAxKRvd75gQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/10/12 13:57, Quentin Barnes wrote:
> I'm curious to know if anyone has run across a long-standing problem
> we've seen with NFSv3 UDP clients.
> 
> Back under RHEL4 (2.6.9-based), NFSv3 UDP mounts had very good
> performance with our internal testing.  However, any release I've
> tested since then (RHEL5, 2.6.31, RHEL6, 3.3, and 3.6) the results
> have been poor and very chaotic with wild swings in results,
> generally showing around a 25%-30% drop in our internal tests when
> compared to TCP.
> 
> Our performance test suite typically runs 50 processes doing a
> random, mixed client load of read, multi-read, append, and write
> operations to an older Netapp filer sprayed across 23 NFSv3 mounted
> file systems.  We often run with the {r,w}size to 32k (I know, not
> usually recommended for UDP, but usually works well for our network)
> and up the tunable "sunrpc.udp_slot_table_entries" from 16 to either
> 64 or 128.
> 
> In looking at the statistics, one problem that stands out is the number of
> RPC retransmits.  On RHEL4 (and also when using a FreeBSD client),
> the number of RPC retransmits during our testing is around 500/hr.
> With all later Linux kernels, that rate shoots up to 7000-12000/hr.
> That still doesn't seem to be much given the number of packets
> slung, but I think that points towards where the problem might be,
> in the sunrpc network error detection, recovery, and backoff code
> (which is completely avoided with TCP mounts).
> 
> Since for our work, for other reasons, we've switched over to
> using NFSv3 TCP mounts, so I can't justify spending a lot of time
> debugging this UDP/RPC problem.  However, for example if someone
> wants me to try something out and gather some new test results or
> a patch to test, I can squeeze that in.
> 
> Does anyone know if this problem has a history or has already been
> looked at?
I think there probably has been a steady decline in UPD performance
over the years. The main reason is that nobody uses it since TCP is a 
much better transport to use with NFS... Why are you still using
UDP as your transport? 

steved.

