Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f52.google.com ([209.85.213.52]:46394 "EHLO
	mail-yh0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731Ab3CFBd7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Mar 2013 20:33:59 -0500
Date: Tue, 5 Mar 2013 17:28:00 -0800
From: Tejun Heo <tj@kernel.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>, Oleg Nesterov <oleg@redhat.com>,
        Mandeep Singh Baines <msb@chromium.org>,
        Ming Lei <ming.lei@canonical.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Message-ID: <20130306012800.GH1227@htj.dyndns.org>
References: <20130304092310.1d21100c@tlielax.poochiereds.net>
 <CACBanvrc0orXGZ1v+gKHtVPKWYKGEFx46dwoDCjTU78+nPtZyg@mail.gmail.com>
 <20130304205307.GA13527@redhat.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9286AEEB0@sacexcmbx05-prd.hq.netapp.com>
 <20130305082308.6607d4db@tlielax.poochiereds.net>
 <20130305174648.GF12795@htj.dyndns.org>
 <20130305174954.GG12795@htj.dyndns.org>
 <20130305140312.243cb094@tlielax.poochiereds.net>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9286B1246@sacexcmbx05-prd.hq.netapp.com>
 <20130306011423.GF1227@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130306011423.GF1227@htj.dyndns.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 05, 2013 at 05:14:23PM -0800, Tejun Heo wrote:
> Then, the operation simply isn't freezable while in progress and
> should be on the receiving end of failed-to-freeze error message and
> users who depend on suspend/hibernation working properly should be
> advised away from using nfs.
> 
> It doesn't really changes anything.  The current code is buggy.  We're
> just not enforcing the rules strictly and people aren't hitting the
> bug often enough.

Just one more thing.  Also, not being able to do retries without
side-effect doesn't mean it can't do retries at all.  There are
syscalls which need to do things differently on re-entry (forgot which
one but there are several).  They record the necessary state in the
restart block and resume from where they left off on re-entry.  It
sure is hairy but is doable and we already have supporting
infrastructure.  Not sure whether that would be worthwhile tho.

Thanks.

-- 
tejun
