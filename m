Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48065 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752543AbaDEMvu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Apr 2014 08:51:50 -0400
Date: Sat, 5 Apr 2014 08:51:43 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Toralf =?ISO-8859-1?B?RvZyc3Rlcg==?= <toralf.foerster@gmx.de>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: NFSv2 directory cannot longer be exported in 3.14, 3.13 works
 fine
Message-ID: <20140405085143.59e578ff@tlielax.poochiereds.net>
In-Reply-To: <533FF457.5080907@gmx.de>
References: <533F2ABF.2030107@gmx.de>
	<533FF457.5080907@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 05 Apr 2014 14:17:27 +0200
Toralf Förster <toralf.foerster@gmx.de> wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA256
> 
> On 04/04/2014 11:57 PM, Toralf Förster wrote:
> > At a user mode linux image (32 bit Gentoo Linux) the recent kernel gives this error while trying to mount a NFSv2 directory:
> > mount.nfs: mount point /mnt/nfsv2 is not a directory
> > 
> 
> A bisect points to :
> 
> 6e14b46b91fee8a049b0940333ce13a820beaaa5 is the first bad commit
> commit 6e14b46b91fee8a049b0940333ce13a820beaaa5
> Author: Albert Fluegel <af@muc.de>
> Date:   Mon Nov 18 12:18:01 2013 -0500
> 
>     nfsd: don't return high mode bits
> 
>     The Linux NFS server replies among other things to a "Check access permission"
>     the following:
> 
>     NFS:    File type = 2 (Directory)
>     NFS:    Mode = 040755
> 
>     A netapp server replies here:
>     NFS:    File type = 2 (Directory)
>     NFS:    Mode = 0755
> 
>     The RFC 1813 i read:
>        fattr3
> 
>           struct fattr3 {
>              ftype3     type;
>              mode3      mode;
>              uint32     nlink;
>     ...
>     For the mode bits only the lowest 9 are defined in the RFC
> 
>     As far as I can tell, knfsd has always done this, so apparently it's harmless.
>     Nevertheless, it appears to be wrong.
> 
>     Note this is already correct in the NFSv4 case, only v2 and v3 need
>     fixing.
> 
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> :040000 040000 a60e55f5a9749db3977e12e8baa08d45fadba225 b982c02ec1069c5d969ccb71197e5569fe93b075 M fs
> 
> - -- 
> MfG/Sincerely
> Toralf Förster
> pgp finger print:1A37 6F99 4A9D 026F 13E2 4DCF C4EA CDDE 0076 E94E
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v2.0.22 (GNU/Linux)
> Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/
> 
> iF4EAREIAAYFAlM/9FcACgkQxOrN3gB26U5F1AD+JAP4cDM+rT9nk9Q8q681RywT
> Ejxq7d0tnVUfWyDFDTgA/1sIUtpv9GSK8SeAJFu7oAhMt4e6eeIdbpMT2qUEQv6q
> =Sles
> -----END PGP SIGNATURE-----
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

This was already tracked down earlier this week. Bruce has a patch
queued to fix it in his nfsd-next branch. See this thread from earlier
this week:

    Subject: Re: linux-3.14 nfsd regression

-- 
Jeff Layton <jlayton@redhat.com>
