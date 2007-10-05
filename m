From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] What's slated for inclusion in 2.6.24-rc1 from the NFS
	client git tree...
Date: Fri, 05 Oct 2007 13:52:30 -0400
Message-ID: <1191606750.6715.98.camel@heimdal.trondhjem.org>
References: <1191454876.6726.32.camel@heimdal.trondhjem.org>
	<20071004085206.0a8e37b5@poseidon.drzeus.cx>
	<1191506450.6685.17.camel@heimdal.trondhjem.org>
	<30494.1191605410@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net, Pierre Ossman <drzeus-list@drzeus.cx>,
	Andrew Morton <akpm@linux-foundation.org>
To: Valdis.Kletnieks@vt.edu
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <30494.1191605410@turing-police.cc.vt.edu>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, 2007-10-05 at 13:30 -0400, Valdis.Kletnieks@vt.edu wrote:
> On Thu, 04 Oct 2007 10:00:50 EDT, Trond Myklebust said:
> 
> > How about a boot/module parameter to turn it on or off?
> > 
> > I don't see any point in having a sysctl for something like this: either
> > you have legacy applications or you don't. It is not something that you
> > switch off as you go off to lunch.
> 
> How does Joe Sysadmin tell if he has an affected legacy app or not?
> 
> (The obvious "try it and see what breaks" is a non-starter for many places,
> because you too easily end up in a loop of "enable it, find 4-5 show stoppers,
> turn it off, fix them, lather rinse repease".  Been there, done that, got
> the tshirt - a project I got dragged into involves a large storage array that
> appears to insist on exporting 64-bit stuff, and a large farm of clients that
> are very 64-bit unclean....)

If you're unsure, then set the bloody boot parameter. That's what it is
for...

Trond
