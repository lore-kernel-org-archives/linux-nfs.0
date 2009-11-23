From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: XFS, NFS and inode64 on 2.6.27
Date: Mon, 23 Nov 2009 10:51:09 -0500
Message-ID: <20091123155109.GA3292@fieldses.org>
References: <200911231419.50678@zmi.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: Michael Monnerie <michael.monnerie@is.it-management.at>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59056 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752250AbZKWPu0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Nov 2009 10:50:26 -0500
In-Reply-To: <200911231419.50678-xqLQU7OFoCs@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 23, 2009 at 02:19:50PM +0100, Michael Monnerie wrote:
> after searching for a long time I guess I found that inode64 on XFS w=
ith=20
> kernel 2.6.27 (shipped with openSUSE 11.1) is incompatible with NFS.=20
> Sorry if this was already know, it wasn't for me and finding the prob=
lem=20
> was complicated.
>=20
> This is my nfs4 root (fsid=3D0):
>=20
> # ls -li
> insgesamt 0
> 4666 drwxr-xr-x 2 root root 48 15. Nov 19:54 daten
> 4668 drwxr-xr-x 2 root root 48 15. Nov 19:54 download2
> 4667 drwxr-xr-x 2 root root 48 15. Nov 19:54 dvd-images
> 4661 drwxr-xr-x 2 root root 48 19. Nov 06:51 mailsrv-backup
> 4669 drwxr-xr-x 2 root root 48 15. Nov 19:54 q
> 4670 drwxr-xr-x 2 root root 48 15. Nov 19:54 z
>=20
> Then I mount those subdirs (mount --bind ....) to fill it with the di=
rs=20
> I want to share:
>=20
> # ls -li
> insgesamt 20
>         256 drwxr-xr-x 14 root root  4096 19. Nov 03:01 daten
>  6454034730 drwxrwx---  3 zmi  users   61 26. M=C3=A4r 2009  download=
2
>     4070671 drwxr-xr-x  2 root root    76 13. Nov 12:17 dvd-images
>  6500330752 drwxr-xr-x  5 root root  4096  8. Nov 04:31 mailsrv-backu=
p
>  8591091465 drwxr-xr-x 17 root root  4096 12. Nov 02:01 q
>  2147483904 drwxrwx--- 31 zmi  bh    4096  7. Nov 09:58 z
>=20
> The shares "daten" and "dvd-images" can be mounted from other servers=
=2E

But not the other four directories?  What error do you get when you try=
?
What client are you using, and are you mounting with NFSv2, NFSv3, or
NFSv4?  Could we see a network trace of a failed mount?  (So, run

	tcpdump -s0 -wtmp.pcap

then attempt to mount one of the directories with a too-big inode
number, then kill tcpdump and send us tmp.pcap.)

--b.
