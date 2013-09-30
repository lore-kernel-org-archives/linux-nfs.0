Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:42620
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755355Ab3I3XzA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Sep 2013 19:55:00 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Bruce Fields'" <bfields@fieldses.org>
Cc: "'Kernel NFS List'" <linux-nfs@vger.kernel.org>,
        "'Ganesha NFS List'" <nfs-ganesha-devel@lists.sourceforge.net>
References: <003301cebe09$5bf81090$13e831b0$@mindspring.com> <20130930221126.GD26382@fieldses.org>
In-Reply-To: <20130930221126.GD26382@fieldses.org>
Subject: RE: pynfs updates
Date: Mon, 30 Sep 2013 19:54:52 -0400
Message-ID: <003f01cebe38$75436480$5fca2d80$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Thanks!  A few questions:
> 
> 	- "4.1 server tests: Fix some exception handling": could you
> 	  include in the changelog and explanation of what problem this
> 	  fixes?  (And ditto, maybe, for the following commit?)

Ok, I'll re-examine those. They were some things I stumbled on as I tried to
resolve some other issues with pynfs.

> 	- "Fix SEQ9d to work in home directory instead of root": did you
> 	  intend to include the chunk in nfs4.1/nfs4lib.py?  It looks
> 	  irrelevant.

Hmm, will fix that.

> 	- "Add two SECINFO_NO_NAME tests for
> SECINFO_STYLE4_PARENT":
> 		- SECNN3: is / required to have no parent?  (I'd assumed
> 		  here that it would also be OK to follow the convention
> 		  that / is its own parent, but I'll admit to not having
> 		  thought about this much.)

>From LOOKUPP:

18.14.3. DESCRIPTION
The current filehandle is assumed to refer to a regular directory or
a named attribute directory. LOOKUPP assigns the filehandle for its
parent directory to be the current filehandle. If there is no parent
directory, an NFS4ERR_NOENT error must be returned. Therefore,
NFS4ERR_NOENT will be returned by the server when the current
filehandle is at the root or top of the server's file tree.

>From SECINFO_NO_NAME:

18.45.3. DESCRIPTION

...

If the style selected is SECINFO_STYLE4_PARENT,
then SECINFO should apply the same access methodology used for
LOOKUPP when evaluating the traversal to the parent directory.

...

If SECINFO_STYLE4_PARENT is specified and there is no parent
directory, SECINFO_NO_NAME MUST return NFS4ERR_NOENT.


> 		- SECNN4: is env.home necessarily unequal to "/"?  Would
> 		  seem better to do the lookup in a subdirectory just to
> 		  be certain.

Env.home is the directory you specify on the command line, I think the
presumption is that it is a writeable file system. Pynfs creates tmp and
tree directories in home (and maybe some files also?). Guess if / was
writeable, you could specify /, so yea, maybe it should go into tmp.

A better test might actually be to do LOOKUP down to home and even into tmp,
looking for a junction, and then do the SECINFO_NO_NAME(parent) on the
directory handle just across the junction if one was found.

Thanks for the review.

Frank

