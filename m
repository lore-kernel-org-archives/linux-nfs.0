Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44399 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753933Ab1I3Qoi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Sep 2011 12:44:38 -0400
Date: Fri, 30 Sep 2011 12:42:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Michal Schmidt <mschmidt@redhat.com>
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <trond@netapp.com>
Subject: Re: [PATCH] sunrpc: add MODULE_ALIAS to match the filesystem name
Message-ID: <20110930164259.GG19125@fieldses.org>
References: <20110701224712.12393.10369.stgit@localhost6.localdomain6>
 <20110706153324.GA30349@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110706153324.GA30349@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jul 06, 2011 at 11:33:24AM -0400, bfields wrote:
> On Sat, Jul 02, 2011 at 12:47:12AM +0200, Michal Schmidt wrote:
> > sunrpc implements the rpc_pipefs filesystem type.
> > Add the alias to have the module requested automatically by the kernel
> > when the filesystem is mounted.
> 
> Makes sense to me.--b.

Hm, don't see this in Trond's stuff so I'll queue it up with nfsd stuff
for 3.2.

--b.

> 
> > 
> > Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> > ---
> > 
> >  net/sunrpc/rpc_pipe.c |    3 +++
> >  1 files changed, 3 insertions(+), 0 deletions(-)
> > 
> > diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> > index 72bc536..c1d1996 100644
> > --- a/net/sunrpc/rpc_pipe.c
> > +++ b/net/sunrpc/rpc_pipe.c
> > @@ -1084,3 +1084,6 @@ void unregister_rpc_pipefs(void)
> >  	kmem_cache_destroy(rpc_inode_cachep);
> >  	unregister_filesystem(&rpc_pipe_fs_type);
> >  }
> > +
> > +/* Make 'mount -t rpc_pipefs ...' autoload this module. */
> > +MODULE_ALIAS("rpc_pipefs");
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
