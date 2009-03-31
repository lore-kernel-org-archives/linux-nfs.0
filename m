From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/4] VFS: Add a VFS helper function
 vfs_remote_path_lookup()
Date: Tue, 31 Mar 2009 14:40:15 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0903311423280.6474@localhost.localdomain>
References: <cover.1238525532.git.Trond.Myklebust@netapp.com> <3f1264127d431f695be25b940b477e3d287edc68.1238525532.git.Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk,
	hch@infradead.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48433 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751191AbZCaVn5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Mar 2009 17:43:57 -0400
In-Reply-To: <3f1264127d431f695be25b940b477e3d287edc68.1238525532.git.Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Wed, 11 Mar 2009, Trond Myklebust wrote:
>
> This patch therefore defines a VFS helper function that sets up a temporary
> mount namespace to represent the server namespace, and has the current
> task pivot into that prior to doing the path lookup. Upon completion, it
> pivots back into the original namespace, and destroys the private one.

This is disgusting.

Why don't you just create the namespace once?

Also, why do you need that disgusting pivot thing, when we could instead 
trivially just add a 

	struct filesystem *fs;

into the nameidata, and then we can initialize it to

	nd->fs = current->fs

and make all the path walkers use that.

Or we could even try to clean up that horrid AT_FDCWD mess, and drop the 
whole "dfd" passing to "do_path_lookup()", and instead do

	rwlock_t *lock;
	struct path *root, *pwd;

and do

	nd->lock = &current->fs->lock;
	nd->root = &current->fs->root;
	nd->pwd =  &current->fs->pwd;

to initialize things. Then drop dfd as an argument entirely from 
path_lookup_open() and do_path_lookup(), and just have the caller 
initialize the nameidata (the only caller that doesn't use fs->pwd 
currently is do_filp_open(), which takes that 'dfd' and could just 
initialize nd->pwd to the right thing.

I dunno. This is very Al Viroish country, but I really hate how your patch 
looks. 99% of it is just working around the fact that you want some very 
_slight_ differences to how that special '/' thing is handled.

It's not worth doing these kinds of hacks for that.

And I think it's positively _wrong_ to have a function that creates and 
destroys the whole "struct fs_struct" and a namespace for just one call. 
Even if you don't think it's at all performance-critical, the interface is 
too damn ugly. Have separate "create/destroy context" functions, so that 
you _can_ do it just once, and have multiple calls in between.

Even if you personally don't happen to care.

			Linus
