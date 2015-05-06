Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:57960 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751225AbbEFQsU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 May 2015 12:48:20 -0400
Date: Wed, 6 May 2015 10:48:17 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Devesh Sharma <devesh.sharma@avagotech.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 02/14] xprtrdma: Warn when there are orphaned IB
 objects
Message-ID: <20150506164817.GC11331@obsidianresearch.com>
References: <20150504174626.3483.97639.stgit@manet.1015granger.net>
 <20150504175700.3483.57728.stgit@manet.1015granger.net>
 <CANjDDBicLDb7K=RZB5Gqv+oACaAG8DANJX3ML971jnXd_5KEuQ@mail.gmail.com>
 <963F9850-38D0-4434-88E8-14BC42F74499@oracle.com>
 <CANjDDBg3Ey0DEM3n9PY9VLW+chF0=AJPghYOopo1a9vL3CKzKg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CANjDDBg3Ey0DEM3n9PY9VLW+chF0=AJPghYOopo1a9vL3CKzKg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 06, 2015 at 07:52:03PM +0530, Devesh Sharma wrote:
> >> Should we check for EBUSY explicitly? other then this is an error in
> >> vendor specific ib_dealloc_pd()
> >
> > Any error return means ib_dealloc_pd() has failed, right? Doesn’t that
> > mean the PD is still allocated, and could cause problems later?
> 
> Yes, you are correct, I was thinking ib_dealloc_pd() has a refcount
> implemented in the core layer, thus if the PD is used by any resource,
> it will always fail with -EBUSY.

.. and it will not be freed, which indicates a serious bug in the
caller, so the caller should respond to the failure with a BUG_ON or
WARN_ON.

> .With emulex adapter it is possible to fail dealloc_pd with ENOMEM or
> EIO in cases where device f/w is not responding etc. this situation do
> not represent PD is actually in use.

This is a really bad idea. If the pd was freed and from the consumer's
perspective everything is sane then it should return success.

If the driver detects an internal failure, then it should move the
driver to a failed state (whatever that means, but at a minimum it
means the firmware state and driver state must be resync'd), and still
succeed the dealloc.

There is absolutely nothing the caller can do about a driver level
failure here, and it doesn't indicate a caller bug.

Returning ENOMEM for dealloc is what we'd call an insane API. You
can't have failable memory allocations in a dealloc path.

Jason
