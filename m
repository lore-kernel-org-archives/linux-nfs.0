Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48059 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751154Ab3DRTMf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Apr 2013 15:12:35 -0400
Date: Thu, 18 Apr 2013 15:12:34 -0400
To: "Stoltenberg, Matthew" <matthew.stoltenberg@tekcomms.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: sunrpc problem on large machine
Message-ID: <20130418191234.GB31075@fieldses.org>
References: <ECF9200F7F201C4CB1319E966C6B7AA716176519@US-PLNO-EXM01-P.global.tektronix.net>
 <ECF9200F7F201C4CB1319E966C6B7AA716178904@US-PLNO-EXM01-P.global.tektronix.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <ECF9200F7F201C4CB1319E966C6B7AA716178904@US-PLNO-EXM01-P.global.tektronix.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 18, 2013 at 03:40:05PM +0000, Stoltenberg, Matthew wrote:
> > Looking at some of the kernel code, I found that auth_domain_find in
> > fs/nfsd/export.c around line 514 is returning NULL.
> 
> I added code some printks to auth_domain_lookup() in net/sunrpc/svcauth.c to printk every time loop of hlist_for_each_entry and it's not printing anything so it doesn't look like the write to /proc/net/rpc/auth.unix.ip/channel by exportfs is having any effect.  My off the wall guess is that it's related to NUMA somehow, but I have no way to validate this idea.  Besides, I feel like many other things would be broken if NUMA wasn't working correctly.
> 
> > I'm at a complete loss because this exact setup (same kernel exactly, same
> > exports, everything) is working on a separate machine.  The only difference is
> > the underlying hardware.  My kernel config is attached.
> 
> Is there anything else I can add?  Only thing I can think of that I left out is that this is an ext3 filesystem.

Huh, that is weird.  Your strace basically shows "-test-client-"
succesfully added to the audh_domain table and then the immediately
following call not finding it there any more.

All I can think is that perhaps the expiry (read and caclculated by the
get_expiry() call in net/sunrpc/svcauth_unix.c:ip_map_parse()) is bogus,
resulting in ip_map_parse()'s final cache_flush immediately evicting the
new entry.

And I guess a boot-time related problem could be hardware dependent
somehow.

--b.
