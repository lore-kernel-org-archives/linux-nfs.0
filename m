Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f181.google.com ([209.85.161.181]:47165 "EHLO
	mail-gg0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751792Ab3CFBO3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Mar 2013 20:14:29 -0500
Date: Tue, 5 Mar 2013 17:14:23 -0800
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
Message-ID: <20130306011423.GF1227@htj.dyndns.org>
References: <4FA345DA4F4AE44899BD2B03EEEC2FA9286AD113@sacexcmbx05-prd.hq.netapp.com>
 <20130304092310.1d21100c@tlielax.poochiereds.net>
 <CACBanvrc0orXGZ1v+gKHtVPKWYKGEFx46dwoDCjTU78+nPtZyg@mail.gmail.com>
 <20130304205307.GA13527@redhat.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9286AEEB0@sacexcmbx05-prd.hq.netapp.com>
 <20130305082308.6607d4db@tlielax.poochiereds.net>
 <20130305174648.GF12795@htj.dyndns.org>
 <20130305174954.GG12795@htj.dyndns.org>
 <20130305140312.243cb094@tlielax.poochiereds.net>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9286B1246@sacexcmbx05-prd.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9286B1246@sacexcmbx05-prd.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Trond.

On Wed, Mar 06, 2013 at 01:10:07AM +0000, Myklebust, Trond wrote:
> Not all RPC calls can just be interrupted and restarted. Something like
> an exclusive file create, unlink, file locking attempt, etc may give
> rise to different results when replayed in the above scenario.
> Interrupting an RPC call is not equivalent to cancelling its effects...

Then, the operation simply isn't freezable while in progress and
should be on the receiving end of failed-to-freeze error message and
users who depend on suspend/hibernation working properly should be
advised away from using nfs.

It doesn't really changes anything.  The current code is buggy.  We're
just not enforcing the rules strictly and people aren't hitting the
bug often enough.

Thanks.

-- 
tejun
