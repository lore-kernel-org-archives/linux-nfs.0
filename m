Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59019 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751145Ab1G2OvN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jul 2011 10:51:13 -0400
Date: Fri, 29 Jul 2011 10:51:11 -0400
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Gregory Magoon <gmagoon@MIT.EDU>, linux-nfs@vger.kernel.org
Subject: Re: NFSv4 vs NFSv3 with MPICH2-1.4
Message-ID: <20110729145111.GG23194@fieldses.org>
References: <20110728152306.219iz5wpkcokoo4c@webmail.mit.edu>
 <1311886684.27285.8.camel@lade.trondhjem.org>
 <20110728172449.8wxxte4jg0s8kcgs@webmail.mit.edu>
 <1311889677.27285.14.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1311889677.27285.14.camel@lade.trondhjem.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 28, 2011 at 05:47:57PM -0400, Trond Myklebust wrote:
> On Thu, 2011-07-28 at 17:24 -0400, Gregory Magoon wrote: 
> > Thanks for the tips...unfortunately, making the changes you suggest (removing
> > timeo, rsize, wsize options) doesn't seem to address the issue with MPICH2 and
> > NFSv4.
> 
> Have you turned off delegations on the server? I wouldn't expect them to
> help much on an MPI workload.

Note, you can do that with "echo 0 >/proc/sys/fs/leases-enable before
starting nfsd.

> Otherwise, you might want to post a comparison of your results from
> 'nfsstat' for your workload on NFSv3 and NFSv4.

Yes.

Taking a sample of the network traffic once it gets stuck might also be
interesting.

(Wait for it to get stuck, the run "tcpdump -s0 -wtmp.pcap", let it go
for a second (longer if that doesn't get anything), then interrupt it
and send us tmp.pcap.)

Or if it gets stuck immediately, then you could start the tcpdump before
the you start your tests and capture everything.  But if it doesn't get
stuck immediately that could be a ton of data.

--b.
