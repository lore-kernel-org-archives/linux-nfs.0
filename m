From: Neil Brown <neilb@suse.de>
Subject: Re: [Cluster-devel] [PATCH 0/4 Revised] NLM - lock failover
Date: Mon, 30 Apr 2007 09:10:38 +1000
Message-ID: <17973.9710.650004.160243@notabene.brown>
References: <46315EED.9020103@redhat.com>
	<17969.37229.250000.895316@notabene.brown>
	<20070427111513.GA25126@salusa.poochiereds.net>
	<17969.61232.323762.29003@notabene.brown>
	<20070427134248.GB25126@salusa.poochiereds.net>
	<20070427141710.GA11484@infradead.org>
	<20070427154259.GF32278@fieldses.org> <46321870.7000607@redhat.com>
	<20070427163129.GI32278@fieldses.org>
	<17970.30655.854497.849900@notabene.brown>
	<20070429201353.GA23531@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>, cluster-devel@redhat.com,
	nfs@lists.sourceforge.net, Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HiIY2-0005oV-SU
	for nfs@lists.sourceforge.net; Sun, 29 Apr 2007 16:11:18 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HiIY4-0000KT-Uv
	for nfs@lists.sourceforge.net; Sun, 29 Apr 2007 16:11:21 -0700
In-Reply-To: message from J. Bruce Fields on Sunday April 29
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Sunday April 29, bfields@fieldses.org wrote:
> On Sat, Apr 28, 2007 at 08:22:55AM +1000, Neil Brown wrote:
> > A flag to unexport cannot work because we don't call unexport - we
> > just flush a kernel cache.
> > 
> > A flag to export is just .... weird.  All the other export flags are
> > state flags.  This would be an action flag.  They are quite different
> > things.   Setting a state flag again is a no-op.  Setting an action
> > flag again has a very real effect.
> 
> In this case the second set shouldn't have any effect--whatever flag is
> set should prevent further locks from being accepted, shouldn't it?  (If
> it matters.)

yes, I guess a "No locks are allowed against this export" makes more
sense than "Remove all locks on this export now".
Though currently the locks are against the filesystem - the export can
disappear from the cache while the locks remain - so it's a long way
from perfect.  Possibly we could insist that the export remains in the
kernel while files are locked .... but we update export flags by
replacing the export, so that would be a little awkward.

Also, I think I was half-thinking about the "reset the grace period"
operation, and that looks a lot like an action.... unless you make it
  grace_period_ends=seconds-since-epoch.

That might work.

> 
> > Also, each filesystem is potentially exported multiple times for
> > different sets of clients.  If such a flag (whether on 'export' or
> > 'unexport') just said "remove locks from this set of clients" it
> > wouldn't meet the needs, and if it said "remove all locks" it would be
> > a very irregular interface.
> 
> The same could be said of the "fsid=" option on exports.  It doesn't
> make sense to provide different filehandle- or path- name spaces
> depending on the IP address of a client.  If my laptop changes IP
> address, then I can (grudgingly) accept the fact that the server may
> have to deny me access that I had before--maybe it just can't trust the
> network I moved to for whatever reason--but I'd really rather it didn't
> suddenly start giving me paths, or different filehandles, or different
> semantics (like sync vs. async).
> 
> So the export interface is already being used for stuff that's really
> intended to be per-filesystem rather than per-(filesystem, client) pair.

ro/rw is often different based on client address, but yes: at lot of
the flags don't really make sense being different for different
clients on the same filesystem.

My feeling was that the "nolocks" flag is essentially pointless unless
it is the same for all exports on the one filesystem, and that gives
it a very different feel.

To make use of such a flag you could not rely on the normal mechanism
for loading flag information: on-demand loading by mountd.
You would need to look through /proc/fs/nfsd/exports, find all the
current exports for the filesystem, tell the kernel to change each
export to have the "nolocks" flag.  And then when you have done all of
that, you want to immediately remove all those export entries so you
can unmount the filesystem.

So while it could be made to work, it doesn't feel clean at all.

A   grace_period_ends=seconds-since-epoch  flag would not have most of
those problems.  e.g. it could be demand loaded.
But there is the risk that it might be set for some exports on a given
filesystem and not for others.  And the consequence of that is that
some clients might not be able to reclaim their locks (because the
lock has already been given to a client which didn't know about the
new grace period).

Now maybe it would be good to have a bunch of nfsd options that are
explicitly per-filesystem rather than per-export.
Maybe that is the sort of interface we should be designing.
  echo "+nolocks /path/to/filesystem" > /proc/fs/nfsd/filesystem_settings
  echo "grace_end=12345678 /path/to/filesystem" > /proc/....
  echo "-write_gather /path" > .....
  

We would need to be clear on how long those settings remain in the
kernel, how it can be told to completely forget a particular
filesystem etc..

But we probably don't need to go over-board straight away.
I like the interface:
   echo -n "flag flag .. /path/name" >  /proc/fs/nfsd/filesystem_settings

where if flags is "?flag", then the value is returned by a subsequent
read on the same file-descriptor.

At this point we only need "nolocks" and "grace_end".
The grace_end information persists until that point in time.
The "nolocks" information .... doesn't persist(?).

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
