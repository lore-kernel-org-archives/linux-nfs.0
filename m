Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35707 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754020AbbCQKSi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Mar 2015 06:18:38 -0400
Received: by pabyw6 with SMTP id yw6so5773074pab.2
        for <linux-nfs@vger.kernel.org>; Tue, 17 Mar 2015 03:18:37 -0700 (PDT)
Date: Tue, 17 Mar 2015 03:18:35 -0700
From: Omar Sandoval <osandov@osandov.com>
To: David Sterba <dsterba@suse.cz>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, osd-dev@open-osd.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        fuse-devel@lists.sourceforge.net, cluster-devel@redhat.com,
        jfs-discussion@lists.sourceforge.net, HPDD-discuss@ml01.01.org,
        linux-nfs@vger.kernel.org, linux-nilfs@vger.kernel.org,
        ocfs2-devel@oss.oracle.com, reiserfs-devel@vger.kernel.org,
        v9fs-developer@lists.sourceforge.net, xfs@oss.sgi.com,
        linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 1/5] new helper: iov_iter_rw()
Message-ID: <20150317101835.GA31649@mew>
References: <cover.1426502566.git.osandov@osandov.com>
 <34dc78b262546e9343e0ed872232a97f5eaa5f15.1426502566.git.osandov@osandov.com>
 <20150316173605.GX29656@ZenIV.linux.org.uk>
 <20150317093151.GS20767@twin.jikos.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150317093151.GS20767@twin.jikos.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 17, 2015 at 10:31:51AM +0100, David Sterba wrote:
> On Mon, Mar 16, 2015 at 05:36:05PM +0000, Al Viro wrote:
> > On Mon, Mar 16, 2015 at 04:33:49AM -0700, Omar Sandoval wrote:
> > > Get either READ or WRITE out of iter->type.
> > 
> > Umm...  
> > 
> > > + * Get one of READ or WRITE out of iter->type without any other flags OR'd in
> > > + * with it.
> > > + */
> > > +static inline int iov_iter_rw(const struct iov_iter *i)
> > > +{
> > > +	return i->type & RW_MASK;
> > > +}
> > 
> > TBH, I would turn that into a macro.  Reason: indirect includes.
> 
> Agreed, but the proposed define is rather cryptic and I was not able to
> understand the meaning on the first glance.
> 
> > #define iov_iter_rw(i) ((0 ? (struct iov_iter *)0 : (i))->type & RW_MASK)
> 
> This worked for me, does not compile with anything else than
> 'struct iov_iter*' as i:
> 
> #define iov_iter_rw(i)	({			\
> 	struct iov_iter __iter = *(i);		\
> 	(i)->type & RW_MASK;			\
> 	})
> 
> The assignment is optimized out.

[-cc individual fs maintainers to avoid all of these email bounces,
should've looked a bit closer at that get_maintainer.pl output...]

I agree that this is a bit more readable, but it evaluates i twice.
That's an easy fix, just do __iter.type instead of (i)->type, but
there's still the possibility of someone passing in something called
__iter as i, and the fix for that tends to be "add more underscores". At
the very least, Al's macro could probably use a comment explaining
what's going on there, though.

-- 
Omar
