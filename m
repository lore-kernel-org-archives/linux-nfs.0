Return-Path: <nfsv4-bounces@ietf.org>
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
In-Reply-To: <1294254263.3574.24.camel@heimdal.trondhjem.org>
References: <978693366.32.1292516428080.JavaMail.root@thunderbeast.private.linuxbox.com>
	<1740153586.34.1292516481789.JavaMail.root@thunderbeast.private.linuxbox.com>
	<20101216230707.GB16760@infradead.org> <4D21DB53.9050104@panasas.com>
	<1294065611.16812.8.camel@heimdal.trondhjem.org>
	<4D24C004.7050202@panasas.com>
	<1294254263.3574.24.camel@heimdal.trondhjem.org>
Date: Wed, 05 Jan 2011 14:14:34 -0500
Message-ID: <1294254874.3574.32.camel@heimdal.trondhjem.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        nfsv4@ietf.org
Subject: Re: [nfsv4] layoutcommits and file layout
List-Unsubscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www.ietf.org/mail-archive/web/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@ietf.org
Errors-To: nfsv4-bounces@ietf.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2011-01-05 at 14:04 -0500, Trond Myklebust wrote: 
> On Wed, 2011-01-05 at 21:01 +0200, Benny Halevy wrote: 
> > On 2011-01-03 16:40, Trond Myklebust wrote:
> > > On Mon, 2011-01-03 at 16:21 +0200, Benny Halevy wrote: 
> > >> On 2010-12-17 01:07, Christoph Hellwig wrote:
> > >>> On Thu, Dec 16, 2010 at 11:21:21AM -0500, Matt W. Benjamin wrote:
> > >>>> Hi,
> > >>>>
> > >>>> We have a files implementation which wants to receive LAYOUTCOMMIT when a client is finished with a layout.  It was my clear understanding from rfc5661 that we could expect this behavior.
> > >>>
> > >>> Care to post it to the list?
> > >>>
> > >>
> > >> I don't know what Matt's server is doing but the fundamental problem is
> > >> manifested with extending a file with parallel DS writes.
> > >> Assuming that the DS writes are executed in arbitrary order,
> > >> exposing the file length before LAYOUTCOMMIT can cause
> > >> a concurrent reader to read a hole.  Although locking can
> > >> solve this case, day-to-day applications that work well over
> > >> local filesystem and legacy NFS may break because of this.
> > > 
> > > ...and this differs from ordinary NFS writes exactly how?
> > > 
> > > Both cached and uncached (i.e. O_DIRECT) writes can and will be flushed
> > > to disk in entirely random order when writing to the MDS. If you have a
> > > parallel reader on another client (or even on the same client in the
> > > case of O_DIRECT), and want it to see accurate data, then use locking.
> > > If not, you will see holes and other strangeness.
> > > 
> > > IOW: There are no 'day-to-day applications that work well over legacy
> > > NFS' that rely on this behaviour.
> > > 
> > 
> > Assuming the client writes sequentially (over tcp) the writes will
> > practically be processed in order into the server's cache so with
> > no crashes in the mix a parallel reader will see no holes.
> > I'd really like the following scenario to work over pNFS with
> > no hassles:
> > 	"some app >> foo" on one client, and
> > 	"tail -f foo" on another
> 
> No, that doesn't work today! Believe me, I get the "bug reports"...
> 
> There is no point in trying to add properties to pNFS that don't exist
> with ordinary NFS.

...and for the record: use of TCP does _not_ suffice to ensure writes
are processed in order.

In the Linux kernel, we have all sorts of parallelism going on before
the writes even hit the socket on the client. Everything from background
flushing to queuing in the sunrpc layer (e.g. for a session slot)
conspires to destroy any hope of ever achieving what you propose above.

That's not even counting what goes on with the server side. Think, for
instance, of the case where the server crashes before a COMMIT has been
successfully sent. Not only will your reader see holes, it will think
the file has been truncated...

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www.ietf.org/mailman/listinfo/nfsv4
