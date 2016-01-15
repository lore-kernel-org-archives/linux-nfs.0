Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f195.google.com ([209.85.160.195]:35292 "EHLO
	mail-yk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076AbcAOQAd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jan 2016 11:00:33 -0500
Received: by mail-yk0-f195.google.com with SMTP id a85so34490977ykb.2
        for <linux-nfs@vger.kernel.org>; Fri, 15 Jan 2016 08:00:32 -0800 (PST)
Date: Fri, 15 Jan 2016 11:00:23 -0500
From: Jeff Layton <jlayton@poochiereds.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org,
        Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v1 38/38] nfs: add a Kconfig option for NFS reexporting
 and documentation
Message-ID: <20160115110023.5bf5eb3a@tlielax.poochiereds.net>
In-Reply-To: <20160114222127.GA4177@fieldses.org>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
	<1447761180-4250-39-git-send-email-jeff.layton@primarydata.com>
	<20151118202220.GA992@fieldses.org>
	<20151118161521.67e79050@tlielax.poochiereds.net>
	<20151120000415.GA11549@fieldses.org>
	<20151119192849.30cb4549@tlielax.poochiereds.net>
	<20160114222127.GA4177@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 14 Jan 2016 17:21:27 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Nov 19, 2015 at 07:28:49PM -0500, Jeff Layton wrote:
