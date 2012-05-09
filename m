Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:37867
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756547Ab2EILUn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 May 2012 07:20:43 -0400
Date: Wed, 9 May 2012 07:19:58 -0400
From: Christoph Hellwig <hch@infradead.org>
To: David Howells <dhowells@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>, adilger@dilger.ca,
        bfields@fieldses.org, smfrench@gmail.com, ben@decadent.org.uk,
        Trond.Myklebust@netapp.com, roland@hack.frob.com, jra@samba.org,
        bernd.schubert@itwm.fraunhofer.de, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Subject: Re: Extended file stat: Splitting file- and fs-specific info?
Message-ID: <20120509111958.GA11345@infradead.org>
References: <20120509002420.GL5091@dastard>
 <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
 <16281.1336508382@redhat.com>
 <20170.1336555274@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170.1336555274@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 09, 2012 at 10:21:14AM +0100, David Howells wrote:
> Dave Chinner <david@fromorbit.com> wrote:
> 
> > I don't think we want to expose the inode generation numbers. It is
> > trivial to construct NFS file handles (usually just fsid, inode
> > number and generation) with that information and hence bypass
> > security checks to access files.
> 
> I was asked for it by Bernd Schubert for userspace NFS servers and FUSE -
> maybe he can say what he wants it for.

It's entirely broken, as a generation number might be part of the file
handle (and for Linux-like filesystems normally is), but it's entirely
up to the filesystem to decide how it works.  That's why we added system
calls to do operations on opaque file handles that the file system
controls.  Exposing a completely meaningless "generation" is a bad idea.

