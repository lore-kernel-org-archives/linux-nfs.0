Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f169.google.com ([209.85.161.169]:56121 "EHLO
	mail-gg0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752794Ab3CFSpc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Mar 2013 13:45:32 -0500
Date: Wed, 6 Mar 2013 10:45:26 -0800
From: Tejun Heo <tj@kernel.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Oleg Nesterov <oleg@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Mandeep Singh Baines <msb@chromium.org>,
        Ming Lei <ming.lei@canonical.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>, Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Message-ID: <20130306184526.GL1227@htj.dyndns.org>
References: <20130304205307.GA13527@redhat.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9286AEEB0@sacexcmbx05-prd.hq.netapp.com>
 <20130305082308.6607d4db@tlielax.poochiereds.net>
 <20130305174648.GF12795@htj.dyndns.org>
 <20130305174954.GG12795@htj.dyndns.org>
 <20130305140312.243cb094@tlielax.poochiereds.net>
 <20130305190923.GI12795@htj.dyndns.org>
 <20130305183941.19ff39ce@tlielax.poochiereds.net>
 <20130306181735.GB18687@redhat.com>
 <20130306134004.16252a21@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130306134004.16252a21@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Wed, Mar 06, 2013 at 01:40:04PM -0500, Jeff Layton wrote:
> Though when I said that, it was before Tejun mentioned hooking this up
> to ptrace. I'll confess that I don't fully understand what he's
> proposing either though...

Oh, they're all just pretty closely related.  All signal and ptrace
traps run off get_signal_to_deliver().  It is still a bit hairy but in
much better shape after cleanups which accompanied PTRACE_SEIZE and I
don't really think it'll be too difficult to extend it so that
freezing is implemented as a type of jobctl trap.

Thanks.

-- 
tejun
