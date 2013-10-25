Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:27642 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718Ab3JYOcK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Oct 2013 10:32:10 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH 0/3] mountd: disabling turning off TCP listeners (v2)
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1382638633-6710-1-git-send-email-steved@redhat.com>
Date: Fri, 25 Oct 2013 10:31:58 -0400
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <69D0FF67-35DE-4BB6-BB95-08D3E3E55845@oracle.com>
References: <1382638633-6710-1-git-send-email-steved@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 24, 2013, at 2:17 PM, Steve Dickson <SteveD@redhat.com> wrote:

> [ Here is the second try for these patches incorporating the code review..]
> 
> Recently it was pointed out to me that the [-n | --no-tcp] flags 
> were broken in mountd. Sure enough they are and they broke 
> when nfs-utils moved to using libtirpc, which was years ago.
> 
> Obviously nobody is using these flags since has not been 
> notice until now,

Agreed, we have clear evidence of that.  Removing the "no TCP" flag makes sense.

> but it seemed to me it no longer makes 
> any sense to have flags. We really want people to use TCP 
> so why should there be a way to turn it off? It should be
> the opposite... They should be able to turn off UDP listeners
> not TCP...

If noone is using --no-tcp now, what makes you believe that anyone would want to use --no-udp?

And, why do we want to force people to use TCP for MNT?  That's going to be a disaster for clients that perform a large number of mounts at once -- I think we even have bugs describing this scenario -- it will suck up the reserved port space on clients faster than you can say "Jack Robinson."

Let's wait for a concrete user request for such a feature.


> Steve Dickson (3):
>  mountd: Use protocol bit fields to turn protocols off.
>  mountd: Deprecate the ability to disable TCP listeners.
>  mountd: Add the ability to disable UDP listeners.
> 
> support/include/rpcmisc.h |  2 +-
> support/nfs/rpcmisc.c     | 19 ++++++++++++++-----
> support/nfs/svc_create.c  |  5 +++++
> utils/mountd/mountd.c     | 17 ++++++++++++-----
> utils/mountd/mountd.man   |  6 +++---
> 5 files changed, 35 insertions(+), 14 deletions(-)
> 
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




