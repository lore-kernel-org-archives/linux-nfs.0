Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37576 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753286AbaDCXV5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Apr 2014 19:21:57 -0400
Date: Thu, 3 Apr 2014 19:21:46 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Mark Lord <mlord@pobox.com>, "J. Bruce Fields" <bfields@redhat.com>,
        Albert Fluegel <af@muc.de>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: linux-3.14 nfsd regression
Message-ID: <20140403192146.79679909@tlielax.poochiereds.net>
In-Reply-To: <20140403201627.GC8343@fieldses.org>
References: <533D8D73.1090603@pobox.com>
	<20140403171643.GB28790@pad.redhat.com>
	<533D9F8A.6030001@pobox.com>
	<20140403145504.3b04170e@tlielax.poochiereds.net>
	<20140403201627.GC8343@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 3 Apr 2014 16:16:27 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Apr 03, 2014 at 02:55:04PM -0400, Jeff Layton wrote:
> > On Thu, 03 Apr 2014 13:51:06 -0400
> > Mark Lord <mlord@pobox.com> wrote:
> > 
> > > On 14-04-03 01:16 PM, J. Bruce Fields wrote:
> > > > On Thu, Apr 03, 2014 at 12:33:55PM -0400, Mark Lord wrote:
> > > >> This commit from linux-3.14 breaks our NFS-root clients here:
> > > >>
> > > >> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=6e14b46b91fee8a049b0940333ce13a820beaaa5
> > > >>
> > > >>
> > > >> - *p++ = htonl((u32) stat->mode);
> > > >> + *p++ = htonl((u32) (stat->mode & S_IALLUGO));
> > > >>
> > > >>
> > > >> Reverting the one-liner above (on the server) fixes it for us,
> > > >> as does reverting back to linux-3.13.8 on the server.
> > > >>
> > > >> The NFS-root clients are on PowerPC (big-endian) architecture,
> > > >> running linux-3.12.16. The NFS server is on an Intel PC running linux-3.14.
> > > >>
> > > >> ACL is completely disabled on server and client,
> > > >> and we're using NFSv2/v3.  No support for v4.
> > > >>
> > > >> I instrumented the function to see what other bits were being cleared
> > > >> by the (stat->mode & S_IALLUGO) masking.  The results are attached.
> > > > 
> > > > Hm, it sounds like a bug in the client if it's depending on those high
> > > > bits.
> > > 
> > > But only for mounting / starting up from the nfsroot, it seems.
> > > I wonder if there's an unusual code path for that in there?
> > > The regular stuff looks mostly fine:
> > > 
> > >         p = xdr_decode_ftype3(p, &fmode);
> > >         fattr->mode = (be32_to_cpup(p++) & ~S_IFMT) | fmode;
> > > 
> > > Except perhaps that second line ought to use the same mask
> > > as the server side is using, just in case there are some other
> > > stray high (higher than S_IFMT) bits in there now/someday.
> > > 
> > > > The original behavior was in practice harmless and changing it broke
> > > > something, so I think we should definitely just revert this patch.
> > > 
> > > Yup.  Who?
> > > 
> > > > But the client may need fixing too.
> > > 
> > > Probably a good thing in the longer term, for better compatibility
> > > with non-Linux servers.  But we'll still have to keep the revert
> > > on the server (nfsd) code for backward compatibility, I think.
> > > 
> > > Cheers
> > > 
> > 
> > It would be good to understand where this is broken in the client.
> > 
> > It's incorrect for the client to interpret those bits, as I think that
> > there's no guarantee that other OS's implement the type bits in the
> > same way that Linux does. So if you end up mounting a different OS,
> > it's possible that the client will get that wrong...
> 
> It turns out these bits actually are defined in rfc 1094, so this is
> just an odd NFSv2-specific wart, and the nfsd change was just flat-out
> wrong.
> 
> --b.

Ahh right -- I remember seeing that long ago.

So according to the RFC you have to encode both the mode bits and the
ftype for v2. The type bits seem to be removed from the mode in NFSv3
though, so perhaps we should only be doing that masking in versions
above v2?

With a quick check, it looks like the v3 code doesn't rely on those bits
and I imagine v4 doesn't either.

It might also be nice to have the client v2 decode_fattr function to
throw a warning if the server sends us mismatched type bits and ftype
values. That would have helped us catch this sooner...

-- 
Jeff Layton <jlayton@redhat.com>
