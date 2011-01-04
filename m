Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6016 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751104Ab1ADOcj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Jan 2011 09:32:39 -0500
Subject: Re: Cache flush question.
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Daniel Stodden <daniel.stodden@citrix.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <1294130649.3529.96.camel@ramone>
References: <1294130649.3529.96.camel@ramone>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 04 Jan 2011 09:32:22 -0500
Message-ID: <1294151542.3389.7.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-01-04 at 00:44 -0800, Daniel Stodden wrote: 
> Hi anyone.
> 
> If somebody's got a sec to enlighten me, there's some phenomenon I
> recently came across and found somewhat counterintuitive first.
> 
> Whenever I
> 
>  1. Dirty a bunch of pages backed by an NFS mount on some server.
> 
>  2. Block the traffic with iptables (TCP, assuming that mattered).
>     Still plenty of writeback pending.
> 
>  3. Sync
> 
> I see #3 drive the dirty count in /proc/meminfo drop back to
> almost-zero, immediately. The sync itself blocks, though.
> 
> So the pages are called clean the moment the write got queued, not
> acked? Leaving the rest just to retransmits by the socket then? Is this
> just done so because one can, or would that order rather matter for
> consistency?

Take a look at the 'Writeback:' count, which should turn non-zero when
you hit #3.

The VM allows pages to be either dirty or in writeback, but not both at
the same time. This is not NFS-specific. The same rule applies to local
filesystems.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

