Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:65385 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752697Ab1EQGgF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 May 2011 02:36:05 -0400
Message-ID: <4DD217DA.5050205@cn.fujitsu.com>
Date: Tue, 17 May 2011 14:38:18 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: Taousif_Ansari@DELLTEAM.com
CC: linux-nfs@vger.kernel.org
Subject: Re: mount.nfs4: Mounting failed, reason given by server: No such
 file or directory
References: <20110517045125.29020.14596.stgit@notabene.brown> <20110517045217.29020.46681.stgit@notabene.brown> <A1A98FD909DC5248811A65C5D18E9C761DF69B191D@BLRX7MCDC202.AMER.DELL.COM>
In-Reply-To: <A1A98FD909DC5248811A65C5D18E9C761DF69B191D@BLRX7MCDC202.AMER.DELL.COM>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



Taousif_Ansari@DELLTEAM.com 写道:
> Hi,
> 
> I have exported one directory from my server it is /export and my /etc/export file looks like
> 
> /export *(rw,fsid=0,sync,pnfs,insecure,no_root_squash,no_subtree_check)
> 
> At client
> tsf@client]# mount -t nfs4 -o minorversion=1 <server-ip>:/export /mnt
> Mount.nfs4: mounting <server-ip>:/export filed, reason given by server: No such file or directory.

 You should mount NFS4 as:
  # mount -t nfs4 -o minorversion=1 <server-ip>:/ /mnt

 Don't add the export dir after server-ip.

> 
> Instead, if I use simple mount then it is succeeding
> tsf@client]# mount <server-ip>:/export /mnt

 As this, you mount nfs success through NFSv3.

-- 
----
thanks
Mi Jinlong

