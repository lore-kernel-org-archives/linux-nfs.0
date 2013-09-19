Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48812 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752153Ab3ISNOa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Sep 2013 09:14:30 -0400
Date: Thu, 19 Sep 2013 09:14:29 -0400
To: Jody Gugelhupf <knueffle@yahoo.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: help with nfs export/mount
Message-ID: <20130919131429.GA20422@fieldses.org>
References: <1379582806.44080.YahooMailNeo@web140003.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1379582806.44080.YahooMailNeo@web140003.mail.bf1.yahoo.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 19, 2013 at 02:26:46AM -0700, Jody Gugelhupf wrote:
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

No, it should actually be sufficient just to export the parent.  Also,
we don't recommend fsid=0 any longer.  Also, "async" should be avoided.
So just:

	/home/user/media/ 192.168.2.0/24(rw,insecure,crossmnt,no_root_check,no_subtree_check)

and you mount that with "mount myserver:/home/user/media /mymountpoint".

(Note the "crossmnt", which tells the server to export all the children
automatically.)

If that doesn't work you've probably found a bug.  I'd recommend
reporting that to Ubuntu, and/or here if you can reproduce with recent
kernel and nfs-utils.

--b.

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
> 
> but when i try to mount in any of the above described scenarios i get timeout e.g.:
> 
> sudo mount -t nfs 192.168.2.3:/home/user/media/Movies /home/jarvis/Videos/xbmc/Movies
> 
> What I would want is to only mount the parent export on the client side, e.g.:
> sudo mount -t nfs 192.168.2.3:/home/user/media/ /home/jarvis/Videos/xbmc
> and have all directories/files that are available on the server side under '/home/user/media/' to be available on client side under '/home/jarvis/Videos/xbmc' as I have with samba at the moment
> 
> how to achieve this?
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
