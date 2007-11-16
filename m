From: Neil Brown <neilb@suse.de>
Subject: Re: uuid/blkid performance problem with large number
	of	mounts - was: Re: stale nfs file handle with exported
	loopback mounts
Date: Fri, 16 Nov 2007 12:10:25 +1100
Message-ID: <18236.60929.411884.287787@notabene.brown>
References: <2087477778@web.de>
	<1195157549.8905.30.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, devzero@web.de, NFS@lists.sourceforge.net,
	Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
In-Reply-To: message from Trond Myklebust on Thursday November 15
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thursday November 15, trond.myklebust@fys.uio.no wrote:
> 
> On Thu, 2007-11-15 at 21:07 +0100, devzero@web.de wrote:
> > > Is it possible to turn this feature off on sourceforge? I
> > 
> > yes - iirc, i have seen projects without  a tracker or without other
> > option, being on by default.
> > 
> > if you want to disable it, maybe this one helps:
> > 
> > https://sourceforge.net/docs/G03/en/#tracker
> 
> That would have to be up to Neil since he is the only one with
> administrator rights on that list.

Actually there are several people with admin rights, some of which I
haven't heard from for ages.
  Chip Salzenberg
  H.J. Lu
  Jay Weber
  Marc Merlin
  Neil Brown
  steved

Anyway, I have made the 4 trackers (bugs, patches, support requests,
feature requests) visible to group members only.  I suspect it would
be good for someone to go through at least the more recent ones.
There is one with patches for man page typos, one with a patch to use
netlink instead of ioctl to get list of local interfaces, one
reporting that nfsstat doesn't match the man page (--mounts or
--mounted)  etc.

If anyone would like to dig through it and post the things that still
seem relevant, I'd be happy to make you a member of the group (if you
aren't already).

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
