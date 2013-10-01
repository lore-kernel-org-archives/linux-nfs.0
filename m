Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:44948 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751781Ab3JAPml (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Oct 2013 11:42:41 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Bruce Fields'" <bfields@fieldses.org>
Cc: "'Kernel NFS List'" <linux-nfs@vger.kernel.org>,
        "'Ganesha NFS List'" <nfs-ganesha-devel@lists.sourceforge.net>
References: <003301cebe09$5bf81090$13e831b0$@mindspring.com> <20130930221126.GD26382@fieldses.org> <003f01cebe38$75436480$5fca2d80$@mindspring.com> <20131001142601.GG26382@fieldses.org> <20131001143051.GH26382@fieldses.org>
In-Reply-To: <20131001143051.GH26382@fieldses.org>
Subject: RE: pynfs updates
Date: Tue, 1 Oct 2013 11:42:31 -0400
Message-ID: <007201cebebc$d83f4fc0$88bdef40$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> One more problem: CSID10 is failing against the Linux server with
> NFS4ERR_TOO_MANY_OPS, because each of those lookups is actually a full
> lookup from PUTROOTFH to /, resulting in 17 ops on my setup.  Could we
> maybe work relative to the parent directory instead?

Sure, I'll rework that one.

> > A better test might actually be to do LOOKUP down to home and even
> > into tmp, looking for a junction, and then do the
> > SECINFO_NO_NAME(parent) on the directory handle just across the
> junction if one was found.
> 
> Yeah it'd be nice to check that cross-filesystem case but I don't think
it's
> necessary (and you still have to deal with the case where a mountpoint's
not
> found).

Well, the cross file system case is actually where you would need to use
SECINFO_NO_NAME. For some reason, you just have a handle to a directory
inside the export and want to navigate back up the tree. In doing so, you
cross back over a junction to a file system that is exported with a
different security flavor.

On the other hand, generally that higher level file system should include
all the security flavors used by the lower level file systems. Unless
SECINFO_NO_NAME lets you cross a junction where the new file system doesn't
have security flavors in common with the upper level file system, but I
don't think it does. Does anyone know the rationale of SECINFO_NO_NAME
(parent)? In fact is there really any use of SECINFO_NO_NAME other than to
get the secinfo for the root or public file handle? I guess it does also
allow a client to recover from the security flavors for a given file system
being changed on the fly (or perhaps after a migration event).

> If tests at mountpoints were useful perhaps we could pass in a mountpoint
> on the commandline.  Or add some sort of export-configuration interface to
> the serverhelper script and let pynfs setup exports itself.

Frank


