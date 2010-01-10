From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC PATCH 0/2] Fix up the NFS mmap code
Date: Sun, 10 Jan 2010 03:00:17 +0100
Message-ID: <20100110020015.GA25323@basil.fritz.box>
References: <1262913974.2659.101.camel@localhost> <20100109005624.7473.33215.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:59097 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754454Ab0AJCAb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Jan 2010 21:00:31 -0500
In-Reply-To: <20100109005624.7473.33215.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 08, 2010 at 07:56:24PM -0500, Trond Myklebust wrote:
> How about something like the following. I chose to wrap the call to
> do_mmap_pgoff() instead of making a special ->pre_mmap(), since that
> seems more consistent with the way we handle ->read() and ->write().

I tested the patch and I don't see the lockdep problem anymore
and seems to work so far on the test system with some quick tests.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
