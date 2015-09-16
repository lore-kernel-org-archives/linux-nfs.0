Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:36606 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753093AbbIPWEa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Sep 2015 18:04:30 -0400
Received: by ykdt18 with SMTP id t18so213524984ykd.3
        for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2015 15:04:29 -0700 (PDT)
Date: Wed, 16 Sep 2015 18:04:24 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: "bfields@fieldses.org" <bfields@fieldses.org>
Cc: "Dilger, Andreas" <andreas.dilger@intel.com>,
        "cluster-devel@redhat.com" <cluster-devel@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "fuse-devel@lists.sourceforge.net" <fuse-devel@lists.sourceforge.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "HPDD-discuss@lists.01.org" <HPDD-discuss@ml01.01.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "ceph-devel@vger.kernel.org" <ceph-devel@vger.kernel.org>,
        "ocfs2-devel@oss.oracle.com" <ocfs2-devel@oss.oracle.com>
Subject: Re: [HPDD-discuss] [PATCH] nfsd: add a new EXPORT_OP_NOWCC flag to
 struct export_operations
Message-ID: <20150916180424.47915fed@synchrony.poochiereds.net>
In-Reply-To: <20150916213044.GB5169@fieldses.org>
References: <1441966830-5517-1-git-send-email-jeff.layton@primarydata.com>
	<D21906EE.10A741%andreas.dilger@intel.com>
	<20150912062454.2283d4b6@tlielax.poochiereds.net>
	<20150914161015.GC5338@fieldses.org>
	<20150916131829.6cbf5657@tlielax.poochiereds.net>
	<20150916213044.GB5169@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 16 Sep 2015 17:30:44 -0400
"bfields@fieldses.org" <bfields@fieldses.org> wrote:

> On Wed, Sep 16, 2015 at 01:18:29PM -0400, Jeff Layton wrote:
> > On Mon, 14 Sep 2015 12:10:15 -0400
> > "bfields@fieldses.org" <bfields@fieldses.org> wrote:
> > 
> > > On Sat, Sep 12, 2015 at 06:24:54AM -0400, Jeff Layton wrote:
> > > > I don't think it matters, at least not on x86_64. bools and chars both
> > > > require a byte. pahole does show this adding a new hole, but that's
> > > > just because this brings the code up to 5 flags and the next field
> > > > (fh_pre_size) needs to be aligned.
> > > > 
> > > > I do agree that replacing those other unsigned chars with bools is more
> > > > clear however. Maybe we should even replace them all with a single
> > > > unsigned int and use bitops to set flags in there. That would be more
> > > > space efficient now that we're at 5 flags.
> > > 
> > > Makes sense to me.--b.
> > 
> > I played around with this a little today, and it turns out not to make
> > a lot of difference. Here's what pahole says about the existing code
> > (once I moved fh_maxsize to snuggle up to fh_handle to plug a hole):
> ...
> > I used an unsigned long for fh_flags since we might as well. Making it
> > smaller just adds a hole in there since the compiler wants to align the
> > fh_pre_size. Moving it around doesn't help either as it just moves the
> > hole around. Note that this is x86_64. It might look different on a
> > 32-bit arch, but I doubt it really matters much in the big scheme of
> > things.
> > 
> > Bruce, I'll send out the patches that change this if you like, but I'm
> > inclined to just leave this alone since it doesn't seem to have a
> > tangible benefit.
> 
> Unless more flags are imminent I guess it's just a question of which is
> more readable.  Arguably there's some value to making it more obvious
> that these are each just a bit.  I'll accept your judgement on that
> question.
> 
> --b.

Sure. Maybe we just switch them to bools. It's the same space
utilization but it does make things a little more clear.

-- 
Jeff Layton <jlayton@poochiereds.net>
