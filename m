From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] enhanced lookup ESTALE error handling (v3)
Date: Mon, 10 Mar 2008 21:12:09 -0700
Message-ID: <20080310211209.19a25c75.akpm@linux-foundation.org>
References: <4790C761.1010603@redhat.com>
	<47A387CF.70201@redhat.com>
	<47D598C5.7080609@redhat.com>
	<20080310143832.08ad52a9.akpm@linux-foundation.org>
	<E1JYq5I-0000D9-8a@pomaz-ex.szeredi.hu>
	<1205187584.8385.6.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Miklos Szeredi <miklos@szeredi.hu>, staubach@redhat.com,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	trond.myklebust@fys.uio.no, linux-fsdevel@vger.kernel.org,
	viro@zeniv.linux.org.uk, hch@lst.de
To: Dave Hansen <haveblue@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46432 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750847AbYCKEOJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Mar 2008 00:14:09 -0400
In-Reply-To: <1205187584.8385.6.camel-FpcvD5N4B9G9xGwK5P7XA+TW4wlIGRCZ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 10 Mar 2008 15:19:44 -0700 Dave Hansen <haveblue@us.ibm.com> wrote:

> On Mon, 2008-03-10 at 23:03 +0100, Miklos Szeredi wrote:
> > > > This is a patch to enhance ESTALE error handling during the
> > > > lookup process.  The error, ESTALE, can occur when out of data
> > > > dentries, stored in the dcache, is used to translate a pathname
> > > > component to a dentry.  When this occurs, the dentry which
> > > > contains the pointer to the inode which refers to the non-existent
> > > > file is dropped from the dcache and then the lookup process
> > > > started again.  Care is taken to ensure that forward process is
> > > > always being made.  If forward process is not detected, then the
> > > > lookup process is terminated and the error, ENOENT, is returned
> > > > to the caller.
> > > 
> > > This collides in non-trivial ways with the always-coming-never-arrives
> > > r-o-bind-mounts patches.
> > > 
> > > I have an old version of those patches in -mm and I believe that Al
> > > is/was/has set up some git tree with these patches and perhaps other stuff.
> 
> Al's tree is here:
> 
> http://git.kernel.org/gitweb.cgi?p=linux/kernel/git/viro/vfs-2.6.git;a=summary
> 
> It's probably best to try and base your patches on top of there.  
> 

Al has a unique versioning scheme which I am not smart enough to
understand, so I'd be reluctant to pick this up without coordinating with
him.

afacit the "b1" branch there is the latest, but it doesn't appear to have
been touched for a couple of weeks.

