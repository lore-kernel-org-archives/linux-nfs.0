Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.15.19]:62710 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752697AbaDENXL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Apr 2014 09:23:11 -0400
Message-ID: <534003B9.5020003@gmx.de>
Date: Sat, 05 Apr 2014 15:23:05 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: NFSv2 directory cannot longer be exported in 3.14, 3.13 works
 fine
References: <533F2ABF.2030107@gmx.de>	<533FF457.5080907@gmx.de> <20140405085143.59e578ff@tlielax.poochiereds.net>
In-Reply-To: <20140405085143.59e578ff@tlielax.poochiereds.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

On 04/05/2014 02:51 PM, Jeff Layton wrote:
> This was already tracked down earlier this week. Bruce has a patch 
> queued to fix it in his nfsd-next branch. See this thread from
> earlier this week:
> 
> Subject: Re: linux-3.14 nfsd regression
yep - fixed the issue here

- -- 
MfG/Sincerely
Toralf Förster
pgp finger print:1A37 6F99 4A9D 026F 13E2 4DCF C4EA CDDE 0076 E94E
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iF4EAREIAAYFAlNAA7kACgkQxOrN3gB26U5UiwD/X/ONRaFIMGyxHLZd7cwrN4zh
QADbpEhyT+N6KwH6m2wA/j++6yigdEtV7k9pjEWMwlCZUyT8reUbNzZOhxMl10+i
=WGBv
-----END PGP SIGNATURE-----
