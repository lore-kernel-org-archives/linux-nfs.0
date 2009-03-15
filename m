From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch 3/3] knfsd: add file to export stats about nfsd pools
Date: Sun, 15 Mar 2009 17:25:34 -0400
Message-ID: <20090315212534.GC27568@fieldses.org>
References: <20090113102633.719563000@sgi.com> <20090113102653.884405000@sgi.com> <20090212171106.GB21445@fieldses.org> <499CFF69.3000708@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>,
	Harshula Jayasuriya <harshula@sgi.com>
To: Greg Banks <gnb@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:48842 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752303AbZCOVZf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Mar 2009 17:25:35 -0400
In-Reply-To: <499CFF69.3000708@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 19, 2009 at 05:42:49PM +1100, Greg Banks wrote:
> J. Bruce Fields wrote:
> > On Tue, Jan 13, 2009 at 09:26:36PM +1100, Greg Banks wrote:
> >   
> >> Add /proc/fs/nfsd/pool_stats to export to userspace various
> >> statistics about the operation of rpc server thread pools.
> >>     
> >
> > Could you explainw hy these specific statistics (total packets,
> > sockets_queued, threads_woken, overloads_avoided, threads_timedout) are
> > the important ones to capture?  Could you give examples of what sort of
> > problems could be solved using them?
> >   
> Actually I originally added these stats to help debug the
> overload-avoiding patch.  Then I thought to use them to drive a
> userspace control loop for controlling the number of nfsds, which I
> never finished writing.
> > As you said, an important question for the sysadmin is "should I
> > configure more nfsds?"  How do they answer that?
> >   
> You can work that out, but it's not obvious, i.e. not human-friendly.  
> Firstly, you need to rate convert all the stats.
> 
> The total_packets stat tells you how many NFS packets are arriving on
> each thread pool.  This is your primary load metric, i.e. with more load
> you want more nfsd threads.
> 
> The sockets_queued stat tells you that calls are arriving which are not
> being immediately serviced by threads, i.e. you're either thread-limited
> or CPU-limited rather than network-limited and you might get better
> throughput if there were more nfsd threads.
> 
> Conversely the overloads_avoided stat tells you if there are more
> threads than can usefully be made runnable on the available CPUs, so
> that adding more nfsd threads is unlikely to be helpful.
> 
> The threads_timedout stat will give you a first-level approximation of
> whether there are threads that are completely idle, i.e. don't see any
> calls for the svc_recv() timeout (which I reduced to IIRC 10 sec as part
> of the original version of this patch).  This is a clue that you can now
> reduce the number of threads.

OK, thanks, that makes sense, but: it would be really fantastic if we
could update and/or replace some of the howto's and faq's that are out
there.  The above would be useful, as would be some of the material from
your nfs-tuning presentation.

Queued up this and the old-stats removal for 2.6.30.

--b.
