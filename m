Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:35680 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757082AbbKRVP1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Nov 2015 16:15:27 -0500
Received: by qgec40 with SMTP id c40so38073100qge.2
        for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2015 13:15:26 -0800 (PST)
Date: Wed, 18 Nov 2015 16:15:21 -0500
From: Jeff Layton <jlayton@poochiereds.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org,
        Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v1 38/38] nfs: add a Kconfig option for NFS reexporting
 and documentation
Message-ID: <20151118161521.67e79050@tlielax.poochiereds.net>
In-Reply-To: <20151118202220.GA992@fieldses.org>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
	<1447761180-4250-39-git-send-email-jeff.layton@primarydata.com>
	<20151118202220.GA992@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 18 Nov 2015 15:22:20 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Nov 17, 2015 at 06:53:00AM -0500, Jeff Layton wrote:
> > +Filehandle size:
> > +----------------
> > +The maximum filehandle size is governed by the NFS version. Version 2
> > +used fixed 32 byte filehandles. Version 3 moved to variable length
> > +filehandles that can be up to 64 bytes in size. NFSv4 increased that
> > +maximum to 128 bytes.
> > +
> > +When reexporting an NFS filesystem, the underlying filehandle from the
> > +server must be embedded inside the filehandles presented to clients.
> > +Thus if the underlying server presents filehandles that are too big, the
> > +reexporting server can fail to encode them. This can lead to
> > +NFSERR_OPNOTSUPP errors being returned to clients.
> > +
> > +This is not a trivial thing to programatically determine ahead of time
> > +(and it can vary even within the same server), so some foreknowledge of
> > +how the underlying server constructs filehandles, and their maximum
> > +size is a must.
> 
> This is the trickiest one, since it depends on an undocumented
> implementation detail of the server.
> 

Yes, indeed...

> Do we even know if this works for all the exportable Linux filesystems?
> 
> If proxying NFSv4.x servers is actually useful, could we add a per-fs
> maximum-filesystem-size attribute to the protocol?
> 

Erm, I think you mean maximum-filehandle-size, but I get your point...

It's tough to do more than a quick survey, but looking at new-style fh:

The max fsid len seems to be 28 bytes (FSID_UUID16_INUM), though you
can get that down to 8 bytes if you specify the fsid directly. The fsid
choice is weird, because it sort of depends on the filehandle sent by
the client (which is used as a template), so I guess we really do need
to assume worst-case.

Once that's done, the encode_fh routines add the fileid part. btrfs has
a pretty large maximum one: 40 bytes. That brings the max size up to 68
bytes, which is already too large for NFSv3, before we ever get to
the part where we embed that inside another fh. We require another 12
bytes on top of the "underlying" filehandle for reexporting.

So, no this may very well not work for all exportable Linux
filesystems, but it sort of depends on the situation (and to some
degree, what gets sent by the clients). That's what makes this so hard
to figure out programmatically.

As far as extending the protocol...that's not a bad idea, though that's
obviously a longer-term solution. I don't think we can reasonably rely
on that anyway. Maybe though...

-- 
Jeff Layton <jlayton@poochiereds.net>
