Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12253 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752841Ab1E2REE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 13:04:04 -0400
Subject: Re: infinite getdents64 loop
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: =?ISO-8859-1?Q?R=FCdiger?= Meier <sweet_f_a@gmx.de>
Cc: linux-nfs@vger.kernel.org
Date: Sun, 29 May 2011 13:04:03 -0400
In-Reply-To: <201105291855.04487.sweet_f_a@gmx.de>
References: <201105281502.32719.sweet_f_a@gmx.de>
	 <201105281700.30726.sweet_f_a@gmx.de>
	 <1306685117.2386.7.camel@lade.trondhjem.org>
	 <201105291855.04487.sweet_f_a@gmx.de>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1306688643.2386.24.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 2011-05-29 at 18:55 +0200, Rüdiger Meier wrote: 
> On Sunday 29 May 2011, Trond Myklebust wrote:
> 
> > Sorry, but that patch makes absolutely no sense whatsoever as a fix
> > for the problem you describe.
> 
> It wasn't ment to be a real fix. I just tried to find out where the prob 
> is roughly located. 
> 
> > All you are doing is changing the size 
> > of the readdir cache entry, which is probably causing a READDIR with
> > a duplicate cookie to trigger.
> 
> Yup, my patch "repaired" the test directory and let another one fail. 
> Currently Ive reverted
> commit d1bacf9e, NFS: add readdir cache array
> (and a lot followups) to let clients work again.
> 
> > When running with the stock 2.6.39 
> > client, do you see the "directory contains a readdir loop." message
> > in your syslog?
> 
> Yes, didn't noticed that because I've booted 2.6.39 only a few times.
> There are a lot like this:
> May 25 13:26:09 kubera-114 kernel: [ 1105.419604] NFS: directory 
> gen/radar contains a readdir loop.  Please contact your server vendor.  
> Offending cookie: 947700512
> 
> I hope it's not my server vendor's fault :)
> Or does this mean the NFS server is bad rather than the client?

It's actually a problem with the underlying filesystem: it is generating
readdir 'offsets' that are not unique. In other words, if you use
telldir() to list out the offsets for each readdir entry on the server,
you will see the same value 947700512 above appear at least two times,
which means that 'seekdir()' is also broken, for instance.

IOW: This isn't something that we can fix on the NFS client. It needs to
be fixed on the server. The only thing that has hidden the problem
previously is blind luck (which is why your patch appeared to work).

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

