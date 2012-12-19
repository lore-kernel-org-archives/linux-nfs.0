Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.agmk.net ([91.192.224.71]:57326 "EHLO mail.agmk.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751175Ab2LSVQM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Dec 2012 16:16:12 -0500
From: =?utf-8?B?UGF3ZcWC?= Sikora <pawel.sikora@agmk.net>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [3.6.11] NFS: Cache request denied due to non-unique superblock keys.
Date: Wed, 19 Dec 2012 22:16:06 +0100
Message-ID: <2073442.2DDQICUc2y@localhost>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA91196AB48@SACEXCMBX04-PRD.hq.netapp.com>
References: <6078496.RFsWrNWv86@localhost> <4FA345DA4F4AE44899BD2B03EEEC2FA91196AB48@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday 19 of December 2012 19:35:50 Myklebust, Trond wrote:
> On Wed, 2012-12-19 at 19:58 +-0100, Pawe+AUI- Sikora wrote:
> +AD4- Hi,
> +AD4- 
> +AD4- i'm testing the 3.6.11 kernel on some small internal nfs network (1 server +ADw--+AD4- 2 clients)
> +AD4- and observing such info in dmesg on the client side. could you put some light on this dmesg entry?
> +AD4- is it a bug or misconfiguration? i can provide more information about nfs configuration
> +AD4- if necessary but denying caching doesn't look nicely.
> +AD4- 
> +AD4- i'm using following nfs related packages:
> +AD4- 
> +AD4- autofs-5.0.5-1.x86+AF8-64
> +AD4- libnfsidmap-0.25-4.x86+AF8-64
> +AD4- nfs-utils-1.2.7-1.x86+AF8-64
> +AD4- nfs-utils-clients-1.2.7-1.x86+AF8-64
> +AD4- nfs-utils-common-1.2.7-1.x86+AF8-64
> +AD4- 
> +AD4- BR,
> +AD4- Pawe+AUI-.
> 
> It's hard to guess when you don't tell us anything about what you are
> doing to trigger this message, but it sounds as if you are trying to use
> the cachefs mount options incorrectly.

on the server side there're following exports:

# exportfs -v
/home/atest/farm-local
                <world>(rw,async,wdelay,nohide,crossmnt,no_root_squash,no_subtree_check,insecure_locks)
/home/atest/farm
                <world>(rw,async,wdelay,nohide,crossmnt,no_root_squash,no_subtree_check,insecure_locks)
/home/users     <world>(rw,no_root_squash,no_subtree_check,insecure_locks)

in the exported /home/atest/* there're crossmounted/binded directories:

# fstab
/home/atest/farm-local/results  /home/atest/farm/results        none bind
/home/services/ftp              /var/lib/ftp                    none bind
/home/services/ftp              /home/atest/farm-local/ftp      none bind

# df -h
Filesystem                   Size  Used Avail Use% Mounted on
rootfs                       7.6G  4.5G  2.7G  63% /
/dev/md0                     7.6G  4.5G  2.7G  63% /
run                           32G  264K   32G   1% /run
devtmpfs                      32G     0   32G   0% /dev
/dev/md1                     7.2T  794G  6.4T  11% /home
none                          32G     0   32G   0% /dev/shm
/dev/md1                     7.2T  794G  6.4T  11% /home/atest/farm/results
/dev/md1                     7.2T  794G  6.4T  11% /var/lib/ftp
/dev/md1                     7.2T  794G  6.4T  11% /home/atest/farm-local/ftp


on the client side there's only a simple autofs configuration:

# cat /etc/autofs/auto.server
farm           -rw,soft,rsize=32768,wsize=32768,intr,vers=4,async,bg,noatime,retry=30,retrans=10        192.168.2.100:/home/atest/farm-local
home           -rw,soft,vers=4        192.168.2.100:/home/users

