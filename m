Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38768 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932536Ab2JCPNw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Oct 2012 11:13:52 -0400
Date: Wed, 3 Oct 2012 11:13:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: Inconsistency when mounting a directory that 'world' cannot
 access.
Message-ID: <20121003151349.GD14313@fieldses.org>
References: <20120918112329.7d88ed9e@notabene.brown>
 <20121001154309.GD18400@fieldses.org>
 <20121002123810.15bd1ee2@notabene.brown>
 <20121002143334.GA1435@fieldses.org>
 <20121003134629.72557522@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121003134629.72557522@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 03, 2012 at 01:46:29PM +1000, NeilBrown wrote:
> On Tue, 2 Oct 2012 10:33:34 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > I guess you're right.  So it starts to sound more like: "you have a
> > confusing setup.  Your export configuration says one thing, and your
> > filesystem permissions say another.  Under NFSv3 the confusion didn't
> > matter, but now it does--time to fix it."
> > 
> 
> That's the best I could come to - I'm glad to have it confirmed.  Thanks!
> 
> It is unfortunate that Linux NFS uses an anon credential to mount when krb5
> is in use, and uses 'root' when auth_sys is used (which might be anon if
> "root_squash" is active, but might not).
> I wonder if it would work to use auth_none for the mount-time lookup, just
> for consistency..
> 
> Is the following appropriate?  Is there somewhere better to put this caveat?

Unfortunately, it's more complicated than this, as it depends on client
implementation and configuration details.

Something like this would be more accurate but possibly too long:

	Note that under NFSv2 and NFSv3, the mount path is traversed by
	mountd acting as root, but under NFSv4 the mount path is looked
	up using the client's credentials.  This means that, for
	example, if a client mounts using a krb5 credential that the
	server maps to an "anonmyous" user, then the mount will only
	succeed if that directory and all its parents allow eXecute
	permissions.

--b.

> 
> Thanks,
> NeilBrown
> 
> 
> diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
> index bc1de73..91e4b9c 100644
> --- a/utils/exportfs/exports.man
> +++ b/utils/exportfs/exports.man
> @@ -126,6 +126,10 @@ will be enforced only for access using flavors listed in the immediately
>  preceding sec= option.  The only options that are permitted to vary in
>  this way are ro, rw, no_root_squash, root_squash, and all_squash.
>  .PP
> +When RPCSEC_GSS is used with NFSv4, a client will only be able to mount a
> +directory if that directory and all its ancestors give eXecute access
> +to "world".
> +.PP
>  .SS General Options
>  .BR exportfs
>  understands the following export options:


