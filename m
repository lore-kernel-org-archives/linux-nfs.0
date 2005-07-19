From: Ian Kent <raven@themaw.net>
Subject: Re: [NFS] making the 'addr=' mount option an address hint
Date: Tue, 19 Jul 2005 20:22:26 +0800 (WST)
Message-ID: <Pine.LNX.4.63.0507192018270.2061@donald.themaw.net>
References: <1121614708.6713.41.camel@localhost.localdomain>
	<1121700961.8780.13.camel@lade.trondhjem.org>
	<1121711065.23863.31.camel@barsoom.rdu.redhat.com>
	<1121711870.8707.5.camel@lade.trondhjem.org>
	<20050718195432.GC24783@suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: autofs@linux.kernel.org, nfs@lists.sourceforge.net,
        Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <autofs-bounces@linux.kernel.org>
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050718195432.GC24783@suse.de>
List-Unsubscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://hera.kernel.org/pipermail/autofs>
List-Post: <mailto:autofs@linux.kernel.org>
List-Help: <mailto:autofs-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=subscribe>
Sender: autofs-bounces@linux.kernel.org
Errors-To: autofs-bounces@linux.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Mon, 18 Jul 2005, Olaf Kirch wrote:

> On Mon, Jul 18, 2005 at 02:37:50PM -0400, Trond Myklebust wrote:
> > I would not at all support doing this sort of thing in autofs. If it is
> > to be done, it should be done by the mount program.
> 
> That would make mount awfully slow, and we're suffering from excessive
> boot times already. Besides, mount can see just the current state,
> a daemon would be able to collect statistics over a period of time and
> average it.

That's an interesting thought.

I've already given some thought to maintaining persistent connections to 
servers to help with this in autofs. Once again I haven't been able to do 
anything about it yet.

Ian
