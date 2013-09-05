Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41125 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757904Ab3IEUpi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Sep 2013 16:45:38 -0400
Date: Thu, 5 Sep 2013 16:45:36 -0400
To: Emmanuel Florac <eflorac@intellique.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Hard to debug NFS loss of connectivity
Message-ID: <20130905204536.GB24805@fieldses.org>
References: <20130905191800.1c75b2fb@harpe.intellique.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130905191800.1c75b2fb@harpe.intellique.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 05, 2013 at 07:18:00PM +0200, Emmanuel Florac wrote:
> 
> Hi list, I have a serious problem I've never met before. Here is the
> setup:
> 
> The NFS server is running Debian 6 amd64 but with a plain vanilla 3.2.50
> kernel. it shares a large 81 TB volume (XFS over LVM on hardware RAID6)
> through nfs without any particular options. Here is a glimpse
> of /etc/exports:
> 
> /mnt/raid 10.1.1.0/255.255.255.128(fsid=1,rw,no_root_squash,async,no_subtree_check)
> 
> On the other side is a VMWare ESX VM running Ubuntu 12.04LTS, kernel 3.2.0-52 Ubuntu 
> amd64 mounting the share. From the fstab:
> 
> 10.1.1.99:/mnt/raid          /server         nfs  rw,hard,intr            0    0
> 
> The problem is as follow: stat'ing files on the VM makes the 
> NFS connection drop. For instance:
> 
> find /server -type f -ls
> 
> It works for a while, then stops responding. The NFS mount is frozen. 
> The network link is OK; I still can ssh from the server to the VM 
> and back, I can wget from the VM to the server, ping the server 
> from the VM, etc. Only NFS is affected.
> 
> Restarting NFS on the server does nothing to unfreeze the mount. 
> Using nfs4 instead of nfs3 does nothing. The only remedy is to reboot the VM.
> There isn't any error in dmesg, /var/log/syslog or 
> /var/log/messages in the VM nor the server.
> 
> I've tried rebooting the server on a 3.9.7 kernel. Same thing. 
> Of course there isn't any data corruption of any sort. 
> Running "find /mnt/raid -type f -ls" on the server works 
> perfectly and lists about 25000 files without the slightest trouble.
> 
> It works equally well if I mount the NFS share on the server itself.
> 
> 
> Now it's becoming crazier: When I run the find command as
> previously said, it freezes always on the same file, for
> instance :
> 
> /server/folder1/folder2/folder3/folder4/.svn/somefile
> 
> However, if after a fresh reboot I do
> 
> stat /server/folder1/folder2/folder3/folder4/.svn/somefile
> 
> no problem. Even doing this:
> 
> cd /server/folder1/folder2/folder3/folder4/ && find . -type f -ls
> 
> works. However this
> 
> cd /server/folder1/folder2/folder3/ && find . -type f -ls
> 
> doesn't fly. It freezes at exactly the same point.
> In the first test (running directly from /server) it
> freezes after successfully listing 10000 files. In the last
> test it freezes after only 25 files. 
> So apparently it's not about the number of files.
> 
> 
> Now I'm stuck. Out of going through tcpdump, I have absolutely 
> not the faintest idea about what's going on, except I tend to 
> think that's some Ubuntu kernel bug.
> 
> Any hint, idea, etc would be extremely welcome. Even some
> debugging method less painful than digging through huge 
> tcpdumps would be nice :)

Well, it sounds like you have a reproducer that shouldn't be *too* huge
(the test where it freezes after stat'ing 25 files).

What do you see on the network in that case?

Are you literally using just tcpdump?  Wireshark will give more
(and easier to read) information.

Does the server stop responding at some point, or reply with an error?
Or does the getattr reply on the problem file look odd in any way?

--b.
