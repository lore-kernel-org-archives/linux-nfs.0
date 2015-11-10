Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35295 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754609AbbKJRHF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Nov 2015 12:07:05 -0500
Date: Tue, 10 Nov 2015 12:07:03 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve French <smfrench@gmail.com>
Cc: Andreas Gruenbacher <agruenba@redhat.com>,
        Christoph Hellwig <hch@infradead.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        XFS Developers <xfs@oss.sgi.com>, LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH v15 00/22] Richacls (Core and Ext4)
Message-ID: <20151110170703.GB17530@fieldses.org>
References: <1447067343-31479-1-git-send-email-agruenba@redhat.com>
 <20151110112943.GA17038@infradead.org>
 <CAHc6FU5g7=wd1Wt4+GCaLJjNu7giruZyAON3VcYn-A=ffYMsmw@mail.gmail.com>
 <CAH2r5ms1ckC59o9sbBEBAWQA0Q3tGOs=YJpk01xg19zThJDt-w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAH2r5ms1ckC59o9sbBEBAWQA0Q3tGOs=YJpk01xg19zThJDt-w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 10, 2015 at 10:43:46AM -0600, Steve French wrote:
> On Tue, Nov 10, 2015 at 6:39 AM, Andreas Gruenbacher
> <agruenba@redhat.com> wrote:
> > On Tue, Nov 10, 2015 at 12:29 PM, Christoph Hellwig <hch@infradead.org> wrote:
> >> On Mon, Nov 09, 2015 at 12:08:41PM +0100, Andreas Gruenbacher wrote:
> >>> Here is another update to the richacl patch queue.  This posting contains
> >>> the patches ready to be merged; the patches later in the queue still need
> >>> some more review.
> <snip>
> >> and still abuses xattrs instead of a proper syscall interface.
> >> That's far from being ready to merge.
> >
> > The xattr syscall interface is what's used for very similar kinds of
> > things today; using it for richacls as well sure does not count as
> > abuse. Things could be improved in the xattr interface and in its
> > implementation, but we need more substantial reasons than that for
> > reimplementing the wheel once again.
> 
> I don't have strong disagreement with using pseudo-xattrs to
> store/retrieve ACLs (we already do this) but retrieving/setting an ACL
> all at once can be awkward  when ACLs are quite large e.g. when it
> encodes to over 1MB

At least in the NFS case, that's also a limitation of the protocol.  If
we really wanted to support massive ACLs then we'd need both syscall and
NFS interfaces to allow incrementally reading and writing ACLs, and I
don't even know what those would look like.

So this is a fine limitation as far as I'm concerned.

> (not all administrators think about the size of
> ACLs when they add hundreds of users or groups or apps to ACLs).
> 
> The bigger problem is that when ACLs are created -- after -- the file
> is created there is a potential race (harder to deal with in cluster
> and network file systems).   Ideally we should be able to optionally
> pass all the security information needed to create a file in the
> create call itself.  For apps which don't care they can continue to
> use the old syscalls.

That would be most of them, I'd think.

But I suppose windows apps (via Samba or Wine?) could use this.

Definitely a project for another day, in any case.

--b.

> In cifs.ko I still need to enable the SMB3 ACL helper functions
> (currently only enabled for the older cifs dialect) since that will
> make it easier, and figure out a way to allow helper tools to view
> "claims based ACLs" (DAC), not just traditional
> CIFS/NTFS/SMB3/RichACLs.
> -- 
> Thanks,
> 
> Steve
