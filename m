From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Issue with stalled NFS
Date: Mon, 2 Nov 2009 13:35:52 -0500
Message-ID: <20091102183552.GA18142@fieldses.org>
References: <4AEE04F2.2070400@o2.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Warpme <warpme-h7QdYz1kt/Q@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36416 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754190AbZKBSeT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Nov 2009 13:34:19 -0500
In-Reply-To: <4AEE04F2.2070400-h7QdYz1kt/Q@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Nov 01, 2009 at 11:00:18PM +0100, Warpme wrote:
> Hi *
>
> I'm looking solution for following problem:
>
> I have file server sharing files to diskless clients via NFS.
>
> My /etc/export looks following:
>
> [CODE]myth                  
> 192.168.1.0/24(rw,crossmnt,no_subtree_check,no_root_squash)
> /tftpboot/PXEclient    
> 192.168.1.0/24(rw,no_subtree_check,no_root_squash)[/CODE]
>
>
> I want  have setup, where plugging ext. USB HDD will be dynamically  
> visible on clients as new <subdir> with plugged HDD contents.
> So if user plug USB HD on server, diskless clients should see plugged  
> HDD contents in dynamically created <subdirectory> with name equal to HD  
> label and HD contents inside it.
>
> I already wrote udev script which auto creates subdir=<label> in NFS  
> server shared dir, and automounts USB HD in this subdir.
> Udev script calls exportfs -r on add/remove operations.
>
> My issue is that sometimes, after longer period of time (hours), in  
> diskless clients, access to dir having HSB HD <subdir> causes stall.

Is it possible that this is the first time those clients attempted to
access the drive, or do they succesfully accessed the new export of the
drive after it was mounted, and only fail much later?

Next time the problem happens, it might be interesting to turn on mountd
debugging (by adding "-d all" to the mountd commandline), then run
exportfs -f, then try to access the directory from a client.

> In such case, cat /proc/fs/nfs/exports on NFS server gives:   
>
> [CODE][root@mythtv ~]# cat /proc/fs/nfs/exports
> # Version 1.1
> # Path Client(Flags) # IPs
> /tftpboot/PXEclient      
> 192.168.1.0/24(rw,no_root_squash,sync,wdelay,no_subtree_check,uuid=61c03e7b:9b7b4650:98dd78b4:18dc5ea6)
> /        
> 192.168.1.0/24(rw,no_root_squash,sync,wdelay,crossmnt,no_subtree_check,uuid=82aa90c3:2cb44663:b912a340:38f73b56)
> /myth/video/DVD_Rip      
> 192.168.1.0/24(rw,no_root_squash,sync,wdelay,crossmnt,no_subtree_check,uuid=cc740348:740334ac:00000000:00000000)
> /myth    
> 192.168.1.0/24(rw,no_root_squash,sync,wdelay,crossmnt,no_subtree_check,uuid=fd3104ea:d5c04a8f:beba8ab6:9115b192)
> /myth/video/HD   
> 192.168.1.0/24(rw,no_root_squash,sync,wdelay,crossmnt,no_subtree_check,uuid=c8c0a856:b8a54c08:9e4a4d48:58a37778)[/CODE]
>
> In above listing, DVD_Rip is <subdir> created by udev script. In this  
> <subdir> udev script mounts USB HDD.
> I don't have clue why NFS server shares "/". Also I'm afraid about  
> security, as for me it looks like server is sharing root dir...

Is this recent Fedora?

Recent Fedora may do an export of /, but it should allow access only to
directory entries on the path to other exports.  (And it should be
marked read-only, so something's wrong in the above.)

--b.
