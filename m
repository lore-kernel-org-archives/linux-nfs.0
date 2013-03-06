Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f51.google.com ([209.85.219.51]:34473 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087Ab3CFA7B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Mar 2013 19:59:01 -0500
Received: by mail-oa0-f51.google.com with SMTP id h2so11946705oag.10
        for <linux-nfs@vger.kernel.org>; Tue, 05 Mar 2013 16:59:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130305231110.GK15816@fieldses.org>
References: <CACVXFVMKN6aeCvJcn7dyuonJYJDfYxWeW5KE6gfKRKJKFj2M4A@mail.gmail.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA9286AD113@sacexcmbx05-prd.hq.netapp.com>
	<20130304092310.1d21100c@tlielax.poochiereds.net>
	<CACBanvrc0orXGZ1v+gKHtVPKWYKGEFx46dwoDCjTU78+nPtZyg@mail.gmail.com>
	<20130304205307.GA13527@redhat.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA9286AEEB0@sacexcmbx05-prd.hq.netapp.com>
	<20130305082308.6607d4db@tlielax.poochiereds.net>
	<20130305174648.GF12795@htj.dyndns.org>
	<20130305174954.GG12795@htj.dyndns.org>
	<20130305231110.GK15816@fieldses.org>
Date: Tue, 5 Mar 2013 16:59:00 -0800
Message-ID: <CACBanvo+JDCFVRQeTQwnwRRxr8bdqxdsgeEr8fqgJhGQJEEQ-Q@mail.gmail.com>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
From: Mandeep Singh Baines <msb@chromium.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Tejun Heo <tj@kernel.org>, Jeff Layton <jlayton@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Oleg Nesterov <oleg@redhat.com>, Ming Lei <ming.lei@canonical.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 5, 2013 at 3:11 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Tue, Mar 05, 2013 at 09:49:54AM -0800, Tejun Heo wrote:
>> On Tue, Mar 05, 2013 at 09:46:48AM -0800, Tejun Heo wrote:
>> > So, I think this is why implementing freezer as a separate blocking
>> > mechanism isn't such a good idea.  We're effectively introducing a
>> > completely new waiting state to a lot of unsuspecting paths which
>> > generates a lot of risks and eventually extra complexity to work
>> > around those.  I think we really should update freezer to re-use the
>> > blocking points we already have - the ones used for signal delivery
>> > and ptracing.  That way, other code paths don't have to worry about an
>> > extra stop state and we can confine most complexities to freezer
>> > proper.
>>
>> Also, consolidating those wait states means that we can solve the
>> event-to-response latency problem for all three cases - signal, ptrace
>> and freezer, rather than adding separate backing-out strategy for
>> freezer.
>
> Meanwhile, as none of this sounds likely to be done this time
> around--are we backing out the new lockdep warnings?
>
> --b.

What if we hide it behind a Kconfig? Its finding real bugs.

http://lkml.org/lkml/2013/3/5/583
