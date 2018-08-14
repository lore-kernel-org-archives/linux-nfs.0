Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58994 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725988AbeHNWcS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Aug 2018 18:32:18 -0400
Date: Tue, 14 Aug 2018 15:43:34 -0400
From: Bruce Fields <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: Nelson Elhage <nelhage@nelhage.com>,
        Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org,
        James Brown <jbrown@easypost.com>
Subject: Re: NFSv3 may inappropriately return EPERM for fsetxattr
Message-ID: <20180814194334.GO7906@fieldses.org>
References: <CAPSG9dbOPRv_gM_w_Ys9fJ-fSPRnw+Rgb3yaaHVEqZ9YyDntzg@mail.gmail.com>
 <20160321144349.GA12804@lst.de>
 <CAPSG9dZX45Uq07Xue55Aom3i-WyH9_SA_SKydBjsEX1Y14VwoA@mail.gmail.com>
 <874lg3roua.fsf@notabene.neil.brown.name>
 <20180810170027.GF7906@fieldses.org>
 <20180810170312.GG7906@fieldses.org>
 <87d0uor11r.fsf@notabene.neil.brown.name>
 <20180812132100.GL7906@fieldses.org>
 <878t5bqgx0.fsf@notabene.neil.brown.name>
 <87ftzhb9rh.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87ftzhb9rh.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 14, 2018 at 07:03:14PM +1000, NeilBrown wrote:
> On Mon, Aug 13 2018, NeilBrown wrote:
> 
> > On Sun, Aug 12 2018, Bruce Fields wrote:
> >> OK, so not too important.  Still, it sounds like
> >> inode_owner_or_capable() is something people expect to work for any
> >> filesystem, so I wonder if there's a way to do that.  Or at least
> >> disable it.
> >
> > We could add a new flag - MAY_OWN (or something) - to the flags
> > recognised by inode_permission() and i_op->permission().
> >
> > If ->permission isn't set, inode_permission() uses
> > inode_owner_or_capable().
> > If it is, it gets to call that, or do whatever is appropriate.
> >
> > Is this flag the same as NFS_MAY_OWNER_OVERRIDE or not....??
> >
> 
> Pursuing this thought...
>   NFSD_MAY_OWNER_OVERRIDE means "an operation is requested which
>    may always be performed by the owner of the file, even if they
>    don't have explicit permission via DAC setting."
> 
> I think this is a reasonable description of how inode_owner_or_capable()
> is used.  It is sometimes used on its own, where there is no permission
> but that is relevant such as O_NOATIME or set_posix_acl(), or is used
> as a precursor to and inode_permission() check, as in notify_change().
> 
> The biggest difference is that NFSD_MAY_OWNER_OVERRIDE does have the
> "or_capable".
> As nfsd drops CAP_FOWNER, and the extra test won't hurt it.
> 
> So I now think that a good solution to this problem would be to hoist
> NFSD_MAY_OWNER_OVERRIDE into the VFS and change inode_permission() and
> various i_op->permission functions to handle it.
> 
> All we need is a good name....
>   MAY_BY_OWNER  ???
>   MAY_IF_OWNER
>   MAY_BE_OWNER ???
> 
> MAY_READ means "may I please read this file".  The flag needs to say
> "may I act as the owner of this file", so
>   MAY_ACT_AS_OWNER ????

It's still a little different from the other permission bits in that I
believe

	permission(., READ|WRITE)
		== permission(., READ) && permission(., WRITE)

but

	permission(., READ|OWNER_OVERRIDE)
		== permission(., READ) || permission(., OWNER_OVERRIDE)

?

Anyway, naming aside....  I don't know, sounds like it might work?
Honestly I'm not completely sure I understand the proposal.

--b.
