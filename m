From: Clemens Schwaighofer <cs@tequila.co.jp>
Subject: Re: [PATCH] NFS using CacheFS
Date: Fri, 08 Oct 2004 13:36:32 +0900
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <41661950.5070508@tequila.co.jp>
References: <4161B664.70109@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net,
	Linux filesystem caching discussion list
	<linux-cachefs@redhat.com>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S267521AbUJHEgp@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <4161B664.70109@RedHat.com>
List-ID: <nfs.lists.sourceforge.net>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 10/05/2004 05:45 AM, Steve Dickson wrote:

| 3) There is no user level support. I realize this is extremely cheesy
|     but I noticed that the NFS posix mount  option (in the 2.6 kernel)
|     was no longer being used, so I high jacked it.  Which means
|     to make NFS to used CacheFS you need to use the posix option:
|
|     mount -o posix server:/export/home /mnt/server/home

brr :) why is it posix, this is so out of the context for me (as a
user). Is it possible to have a cachefs flag. Would make it more logical.

- --
[ Clemens Schwaighofer                      -----=====:::::~ ]
[ TBWA\ && TEQUILA\ Japan IT Group                           ]
[                6-17-2 Ginza Chuo-ku, Tokyo 104-0061, JAPAN ]
[ Tel: +81-(0)3-3545-7703            Fax: +81-(0)3-3545-7343 ]
[ http://www.tequila.co.jp        http://www.tbwajapan.co.jp ]
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBZhlPjBz/yQjBxz8RAtKbAKCLWJBqWQUcroSaLzlrH1r2nuqI8gCfUzyL
kpANJQ4pYt1026VBRm8UlpU=
=NGFC
-----END PGP SIGNATURE-----
