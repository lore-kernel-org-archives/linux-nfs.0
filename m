Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:32821 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752660AbbIKVot (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Sep 2015 17:44:49 -0400
Received: by ykei199 with SMTP id i199so104804925yke.0
        for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2015 14:44:49 -0700 (PDT)
Date: Fri, 11 Sep 2015 17:44:45 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, HPDD-discuss@ml01.01.org,
        ceph-devel@vger.kernel.org, cluster-devel@redhat.com,
        fuse-devel@lists.sourceforge.net, ocfs2-devel@oss.oracle.com
Subject: Re: [PATCH] nfsd: add a new EXPORT_OP_NOWCC flag to struct
 export_operations
Message-ID: <20150911174445.402d4dca@tlielax.poochiereds.net>
In-Reply-To: <20150911212957.GH11677@fieldses.org>
References: <1441966830-5517-1-git-send-email-jeff.layton@primarydata.com>
	<20150911212957.GH11677@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 11 Sep 2015 17:29:57 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Sep 11, 2015 at 06:20:30AM -0400, Jeff Layton wrote:
> > With NFSv3 nfsd will always attempt to send along WCC data to the
> > client. This generally involves saving off the in-core inode information
> > prior to doing the operation on the given filehandle, and then issuing a
> > vfs_getattr to it after the op.
> > 
> > Some filesystems (particularly clustered or networked ones) have an
> > expensive ->getattr inode operation. Atomicitiy is also often difficult
> > or impossible to guarantee on such filesystems. For those, we're best
> > off not trying to provide WCC information to the client at all, and to
> > simply allow it to poll for that information as needed with a GETATTR
> > RPC.
> > 
> > This patch adds a new flags field to struct export_operations, and
> > defines a new EXPORT_OP_NOWCC flag that filesystems can use to indicate
> > that nfsd should not attempt to provide WCC info in NFSv3 replies. It
> > also adds a blurb about the new flags field and flag to the exporting
> > documentation.
> > 
> > The server will also now skip collecting this information for NFSv2 as
> > well, since that info is never used there anyway.
> > 
> > Note that this patch does not add this flag to any filesystem
> > export_operations structures. This was originally developed to allow
> > reexporting nfs via nfsd. That code is not (and may never be) suitable
> > for merging into mainline.
> > 
> > Other filesystems may want to consider enabling this flag too. It's hard
> > to tell however which ones have export operations to enable export via
> > knfsd and which ones mostly rely on them for open-by-filehandle support,
> 
> Are there any in the latter class?  I'm not sure how or why you'd
> support open-by-filehandle without supporting nfs exports.
> 

I don't know. I'm not sure that there's any difference from a technical
standpoint. If you enable open by fh support, then you sort of get
knfsd exporting "for free".

That said, I imagine at least some of these filesystems are typically
exported by some sort of userland server instead of knfsd (ganesha or
whatnot), and for them knfsd v3 performance is not terribly critical
either way.

> > so I'm leaving that up to the individual maintainers to decide. I am
> > cc'ing the relevant lists for those filesystems that I think may want to
> > consider adding this though.
> 
> I'd definitely like to see evidence from maintainers of those
> filesystems that this would be useful to them.
> 

Agreed. If it turns out that there aren't any, then we can drop this
patch and I'll just plan to carry it privately.

-- 
Jeff Layton <jlayton@poochiereds.net>
