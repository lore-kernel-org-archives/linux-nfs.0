Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55694 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755199AbeEaOGT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 31 May 2018 10:06:19 -0400
Date: Thu, 31 May 2018 10:06:19 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Trond Myklebust <trondmy@hammerspace.com>,
        "agruenba@redhat.com" <agruenba@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "rgoldwyn@suse.de" <rgoldwyn@suse.de>,
        "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>
Subject: Re: nfs4_acl restricts copy_up in overlayfs
Message-ID: <20180531140619.GA1298@fieldses.org>
References: <f2af62fdf8a5bb185ec75cff118178d58b28ceb4.camel@hammerspace.com>
 <2cf94c6b-e819-79af-4ac9-3b19d26dc6d9@suse.de>
 <75266c983a03f6dbfd5d1a39c94fa6d56a1a8a22.camel@hammerspace.com>
 <a0617bb0-b7a5-fab2-c72c-595e005bd8f7@suse.de>
 <20180531004554.GA29116@fieldses.org>
 <CAJfpegtoLpwo6aA9=uF72UDaKvv_Q3bUbv778VwnSDa72yO9Mw@mail.gmail.com>
 <128c74cb1507d7eab36ac8d32182dbbc7d3f9f88.camel@hammerspace.com>
 <CAJfpeguK9rmXK4F7wkE8of7gwDTV_KbM4yWAW8iGJ0RvOMH0-g@mail.gmail.com>
 <e692f5a6f612660ad0a64e083ed7a1398629aa6d.camel@hammerspace.com>
 <CAJfpegsW7CwZYJf_EH80aaYotMMBDk1BjR_RA6dz8e=Y3-ox5w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAJfpegsW7CwZYJf_EH80aaYotMMBDk1BjR_RA6dz8e=Y3-ox5w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 31, 2018 at 03:30:04PM +0200, Miklos Szeredi wrote:
> On Thu, May 31, 2018 at 3:10 PM, Trond Myklebust
> <trondmy@hammerspace.com> wrote:
> > On Thu, 2018-05-31 at 14:55 +0200, Miklos Szeredi wrote:
> >> On Thu, May 31, 2018 at 2:47 PM, Trond Myklebust <trondmy@hammerspace.com> wrote:
> >> > I'm still in strong disagreement with the model you are presenting
> >> > here. It is a client enforced model, which is not ever going to be
> >> > compatible with the NFS model.
> >>
> >> It's the only sane model that overlayfs can do.
> >>
> >> Think of it this way:  creating an image file on NFS, formating it to
> >> ext4 and mounting it locally through the loop device is not going to
> >> be compatible with the NFS security model either.  Should we care?
> >
> > Yes you should care because you are proposing that the simple act of
> > mounting through overlayfs will change who can access, read and modify
> > existing files from a NFS server.
> 
> Only access/read: NFS can only be read-only layer.  So it's impossible
> to actually modify a file on NFS through overlayfs.

In addition to being read-only, I assume it's also unchanging?  I wonder
why you'd want to use NFS at all for this case--sharing a read-only
ext4-formatted block device would seem more straightforward.

Apologies if we've been through this before too, I've long ago paged out
any previous conversation....

> > The model for overlayfs and all unionfs should be that security is
> > enforced by the underlying filesystem _UNTIL_ the access mode is
> > modified on the top level filesystem.
> 
> How?
> 
> We've been through this.  We can't ask an NFS server exported
> read-only about what the permission to modify the filesystem would
> have been if it were exported read-write.  Sure, the protocol could be
> extended, etc, etc...  But it's just not a good fit.
> 
> >
> > IOW: if the user does a chmod, and that is authorised by the underlying
> > filesystem, then overlayfs is in charge of any further authorisation to
> > that file.
> > Adding richacls to that model means that you can attempt to copy the
> > ACL and allow the user to modify that instead of doing the chmod, but
> > the understanding should be that it's not the same ACL as was been
> > enforced by the server, so the copy up of the ACL should be treated as
> > a modification of the ACL (and should therefore first be subject to
> > authorisation by the server).
> 
> If someone adds the interface for access checking in the NFS client
> based on server sercurity model, but without actually having to do the
> request, and it works for read-only exports (which make a LOT of sense
> for the use cases where overlayfs may be used with NFS) then we can
> use that from overlayfs.  Last time Bruce looked this issue, he ran
> away screeming, IIRC.

In theory I suppose it's all possible, but I think the only practical
thing to do for now is just ignore NFSv4 ACLs.

--b.
