From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] enhanced lookup ESTALE error handling (v3)
Date: Mon, 10 Mar 2008 14:38:32 -0700
Message-ID: <20080310143832.08ad52a9.akpm@linux-foundation.org>
References: <4790C761.1010603@redhat.com>
	<47A387CF.70201@redhat.com>
	<47D598C5.7080609@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	trond.myklebust@fys.uio.no, linux-fsdevel@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christoph Hellwig <hch@lst.de>,
	Dave Hansen <haveblue@us.ibm.com>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55099 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751079AbYCJVsI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Mar 2008 17:48:08 -0400
In-Reply-To: <47D598C5.7080609@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 10 Mar 2008 16:23:33 -0400
Peter Staubach <staubach@redhat.com> wrote:

> This is a patch to enhance ESTALE error handling during the
> lookup process.  The error, ESTALE, can occur when out of data
> dentries, stored in the dcache, is used to translate a pathname
> component to a dentry.  When this occurs, the dentry which
> contains the pointer to the inode which refers to the non-existent
> file is dropped from the dcache and then the lookup process
> started again.  Care is taken to ensure that forward process is
> always being made.  If forward process is not detected, then the
> lookup process is terminated and the error, ENOENT, is returned
> to the caller.

This collides in non-trivial ways with the always-coming-never-arrives
r-o-bind-mounts patches.

I have an old version of those patches in -mm and I believe that Al
is/was/has set up some git tree with these patches and perhaps other stuff.

So some coordination is required please.  I'd suggest that if Al indeed
does have such a tree, he hand over the URL so I can get it into -mm and
that you then redo these patches on top of that.

Please also Cc Al and Christoph on these patches, as they are hitting files
which they maintain and develop.

Thanks.

