Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:33347 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230Ab1BRRNE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Feb 2011 12:13:04 -0500
Subject: Re: umount.nfs4 is disturbed by /proc/mounts
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <alpine.LNX.2.01.1102180041530.20379@obet.zrqbmnf.qr>
Date: Fri, 18 Feb 2011 09:11:54 -0800
Cc: linux-nfs@vger.kernel.org, kzak@redhat.com
Message-Id: <AF3E1D8A-81C5-4B78-894A-49E29A775404@oracle.com>
References: <alpine.LNX.2.01.1102180041530.20379@obet.zrqbmnf.qr>
To: Jan Engelhardt <jengelh@medozas.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Feb 17, 2011, at 3:44 PM, Jan Engelhardt wrote:

> 
> Recent distributions start to have /etc/mtab being a symlink to 
> /proc/mounts with util-linux 2.19. Subsequently, this annoys umount.nfs4 
> from nfs-client-1.2.3 and emits a warning:
> 
> jng-0:/ # grep nfs4 /proc/mounts
> 10.10.1.1:/home/ /home nfs4 rw,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=10.10.1.212,minorversion=0,local_lock=none,addr=10.10.1.1 0 0
> jng-0:/ # umount /home
> umount.nfs4: invalid value for 'port=' option

I can take a look at this.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



