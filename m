Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33786 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751915Ab3HFNeL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Aug 2013 09:34:11 -0400
Date: Tue, 6 Aug 2013 09:34:07 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Larry Keegan <lk@pfw.demon.co.uk>, linux-nfs@vger.kernel.org
Subject: Re: nfs client: Now you see it, now you don't (aka spurious ESTALE
 errors)
Message-ID: <20130806133407.GB5282@fieldses.org>
References: <20130725134515.67af44e2@cs3.al.itld>
 <20130725101143.6a22cb81@corrin.poochiereds.net>
 <20130725170526.6e54c7db@cs3.al.itld>
 <20130726145937.GB30651@fieldses.org>
 <20130726232111.2567a941@cs3.al.itld>
 <20130806110209.56e554a7@cs3.al.itld>
 <20130806071428.5d68052a@corrin.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130806071428.5d68052a@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 06, 2013 at 07:14:28AM -0400, Jeff Layton wrote:
> On Tue, 6 Aug 2013 11:02:09 +0000
> Larry Keegan <lk@pfw.demon.co.uk> wrote:
> > These figures seem reasonable for a single SATA HDD in concert
> > with dmcrypt. Whilst I expected some degradation from exporting and
> > mounting sync, I have to say that I'm truly flabbergasted by the
> > difference between the sync and async figures. I can't help but
> > think I am still suffering from some sort of configuration
> > problem. Do the numbers from the NFS client seem unreasonable?
> > 
> 
> That's expected. Performance is the tradeoff for tight cache coherency.
> 
> With -o sync, each write() sycall requires a round trip to the server.
> They don't get batched and you can't issue them in parallel. That has a
> terrible effect on write performance.

Note also mounting -osync and exporting with the "sync" export option
are entirely different things.

The defaults are what you want (async mount option, sync export option)
unless you've thought hard about it.  This is especially true on the
server, since the "async" export option make it skip committing data to
disk even when the protocol mandates it.

--b.
