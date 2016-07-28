Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43636 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754501AbcG1UyJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jul 2016 16:54:09 -0400
Date: Thu, 28 Jul 2016 16:54:07 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 6/8] mountd: don't add paths to non-mounted export points
 to pseudo-root
Message-ID: <20160728205407.GE30034@fieldses.org>
References: <20160714021310.5874.22953.stgit@noble>
 <20160714022643.5874.27117.stgit@noble>
 <20160718203242.GD12304@fieldses.org>
 <8760s19qul.fsf@notabene.neil.brown.name>
 <20160721173350.GD27148@fieldses.org>
 <87zip641y6.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87zip641y6.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 25, 2016 at 05:22:09PM +1000, NeilBrown wrote:
> On Fri, Jul 22 2016, J. Bruce Fields wrote:
> 
> > On Wed, Jul 20, 2016 at 08:59:30AM +1000, NeilBrown wrote:
> >> On Tue, Jul 19 2016, J. Bruce Fields wrote:
> >> 
> >> > On Thu, Jul 14, 2016 at 12:26:43PM +1000, NeilBrown wrote:
> >> >> export points with the "mountpoint" flag should not be exported
> >> >> if they aren't mounted.
> >> >> They shouldn't even appear in the pseudo-root filesystem.
> >> >> So add an appropriate check to v4root_set().
> >> >> 
> >> >> This means that the v4root might need to be recomputed whenever a
> >> >> filesystem is mounted or unmounted.  So when there are export points
> >> >> with the "mountpoint" flag, check for changes in the mount table.
> >> >> This is done be measuring the size of /proc/mounts.
> >> >
> >> > Surely there's some more reliable measurement--could we track some data
> >> > about the mountpoint itself, maybe?
> >> 
> >> We could.  But it would be more complex code for very little gain.
> >> I did consider using select() on /proc/mounts to get a notification
> >> whenever anything changes.  What we be more reliable but more difficult.
> >> I also considered calculating an SHA1, or maybe just a crc32 on the
> >> contents of /proc/mounts.  But then I realised that the size was very
> >> easy and very nearly as reliable.
> >
> > So we don't care enough about the mountpoint option enough to make it
> > work 100% reliably?
> >
> > If we expect too few users for there to be a real chance of hitting the
> > bad case here, then I wonder again whether the whole feature is worth
> > the trouble.
> >
> >> > But I'd still like some more justification for this change in logic.
> >> > Does anyone currently use the "mp" option?  If not, could we just
> >> > deprecate it?  If so, can we really get away with changing it this way?
> >> 
> >> I have a customer complaining that it doesn't work as advertised for
> >> NFSv4.  So presumably they have a use-case, though I haven't asked for
> >> details on exactly why they want it.
> >
> > I'd be inclined to ask for more details about the use case before
> > continuing.
> 
> I asked, and found the answer quite helpful.

I agree, thanks!

> So thanks for prompting that.
> 
> For NFSv2/3, If I list "/export/foo" in /etc/exports, but /export/foo
> fails to mount during boot, then a client which tries to mount
> "/export/foo" will get a file handle on /export (probably the root
> filesystem).
> Unless subtree_check is set (which we don't like) this effectively means
> that the whole root filesystem is potentially exported, if the client can
> determine the filehandles.
> Once the problem is fixed, the filesystem is mounted, and "exportfs -r"
> is run (possibly by reboot), the root filesystem will no longer be
> exported, so that filehandle that the client has becomes stale (this is
> the particlar symptom the customer mentioned).
> 
> I think it is safe to argue that having 'mount' fail is safer than
> having it succeed, present an empty directory, and then have that
> directory suddenly become stale at some later time.

Yes, and the security exposure is terrible too.

But users should get security by default.  And the same for sensible
errors on mount failures.  They shouldn't have to request it.

(Maybe they do: on typical distributions, nfsd probably won't start
until all local filesystems are mounted, will it?)

> For NFSv4 the root filesystem is always exported, but usually as the
> 'pseudo-root', being read-only and files being completely unavailable.
> If /export/foo is not mounted but /export/foo is exported, then at least
> part of the root filesystem will be exported (potentially) r/w.
> I'm not sure what happens with filehandles.  A filehandle from the pseudo-root
> filesystem has fsid=0.  A filehandle from a properly exported directory
> on the root filesystem might not - I'd have to check another day.
> So you might not get the 'stale file handles', but would might still get
> unexpected access to the root filesystem.

In the end the situation sounds about the same for all NFS versions.

> So I think this justifies maintaining (and maybe even encouraging) the
> 'mountpoint' export option.
> 
> For NFSv4 it is probably OK for the to-be-mounted-on directory to be visible,
> but firmly 'pseudo'.  So I can probably drop my elegant /proc/mounts
> change detector which you aren't fond of.

If we do keep (even encourage) "mountpoint", then we will get a bug
where somebody hit a false negative.

> When we get a filehandle for a filesystem which isn't currently mounted
> the current code sends no response, so clients hang.  My latest patch
> sends ESTALE, so client gets an error.
> I wonder if we could arrange to make just the exported root look like an
> empty (pseudo-root-style) directory.  Then when the filesystem gets
> mounted the directory morphs into the real thing..
> For files on the filesystem I could probably be convinced either way,
> unless testing shows some unpleasant behaviour.
> 
> Are you convinced?  At all?

I dunno.  "mountpoint" probably isn't widely used, so maybe we can get
away with changing it in the way you suggest, and I agree that that
would be better (though I still don't get why the
not-completely-reliable /proc/mounts thing is OK).

--b.
