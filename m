Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19776 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752754Ab1AYXf7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jan 2011 18:35:59 -0500
Subject: Re: Stale file not being refreshed automatically?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Nathan March <nathan@gt.net>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <4D3F5CD0.9010204@gt.net>
References: <4D3F4A8A.7040003@gt.net>
	 <1295994532.6867.12.camel@heimdal.trondhjem.org>  <4D3F5CD0.9010204@gt.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 25 Jan 2011 18:35:58 -0500
Message-ID: <1295998558.6867.28.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-01-25 at 15:29 -0800, Nathan March wrote: 
> On 1/25/2011 2:28 PM, Trond Myklebust wrote:
> > On Tue, 2011-01-25 at 14:
> > Does '-e' in perl only do a lookup, or does it result in a 'stat()'
> > call? If the latter, then your test is flawed: a stat() is a lookup+a
> > getattr, and the latter can definitely return ESTALE when you are
> > constantly replacing the file.
> >
> > Cheers
> >    Trond
> 
> Hi Trond,
> 
> Has any behavior here changed between 2.6.19 and 2.6.32 that you know of?
> 
> Testing that perl one liner out with a variety of nfs setups we run:
> 
> 2.6.11 client vs 2.6.32 server - no error
> 2.6.11 client vs netapp - no error
> 2.6.19 client vs 2.6.19 server - no error
> 2.6.19 client vs netapp - no error
> 2.6.32 client vs 2.6.32 server - stale file handles
> 2.6.32 client vs netapp - stale file handles
> 
> So it seems to be a client specific change sometime between 2.6.19 and 
> 2.6.32....

You are probably seeing an effect due to attribute caching. Newer
kernels have tighter restrictions on when they are allowed to cache.

IOW: I suspect the above is just a timing artefact that would probably
disappear on a slower machine.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

