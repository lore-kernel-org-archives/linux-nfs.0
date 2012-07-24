Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37958 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755149Ab2GXUJf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jul 2012 16:09:35 -0400
Date: Tue, 24 Jul 2012 16:09:32 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Nico Williams <nico@cryptonector.com>
Cc: "Haynes, Tom" <thomas@netapp.com>, linux-nfs@vger.kernel.org,
        nfsv4@ietf.org
Subject: Re: [nfsv4] Constructing a NFSv4 ACL from POSIX mode bits
Message-ID: <20120724200932.GM8570@fieldses.org>
References: <20120724193348.GA4977@netapp.com>
 <CAK3OfOji009CP88tDNOp-nvdPBkvp0oKfJUqhO_TYuZktwhUCg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAK3OfOji009CP88tDNOp-nvdPBkvp0oKfJUqhO_TYuZktwhUCg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 24, 2012 at 03:00:57PM -0500, Nico Williams wrote:
> On Tue, Jul 24, 2012 at 2:33 PM, Haynes, Tom <thomas@netapp.com> wrote:
> > Bruce,
> >
> > In looking at http://tools.ietf.org/html/draft-ietf-nfsv4-acl-mapping-05, it
> > states that when mapping the write bit, only for the owner do we set
> > ACE4_WRITE_ACL.
> >
> > Back in version 00, it is open as to whether we can also set it for the
> > group and other if they have the write bit set.
> >
> > I looked back at the NFSv4 WG aliases and I see some discussion from Lisa
> > on how Solaris only ever sets it for the owner due to POSIX restrictions
> > via chmod(). So, now I know how another server does it.
> 
> This has changed.  I wrote this up here:
> 
> http://cryptonector.com/2011/11/zfs-aclchmod-interactions-in-solaris-11/
> 
> IIRC all ACEs for anything other than OWNER@ (or a user of the same
> name/ID) contribute to the group bits of the mode, the EVERYONE@ entry
> contributes to the world bits of the mode, and the OWNER@ and/or user
> ACEs for the owner name/ID contribute to the owner bits of the mode.
> 
> The new scheme is really much simpler and more natural than everything
> else tried before.

Sounds reasonable.

But Tom was asking above only about ACE4_WRITE_ACL.  And possibly only
in the legacy case.  (Does ZFS have a real ACE4_WRITE_ACL bit?)

--b.
