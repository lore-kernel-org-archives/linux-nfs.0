Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e9.ny.us.ibm.com ([32.97.182.139]:59593 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752691Ab3ISLgI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Sep 2013 07:36:08 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Thu, 19 Sep 2013 07:36:07 -0400
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 2CC76C90042
	for <linux-nfs@vger.kernel.org>; Thu, 19 Sep 2013 07:36:04 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8JBa4Zl52625434
	for <linux-nfs@vger.kernel.org>; Thu, 19 Sep 2013 11:36:04 GMT
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8JBa47j005760
	for <linux-nfs@vger.kernel.org>; Thu, 19 Sep 2013 08:36:04 -0300
Date: Thu, 19 Sep 2013 06:36:02 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: Jody Gugelhupf <knueffle@yahoo.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: help with nfs export/mount
Message-ID: <20130919113602.GB19956@us.ibm.com>
References: <1379582806.44080.YahooMailNeo@web140003.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <1379582806.44080.YahooMailNeo@web140003.mail.bf1.yahoo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jody Gugelhupf [knueffle@yahoo.com] wrote:
> i'm currently using samba for fileshares with my media center (xbmc/openelec on a pi). I have a server on the network with 20 different harddisks on this system that contain all my media. I have directory "/home/user/media" on my server into which i "mount --bind" all the media i want to be accessible on xbmc (on the pi) or on other computers on the local network. To give you an idea of the mounts on my server:
> 
> /home/user/media#located on /dev/sda
> /home/user/media/Movies#located on /dev/sdf used 'mount --bind /dev/sdf/Movies /home/user/media/Movies'
> /home/user/media/Series#located on /dev/sda has +300 sub directories, that i created within '/home/user/media/Series' and 'mount --bind' from all other locations/hdd's into the respective folder within '/home/user/media/Series' e.g.
> /home/user/media/Series/24#located on /dev/sdb used 'mount --bind /dev/sdb/24 /home/user/media/Series/24' 
> /home/user/media/Series/Star.Trek#located on /dev/sdc used 'mount --bind' and so forth but also:
> /home/user/media/Series/Animation#located on /dev/sda has +30 sub directories, e.g.
> /home/user/media/Series/Animation/Ben10#located on /dev/sdz used 'mount --bind /dev/sdz/Ben10 /home/user/media/Series/Animation/Ben10'
> 
> a more elaborate list here: http://pastebin.com/DhUA5tks
> 
> this all works fine, but I was told NFS would be faster so i wanted to give it a try. the server runs ubuntu 12.04.2, kernel 3.2.0-48-generic x86_64, up to date NFSv4. After installing NFS I tried simple exports (one folder without any sub directories that have no 'mount --bind' in them) and accessing them works fine. So now I thought to export the '/home/user/media' directory but using the samba setup as described from above does not work. Ideally, I would like to have to nfs mount only '/home/user/media' and have all the 'mount --bind' folders accessible on the server also accessible on all clients.
> Rather then using the xbmc/pi mentioned above I use my laptop with ubuntu to test the export mounts as a client. In samba it was enough to share the parent folder, in this case '/home/user/media' and everything below that share would be visible but as i understand this is not the case in nfs, I need to specify each sub directory that is 'mount --bind' (from a different file system) in the export.
> 
> my export file:
> /home/user/media/       192.168.2.0/24(rw,insecure,fsid=0,nohide,no_root_squash,no_subtree_check,async)
> /home/user/media/Movies       192.168.2.0/24(rw,insecure,nohide,no_root_squash,no_subtree_check,async)
> /home/user/media/Series       192.168.2.0/24(rw,insecure,nohide,no_root_squash,no_subtree_check,async)
> /home/user/media/Series/show_33       192.168.2.0/24(rw,insecure,nohide,no_root_squash,no_subtree_check,async)
> /home/user/media/Series/show_34       192.168.2.0/24(rw,insecure,nohide,no_root_squash,no_subtree_check,async)
> /home/user/media/Series/Animations       192.168.2.0/24(rw,insecure,nohide,no_root_squash,no_subtree_check,async)
> /home/user/media/Series/Animations/show_1       192.168.2.0/24(rw,insecure,nohide,no_root_squash,no_subtree_check,async)
> /home/user/media/Series/Animations/show_2       192.168.2.0/24(rw,insecure,nohide,no_root_squash,no_subtree_check,async)
> 
> I also have tried 'crossmnt' instead of 'nohide' as I'm using a subnet and that appears to be problematic at times. 
> /home/user/media/       192.168.2.0/24(rw,insecure,fsid=0,crossmnt,no_root_squash,no_subtree_check,async)
> /home/user/media/Movies       192.168.2.0/24(rw,insecure,crossmnt,no_root_squash,no_subtree_check,async)
> /home/user/media/Series       192.168.2.0/24(rw,insecure,crossmnt,no_root_squash,no_subtree_check,async)
> /home/user/media/Series/show_33       192.168.2.0/24(rw,insecure,crossmnt,no_root_squash,no_subtree_check,async)
> /home/user/media/Series/show_34       192.168.2.0/24(rw,insecure,crossmnt,no_root_squash,no_subtree_check,async)
> /home/user/media/Series/Animations       192.168.2.0/24(rw,insecure,crossmnt,no_root_squash,no_subtree_check,async)
> /home/user/media/Series/Animations/show_1       192.168.2.0/24(rw,insecure,crossmnt,no_root_squash,no_subtree_check,async)
> /home/user/media/Series/Animations/show_2       192.168.2.0/24(rw,insecure,crossmnt,no_root_squash,no_subtree_check,async)
> 
> Same result.
> 
> I also have tried 'nohide' and then specified only the client IP instead of subnet info.
> /home/user/media/       192.168.2.101(rw,insecure,fsid=0,nohide,no_root_squash,no_subtree_check,async)
> /home/user/media/Movies       192.168.2.101(rw,insecure,nohide,no_root_squash,no_subtree_check,async)
> /home/user/media/Series       192.168.2.101(rw,insecure,nohide,no_root_squash,no_subtree_check,async)
> /home/user/media/Series/show_33       192.168.2.101(rw,insecure,nohide,no_root_squash,no_subtree_check,async)
> /home/user/media/Series/show_34       192.168.2.101(rw,insecure,nohide,no_root_squash,no_subtree_check,async)
> /home/user/media/Series/Animations       192.168.2.101(rw,insecure,nohide,no_root_squash,no_subtree_check,async)
> /home/user/media/Series/Animations/show_1       192.168.2.101(rw,insecure,nohide,no_root_squash,no_subtree_check,async)
> /home/user/media/Series/Animations/show_2       192.168.2.101(rw,insecure,nohide,no_root_squash,no_subtree_check,async)
> 
> Also does not work.
> 
> In all the above scenarios I manage to mount on client side:
> sudo mount -t nfs 192.168.2.3:/home/user/media/ /home/jarvis/Videos/xbmc

I am assuming this worked fine, correct? Are you using NFSv3 or V4? User
(cat /proc/mounts to see if that is mounted with NFSv4 or V3). For
V4, the following should work:

mount 192.168.2.3:/ /home/jarvis/Videos/xbmc

> but when i try to mount in any of the above described scenarios i get timeout e.g.:
> 
> sudo mount -t nfs 192.168.2.3:/home/user/media/Movies /home/jarvis/Videos/xbmc/Movies
> 
> What I would want is to only mount the parent export on the client side, e.g.:
> sudo mount -t nfs 192.168.2.3:/home/user/media/ /home/jarvis/Videos/xbmc
> and have all directories/files that are available on the server side under '/home/user/media/' to be available on client side under '/home/jarvis/Videos/xbmc' as I have with samba at the moment
> 
> how to achieve this?

You should be able to achieve this with NFSv4.

Regards, Malahal.

