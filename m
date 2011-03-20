Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:59765 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752367Ab1CTTtg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Mar 2011 15:49:36 -0400
From: Maciej Rutecki <maciej.rutecki@gmail.com>
Reply-To: maciej.rutecki@gmail.com
To: Adam Lackorzynski <adam@os.inf.tu-dresden.de>
Subject: Re: 2.6.38: Quota over NFS4
Date: Sun, 20 Mar 2011 20:49:29 +0100
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <20110317133247.GB6424@os.inf.tu-dresden.de>
In-Reply-To: <20110317133247.GB6424@os.inf.tu-dresden.de>
Content-Type: Text/Plain;
  charset="us-ascii"
Message-Id: <201103202049.29772.maciej.rutecki@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On czwartek, 17 marca 2011 o 14:32:47 Adam Lackorzynski wrote:
> Hello,
> 
> I'm seeing a problem with quotas in a system where the server running
> 2.6.38 exports an XFS filesystem via NFS4 to a client. The client kernel
> version does not seem to play a role, checked with 2.6.38, 2.6.37 and
> 2.6.36. The following script and output show the problem:
> 
> #! /bin/sh
> 
> quota | grep home
> du
> cp /bin/ls x1
> du
> cat x1 > /dev/null
> rm x1
> du
> quota | grep home
> 
> Output:
> 
>    homes:/home/ 8194720  9072000 9174400          403670  500000  550000
> 0       .
> 96      .
> 0       .
>    homes:/home/ 8194816  9072000 9174400          403671  500000  550000
> 
> 
> As can be seen the 96 kb are still accounted on the quota of the user.
> Removing the 'cat' command from the script makes the quota be ok again
> (original value). Also mounting via nfs3 does not exhibit it, same for
> running the script on the nfs-server directly.
> 
> Client mount options are:
> homes:/home/ /home nfs4
> rw,nosuid,nodev,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,har
> d,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=1.2.3.3,minorvers
> ion=0,local_lock=none,addr=1.2.3.4 0 0
> 
> Server mount options are:
> /dev/mapper/vg-homefs /home xfs rw,nosuid,nodev,relatime,attr2,usrquota 0 0
> 
>
I created a Bugzilla entry at 
https://bugzilla.kernel.org/show_bug.cgi?id=31532
for your bug report, please add your address to the CC list in there, thanks!

-- 
Maciej Rutecki
http://www.maciek.unixy.pl
