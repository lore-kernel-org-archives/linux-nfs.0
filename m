From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 19/19] exportfs: update documentation
Date: Fri, 14 Sep 2007 14:24:57 -0700
Message-ID: <20070914142457.d96c9924.randy.dunlap@oracle.com>
References: <20070914114928.GT28282@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
To: hch@lst.de
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070914114928.GT28282@lst.de>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, 14 Sep 2007 13:49:28 +0200 hch@lst.de wrote:

typos only below:


> Update deocumentation to the current state of affairs.  Remove duplicated
> method descruptions in exportfs.h and point to Documentation/filesystems/
> Exporting instead.  Add a little file header comment in expfs.c describing
> what's going on and mentioning Neils and my copyright [1].
> 
> [1] Neil, in case you want a different/additional attribution just change
>     the patch in your queue to reflect the preferred version.
> 
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> Index: linux-2.6/Documentation/filesystems/Exporting
> ===================================================================
> --- linux-2.6.orig/Documentation/filesystems/Exporting	2007-03-16 15:10:54.000000000 +0100
> +++ linux-2.6/Documentation/filesystems/Exporting	2007-03-16 17:11:50.000000000 +0100
> + encode_fh  (optinonal)

               (optional)

> +    Takes a dentry and creates a filehandle fragment which can later be used
> +    to find/create a dentry for the same object.  The default implementation
> +    creates a filehandle fragment that encodes a 32bit inode and generation
> +    number for the inode encoded, and if nessecary the same information for

                                            necessary

> +    the parent.
> +
> +  fh_to_dentry (mandatory)
> +    Given a filehandle fragment, this should find the implied object and
> +    create a dentry for it (possibly with d_alloc_anon).
> +
> +  fh_to_parent (optional but strongly recommended)
> +    Given a filehandle fragment, this should find the parent of the
> +    implied object and create a dentry for it (possibly with d_alloc_anon).
> +    May simplify fail if the filehandle fragment is too small.\

           simply  (?)

> +
> +  get_parent (optional but strongly recommended)
> +    When given a dentry for a directory, this should return  a dentry for
> +    the parent.  Quite possibly the parent dentry will have been allocated
> +    by d_alloc_anon.  The default get_parent function just returns an error
> +    so any filehandle lookup that requires finding a parent will fail.
> +    ->lookup("..") is *not* used as a default as it can leave ".." entries
> +    in the dcache which are too messy to work with.

> Index: linux-2.6/fs/exportfs/expfs.c
> ===================================================================
> --- linux-2.6.orig/fs/exportfs/expfs.c	2007-03-16 17:06:10.000000000 +0100
> +++ linux-2.6/fs/exportfs/expfs.c	2007-03-16 23:45:14.000000000 +0100
> @@ -1,4 +1,13 @@
> -
> +/*
> + * Copyright (C) Neil Brown 2002
> + * Copyright (C) Christoph Hellwig 2007
> + *
> + * This file contains the code mapping from inodes to NFS file handles,
> + * and for mapping back from file handles to dentries.
> + *
> + * For details on why we doo all the strange and hairy things in here

                            do

> + * take a look at Documentation/filesystems/Exporting.
> + */
>  #include <linux/exportfs.h>
>  #include <linux/fs.h>
>  #include <linux/file.h>


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
