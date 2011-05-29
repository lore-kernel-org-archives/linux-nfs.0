Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63235 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751049Ab1E2QFT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 12:05:19 -0400
Subject: Re: infinite getdents64 loop
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: =?ISO-8859-1?Q?R=FCdiger?= Meier <sweet_f_a@gmx.de>
Cc: linux-nfs@vger.kernel.org
Date: Sun, 29 May 2011 12:05:17 -0400
In-Reply-To: <201105281700.30726.sweet_f_a@gmx.de>
References: <201105281502.32719.sweet_f_a@gmx.de>
	 <201105281700.30726.sweet_f_a@gmx.de>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1306685117.2386.7.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 2011-05-28 at 17:00 +0200, Rüdiger Meier wrote: 
> On Saturday 28 May 2011, Rüdiger Meier wrote:
> > I could track down the problem to:
> >
> > commit 0b26a0bf6ff398185546432420bb772bcfdf8d94
> > Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> > Date:   Sat Nov 20 14:26:44 2010 -0500
> >
> >     NFS: Ensure we return the dirent->d_type when it is known
> >
> >
> > After reverting the problem is gone.
> 
> Actually it's enough to remove d_type from struct nfs_cache_array_entry 
> again. It's not enough to set it DT_UNKNOWN always. I had to remove it 
> from struct to let it work.
> Tested with kernels 2.6.37.6 and 2.6.39.

Sorry, but that patch makes absolutely no sense whatsoever as a fix for
the problem you describe. All you are doing is changing the size of the
readdir cache entry, which is probably causing a READDIR with a
duplicate cookie to trigger. When running with the stock 2.6.39 client,
do you see the "directory contains a readdir loop." message in your
syslog?

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

