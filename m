Return-Path: linux-nfs-owner@vger.kernel.org
Received: from one.firstfloor.org ([193.170.194.197]:36660 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755365Ab3E2Q4F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 May 2013 12:56:05 -0400
Date: Wed, 29 May 2013 18:56:03 +0200
From: Andi Kleen <andi@firstfloor.org>
To: Simo Sorce <simo@redhat.com>
Cc: Waiman Long <waiman.long@hp.com>, Dave Chinner <david@fromorbit.com>,
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
Message-ID: <20130529165603.GL6123@two.firstfloor.org>
References: <1369273048-60256-1-git-send-email-Waiman.Long@hp.com>
 <20130523094201.GA24543@dastard>
 <519E8B5F.3080905@hp.com>
 <20130527020903.GR29466@dastard>
 <51A624E2.3000301@hp.com>
 <1369844289.2769.146.camel@willson.li.ssimo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1369844289.2769.146.camel@willson.li.ssimo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 29, 2013 at 12:18:09PM -0400, Simo Sorce wrote:
> On Wed, 2013-05-29 at 11:55 -0400, Waiman Long wrote:
> 
> > My patch set consists of 2 different changes. The first one is to avoid 
> > taking the d_lock lock when updating the reference count in the 
> > dentries. This particular change also benefit some other workloads that 
> > are filesystem intensive. One particular example is the short workload 
> > in the AIM7 benchmark. One of the job type in the short workload is 
> > "misc_rtns_1" which calls security functions like getpwnam(), 
> > getpwuid(), getgrgid() a couple of times. These functions open the 
> > /etc/passwd or /etc/group files, read their content and close the files. 
> > It is the intensive open/read/close sequence from multiple threads that 
> > is causing 80%+ contention in the d_lock on a system with large number 
> > of cores.
> 
> To be honest a workload base on /etc/passwd or /etc/group is completely
> artificial, in actual usage, if you really have  such access you use
> nscd or sssd with their shared memory caches to completely remove most
> of the file access.

I don't fully agree at this point. A lot of things can be tuned away,
but in practice we want things to perform well out of the box without
needing all kinds of magic tuning that only 

Also this is just normal file access, nothing special about it.
It simply has to scale. For all kinds of workloads.

And it does, just d_path messes it up.

> I have no beef on the rest but repeated access to Nsswitch information
> is not something you need to optimize at the file system layer and
> should not be brought up as a point in favor.

This is about repeated access to arbitrary files.

-Andi
