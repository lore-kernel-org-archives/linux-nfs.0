From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Make sm-notify faster if there are no servers to notify
Date: Fri, 5 Dec 2008 21:42:41 -0500
Message-ID: <20081206024241.GB5464@fieldses.org>
References: <5AB39614-D03F-43DF-BCD2-2B2501A79D65@oracle.com> <20081029211145.GE1406@fieldses.org> <49183A12.7010707@RedHat.com> <20081204211057.GC9593@fieldses.org> <18744.41310.635618.148281@notabene.brown> <20081205035803.GC15115@fieldses.org> <49392C14.7000709@RedHat.com> <20081205163824.GA29227@fieldses.org> <20081205172913.GB29227@fieldses.org> <6763B58B-6C3B-40FA-84F4-737E93D429A6@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>, Neil Brown <neilb@suse.de>,
	Phil Endecott <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56014 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753862AbYLFCmy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Dec 2008 21:42:54 -0500
In-Reply-To: <6763B58B-6C3B-40FA-84F4-737E93D429A6@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 05, 2008 at 01:41:32PM -0500, Chuck Lever wrote:
> On Dec 5, 2008, at 12:29 PM, J. Bruce Fields wrote:
>> How about adding an explicit fsync() of the state file (and parent
>> directory) to statd's first succesful creation of a statd record,
>> together with a comment explaining this?  So around about line 194 in
>> utils/statd/monitor.c:sm_mon_1_svc()?
>>
>> In fact, we could delete the sync entirely and do the same before the
>> first notification, and then we wouldn't have to wait for the sync in
>> the case host records are present either....  (statd would, but  
>> perhaps
>> we could still get other work done in the mean time).
>>
>> (Am I missing something?)
>
> This all might work, but I think we're adding a lot of complexity as a  
> workaround.

I think you mean the justification is too subtle--the code itself (just
a couple syncs or fsyncs) is pretty simple.

> Someone should fix the real problem, which is the  
> implementation of sync().

I think you mean of fsync().  My understanding of past discussions on
the issue is that it's not really fixable on ext3, at least.  So
default setups will have this problem for a while.

--b.

> That would probably have other benefits too.
