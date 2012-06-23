Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga01.intel.com ([192.55.52.88]:38726 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754571Ab2FWPHT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 23 Jun 2012 11:07:19 -0400
Date: Sat, 23 Jun 2012 23:07:14 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Linux-NFS <linux-nfs@vger.kernel.org>
Cc: Andi Kleen <ak@linux.intel.com>
Subject: Re: rpcauth_lookup_credcache() lock contentions
Message-ID: <20120623150714.GA12845@localhost>
References: <20120623122604.GA10887@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120623122604.GA10887@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jun 23, 2012 at 08:26:04PM +0800, Fengguang Wu wrote:
> Hi,
> 
> When doing parallel kernel builds on an NFSROOT system with 32 logical
> CPUs, I see half CPU time spent in kernel:
> 
> top - 20:08:28 up  5:01,  8 users,  load average: 62.97, 55.82, 54.56
> Tasks: 751 total,  80 running, 671 sleeping,   0 stopped,   0 zombie
> Cpu(s):  0.1%us, 53.5%sy, 46.4%ni,  0.0%id,  0.0%wa,  0.0%hi,  0.1%si,  0.0%st
> Mem:  65401132k total, 36455604k used, 28945528k free,        0k buffers
> Swap:        0k total,        0k used,        0k free, 31858244k cached
> 
> The attached lock_stat shows that rpcauth_lookup_credcache() has the
> outstanding contentions.

Aha, I got some progress: 20% kernel time can be saved when increasing
the hash bits from 4 to 10 with sunrpc.auth_hashtable_size=10:

Cpu(s):  0.0%us, 38.3%sy, 61.6%ni,  0.0%id,  0.0%wa,  0.0%hi,  0.1%si,  0.0%st

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                              class name    con-bounces    contentions   waittime-min   waittime-max waittime-total    acq-bounces   acquisitions   holdtime-min   holdtime-max holdtime-total
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

               &(&dentry->d_lock)->rlock:     268601736      276206929           0.07       26627.70   496747630.48     2001328443     5557869248           0.06       37208.89  1755583747.41
               -------------------------
               &(&dentry->d_lock)->rlock       24861581          [<ffffffff8116de34>] unlazy_walk+0x8a/0x1bb
               &(&dentry->d_lock)->rlock      148863110          [<ffffffff81177f50>] dput+0x46/0x17c
               &(&dentry->d_lock)->rlock       13725203          [<ffffffff81178c3c>] __d_lookup+0xa2/0x19d
               &(&dentry->d_lock)->rlock       46173902          [<ffffffff811770a9>] dget_parent+0x63/0xd5
               -------------------------
               &(&dentry->d_lock)->rlock       86386730          [<ffffffff811770a9>] dget_parent+0x63/0xd5
               &(&dentry->d_lock)->rlock       20746860          [<ffffffff8116dd9a>] path_get+0x2c/0x3c
               &(&dentry->d_lock)->rlock       12672320          [<ffffffff81178c3c>] __d_lookup+0xa2/0x19d
               &(&dentry->d_lock)->rlock       32752994          [<ffffffff8116de34>] unlazy_walk+0x8a/0x1bb

...............................................................................................................................................................................................

                    &(&new->lock)->rlock:     230350869      230621514           0.08        6929.01   361504869.99      965086516     1052051247           0.07        5783.47   369851400.65
                    --------------------
                    &(&new->lock)->rlock      230621514          [<ffffffff81d026c0>] rpcauth_lookup_credcache+0xa7/0x244
                    --------------------
                    &(&new->lock)->rlock      230621514          [<ffffffff81d026c0>] rpcauth_lookup_credcache+0xa7/0x244

Thanks,
Fengguang
