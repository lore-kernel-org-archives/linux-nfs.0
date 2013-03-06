Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34552 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758264Ab3CFOkh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Mar 2013 09:40:37 -0500
Date: Wed, 6 Mar 2013 09:40:34 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Subject: Re: [Devel] [PATCH] nfsd: check client tracker initialization result
Message-ID: <20130306144034.GN15816@fieldses.org>
References: <20130228120959.6764.17787.stgit@localhost.localdomain>
 <20130305212001.GD15816@fieldses.org>
 <5136CEEB.5090505@parallels.com>
 <5136DFBE.3090505@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <5136DFBE.3090505@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 06, 2013 at 10:18:38AM +0400, Stanislav Kinsbursky wrote:
> 06.03.2013 09:06, Stanislav Kinsbursky пишет:
> >06.03.2013 01:20, J. Bruce Fields пишет:
> >>On Thu, Feb 28, 2013 at 03:09:59PM +0300, Stanislav Kinsbursky wrote:
> >>>Function nfsd4_client_tracking_init() can return error.
> >>
> >>Before, I think that we the nfsd4_client_* functions just became no-ops
> >>in this case.  With the result that no client records get written, and
> >>so clients are unable to reclaim on the next boot.
> >>
> >>Which is annoying, but possibly not as annoying as your server
> >>completely refusing to start.
> >>
> >>It's arguably more helpful in the long run to fail immediately when we
> >>recognize reboot recovery isn't going to work.  But in practice this may
> >>mean people that never knew they had a problem suddenly have servers
> >>that don't start at all.
> >>
> >>So I'm inclined to be more forgiving and leave this as it is.  But maybe
> >>something like a warning printk would be appropriate.
> >>
> >
> >Ok then.
> >I'll add the warning anf convert the function to be "void" rather then "int".
> >Thanks!
> >
> 
> We already have a warning.
> So, probably all we need is just to change a prototype to make it less confusing.
> Is it ok?

Sure.  And/or add a comment if you think it would be useful.

--b.
