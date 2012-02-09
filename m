Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51091 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757646Ab2BID4X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 22:56:23 -0500
Message-ID: <1328759776.8981.75.camel@serendib>
Subject: Re: NFS Mount Option 'nofsc'
From: Harshula <harshula@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Derek McEachern <derekm@ti.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Thu, 09 Feb 2012 14:56:16 +1100
In-Reply-To: <386479B9-C285-44C9-896B-A254091272FD@oracle.com>
References: <4F31E1CA.8060105@ti.com>
	 <1328676860.2954.9.camel@lade.trondhjem.org>
	 <1328687026.8981.25.camel@serendib>
	 <386479B9-C285-44C9-896B-A254091272FD@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

On Wed, 2012-02-08 at 10:40 -0500, Chuck Lever wrote:
> On Feb 8, 2012, at 2:43 AM, Harshula wrote:

> > Could you please expand on the subtleties involved that require an
> > application to be rewritten if forcedirectio mount option was available?
> > 
> > A scenario where forcedirectio would be useful is when an application
> > reads nearly a TB of data from local disks, processes that data and then
> > dumps it to an NFS mount. All that happens while other processes are
> > reading/writing to the local disks. The application does not have an
> > O_DIRECT option nor is the source code available.
> > 
> > With paged I/O the problem we see is that the NFS client system reaches
> > dirty_bytes/dirty_ratio threshold and then blocks/forces all the
> > processes to flush dirty pages. This effectively 'locks' up the NFS
> > client system while the NFS dirty pages are pushed slowly over the wire
> > to the NFS server. Some of the processes that have nothing to do with
> > writing to the NFS mount are badly impacted. A forcedirectio mount
> > option would be very helpful in this scenario. Do you have any advice on
> > alleviating such problems on the NFS client by only using existing
> > tunables?
> 
> Using direct I/O would be a work-around.  The fundamental problem is
> the architecture of the VM system, and over time we have been making
> improvements there.
> 
> Instead of a mount option, you can fix your application to use direct
> I/O.  Or you can change it to provide the kernel with (better) hints
> about the disposition of the data it is generating (madvise and
> fadvise system calls).  (On Linux we assume you have source code and
> can make such changes.  I realize this is not true for proprietary
> applications).
> 
> You could try using the "sync" mount option to cause the NFS client to
> push writes to the server immediately rather than delaying them.  This
> would also slow down applications that aggressively dirties pages on
> the client.
> 
> Meanwhile, you can dial down the dirty_ratio and especially the
> dirty_background_ratio settings to trigger earlier writeback.  We've
> also found increasing min_free_bytes has positive effects.  The exact
> settings depend on how much memory your client has.  Experimenting
> yourself is pretty harmless, so I won't give exact settings here.

Thanks for the reply. Unfortunately, not all vendors provide the source
code, so using O_DIRECT or fsync is not always an option. 

Lowering dirty_bytes/dirty_ratio and
dirty_background_bytes/dirty_background_ratio did help as it smoothed
out the data transfer over the wire by pushing data out to the NFS
server sooner. Otherwise, I was seeing the data transfer over the wire
having idle periods while >10GiB of pages were being dirtied by the
processes, then congestion as soon as the dirty_ratio was reached and
the frantic flushing of dirty pages to the NFS server. However,
modifying dirty_* tunables has a system-wide impact, hence it was not
accepted.

The "sync" option, depending on the NFS server, may impact the NFS
server's performance when serving many NFS clients. But still worth a
try.

The other hack that seems to work is periodically triggering an
nfs_getattr(), via ls -l, to force the dirty pages to be flushed to the
NFS server. Not exactly elegant ...

Thanks,
#

