Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:38030
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756897Ab2EIMF4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 May 2012 08:05:56 -0400
Date: Wed, 9 May 2012 08:05:44 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: Christoph Hellwig <hch@infradead.org>, David Howells <dhowells@redhat.com>,
        Dave Chinner <david@fromorbit.com>, adilger@dilger.ca,
        bfields@fieldses.org, smfrench@gmail.com, ben@decadent.org.uk,
        Trond.Myklebust@netapp.com, roland@hack.frob.com, jra@samba.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-ext4@vger.kernel.org, linux-api@vger.kernel.org,
        libc-alpha@sourceware.org
Subject: Re: Extended file stat: Splitting file- and fs-specific info?
Message-ID: <20120509120544.GA17535@infradead.org>
References: <20120509002420.GL5091@dastard>
 <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
 <16281.1336508382@redhat.com>
 <20170.1336555274@redhat.com>
 <20120509111958.GA11345@infradead.org>
 <4FAA5B24.1020306@itwm.fraunhofer.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FAA5B24.1020306@itwm.fraunhofer.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 09, 2012 at 01:55:16PM +0200, Bernd Schubert wrote:
> The basic idea of generation numbers is to check if an inode was
> recycled, so only if the tuple of inode-number and generation-number
> matches we still have the same file. Kernel nfs

NFS does not and should not look at the inode generation.  Except for a
bit of legacy code for the old pre-Linux 2.4 filehandles it looks at the
opaque file handle returned and only interpreted by the filesystem.  Any
userspace NFS server should do the same.
