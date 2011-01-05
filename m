From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [nfsv4] layoutcommits and file layout
Date: Wed, 05 Jan 2011 14:04:23 -0500
Message-ID: <1294254263.3574.24.camel@heimdal.trondhjem.org>
References: <978693366.32.1292516428080.JavaMail.root@thunderbeast.private.linuxbox.com>
	 <1740153586.34.1292516481789.JavaMail.root@thunderbeast.private.linuxbox.com>
	 <20101216230707.GB16760@infradead.org>  <4D21DB53.9050104@panasas.com>
	 <1294065611.16812.8.camel@heimdal.trondhjem.org>
	 <4D24C004.7050202@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
	nfsv4@ietf.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22570 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751353Ab1AETEY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jan 2011 14:04:24 -0500
In-Reply-To: <4D24C004.7050202@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2011-01-05 at 21:01 +0200, Benny Halevy wrote: 
> On 2011-01-03 16:40, Trond Myklebust wrote:
> > On Mon, 2011-01-03 at 16:21 +0200, Benny Halevy wrote: 
> >> On 2010-12-17 01:07, Christoph Hellwig wrote:
> >>> On Thu, Dec 16, 2010 at 11:21:21AM -0500, Matt W. Benjamin wrote:
> >>>> Hi,
> >>>>
> >>>> We have a files implementation which wants to receive LAYOUTCOMMIT when a client is finished with a layout.  It was my clear understanding from rfc5661 that we could expect this behavior.
> >>>
> >>> Care to post it to the list?
> >>>
> >>
> >> I don't know what Matt's server is doing but the fundamental problem is
> >> manifested with extending a file with parallel DS writes.
> >> Assuming that the DS writes are executed in arbitrary order,
> >> exposing the file length before LAYOUTCOMMIT can cause
> >> a concurrent reader to read a hole.  Although locking can
> >> solve this case, day-to-day applications that work well over
> >> local filesystem and legacy NFS may break because of this.
> > 
> > ...and this differs from ordinary NFS writes exactly how?
> > 
> > Both cached and uncached (i.e. O_DIRECT) writes can and will be flushed
> > to disk in entirely random order when writing to the MDS. If you have a
> > parallel reader on another client (or even on the same client in the
> > case of O_DIRECT), and want it to see accurate data, then use locking.
> > If not, you will see holes and other strangeness.
> > 
> > IOW: There are no 'day-to-day applications that work well over legacy
> > NFS' that rely on this behaviour.
> > 
> 
> Assuming the client writes sequentially (over tcp) the writes will
> practically be processed in order into the server's cache so with
> no crashes in the mix a parallel reader will see no holes.
> I'd really like the following scenario to work over pNFS with
> no hassles:
> 	"some app >> foo" on one client, and
> 	"tail -f foo" on another

No, that doesn't work today! Believe me, I get the "bug reports"...

There is no point in trying to add properties to pNFS that don't exist
with ordinary NFS.

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

