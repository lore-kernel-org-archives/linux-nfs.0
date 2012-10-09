Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51580 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755016Ab2JIWlL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Oct 2012 18:41:11 -0400
Date: Tue, 9 Oct 2012 18:41:09 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: David Howells <dhowells@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [GIT PULL] Disintegrate UAPI for nfs
Message-ID: <20121009224109.GB25826@fieldses.org>
References: <30732.1349789436@warthog.procyon.org.uk>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90901876D@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA90901876D@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 09, 2012 at 02:13:30PM +0000, Myklebust, Trond wrote:
> On Tue, 2012-10-09 at 14:30 +0100, David Howells wrote:
> > Can you merge the following branch into the nfs tree please.
> > 
> > This is to complete part of the Userspace API (UAPI) disintegration for which
> > the preparatory patches were pulled recently.  After these patches, userspace
> > headers will be segregated into:
> > 
> > 	include/uapi/linux/.../foo.h
> > 
> > for the userspace interface stuff, and:
> > 
> > 	include/linux/.../foo.h
> > 
> > for the strictly kernel internal stuff.
> > 
> > ---
> > The following changes since commit 9e2d8656f5e8aa214e66b462680cf86b210b74a8:
> > 
> >   Merge branch 'akpm' (Andrew's patch-bomb) (2012-10-09 16:23:15 +0900)
> > 
> > are available in the git repository at:
> > 
> > 
> >   git://git.infradead.org/users/dhowells/linux-headers.git tags/disintegrate-nfs-20121009
> > 
> > for you to fetch changes up to e3dd9a52cb5552c46c2a4ca7ccdfb4dab5c72457:
> > 
> >   UAPI: (Scripted) Disintegrate include/linux/sunrpc (2012-10-09 09:49:04 +0100)
> > 
> > ----------------------------------------------------------------
> > UAPI Disintegration 2012-10-09
> > 
> > ----------------------------------------------------------------
> > David Howells (2):
> >       UAPI: (Scripted) Disintegrate include/linux/nfsd
> >       UAPI: (Scripted) Disintegrate include/linux/sunrpc
> > 
> >  include/linux/nfsd/Kbuild           |   5 --
> >  include/linux/nfsd/debug.h          |  31 +--------
> >  include/linux/nfsd/export.h         |  52 +--------------
> >  include/linux/nfsd/nfsfh.h          | 111 +-------------------------------
> >  include/linux/nfsd/stats.h          |   8 +--
> >  include/linux/sunrpc/Kbuild         |   1 -
> >  include/linux/sunrpc/debug.h        |  39 +-----------
> >  include/uapi/linux/nfsd/Kbuild      |   5 ++
> >  include/{ => uapi}/linux/nfsd/cld.h |   0
> >  include/uapi/linux/nfsd/debug.h     |  40 ++++++++++++
> >  include/uapi/linux/nfsd/export.h    |  58 +++++++++++++++++
> >  include/uapi/linux/nfsd/nfsfh.h     | 122 ++++++++++++++++++++++++++++++++++++
> >  include/uapi/linux/nfsd/stats.h     |  17 +++++
> >  include/uapi/linux/sunrpc/Kbuild    |   1 +
> >  include/uapi/linux/sunrpc/debug.h   |  48 ++++++++++++++
> >  15 files changed, 296 insertions(+), 242 deletions(-)
> >  rename include/{ => uapi}/linux/nfsd/cld.h (100%)
> >  create mode 100644 include/uapi/linux/nfsd/debug.h
> >  create mode 100644 include/uapi/linux/nfsd/export.h
> >  create mode 100644 include/uapi/linux/nfsd/nfsfh.h
> >  create mode 100644 include/uapi/linux/nfsd/stats.h
> >  create mode 100644 include/uapi/linux/sunrpc/debug.h
> 
> These files look like they are mainly NFS server related, so perhaps it
> is better to merge through Bruce's tree.
> 
> Bruce?

Sure, I'll take it, thanks.

--b.
