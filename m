Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:63141 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751470Ab1AEX0m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jan 2011 18:26:42 -0500
Subject: Re: Cache flush question.
From: Daniel Stodden <daniel.stodden@citrix.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Rob Landley <rlandley@parallels.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <1294151542.3389.7.camel@heimdal.trondhjem.org>
References: <1294130649.3529.96.camel@ramone>
	 <1294151542.3389.7.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 5 Jan 2011 15:15:47 -0800
Message-ID: <1294269347.29719.1673.camel@agari.van.xensource.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-01-04 at 09:32 -0500, Trond Myklebust wrote:
> On Tue, 2011-01-04 at 00:44 -0800, Daniel Stodden wrote: 
> > Hi anyone.
> > 
> > If somebody's got a sec to enlighten me, there's some phenomenon I
> > recently came across and found somewhat counterintuitive first.
> > 
> > Whenever I
> > 
> >  1. Dirty a bunch of pages backed by an NFS mount on some server.
> > 
> >  2. Block the traffic with iptables (TCP, assuming that mattered).
> >     Still plenty of writeback pending.
> > 
> >  3. Sync
> > 
> > I see #3 drive the dirty count in /proc/meminfo drop back to
> > almost-zero, immediately. The sync itself blocks, though.
> > 
> > So the pages are called clean the moment the write got queued, not
> > acked? Leaving the rest just to retransmits by the socket then? Is this
> > just done so because one can, or would that order rather matter for
> > consistency?
> 
> Take a look at the 'Writeback:' count, which should turn non-zero when
> you hit #3.
> 
> The VM allows pages to be either dirty or in writeback, but not both at
> the same time. This is not NFS-specific. The same rule applies to local
> filesystems.

Ah. That explains everything. Actually a question then, thanks for the
clarification :)

Rob Landley's comment regarding tx queue size somewhat made a good point
too. But, given the rates I see, this queues mostly cache pages on the
transport, not copies, right?

Thanks.

Daniel

