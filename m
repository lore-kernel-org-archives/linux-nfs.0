Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47897 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751410Ab2KFNHK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Nov 2012 08:07:10 -0500
Date: Tue, 6 Nov 2012 08:07:06 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: [PATCH v3] SUNRPC: set desired file system root before
 connecting local transports
Message-ID: <20121106130705.GC6718@fieldses.org>
References: <20121008105437.18668.99905.stgit@localhost.localdomain>
 <20121009193506.GA19680@fieldses.org>
 <5098E31A.5080801@parallels.com>
 <20121106120642.GA6718@fieldses.org>
 <20121106124035.GA20522@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121106124035.GA20522@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 06, 2012 at 07:40:35AM -0500, Christoph Hellwig wrote:
> On Tue, Nov 06, 2012 at 07:06:42AM -0500, J. Bruce Fields wrote:
> > On Tue, Nov 06, 2012 at 02:14:50PM +0400, Stanislav Kinsbursky wrote:
> > > 09.10.2012 23:35, J. Bruce Fields ??????????:
> > > >Cc'ing Eric since I seem to recall he suggested doing it this way?
> > > >
> > > >Seems OK to me, but maybe that swap_root should be in common code?  (Or
> > > >maybe we could use set_fs_root()?)
> > > >
> > > 
> > > This patch is not good since, as Eric mentioned, all kernel threads
> > > share same fs struct.
> > > We can swap whole fs struct. Or we can unshare fs struct
> > > (unshare_fs_struct() is exported) and swap root in this case.
> > > But this approach is to close to set_fs_root() logic, which is not
> > > exported and seems there are some valid reasons for it.
> > 
> > What are those reasons?
> > 
> > Googling found one previous thread:
> > 
> > 	http://thread.gmane.org/gmane.linux.kernel/1259986/focus=47687
> > 
> > There Trond requests an ACK from Al or Cristoph for the export, but I
> > don't see either an ACK or any objection.
> 
> I really don't think messing with current->fs for workqueue worker
> threads is a good idea, as the worker threads are shared by different
> workqueues and thus this can easily cause havoc for entirely unrelated
> subsystems.

So you're worried that a bug in the nfs code could modify the root and
then not restore it?

--b.

> 
> To do this properly you'll need to avoid current->fs references in the
> sunrpc code.
> 
> And just in case it wasn't clear: the hack in this iteration is even
> worse than the original.
