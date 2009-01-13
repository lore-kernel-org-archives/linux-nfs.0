From: Peter Staubach <staubach@redhat.com>
Subject: Re: [patch 2/3] knfsd: avoid overloading the CPU scheduler with enormous
 load averages
Date: Tue, 13 Jan 2009 09:33:00 -0500
Message-ID: <496CA61C.5050208@redhat.com>
References: <20090113102633.719563000@sgi.com> <20090113102653.664553000@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS ML <linux-nfs@vger.kernel.org>
To: Greg Banks <gnb@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:44621 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755141AbZAMOdG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Jan 2009 09:33:06 -0500
In-Reply-To: <20090113102653.664553000@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Greg Banks wrote:
> Avoid overloading the CPU scheduler with enormous load averages
> when handling high call-rate NFS loads.  When the knfsd bottom half
> is made aware of an incoming call by the socket layer, it tries to
> choose an nfsd thread and wake it up.  As long as there are idle
> threads, one will be woken up.
>
> If there are lot of nfsd threads (a sensible configuration when
> the server is disk-bound or is running an HSM), there will be many
> more nfsd threads than CPUs to run them.  Under a high call-rate
> low service-time workload, the result is that almost every nfsd is
> runnable, but only a handful are actually able to run.  This situation
> causes two significant problems:
>
> 1. The CPU scheduler takes over 10% of each CPU, which is robbing
>    the nfsd threads of valuable CPU time.
>
> 2. At a high enough load, the nfsd threads starve userspace threads
>    of CPU time, to the point where daemons like portmap and rpc.mountd
>    do not schedule for tens of seconds at a time.  Clients attempting
>    to mount an NFS filesystem timeout at the very first step (opening
>    a TCP connection to portmap) because portmap cannot wake up from
>    select() and call accept() in time.
>
> Disclaimer: these effects were observed on a SLES9 kernel, modern
> kernels' schedulers may behave more gracefully.
>
> The solution is simple: keep in each svc_pool a counter of the number
> of threads which have been woken but have not yet run, and do not wake
> any more if that count reaches an arbitrary small threshold.
>
> Testing was on a 4 CPU 4 NIC Altix using 4 IRIX clients, each with 16
> synthetic client threads simulating an rsync (i.e. recursive directory
> listing) workload reading from an i386 RH9 install image (161480
> regular files in 10841 directories) on the server.  That tree is small
> enough to fill in the server's RAM so no disk traffic was involved.
> This setup gives a sustained call rate in excess of 60000 calls/sec
> before being CPU-bound on the server.  The server was running 128 nfsds.
>
> Profiling showed schedule() taking 6.7% of every CPU, and __wake_up()
> taking 5.2%.  This patch drops those contributions to 3.0% and 2.2%.
> Load average was over 120 before the patch, and 20.9 after.
>
> This patch is a forward-ported version of knfsd-avoid-nfsd-overload
> which has been shipping in the SGI "Enhanced NFS" product since 2006.
> It has been posted before:
>
> http://article.gmane.org/gmane.linux.nfs/10374
>
> Signed-off-by: Greg Banks <gnb@sgi.com>
> ---

Have you measured the impact of these changes for something
like SpecSFS?

    Thanx...

       ps
