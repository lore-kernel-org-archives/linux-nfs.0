From: Jeff Layton <jlayton@redhat.com>
Subject: Re: list corruption in locks_start_grace with 2.6.28-rc3
Date: Sat, 22 Nov 2008 20:00:15 -0500
Message-ID: <20081122200015.4007ed53@tleilax.poochiereds.net>
References: <x498wrokjj8.fsf@segfault.boston.devel.redhat.com>
	<20081120203735.GB30808@fieldses.org>
	<x49ej15gktp.fsf@segfault.boston.devel.redhat.com>
	<20081122005400.GB28094@fieldses.org>
	<20081122092237.1ab81cdb@tleilax.poochiereds.net>
	<49287005.5050009@opengridcomputing.com>
	<49289B2D.1090404@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Jeff Moyer <jmoyer@redhat.com>, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35911 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753942AbYKWBAW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Nov 2008 20:00:22 -0500
In-Reply-To: <49289B2D.1090404@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 22 Nov 2008 17:52:13 -0600
Tom Tucker <tom@opengridcomputing.com> wrote:

> Jeff M/L:
> 
> Could you guys confirm that this patch fixes the problem? I was 
> able to reproduce Jeff Layton's problem and this patch resolved
> the under-reference condition for me.
> 
> Thanks,
> 

Thanks Tom,
Confirmed. That patch does seem to resolve the refcount imbalance
when restarting nfsd.

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
