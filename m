Return-Path: linux-nfs-owner@vger.kernel.org
Received: from li9-11.members.linode.com ([67.18.176.11]:45429 "EHLO
	test.thunk.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756767Ab2EPBgs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 May 2012 21:36:48 -0400
Date: Tue, 15 May 2012 21:36:42 -0400
From: "Ted Ts'o" <tytso@mit.edu>
To: Josef Bacik <josef@redhat.com>
Cc: linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org,
        bfields@fieldses.org, adilger@dilger.ca, jack@suse.cz
Subject: Re: [PATCH] ext4: fix how i_version is modified and turn it on by
 default V2
Message-ID: <20120516013642.GB7360@thunk.org>
References: <1337092396-3272-1-git-send-email-josef@redhat.com>
 <20120515175308.GB1907@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120515175308.GB1907@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 15, 2012 at 01:53:08PM -0400, Josef Bacik wrote:
> 
> Ok did some basic benchmarking with dd, I ran
> 
> dd if=/dev/zero of=/mnt/btrfs-test/file bs=1 count=10485760
> dd if=/dev/zero of=/mnt/btrfs-test/file bs=1M count=1000
> dd if=/dev/zero of=/mnt/btrfs-test/file bs=1M count=5000
> 
> 3 times with the patch and without the patch.  With the worst case
> scenario there is about a 40% longer run time, going from on average
> 12 seconds to 17 seconds.  With the other two runs they are the same
> runtime with the 1 megabyte blocks.  So the question is, do we care
> about this worst case since any sane application developer isn't
> going to do writes that small?  

Even if there's no runtime change, it's also useful to measure the CPU
utilization.  If there's an increase in CPU utilization, then it can
show up in workloads and benchmarks which are sensitive to CPU
utilization as well as disk utilization, e.g., TPC-C/H.

But since it takes so long for performance teams to notice, they tend
to get very cranky when they observe regressions.  So for changes like
this it's really important to measure any changes in CPU utilization,
especially on larger on SMP systems when there multiple processes
writing to the same file at high rates --- you know, like what an
Enterprise database might do to a table space file.  :-)

    		   	   		     	   - Ted
