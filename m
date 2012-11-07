Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47097 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753628Ab2KGSeD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Nov 2012 13:34:03 -0500
Date: Wed, 7 Nov 2012 13:33:55 -0500
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
Message-ID: <20121107183355.GA7421@fieldses.org>
References: <20121008105437.18668.99905.stgit@localhost.localdomain>
 <20121009193506.GA19680@fieldses.org>
 <5098E31A.5080801@parallels.com>
 <20121106120642.GA6718@fieldses.org>
 <20121106124035.GA20522@infradead.org>
 <20121106130705.GC6718@fieldses.org>
 <20121106131018.GA12211@infradead.org>
 <20121106133605.GD6718@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121106133605.GD6718@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 06, 2012 at 08:36:05AM -0500, J. Bruce Fields wrote:
> On Tue, Nov 06, 2012 at 08:10:18AM -0500, Christoph Hellwig wrote:
> > On Tue, Nov 06, 2012 at 08:07:06AM -0500, J. Bruce Fields wrote:
> > > So you're worried that a bug in the nfs code could modify the root and
> > > then not restore it?
> > 
> > At least the link you pointed to earlier never sets it back.
> 
> This? http://thread.gmane.org/gmane.linux.kernel/1259986/focus=47687
> 
> 	+	get_fs_root(current->fs, &root);
> 	+	set_fs_root(current->fs, &transport->root);
> 	+
> 	 	status = xs_local_finish_connecting(xprt, sock);
> 	+
> 	+	set_fs_root(current->fs, &root);
> 	+	path_put(&root);
> 
> > Instead
> > of messing with it I'd rather have the sunrpc code use vfs_path_lookup
> > and not care about current->fs->root at all.
> 
> The annoyance is that the lookup happens somewhere lower down in the
> networking code (net/unix/af_unix.c:unix_find_other, I think).  So we'd
> need some new (internal) API.  We'd likely be the only user of that new
> API.

So, if the only drawback is really just the risk of introducing a bug
that leaves the fs_root changed--the above seems simple enough for that
not to be a great risk, right?

Is there any other hazard to doing this that people can think of?

--b.
