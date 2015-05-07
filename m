Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:36639 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751622AbbEGHxQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 May 2015 03:53:16 -0400
Received: by lagv1 with SMTP id v1so24597715lag.3
        for <linux-nfs@vger.kernel.org>; Thu, 07 May 2015 00:53:14 -0700 (PDT)
From: Devesh Sharma <devesh.sharma@avagotech.com>
References: <20150504174626.3483.97639.stgit@manet.1015granger.net>
 <20150504175700.3483.57728.stgit@manet.1015granger.net> <CANjDDBicLDb7K=RZB5Gqv+oACaAG8DANJX3ML971jnXd_5KEuQ@mail.gmail.com>
 <963F9850-38D0-4434-88E8-14BC42F74499@oracle.com> <CANjDDBg3Ey0DEM3n9PY9VLW+chF0=AJPghYOopo1a9vL3CKzKg@mail.gmail.com>
 <20150506164817.GC11331@obsidianresearch.com>
In-Reply-To: <20150506164817.GC11331@obsidianresearch.com>
MIME-Version: 1.0
Date: Thu, 7 May 2015 13:23:13 +0530
Message-ID: <a943c57dfa28c91f418a07a2904ef852@mail.gmail.com>
Subject: RE: [PATCH v1 02/14] xprtrdma: Warn when there are orphaned IB objects
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Jason Gunthorpe [mailto:jgunthorpe@obsidianresearch.com]
> Sent: Wednesday, May 06, 2015 10:18 PM
> To: Devesh Sharma
> Cc: Chuck Lever; linux-rdma@vger.kernel.org; Linux NFS Mailing List
> Subject: Re: [PATCH v1 02/14] xprtrdma: Warn when there are orphaned IB
> objects
>
> On Wed, May 06, 2015 at 07:52:03PM +0530, Devesh Sharma wrote:
> > >> Should we check for EBUSY explicitly? other then this is an error
> > >> in vendor specific ib_dealloc_pd()
> > >
> > > Any error return means ib_dealloc_pd() has failed, right? Doesn’t
> > > that mean the PD is still allocated, and could cause problems later?
> >
> > Yes, you are correct, I was thinking ib_dealloc_pd() has a refcount
> > implemented in the core layer, thus if the PD is used by any resource,
> > it will always fail with -EBUSY.
>
> .. and it will not be freed, which indicates a serious bug in the caller,
> so the
> caller should respond to the failure with a BUG_ON or WARN_ON.

Yes, that’s what this patch is doing.

>
> > .With emulex adapter it is possible to fail dealloc_pd with ENOMEM or
> > EIO in cases where device f/w is not responding etc. this situation do
> > not represent PD is actually in use.
>
> This is a really bad idea. If the pd was freed and from the consumer's
> perspective everything is sane then it should return success.
>
> If the driver detects an internal failure, then it should move the driver
> to a
> failed state (whatever that means, but at a minimum it means the firmware
> state and driver state must be resync'd), and still succeed the dealloc.

Makes sense.

>
> There is absolutely nothing the caller can do about a driver level failure
> here,
> and it doesn't indicate a caller bug.
>
> Returning ENOMEM for dealloc is what we'd call an insane API. You can't
> have
> failable memory allocations in a dealloc path.

I will supply a fix in ocrdma.

Reviewed-by: Devesh Sharma <devesh.sharma@avagotech.com>
>
> Jason
