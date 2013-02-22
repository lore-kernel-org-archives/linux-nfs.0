Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54098 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758780Ab3BVSwy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Feb 2013 13:52:54 -0500
Date: Fri, 22 Feb 2013 13:52:52 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Dave Wysochanski <dwysocha@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: Don't allow NFS silly-renamed files to be deleted,
 no signal
Message-ID: <20130222135252.405bbdbf@tlielax.poochiereds.net>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9235DC4AF@SACEXCMBX04-PRD.hq.netapp.com>
References: <1361282391-6578-1-git-send-email-dwysocha@redhat.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA9235DC4AF@SACEXCMBX04-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 22 Feb 2013 18:02:06 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Tue, 2013-02-19 at 08:59 -0500, Dave Wysochanski wrote:
> > Commit 73ca100 broke the code that prevents the client from deleting
> > a silly renamed dentry.  This affected "delete on last close"
> > semantics as after that commit, nothing prevented removal of
> > silly-renamed files.  As a result, a process holding a file open
> > could easily get an ESTALE on the file in a directory where some
> > other process issued 'rm -rf some_dir_containing_the_file' twice.
> > Before the commit, any attempt at unlinking silly renamed files would
> > fail inside may_delete() with -EBUSY because of the
> > DCACHE_NFSFS_RENAMED flag.  The following testcase demonstrates
> > the problem:
> >   tail -f /nfsmnt/dir/file &
> >   rm -rf /nfsmnt/dir
> >   rm -rf /nfsmnt/dir
> >   # second removal does not fail, 'tail' process receives ESTALE
> 
> Hi Dave,
> 
> I'm not sure I understand why we must do the dropping/moving of the
> dentries inside nfs_async_rename_done. Why isn't something like the
> attached patch sufficient?
> 
> Cheers,
>   Trond
> 

That looks like a much simpler alternative. Nice work.

Acked-by: Jeff Layton <jlayton@redhat.com>
