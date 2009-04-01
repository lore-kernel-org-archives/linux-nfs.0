From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/4] VFS: Add a VFS helper function
 vfs_remote_path_lookup()
Date: Tue, 31 Mar 2009 20:51:05 -0400
Message-ID: <1238547065.28445.178.camel@heimdal.trondhjem.org>
References: <cover.1238525532.git.Trond.Myklebust@netapp.com>
	 <3f1264127d431f695be25b940b477e3d287edc68.1238525532.git.Trond.Myklebust@netapp.com>
	 <alpine.LFD.2.00.0903311423280.6474@localhost.localdomain>
	 <1238539079.28445.103.camel@heimdal.trondhjem.org>
	 <alpine.LFD.2.00.0903311540120.6474@localhost.localdomain>
	 <1238542722.28445.154.camel@heimdal.trondhjem.org>
	 <alpine.LFD.2.00.0903311715110.4130@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk,
	hch@infradead.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:60167 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756739AbZDAAvr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 20:51:47 -0400
In-Reply-To: <alpine.LFD.2.00.0903311715110.4130-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-03-31 at 17:16 -0700, Linus Torvalds wrote:
> 
> On Tue, 31 Mar 2009, Trond Myklebust wrote:
> > 
> > However, if your mount point filehandle has expired, then chances are
> > that you'll probably have to look up all the filehandles in the mount
> > path again too, so why should you cache all that information?
> 
> No, that' not the caching I was thinking about.
> 
> I meant literally just the "namespace" thing. Keeping that around as long 
> as you have a export active. How many of those do you have on your average 
> nfs server? Why not just create those nfsd namespaces once for each 
> export at startup, and destroy them at exit.

Wait, I'm confused now.

None of this is running on the server. The private namespace is being
created on the NFSv4 client, which only needs to resolve a mount path as
part of a sys_mount() call.

Unlike NFSv2/v3, there is no MOUNT protocol to translate an NFSv4 mount
path into a filehandle. Instead the client has an operation to fetch the
'root filehandle' (i.e. the filehandle representing 'mount -t nfs4
foo:/') and then does a series of LOOKUP rpc calls to resolve the rest
of the path.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
