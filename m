From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/4] VFS: Add a VFS helper function
 vfs_remote_path_lookup()
Date: Tue, 31 Mar 2009 17:16:47 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0903311715110.4130@localhost.localdomain>
References: <cover.1238525532.git.Trond.Myklebust@netapp.com>  <3f1264127d431f695be25b940b477e3d287edc68.1238525532.git.Trond.Myklebust@netapp.com>  <alpine.LFD.2.00.0903311423280.6474@localhost.localdomain>  <1238539079.28445.103.camel@heimdal.trondhjem.org>
  <alpine.LFD.2.00.0903311540120.6474@localhost.localdomain> <1238542722.28445.154.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk,
	hch@infradead.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1238542722.28445.154.camel@heimdal.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Tue, 31 Mar 2009, Trond Myklebust wrote:
> 
> However, if your mount point filehandle has expired, then chances are
> that you'll probably have to look up all the filehandles in the mount
> path again too, so why should you cache all that information?

No, that' not the caching I was thinking about.

I meant literally just the "namespace" thing. Keeping that around as long 
as you have a export active. How many of those do you have on your average 
nfs server? Why not just create those nfsd namespaces once for each 
export at startup, and destroy them at exit.

			Linus
