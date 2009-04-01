From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/4] VFS: Add a VFS helper function
 vfs_remote_path_lookup()
Date: Tue, 31 Mar 2009 18:04:45 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0903311803260.4130@localhost.localdomain>
References: <cover.1238525532.git.Trond.Myklebust@netapp.com>  <3f1264127d431f695be25b940b477e3d287edc68.1238525532.git.Trond.Myklebust@netapp.com>  <alpine.LFD.2.00.0903311423280.6474@localhost.localdomain>  <1238539079.28445.103.camel@heimdal.trondhjem.org>
  <alpine.LFD.2.00.0903311540120.6474@localhost.localdomain>  <1238542722.28445.154.camel@heimdal.trondhjem.org>  <alpine.LFD.2.00.0903311715110.4130@localhost.localdomain> <1238547065.28445.178.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk,
	hch@infradead.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34362 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752734AbZDABIX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Mar 2009 21:08:23 -0400
In-Reply-To: <1238547065.28445.178.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Tue, 31 Mar 2009, Trond Myklebust wrote:
> 
> None of this is running on the server. The private namespace is being
> created on the NFSv4 client, which only needs to resolve a mount path as
> part of a sys_mount() call.

Ahh. A light goes on. So it realy does end up being a once-only thing. I 
didn't look at the users, and assumed that "server side" implied nfsd.

		Linus
