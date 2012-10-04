Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41686 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757015Ab2JDQHr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Oct 2012 12:07:47 -0400
Date: Thu, 4 Oct 2012 12:07:39 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Inconsistency when mounting a directory that 'world' cannot
 access.
Message-ID: <20121004160739.GA4693@fieldses.org>
References: <20120918112329.7d88ed9e@notabene.brown>
 <20121001154309.GD18400@fieldses.org>
 <20121002123810.15bd1ee2@notabene.brown>
 <20121002143334.GA1435@fieldses.org>
 <20121003134629.72557522@notabene.brown>
 <20121003151349.GD14313@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA909001D77@SACEXCMBX04-PRD.hq.netapp.com>
 <20121003162728.GE14313@fieldses.org>
 <20121004084659.38632320@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121004084659.38632320@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 04, 2012 at 08:46:59AM +1000, NeilBrown wrote:
> On Wed, 3 Oct 2012 12:27:28 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > On Wed, Oct 03, 2012 at 03:48:43PM +0000, Myklebust, Trond wrote:
> > > On Wed, 2012-10-03 at 11:13 -0400, J. Bruce Fields wrote:
> > > > On Wed, Oct 03, 2012 at 01:46:29PM +1000, NeilBrown wrote:
> > > > > On Tue, 2 Oct 2012 10:33:34 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> > > > > wrote:
> > > > > 
> > > > > > I guess you're right.  So it starts to sound more like: "you have a
> > > > > > confusing setup.  Your export configuration says one thing, and your
> > > > > > filesystem permissions say another.  Under NFSv3 the confusion didn't
> > > > > > matter, but now it does--time to fix it."
> > > > > > 
> > > > > 
> > > > > That's the best I could come to - I'm glad to have it confirmed.  Thanks!
> > > > > 
> > > > > It is unfortunate that Linux NFS uses an anon credential to mount when krb5
> > > > > is in use, and uses 'root' when auth_sys is used (which might be anon if
> > > > > "root_squash" is active, but might not).
> > > > > I wonder if it would work to use auth_none for the mount-time lookup, just
> > > > > for consistency..
> > > > > 
> > > > > Is the following appropriate?  Is there somewhere better to put this caveat?
> > > > 
> > > > Unfortunately, it's more complicated than this, as it depends on client
> > > > implementation and configuration details.
> > > > 
> > > > Something like this would be more accurate but possibly too long:
> > > > 
> > > > 	Note that under NFSv2 and NFSv3, the mount path is traversed by
> > > > 	mountd acting as root, but under NFSv4 the mount path is looked
> > > > 	up using the client's credentials.  This means that, for
> > > > 	example, if a client mounts using a krb5 credential that the
> > > > 	server maps to an "anonmyous" user, then the mount will only
> > > > 	succeed if that directory and all its parents allow eXecute
> > > > 	permissions.
> > > 
> > > So you're listing this as a "feature" rather than a bug? There should be
> > > no reason to constrain the pseudofs to use the permission checks from
> > > the underlying filesystem.
> > 
> > I'd be fine with that.
> > 
> > (That still leaves some subtle v3/v4 difference in the case of mount
> > paths underneath an export?
> > 
> > What *is* the existing mountd behavior there, exactly?  I'm inclined to
> > think allowing mounts of arbitrary subdirectories is a bug, but maybe
> > there's some historical reason for it or maybe someone already depends
> > on it.)
> > 
> > --b.
> 
> The behaviour is simple that you mount a filehandle (typically belonging to a
> directory) and that filehandle can be anything inside any exported filesystem.

It's not the nfsd behavior that bothers me--there's nothing we can do
about the fact that access by filehandle can bypass directory
permissions.

What bothers is that mountd will apparently allow anyone to do a lookup
anywhere in an exported filesystem.

I don't know--maybe I shouldn't be so concerned about the possibility a
rogue user could figure out that my "Music" directory includes an
unreasonable number of Miles Davis titles.

> Yes, please do depend on being able to mount filehandles that aren't to root
> of a filesystem.
> 
> The case the brought this issue to my attention involved the server having
> a directory containing hundreds of home directories.  This directory is
> exported.
> 
> If they mount that top level directory they get horrible performance.  If
> they use an automounter to just mount the homes that are accessed it works
> better.  They weren't able to explain why but my guess is that some tools
> (GUI filesystem browser) would occasionally do the equivalent of "ls  -l" of
> the top level directory which would hammer nfs-idmapd and probably ldap....
> though you would think that would get cached and not be a problem for long.
> So maybe it is more subtle than that.

Getting all the id->name mappings for a 100-entry directory is going to
require a 100 serialized upcalls to idmapd (and then possibly ldap), and
by default it looks like the idmapd cache will go cold after 10
minutes....  Not hard to imagine that could be a problem.

Running multiple idmapd process would be easy and might help?  Though
not if the client's just giving us the getattrs one at a time.

Or maybe the problem's somewhere else entirely, but that's a real bug if
we aren't giving good performance on /home.

--b.

> I've built similar setups before.  There is something attractive about
> everyone's home directory being /home/$USERNAME even though they are on
> different servers and different filesystems.
> 
> In the particular problem scenario, local policy requires that the 'staff'
> directory on the server to not be world-accessible, but they still want to
> mount the individual home directories from there onto client machines as
> required.
> I cannot easily justify that policy, but the point is that it works with
> NFSv3 and with AUTH_SYS/no_root_squash, but not with NFSv4/kerb5.  I don't
> think we can fix this inconsistency but maybe we can explain it.
> 
> I think your text is more accurate than mine, but also a little more vague so
> the important may not be immediately obvious.  That might be a price we have
> to pay for accuracy.
