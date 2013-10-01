Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50766 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753151Ab3JAO0C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Oct 2013 10:26:02 -0400
Date: Tue, 1 Oct 2013 10:26:01 -0400
From: "'Bruce Fields'" <bfields@fieldses.org>
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: "'Kernel NFS List'" <linux-nfs@vger.kernel.org>,
        "'Ganesha NFS List'" <nfs-ganesha-devel@lists.sourceforge.net>
Subject: Re: pynfs updates
Message-ID: <20131001142601.GG26382@fieldses.org>
References: <003301cebe09$5bf81090$13e831b0$@mindspring.com>
 <20130930221126.GD26382@fieldses.org>
 <003f01cebe38$75436480$5fca2d80$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <003f01cebe38$75436480$5fca2d80$@mindspring.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 30, 2013 at 07:54:52PM -0400, Frank Filz wrote:
> > 	- "Add two SECINFO_NO_NAME tests for
> > SECINFO_STYLE4_PARENT":
> > 		- SECNN3: is / required to have no parent?  (I'd assumed
> > 		  here that it would also be OK to follow the convention
> > 		  that / is its own parent, but I'll admit to not having
> > 		  thought about this much.)
> 
> >From LOOKUPP:
> 
> 18.14.3. DESCRIPTION
> The current filehandle is assumed to refer to a regular directory or
> a named attribute directory. LOOKUPP assigns the filehandle for its
> parent directory to be the current filehandle. If there is no parent
> directory, an NFS4ERR_NOENT error must be returned. Therefore,
> NFS4ERR_NOENT will be returned by the server when the current
> filehandle is at the root or top of the server's file tree.

OK, fine.

> > 		- SECNN4: is env.home necessarily unequal to "/"?  Would
> > 		  seem better to do the lookup in a subdirectory just to
> > 		  be certain.
> 
> Env.home is the directory you specify on the command line, I think the
> presumption is that it is a writeable file system. Pynfs creates tmp and
> tree directories in home (and maybe some files also?). Guess if / was
> writeable, you could specify /, so yea, maybe it should go into tmp.

Sounds good.

> 
> A better test might actually be to do LOOKUP down to home and even into tmp,
> looking for a junction, and then do the SECINFO_NO_NAME(parent) on the
> directory handle just across the junction if one was found.

Yeah it'd be nice to check that cross-filesystem case but I don't think
it's necessary (and you still have to deal with the case where a
mountpoint's not found).

If tests at mountpoints were useful perhaps we could pass in a
mountpoint on the commandline.  Or add some sort of export-configuration
interface to the serverhelper script and let pynfs setup exports itself.

--b.
