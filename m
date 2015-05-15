Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46352 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422770AbbEOVLf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 May 2015 17:11:35 -0400
Date: Fri, 15 May 2015 17:11:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Kinglong Mee <kinglongmee@gmail.com>, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 4/4] nfsd: Pin to vfsmnt instead of mntget
Message-ID: <20150515211134.GG29627@fieldses.org>
References: <554A149B.5060102@gmail.com>
 <554A154B.6040103@gmail.com>
 <20150508144031.6f0d3cda@notabene.brown>
 <20150508134744.GA23753@fieldses.org>
 <5550A9DF.1070908@gmail.com>
 <20150513142515.6bd881c8@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150513142515.6bd881c8@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 13, 2015 at 02:25:15PM +1000, NeilBrown wrote:
> On Mon, 11 May 2015 21:08:47 +0800 Kinglong Mee <kinglongmee@gmail.com> wrote:
> 
> > On 5/8/2015 9:47 PM, J. Bruce Fields wrote:
> > > It could also be useful to have the ability to force an unmount even in
> > > the presence of locks.  That's not a safe default, but an
> > > "allow_force_unmount" export option might be useful.
> 
> We already have a mechanism to forcibly drop any locks by writing some magic
> to /proc/fs/nfsd/unlock_{ip,filesystem}.  I don't think we need any more.

Yeah, I remember thinking this sort of approach would have advantages,
maybe I was wrong, I need to revisit it.

The unlock_{ip,filesystem} approach requires temporarily shutting down
mountd, doesn't it?

--b.
