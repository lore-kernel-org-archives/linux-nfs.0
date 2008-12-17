From: Steve Dickson <SteveD@redhat.com>
Subject: Re: what's the real meaning of fsid?
Date: Wed, 17 Dec 2008 17:32:07 -0500
Message-ID: <49497DE7.6050102@RedHat.com>
References: <200812171336070316863@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: lioupayphone <lioupayphone@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34825 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752510AbYLQWeU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Dec 2008 17:34:20 -0500
In-Reply-To: <200812171336070316863@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



lioupayphone wrote:
> Hello, everyone. 
> 
> fsid in /etc/exports was used for identifying a file system. if a file system which exported 2 directories, it seems that we should tag the two export entries with same fsid.
> 
> eg
> on one machine (server   10.10.37.147,  Centos5.2 with linux2.6.18):
> 
> #mkfs.ext3 /dev/sdc; mount /dev/sdc /mnt/;mkdir -p /mnt/dir1 /mnt/dir2; touch /mnt/dir1/wall-e /mnt/dir2/eva;
> #echo "/mnt/dir1 *(rw,async,root_squash,fsid=2)" > /etc/exports
> #echo "/mnt/dir2 *(rw,async,root_squash,fsid=2)" >> /etc/exports
> #service nfs start && exportfs -r
> 
> on another machine (client   10.10.37.154):
> #mount  10.10.37.147:/mnt/dir1 /mnt/1/ && mount 10.10.37.147:/mnt/dir2 /mnt/2/
> 
> i am puzzled:   on the client (10.10.37.154), i found both "/mnt/1/" and "/mnt/2/" have the same child ---- "wall-e".
> 
> so i browsed the code of 2.6.18 and found: exp_export(), fs/nfsd/export.c . i have taged a comment on this code listed below. please give me some suggestions. thx.
I'm a bit puzzled by "both "/mnt/1/" and "/mnt/2/" have the same child". 
Do mean they have the same file handle??

steved.


