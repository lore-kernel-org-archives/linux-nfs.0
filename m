Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37903 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752720AbbHESYB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Aug 2015 14:24:01 -0400
Date: Wed, 5 Aug 2015 14:24:00 -0400
To: jhopper@Safe-mail.net
Cc: linux-nfs@vger.kernel.org
Subject: Re: extremely slow v4 performance on gigabit link
Message-ID: <20150805182400.GA18809@fieldses.org>
References: <N1B-heRnt8zOCE@Safe-mail.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <N1B-heRnt8zOCE@Safe-mail.net>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 05, 2015 at 07:13:58AM -0400, jhopper@Safe-mail.net wrote:
> I have a very slow (less than 1MB/s) performance with nfsv4 TCP,

How are you measuring this?

> rsize/wsize have no effect, server is a kernel 3.19 x86 100hz no
> preempt exporting async nfsv4 TCP on nfs-utils 1.2.7,

The "async" export option isn't normally recommended, though it's
unlikely to have anything to do with this problem.

> client is a
> kernel 4.1.3 x64 1000hz full preempt with nfs-utils 1.3.2 , physical
> link is 1 gigabit full duplex, I mounted a few cifs shares to check,
> the cifs shares are working at 30 MB/s and higher
> 
> is it possible that preempt has an effect on NFS performance ? does
> timeslice have effect on performance ?

I think those are unlikely to be relevant.

--b.
