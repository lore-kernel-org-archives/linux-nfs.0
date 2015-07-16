Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:35606 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235AbbGPWF6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jul 2015 18:05:58 -0400
Received: by wibxm9 with SMTP id xm9so24716186wib.0
        for <linux-nfs@vger.kernel.org>; Thu, 16 Jul 2015 15:05:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAEMJtDuOopoSUJup0Ux5myGOT0dCZG7=4Mu7f0K-gMStbNYhoA@mail.gmail.com>
References: <CAEMJtDuOopoSUJup0Ux5myGOT0dCZG7=4Mu7f0K-gMStbNYhoA@mail.gmail.com>
Date: Thu, 16 Jul 2015 15:05:56 -0700
Message-ID: <CAEMJtDsF5Af3SH=wExbTL1OpkLoOeHTnr5_eBtUdemhjeXG40g@mail.gmail.com>
Subject: Re: NFSv4 mount with fsid=0, clients CentOS6/7 show different mounts
From: Steve Dainard <sdainard@spd1.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello

I'm using CentOS 7 to export multiple filesystems under a root
filesystem with fsid=0.

eg:
/etc/exports:
/datasets    10.0.231.0/255.255.255.0(rw,fsid=0,no_root_squash,no_subtree_check)
/datasets/home 10.0.231.0/255.255.255.0(rw,no_subtree_check,no_root_squash,no_subtree_check)


On a CentOS 7 client, a mount command will show the NFS servers /
(fsid=0) location. If I then descend into a subdirectory on the client
side, the mount command will show that subdirectory mounted as well.
This is very useful as df -h commands will show the different server
filesystems free space.

eg:
/etc/fstab:
10.0.231.56:/    /datasets    nfs    bg    0 0

# mount:
10.0.231.56:/      6.8G  2.4G  4.4G  36% /datasets

# cd /datasets/home

# mount
10.0.231.56:/ on /datasets type nfs4
(rw,relatime,vers=4.0,rsize=524288,wsize=524288,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=10.0.231.205,local_lock=none,addr=10.0.231.56)

10.0.231.56:/home on /datasets/home type nfs4
(rw,relatime,vers=4.0,rsize=524288,wsize=524288,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=10.0.231.205,local_lock=none,addr=10.0.231.56)

# df -h
10.0.231.56:/      6.8G  2.4G  4.4G  36% /datasets
10.0.231.56:/home  6.9T  507G  6.4T   8% /datasets/home


On a CentOS 6.6 client, a mount command will only show the NFS
server / (fsid=0) location mounted. After descending into a subdirectory on
the client side, no change is shown with the mount command. Obviously
this is then an issue when trying to see what the filesystems
freespace under the NFS servers / (fsid=0) location is.

eg:
/etc/fstab:
10.0.231.56:/    /datasets    nfs4    bg    0 0

# mount:
10.0.231.56:/ on /datasets type nfs4
(rw,bg,addr=10.0.231.56,clientaddr=10.0.231.218)

# cd /datasets/home

# mount:
10.0.231.56:/ on /datasets type nfs4
(rw,bg,addr=10.0.231.56,clientaddr=10.0.231.218)

# df -h
10.0.231.56:/   6.8G  2.4G  4.4G  36% /datasets



I've looked through the man pages but don't see any options that would
make CentOS 6.6 show all the NFS subdirectory mountpoints.

Is this just a difference between NFS client versions on CentOS 6 vs
7? Any suggestions on how to deal with this?

Thanks,
Steve
