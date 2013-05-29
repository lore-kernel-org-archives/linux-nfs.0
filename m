Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40601 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965259Ab3E2QSf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 May 2013 12:18:35 -0400
Subject: Re: [PATCH 0/3 v3] dcache: make it more scalable on large system
From: Simo Sorce <simo@redhat.com>
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
In-Reply-To: <51A624E2.3000301@hp.com>
References: <1369273048-60256-1-git-send-email-Waiman.Long@hp.com>
	 <20130523094201.GA24543@dastard> <519E8B5F.3080905@hp.com>
	 <20130527020903.GR29466@dastard>  <51A624E2.3000301@hp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 29 May 2013 12:18:09 -0400
Message-ID: <1369844289.2769.146.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-05-29 at 11:55 -0400, Waiman Long wrote:

> My patch set consists of 2 different changes. The first one is to avoid 
> taking the d_lock lock when updating the reference count in the 
> dentries. This particular change also benefit some other workloads that 
> are filesystem intensive. One particular example is the short workload 
> in the AIM7 benchmark. One of the job type in the short workload is 
> "misc_rtns_1" which calls security functions like getpwnam(), 
> getpwuid(), getgrgid() a couple of times. These functions open the 
> /etc/passwd or /etc/group files, read their content and close the files. 
> It is the intensive open/read/close sequence from multiple threads that 
> is causing 80%+ contention in the d_lock on a system with large number 
> of cores.

To be honest a workload base on /etc/passwd or /etc/group is completely
artificial, in actual usage, if you really have  such access you use
nscd or sssd with their shared memory caches to completely remove most
of the file access.
I have no beef on the rest but repeated access to Nsswitch information
is not something you need to optimize at the file system layer and
should not be brought up as a point in favor.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

