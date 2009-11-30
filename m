From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [nfs-utils PATCH] retry on EPERM from NFSv4 mount attempt
Date: Mon, 30 Nov 2009 13:18:58 -0500
Message-ID: <20091130181858.GA6348@fieldses.org>
References: <19211.7054.291514.185591@notabene.brown> <4B0BEDDB.1010203@RedHat.com> <4B13C48E.5020009@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34596 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752601AbZK3SR7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Nov 2009 13:17:59 -0500
In-Reply-To: <4B13C48E.5020009-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 30, 2009 at 08:11:42AM -0500, Steve Dickson wrote:
> Sorry for the delayed response, I took some time off...
> 
> On 11/24/2009 09:29 AM, Steve Dickson wrote:
> > 
> > 
> > On 11/23/2009 06:32 PM, Neil Brown wrote:
> >>
> >> Hi,
> >>  I recently packaged nfs-utils 1.2.1 for openSUSE and fairly quickly
> >>  got a bug report - "-o nfsvers=3" was needed to mount NFSv3
> >>  filesystems.
> >>
> >>  mount.nfs in 1.2.1 will first try a v4 mount but will fall-back to v3
> >>  if it gets ENOENT.  This works fine.
> >>  However for kernel prior to 2.6.25, you don't get ENOENT, you get
> >>  EPERM.
> >>  In that case the fall-back to v3 doesn't happen and you get a failure
> >>  to mount.
> >>
> >>  So I think we need to fall back on EPERM as well.  See below.
> > I already posted this patch on the v4 mailing list
> > http://linux-nfs.org/pipermail/nfsv4/2009-November/011595.html
> > but it got shot down...  at least that's how I interpreted the
> > responses... 
> > 
> > But I do thing we need this, since there are so many server 
> > that will simple break if we don't... Agreed?
> 
> There appears to be a consensus that we need to do something
> but no agreement on what.... 
> 
> I believe the options are:

Note we want to do more than one of these; in particular:

>    1) Start servers with '-N 4' when there is no root configured.

This is required.  The current behavior is a bug, and we must not start
servers with v4 support without having a pseudoroot.

>       * The problem I see with this is, in the event v4 support is wanted 
>         its yet another configuration knob that has to be turned, basically
>         making it more difficult for people use v4. 

Yes.  There are things we can do to help (the pseudoroot patches, for
example).  However, continuing to turn on v4 by default in the absence
of a pseudoroot is not an option.

>    2) Change the kernel to return NFS4ERR_SERVERFAULT when there is no
>       root configured. 
>       * I see this is yet another errno the mounting code has to deal with..
>         We are up to two errnos, do we really want to add a third?

I think SERVERFAULT is a little more accurate, but I'm open to argument.

> Neither one of these solutions deal with legacy servers or move
> the "v4 technology" forward... IMHO...   

Yes, so we also need to do one of these:

> So what I suggest we do is:
>    1) Finish the dynamic pseudo root support asap, since all this
>       goes away when that support exists. 

Sure.

>    2) We commit the "roll back to v3 on EPERM errors" and we draw a 
>       line in the sand saying if a server does not return one of these
>       errors on v4 mounts when there is a not a root configured, the
>       server is broken and needs to be fix. Point, these are the only
>       two errnos that will cause a v3 roll back.
>       * My only concern is how we are going to work with 
>         non-linux servers and how much extra network trace will 
>         this cause during automount storms... 
> 
> But in the end, I think we will have to go with the "roll back on EPERM errors"
> patch, because there is simply no way a mount command can be released 
> in an enterprise environment that is not backward compatible with
> existing servers.

OK.

--b.
