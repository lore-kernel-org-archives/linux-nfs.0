Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:61918 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966328Ab2EQULS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 May 2012 16:11:18 -0400
Date: Thu, 17 May 2012 16:11:14 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] statd: drop all capabilities from the bounding set
 as well
Message-ID: <20120517161114.5cebfa68@tlielax.poochiereds.net>
In-Reply-To: <73BC4C93-9192-4FE7-B32E-58345EB28AAD@oracle.com>
References: <1337277259-5101-1-git-send-email-jlayton@redhat.com>
	<73BC4C93-9192-4FE7-B32E-58345EB28AAD@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 17 May 2012 14:52:58 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On May 17, 2012, at 1:54 PM, Jeff Layton wrote:
> 
> > statd drops all capabilities except for CAP_NET_BIND when it starts. It's
> > possible though that if it ever had a compromise that an attacker would be
> > able to invoke a setuid process (or something with file capabilities) in
> > order to reinstate some caps.
> > 
> > This could happen as a result of the daemon becoming compromised, or
> > possibly as a result of the ha-callout program becoming compromised.
> 
> Generally, I wonder what our exposure to this attack for a statd built without capability support.  Just musing out loud.
> 

It is difficult to qualify this without a specific attack in mind. The
story I've always gotten from those who work with capabilities for a
living however is that unless you prune the bounding set, the job isn't
complete.

Given the right circumstances, a process could reacquire capabilities
via exec'ing a (possibly compromised) setuid program or one with file
caps.

Since we've taken a step to trim out capabilities that we do not deem
necessary for normal statd functioning, you can consider this to be
trimming that list even further. This patch effectively says that statd
should never be able to reacquire caps that it has dropped under any
circumstances.

> > In order to prevent that, have statd also prune the capability bounding
> > set to nothing prior to dropping capabilities. That ensures that the
> > process won't be able to reacquire capabilities via any means --
> > including exec'ing a setuid program.
> > 
> > We do however need to be cognizant of the fact that PR_CAPBSET_DROP was
> > only added in 2.6.25, so check to make sure that #define exists via
> > autoconf before we rely on it. In order to do that, we must add
> > ax_check_define.m4 from the GNU autoconf macro archive.
> 
> On pre-2.6.25 kernels, the bounding set is a fixed system-wide setting.  What we decided is to forego a run-time check here in favor of a build-time check.  Would it be difficult to do both?
> 

So you're suggesting that we should do something like see
if /proc/sys/kernel/cap-bound exists at runtime and only try to drop
the capabilities if doesn't? I suppose that's a reasonable thing to
do. I'll plan to respin it with that.

It occurs to me here too that this may fail incorrectly if the kernel
is built w/o capabilities support period. So I probably need to do
another respin anyway and either not attempt to prune the bounding set
unless statd is built with caps support, or handle an EINVAL return
here as if the kernel were not built with it.

The latter is probably the safest method...

Thanks for the review,
-- 
Jeff Layton <jlayton@redhat.com>
