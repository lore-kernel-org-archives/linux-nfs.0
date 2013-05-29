Return-Path: linux-nfs-owner@vger.kernel.org
Received: from one.firstfloor.org ([193.170.194.197]:36562 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753745Ab3E2QOG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 May 2013 12:14:06 -0400
Date: Wed, 29 May 2013 18:13:58 +0200
From: Andi Kleen <andi@firstfloor.org>
To: Waiman Long <waiman.long@hp.com>
Cc: Dave Chinner <david@fromorbit.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Jeff Layton <jlayton@redhat.com>, Miklos Szeredi <mszeredi@suse.cz>,
        Ian Kent <raven@themaw.net>, Sage Weil <sage@inktank.com>,
        Steve French <sfrench@samba.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Eric Paris <eparis@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, autofs@vger.kernel.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, "Chandramouleeswaran, Aswin" <aswin@hp.com>,
        "Norton, Scott J" <scott.norton@hp.com>,
        Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/3 v3] dcache: make it more scalable on large system
Message-ID: <20130529161358.GJ6123@two.firstfloor.org>
References: <1369273048-60256-1-git-send-email-Waiman.Long@hp.com>
 <20130523094201.GA24543@dastard>
 <519E8B5F.3080905@hp.com>
 <20130527020903.GR29466@dastard>
 <51A624E2.3000301@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <51A624E2.3000301@hp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> The d_path() is called by perf_event_mmap_event() which translates
> VMA to its file path for memory segments backed by files. As perf is
> not just for sampling data within the kernel, it can also be used
> for checking access pattern in the user space. As a result, it needs
> to map VMAs back to the backing files to access their symbols
> information. If d_path() is not the right function to call for this
> purpose, what other alternatives do we have?

In principle it should be only called for new file mappings
getting maped.  Do you really have that many new file mappings all
the time? Or is this related to program startup?

> 
> My patch set consists of 2 different changes. The first one is to
> avoid taking the d_lock lock when updating the reference count in
> the dentries. This particular change also benefit some other
> workloads that are filesystem intensive. One particular example is
> the short workload in the AIM7 benchmark. One of the job type in the
> short workload is "misc_rtns_1" which calls security functions like
> getpwnam(), getpwuid(), getgrgid() a couple of times. These
> functions open the /etc/passwd or /etc/group files, read their
> content and close the files. It is the intensive open/read/close
> sequence from multiple threads that is causing 80%+ contention in
> the d_lock on a system with large number of cores. The MIT's
> MOSBench paper also outlined dentry reference counting as a

The paper was before Nick Piggin's RCU (and our) work on this.
Modern kernels do not have dcache problems with mosbench, unless
you run weird security modules like SMACK that effectively 
disable dcache RCU.

BTW lock elision may fix these problems anyways, in a much
simpler way.

-Andi

ak@linux.intel.com -- Speaking for myself only.
