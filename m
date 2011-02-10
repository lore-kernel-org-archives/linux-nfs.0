Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:38817 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756361Ab1BJPvP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Feb 2011 10:51:15 -0500
Subject: Re: NFS only mount with -o udp option
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <AANLkTik_Y4_UpBx-OMaedXz34qc+zuVzN1B5A5qnzW5y@mail.gmail.com>
Date: Thu, 10 Feb 2011 10:50:54 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <665D28F4-A8C9-47E8-AE27-E1D960A1830B@oracle.com>
References: <AANLkTik_Y4_UpBx-OMaedXz34qc+zuVzN1B5A5qnzW5y@mail.gmail.com>
To: Edgar Almonte <samudhio@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Feb 9, 2011, at 7:59 PM, Edgar Almonte wrote:

> hello list
> 
> like the subject say after some upgrade of my distro ( i have 2
> machine with the same distro and only in one happne the problem ) i
> can only mount nfs share using the option -o udp , without it i get
> this error
> mount.nfs: mount system call failed

What does

  sudo mount.nfs heaven.local:/STORAGE /nfs/STORAGE -v

say?  It should tell you how the mount command is negotiating with the server.

> i am using avahi-dns ( mdns ) for hostname resolve
> 
> command used:
> mount heaven.local:/STORAGE /nfs/STORAGE/
> check dns is work right :
> 
> ping heaven.local
> PING heaven.local (192.168.1.102) 56(84) bytes of data.
> 64 bytes from heaven.local (192.168.1.102): icmp_seq=1 ttl=64 time=0.153 ms
> 64 bytes from heaven.local (192.168.1.102): icmp_seq=2 ttl=64 time=0.160 ms
> ^C
> --- heaven.local ping statistics ---
> 2 packets transmitted, 2 received, 0% packet loss, time 1001ms
> rtt min/avg/max/mdev = 0.153/0.156/0.160/0.013 ms
> 
> 
> anyidea what i need check for solve this issue ?
> 
> thanks
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




