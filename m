Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from hr2.samba.org ([144.76.82.148]:64663 "EHLO hr2.samba.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750813AbcLFVhE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Dec 2016 16:37:04 -0500
Date: Tue, 6 Dec 2016 13:36:28 -0800
From: Jeremy Allison <jra@samba.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Andreas Gruenbacher <agruenba@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>, linux-cifs@vger.kernel.org,
        Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH v27 03/21] vfs: Add MAY_DELETE_SELF and MAY_DELETE_CHILD
 permission flags
Message-ID: <20161206213628.GD4498@jra3>
Reply-To: Jeremy Allison <jra@samba.org>
References: <1476190256-1677-1-git-send-email-agruenba@redhat.com>
 <1476190256-1677-4-git-send-email-agruenba@redhat.com>
 <CAELBmZCgttywPy3EtkFao7SPESaw8VB5K6x7PTRk7gwSk7sXqg@mail.gmail.com>
 <20161206201529.GA1203@fieldses.org>
 <20161206203347.GC4498@jra3>
 <CAJfpegsvoZfzUXyCJrxXAG6dxk8HMCGMEKA0E-6FzWNGkM17Tw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAJfpegsvoZfzUXyCJrxXAG6dxk8HMCGMEKA0E-6FzWNGkM17Tw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 06, 2016 at 10:25:22PM +0100, Miklos Szeredi wrote:
> On Tue, Dec 6, 2016 at 10:13 PM, Jeremy Allison <jra@samba.org> wrote:
> > On Tue, Dec 06, 2016 at 03:15:29PM -0500, J. Bruce Fields wrote:
> >> On Fri, Dec 02, 2016 at 10:57:42AM +0100, Miklos Szeredi wrote:
> >> > On Tue, Oct 11, 2016 at 2:50 PM, Andreas Gruenbacher
> >> > <agruenba@redhat.com> wrote:
> >> > > Normally, deleting a file requires MAY_WRITE access to the parent
> >> > > directory.  With richacls, a file may be deleted with MAY_DELETE_CHILD access
> >> > > to the parent directory or with MAY_DELETE_SELF access to the file.
> >> > >
> >> > > To support that, pass the MAY_DELETE_CHILD mask flag to inode_permission()
> >> > > when checking for delete access inside a directory, and MAY_DELETE_SELF
> >> > > when checking for delete access to a file itself.
> >> > >
> >> > > The MAY_DELETE_SELF permission overrides the sticky directory check.
> >> >
> >> > And MAY_DELETE_SELF seems totally inappropriate to any kind of rename,
> >> > since from the point of view of the inode we are not doing anything at
> >> > all.  The modifications are all in the parent(s), and that's where the
> >> > permission checks need to be.
> >>
> >> I'm having a hard time finding an authoritative reference here (Samba
> >> people might be able to help), but my understanding is that Windows
> >> gives this a meaning something like "may I delete a link to this file".
> >>
> >> (And not even "may I delete the *last* link to this file", which might
> >> also sound more logical.)
> >
> > I just did a recent patch here. In Samba we now check for
> > SEC_DIR_ADD_FILE/SEC_DIR_ADD_SUBDIR on the target directory
> > (depending on if the object being moved is a file or dir).
> 
> And MAY_DELETE_SELF as well, for rename?  That's really counterintuitive for me.

Yeah on the source handle we insist on DELETE_ACCESS|FILE_WRITE_ATTRIBUTES
permissions also.
