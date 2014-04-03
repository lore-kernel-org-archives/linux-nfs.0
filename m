Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:11380 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753169AbaDCV2t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Apr 2014 17:28:49 -0400
Date: Thu, 3 Apr 2014 17:28:41 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Mark Lord <mlord@pobox.com>
Cc: Albert Fluegel <af@muc.de>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: linux-3.14 nfsd regression
Message-ID: <20140403212841.GM28790@pad.redhat.com>
References: <533D8D73.1090603@pobox.com>
 <20140403171643.GB28790@pad.redhat.com>
 <533D9F8A.6030001@pobox.com>
 <20140403193024.GC28790@pad.redhat.com>
 <533DC90B.8050906@pobox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <533DC90B.8050906@pobox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 03, 2014 at 04:48:11PM -0400, Mark Lord wrote:
> On 14-04-03 03:30 PM, J. Bruce Fields wrote:
> > On Thu, Apr 03, 2014 at 01:51:06PM -0400, Mark Lord wrote:
> >> On 14-04-03 01:16 PM, J. Bruce Fields wrote:
> >>> On Thu, Apr 03, 2014 at 12:33:55PM -0400, Mark Lord wrote:
> >>>> This commit from linux-3.14 breaks our NFS-root clients here:
> >>>>
> >>>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=6e14b46b91fee8a049b0940333ce13a820beaaa5
> >>>>
> >>>>
> >>>> - *p++ = htonl((u32) stat->mode);
> >>>> + *p++ = htonl((u32) (stat->mode & S_IALLUGO));
> >>>>
> >>>>
> >>>> Reverting the one-liner above (on the server) fixes it for us,
> >>>> as does reverting back to linux-3.13.8 on the server.
> >>>>
> >>>> The NFS-root clients are on PowerPC (big-endian) architecture,
> >>>> running linux-3.12.16. The NFS server is on an Intel PC running linux-3.14.
> >>>>
> >>>> ACL is completely disabled on server and client,
> >>>> and we're using NFSv2/v3.  No support for v4.
> >>>>
> >>>> I instrumented the function to see what other bits were being cleared
> >>>> by the (stat->mode & S_IALLUGO) masking.  The results are attached.
> >>>
> >>> Hm, it sounds like a bug in the client if it's depending on those high
> >>> bits.
> >>
> >> But only for mounting / starting up from the nfsroot, it seems.
> >> I wonder if there's an unusual code path for that in there?
> >> The regular stuff looks mostly fine:
> >>
> >>         p = xdr_decode_ftype3(p, &fmode);
> >>         fattr->mode = (be32_to_cpup(p++) & ~S_IFMT) | fmode;
> > 
> > Hm, but that's in nfs3xdr.c; in nfs2xdr.c we have just
> > 
> > 	fattr->mode = be32_to_cpup(p+);
> > 
> > and NFSv2 is the default for nfsroot.  Do you have some reason to
> > believe you're not using NFSv2?
> 
> Oh, the client here was using NFS2, absolutely.
> I just don't know my way around the code very well yet.  :)
> 
> But that mask in nfs3xdr.c (client) doesn't match what the server side is using.

Not sure there's anything to see there.

Looking at include/uapi/linux/stat.h and include/linux/stat.h, if I'm
doing this right...

S_ISFMT is   0170000
S_IALLUGO is 0007777

So they're 16-bit complements.  And we're storing the result in a short?

--b.
