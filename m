Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f49.google.com ([209.85.216.49]:35383 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755179Ab3CERrB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Mar 2013 12:47:01 -0500
Date: Tue, 5 Mar 2013 09:46:48 -0800
From: Tejun Heo <tj@kernel.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Oleg Nesterov <oleg@redhat.com>,
        Mandeep Singh Baines <msb@chromium.org>,
        Ming Lei <ming.lei@canonical.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Message-ID: <20130305174648.GF12795@htj.dyndns.org>
References: <CACVXFVMKN6aeCvJcn7dyuonJYJDfYxWeW5KE6gfKRKJKFj2M4A@mail.gmail.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9286AD113@sacexcmbx05-prd.hq.netapp.com>
 <20130304092310.1d21100c@tlielax.poochiereds.net>
 <CACBanvrc0orXGZ1v+gKHtVPKWYKGEFx46dwoDCjTU78+nPtZyg@mail.gmail.com>
 <20130304205307.GA13527@redhat.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9286AEEB0@sacexcmbx05-prd.hq.netapp.com>
 <20130305082308.6607d4db@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130305082308.6607d4db@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, guys.

On Tue, Mar 05, 2013 at 08:23:08AM -0500, Jeff Layton wrote:
> So, not a deadlock per-se in this case but it does prevent the freezer
> from running to completion. I don't see any way to solve it though w/o
> making all mutexes freezable. Note that I don't think this is really
> limited to NFS either -- a lot of other filesystems will have similar
> problems: CIFS, some FUSE variants, etc...

So, I think this is why implementing freezer as a separate blocking
mechanism isn't such a good idea.  We're effectively introducing a
completely new waiting state to a lot of unsuspecting paths which
generates a lot of risks and eventually extra complexity to work
around those.  I think we really should update freezer to re-use the
blocking points we already have - the ones used for signal delivery
and ptracing.  That way, other code paths don't have to worry about an
extra stop state and we can confine most complexities to freezer
proper.

Thanks.

-- 
tejun
