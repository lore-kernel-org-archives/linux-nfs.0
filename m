Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:39940 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752351AbZHLNXY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Aug 2009 09:23:24 -0400
From: Jeff Moyer <jmoyer@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        nfsv4@linux-nfs.org
Subject: Re: [PATCH 0/3] Fix the Linux rpc-over-tcp server performance
References: <20090518214756.786.28129.stgit@heimdal.trondhjem.org>
	<20090812024341.GA3227@fieldses.org>
Date: Wed, 12 Aug 2009 09:22:17 -0400
In-Reply-To: <20090812024341.GA3227@fieldses.org> (J. Bruce Fields's message
	of "Tue, 11 Aug 2009 22:43:41 -0400")
Message-ID: <x49ab25w4ja.fsf@segfault.boston.devel.redhat.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

"J. Bruce Fields" <bfields@fieldses.org> writes:

> On Mon, May 18, 2009 at 05:47:56PM -0400, Trond Myklebust wrote:
>> I squashed the previous set of 4 incremental patches into 3. Otherwise
>> there should be no differences w.r.t. the set that Jeff tested.
>
> Apologies for the long delay.... Unfortunately, I can't reproduce any of
> this at all: I reliably get about 112MB/s regardless of what combination
> of these patches I apply (including none).  This is over gigabit
> ethernet to a server exporting a filesystem on raid 0 over 3 sata disks
> which iozone locally reports getting just over 200MB/s reads from.
>
> Any suggestions?

Well, you gave me nothing to go on here, Bruce!  I assume you're using
the deadline I/O scheduler on the NFS server, is that right?  If not,
you should be.  Second, are you using iozone to reproduce?

  iozone -s 2000000 -r 64 -f /mnt/test/testfile -i 1 -w

That's the command line I was using.  Third, I reproduced this on
2.6.30-rc1.  Perhaps you should start there and make sure you at least
see the same problem on that kernel.  Otherwise, maybe we've made up for
the performance elsewhere.

Finally, didn't you revert the autotuning patch?  If so, you wouldn't
see this problem.  Let me know how this goes, and if you still can't
reproduce it I'll setup for testing it here.

Cheers,
Jeff
