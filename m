Return-Path: linux-nfs-owner@vger.kernel.org
Received: from DMZ-MAILSEC-SCANNER-7.MIT.EDU ([18.7.68.36]:57683 "EHLO
	dmz-mailsec-scanner-7.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752646Ab1JMND0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Oct 2011 09:03:26 -0400
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/2] VFS: New /proc file /proc/self/mountstats
References: <20050317162613.756101BB98@citi.umich.edu>
From: stark@MIT.EDU
Date: 13 Oct 2011 08:58:20 -0400
Message-ID: <ycqsjmx9hg3.fsf@multics.mit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Chuck Lever <cel <at> citi.umich.edu> writes:

> Create a new file under /proc/self, called mountstats, where mounted file
> systems can export information (configuration options, performance counters,
> and so on). Use a mechanism similar to /proc/mounts and s_ops->show_options.

I'm using this file to dump data into our performance metrics database along
with all the other counters from snmp and other sources. This lets us
calculate things like the average number of requests pending, average latency
per request over time.

But I have a few questions about the meaning of the values and they don't seem
to be documented outside the comments in the source. 

In particular is it an invariant that execution = rtt + queue? Or is execution
including some additional overhead other than the server and network
congestion? Or is there something more subtle going on and these values aren't
related in the way I'm imagining at all?

And where can I read about the meaning of bad_xids, req_u, and bklog_u? What
do they mean?

Also, connect_time, idle_time, req_u, and bklog_u are instantaneous samples
("guages" so to speak), not integrated over time right? So they can't be used
to calculate any aggregates?