> > On Thu, 19 Nov 2015 19:04:15 -0500
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> >   
> > > On Wed, Nov 18, 2015 at 04:15:21PM -0500, Jeff Layton wrote:  
> > > > On Wed, 18 Nov 2015 15:22:20 -0500
> > > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > >   
> > > > > On Tue, Nov 17, 2015 at 06:53:00AM -0500, Jeff Layton wrote:  
> > > > > > +Filehandle size:
> > > > > > +----------------
> > > > > > +The maximum filehandle size is governed by the NFS version. Version 2
> > > > > > +used fixed 32 byte filehandles. Version 3 moved to variable length
> > > > > > +filehandles that can be up to 64 bytes in size. NFSv4 increased that
> > > > > > +maximum to 128 bytes.
> > > > > > +
> > > > > > +When reexporting an NFS filesystem, the underlying filehandle from the
> > > > > > +server must be embedded inside the filehandles presented to clients.
> > > > > > +Thus if the underlying server presents filehandles that are too big, the
> > > > > > +reexporting server can fail to encode them. This can lead to
> > > > > > +NFSERR_OPNOTSUPP errors being returned to clients.
> > > > > > +
> > > > > > +This is not a trivial thing to programatically determine ahead of time
> > > > > > +(and it can vary even within the same server), so some foreknowledge of
> > > > > > +how the underlying server constructs filehandles, and their maximum
> > > > > > +size is a must.  
> > > > > 
> > > > > This is the trickiest one, since it depends on an undocumented
> > > > > implementation detail of the server.
> > > > >   
> > > > 
> > > > Yes, indeed...
> > > >   
> > > > > Do we even know if this works for all the exportable Linux filesystems?
> > > > > 
> > > > > If proxying NFSv4.x servers is actually useful, could we add a per-fs
> > > > > maximum-filesystem-size attribute to the protocol?
> > > > >   
> > > > 
> > > > Erm, I think you mean maximum-filehandle-size, but I get your point...  
> > > 
> > > Whoops, thanks.
> > >   
> > > > It's tough to do more than a quick survey, but looking at new-style fh:
> > > > 
> > > > The max fsid len seems to be 28 bytes (FSID_UUID16_INUM), though you
> > > > can get that down to 8 bytes if you specify the fsid directly. The fsid
> > > > choice is weird, because it sort of depends on the filehandle sent by
> > > > the client (which is used as a template), so I guess we really do need
> > > > to assume worst-case.  
> > > 
> > > The client can only ever use filehandles it's been given, so if the
> > > backend server's always been configured to use a certain kind (e.g. if
> > > the exports have fsid= set), then we're OK, we're not responsible for
> > > clients that guess random filehandles.
> > >   
> > > > Once that's done, the encode_fh routines add the fileid part. btrfs has
> > > > a pretty large maximum one: 40 bytes. That brings the max size up to 68
> > > > bytes, which is already too large for NFSv3, before we ever get to
> > > > the part where we embed that inside another fh. We require another 12
> > > > bytes on top of the "underlying" filehandle for reexporting.  
> > > 
> > > So it's not necessarily that bad for nfsd, though of course it makes it
> > > more complicated to configure the backend server.  Well, and knfsd has
> > > v3 support so this is all a bit academic I guess.
> > >   
> > 
> > You just have to make sure you vet the filehandle size on the stuff
> > you're reexporting. In our use-case, we know that the backend server's
> > filehandles are well under 42 bytes, so we're well under the max size.
> > 
> > One thing we could consider is promoting the dprintk in nfs_encode_fh
> > when this occurs to a pr_err or something. That would at least make
> > it very obvious when that occurs...
> >   
> > > So I'm having trouble weighing the benefits of this patch set against
> > > the risks.
> > > 
> > > It's not even necessarily true that filehandles on a given filesystem
> > > need be constant length.  In theory a server could decide to start
> > > giving out bigger filehandles some day (as long as it continued to
> > > respect the old ones), and the proxy would break.  In practice maybe
> > > nobody does that.
> > >   
> > 
> > Hard to say. There are a lot of oddball servers out there. There
> > certainly are risks involved in reexporting, particularly if you don't
> > heed the caveats. It's for good reason this Kconfig option defaults to
> > "n". ;)
> > 
> > OTOH, the kernel shouldn't crash or anything if that occurs. If your
> > filehandles are too large to be embedded, then you just end up getting
> > back FILEID_INVALID on the encode_fh. That sucks if it occurs, but
> > it shouldn't happen if you're careful about what gets reexported.  
> 
> OK, sorry for the long silence on this.
> 
> Basically I'm having trouble making the case to myself here:
> 
> 	- On the one hand, having you guys carry all this stuff is
> 	  annoying, I'd rather our code bases were closer.
> 	- On the other hand, I can't see taking something that's in
> 	  practice basically only useful for one proprietary server,
> 	  which is the way it looks to me right now.
> 	- Also, "NFS proxying" *sounds* much more general than it really
> 	  is, and I fear a lot of people are going to fall into that
> 	  trap now matter how we warn them.
> 
> Gah.
> 
> Anyway, for now I should take the one tracepoint patch at least (and
> shouldn't some of the fs patches go in regardless?) but I'm punting on
> the rest.
> 
> --b.

Understood.

I've not had the cycles to spend on this lately anyway, as I've been
putting out fires elsewhere. Perhaps once I am able to do that and
spend some time on the performance of this, we may find that the open
file cache is more generally useful, and we can revisit it then. We'll
see...

FWIW, there is one significant bugfix to that series that I've also not
had the time to post as well. The error handling when fsnotify_add_mark
returns an error is not right, and it can end up with a double free of
the mark.

As far as what should go in soon...yeah, this tracepoint patch might be
nice:

    nfsd: add new io class tracepoint

For the vfs, these two might be good, but I'd like Al to offer an
opinion on the first one. I'm pretty sure we don't call
flush_delayed_fput until after the workqueue threads have been started,
but the only caller now is in the boot code, AFAICT and I'm not 100%
sure on that point:

    fs: have flush_delayed_fput flush the workqueue job
    fs: add a kerneldoc header to fput

This patch has already been picked up by Andrew, AFAICT:

    fsnotify: destroy marks with call_srcu instead of dedicated thread

...and the rest are pretty much specific to the reexporting
functionality.

-- 
Jeff Layton <jlayton@poochiereds.net>
