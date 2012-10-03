Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57837 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932474Ab2JCQ1b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Oct 2012 12:27:31 -0400
Date: Wed, 3 Oct 2012 12:27:28 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: NeilBrown <neilb@suse.de>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: Inconsistency when mounting a directory that 'world' cannot
 access.
Message-ID: <20121003162728.GE14313@fieldses.org>
References: <20120918112329.7d88ed9e@notabene.brown>
 <20121001154309.GD18400@fieldses.org>
 <20121002123810.15bd1ee2@notabene.brown>
 <20121002143334.GA1435@fieldses.org>
 <20121003134629.72557522@notabene.brown>
 <20121003151349.GD14313@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA909001D77@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA909001D77@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 03, 2012 at 03:48:43PM +0000, Myklebust, Trond wrote:
> On Wed, 2012-10-03 at 11:13 -0400, J. Bruce Fields wrote:
> > On Wed, Oct 03, 2012 at 01:46:29PM +1000, NeilBrown wrote:
> > > On Tue, 2 Oct 2012 10:33:34 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> > > wrote:
> > > 
> > > > I guess you're right.  So it starts to sound more like: "you have a
> > > > confusing setup.  Your export configuration says one thing, and your
> > > > filesystem permissions say another.  Under NFSv3 the confusion didn't
> > > > matter, but now it does--time to fix it."
> > > > 
> > > 
> > > That's the best I could come to - I'm glad to have it confirmed.  Thanks!
> > > 
> > > It is unfortunate that Linux NFS uses an anon credential to mount when krb5
> > > is in use, and uses 'root' when auth_sys is used (which might be anon if
> > > "root_squash" is active, but might not).
> > > I wonder if it would work to use auth_none for the mount-time lookup, just
> > > for consistency..
> > > 
> > > Is the following appropriate?  Is there somewhere better to put this caveat?
> > 
> > Unfortunately, it's more complicated than this, as it depends on client
> > implementation and configuration details.
> > 
> > Something like this would be more accurate but possibly too long:
> > 
> > 	Note that under NFSv2 and NFSv3, the mount path is traversed by
> > 	mountd acting as root, but under NFSv4 the mount path is looked
> > 	up using the client's credentials.  This means that, for
> > 	example, if a client mounts using a krb5 credential that the
> > 	server maps to an "anonmyous" user, then the mount will only
> > 	succeed if that directory and all its parents allow eXecute
> > 	permissions.
> 
> So you're listing this as a "feature" rather than a bug? There should be
> no reason to constrain the pseudofs to use the permission checks from
> the underlying filesystem.

I'd be fine with that.

(That still leaves some subtle v3/v4 difference in the case of mount
paths underneath an export?

What *is* the existing mountd behavior there, exactly?  I'm inclined to
think allowing mounts of arbitrary subdirectories is a bug, but maybe
there's some historical reason for it or maybe someone already depends
on it.)

--b.
