Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:53843 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753220AbZBSGqD (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Thu, 19 Feb 2009 01:46:03 -0500
Message-ID: <499CFF69.3000708@sgi.com>
Date: Thu, 19 Feb 2009 17:42:49 +1100
From: Greg Banks <gnb@sgi.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS ML <linux-nfs@vger.kernel.org>,
        Harshula Jayasuriya <harshula@sgi.com>
Subject: Re: [patch 3/3] knfsd: add file to export stats about nfsd pools
References: <20090113102633.719563000@sgi.com> <20090113102653.884405000@sgi.com> <20090212171106.GB21445@fieldses.org>
In-Reply-To: <20090212171106.GB21445@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

J. Bruce Fields wrote:
> On Tue, Jan 13, 2009 at 09:26:36PM +1100, Greg Banks wrote:
>   
>> Add /proc/fs/nfsd/pool_stats to export to userspace various
>> statistics about the operation of rpc server thread pools.
>>     
>
> Could you explainw hy these specific statistics (total packets,
> sockets_queued, threads_woken, overloads_avoided, threads_timedout) are
> the important ones to capture?  Could you give examples of what sort of
> problems could be solved using them?
>   
Actually I originally added these stats to help debug the
overload-avoiding patch.  Then I thought to use them to drive a
userspace control loop for controlling the number of nfsds, which I
never finished writing.
> As you said, an important question for the sysadmin is "should I
> configure more nfsds?"  How do they answer that?
>   
You can work that out, but it's not obvious, i.e. not human-friendly.  
Firstly, you need to rate convert all the stats.

The total_packets stat tells you how many NFS packets are arriving on
each thread pool.  This is your primary load metric, i.e. with more load
you want more nfsd threads.

The sockets_queued stat tells you that calls are arriving which are not
being immediately serviced by threads, i.e. you're either thread-limited
or CPU-limited rather than network-limited and you might get better
throughput if there were more nfsd threads.

Conversely the overloads_avoided stat tells you if there are more
threads than can usefully be made runnable on the available CPUs, so
that adding more nfsd threads is unlikely to be helpful.

The threads_timedout stat will give you a first-level approximation of
whether there are threads that are completely idle, i.e. don't see any
calls for the svc_recv() timeout (which I reduced to IIRC 10 sec as part
of the original version of this patch).  This is a clue that you can now
reduce the number of threads.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

