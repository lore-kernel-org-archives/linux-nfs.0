Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:43549 "EHLO
	prv3-mh.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754879AbcEDX5R (ORCPT
	<rfc822;groupwise-linux-nfs@vger.kernel.org:0:0>);
	Wed, 4 May 2016 19:57:17 -0400
From: NeilBrown <nfbrown@novell.com>
To: David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org
Date: Thu, 05 May 2016 09:56:58 +1000
Cc: linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 1/6] statx: Add a system call to make enhanced file info available
In-Reply-To: <20160429125743.23636.85219.stgit@warthog.procyon.org.uk>
References: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk> <20160429125743.23636.85219.stgit@warthog.procyon.org.uk>
Message-ID: <87vb2tbcmt.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Fri, Apr 29 2016, David Howells wrote:

> Add a system call to make extended file information available, including
> file creation time, inode version and data version where available through
> the underlying filesystem.
>
>
> ========
> OVERVIEW
> ========

I think all this documentation is invaluable - thanks.
I would really like to see much of it in
    Documentation/filesystems/something.txt
rather than just in the commit log.

>
> The defined bits in the st_information field give local system data on a
> file, how it is accessed, where it is and what it does:

These bits form a channel for communication between the filesystem
developer and the application writer.  As such we should be sure that
channel actually communicates meaning...


>
> 	STATX_INFO_ENCRYPTED		File is encrypted
> 	STATX_INFO_TEMPORARY		File is temporary

What is "temporary"?  Is it a statement about quality of storage
technology (will be destroyed by reboot) or intention of creator
(created with O_TMPFILE) or something else?


> 	STATX_INFO_FABRICATED		File was made up by filesystem
> 	STATX_INFO_KERNEL_API		File is kernel API (eg: procfs/sysfs)

What is the difference between these two?  Both are synthesized by the
kernel.
Maybe the "KERNEL_API" is declared never to change its meaning, while the
fabricated one doesn't make a "stable API" promise?

What is the difference between fabricating a file from a bunch of blocks
spread over a storage device, and fabricating a file from a single field
in the super-block?


> 	STATX_INFO_REMOTE		File is remote

How far is "remote"?  Does Infiniband count?  Fibre channel?  iSCSI?
Is a file on a loop-back mounted NFS filesystem more remote than a
fibre-channel connection to the next town?

Or is this relative?  Within a filesystem there are "remote" files and
"non-remote" files and the distinction is filesystem-dependant??

> 	STATX_INFO_AUTOMOUNT		Dir is automount trigger
> 	STATX_INFO_AUTODIR		Dir provides unlisted automounts

I think this last one means that there are names in the directory which
may not appear in "readdir" but will respond to "stat".  I would prefer
the description to match the behavior without necessarily implying that
those names will be automounts.  e.g
        STATX_INFO_INCOMPLETE_READDIR   getdents may not report all
                                        names that respond to stat

> 	STATX_INFO_NONSYSTEM_OWNERSHIP	File has non-system ownership details

This probably is a well defined meaning that I just don't have the
context to understand.  For me, more words would help here.


I don't object to any of these flag.  I just want to be sure that I
understand them.
I am generally in favour this functionality going in promptly.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXKoxKAAoJEDnsnt1WYoG5O6sQAIsr3Edm/d0x/1lRFCMxU5oC
nS0AopKDb/dsOf69nkQhXjKGXqFpbnTOkNY4+MJj1u1x2rJxZ3t0qxu6Om99JgYd
6dYRqlIBglKiZa5XC7FMoR8l9nnZuEJ8O8FP3P53fEOMgcPZbTiBW3O/MbECLJH8
eTKm03+sQmyaikhEZdcbubPnf9hEFH9NCWpM39zVauQDA+xxf7M4Szl03gX8tExK
70Hz3KWE7peAaQtUs6LK9ElDF9WDs5jygpqSksN3MIRsnu++O/FX7w9ECTCBCC7L
Md/G+iAuysPdtAy6lPmT82N/L2Ejdav5d9IbbDZ9zyUN1xNuJItWqqaWxC1dZCwU
UXfhGYUnvkfJANwef+riX8DduTeYubJ/KW02z8BhSWoeSY+byHjapl8rJZ1EgiK8
m1p+8L36H3ntqzwIrVwrceJVkNX/73O5mZ744rAY2dQMp+hzLNPmsp9/Na66q3/B
u75lUGQodhUy4YxkA5R5uxDGbfhrHRg+QHFuzMfx63BmeKQ2y7YWVRAcLtQJjcEK
q0eJ5nvh14T3pcTzG4qy0kQrhftR53PqGoJJhzCJ+88qT+JPlXxvkEI19d/I/fgS
kTQeNYBQ73fGJfrO4bDFj/T4il1Rw21deR5F4uzE4xVwVvBklObjx8FZ4z8adJyI
X0yuwcfJsMQjiqpkgGeY
=jgAp
-----END PGP SIGNATURE-----
--=-=-=--
