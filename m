From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: mount issue with Mac OSX and --manage-gids, client hangs
Date: Thu, 31 Jul 2008 19:11:31 -0400
Message-ID: <76bd70e30807311611o327339dakd2de3577608897a4@mail.gmail.com>
References: <20080731204701.GE26609@samad.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Alex Samad" <alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:64622 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751746AbYGaXLe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Jul 2008 19:11:34 -0400
Received: by fg-out-1718.google.com with SMTP id 19so403496fgg.17
        for <linux-nfs@vger.kernel.org>; Thu, 31 Jul 2008 16:11:32 -0700 (PDT)
In-Reply-To: <20080731204701.GE26609-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 31, 2008 at 4:47 PM, Alex Samad <alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org> wrote:
> Hi
>
> I have a nfs debian amd64 server, with a few linux clients that is
> working well. I recently tried to attach a mac osx (10.5 Leopard)
> client.
>
> Everytime I attached it would hang when i attempted to use the mount
>
> on the nas box I have this line in /etc/exports
> /exports/shared
> -async,no_subtree_check,no_root_squash,insecure,mp=/exports/shared
> 192.168.8.0/22(rw)

One comment: you shouldn't need "insecure" if you are mounting on the
command line and not from the Finder's "Go" menu.  The Finder will try
to mount an NFS share using a non-privleged port, but Darwin's mount
command (and automounter, AFAIK) works like other Unices -- it should
try to use a privileged port for communicating with the server.

> I mounted with this command
>
> mount -t nfs -o rw,async,rsize=32768,wsize=32768
> nas.hme1.samad.com.au:/exports/shared /mounts/shared
>
>
> I then tried
>
> df -h &
> ls -l /mounts/shared &
> umount -f /mounts/shared &
>
> all the commands failed to return, I could not kill them with -9, I had
> to reboot

I find looking at the Mac's dmesg via Console.app to be helpful in such cases.

> I have attached a tcpdump (tcpdump -pni eth0 ether host
> xx:xx:xx:xx:xx:xx -s 9100 -w
> nas.capture.dmp) on the nas box
>
> a copy of the dumo is at www.samad.com.au/~alex/nas.capture.dmp
>
> I tracked it down to --manage-gids - when I remove this from
> /etc/defaults/nfs-kernel-server everything works fine.
>
> Note though, the UID's, GIDs are not synced between the linux box and
> the mac box. so the 2 users I have on the mac box uid 501 & 502, do not
> exist on the nas box
>
>
> I read that manage-gids was a means of handle a uid with more than 16
> gids and it was protocol compliant, so I have opened a bug report with
> Apple, and opened a bug report with debian
>
>
> I have had a quick look at the source code, but it looks more like
> something that is in the kernel.
>
> Is there another place I can log a bugreport for this ?
>
> Thanks
> Alex
>
>
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1.4.9 (GNU/Linux)
>
> iEYEARECAAYFAkiSJMUACgkQkZz88chpJ2MHXgCgtfGAogy3RbEkqvacDNwvzYqf
> nikAn3P0J3bB+/Kx6TSmJiK35mAF7+Xh
> =T+Kq
> -----END PGP SIGNATURE-----
>
>



-- 
 "Alright guard, begin the unnecessarily slow-moving dipping mechanism."
--Dr. Evil
