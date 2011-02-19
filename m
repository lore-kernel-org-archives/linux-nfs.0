Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:17407 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932071Ab1BSWao convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 19 Feb 2011 17:30:44 -0500
Subject: Re: umount.nfs4 is disturbed by /proc/mounts
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <alpine.LNX.2.01.1102180041530.20379@obet.zrqbmnf.qr>
Date: Sat, 19 Feb 2011 14:28:47 -0800
Cc: linux-nfs@vger.kernel.org, kzak@redhat.com
Message-Id: <0388D451-4AF3-4B6A-8EFF-283F2B049F10@oracle.com>
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

With the latest nfs-utils (post 1.2.3) I can't reproduce this on my Fedora 13 client after replacing /etc/mtab with a symlink to /proc/mounts.  I think we may have an upstream fix for this already:

commit dc08c702a6c7f824f317af561f491635ee898a71
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Oct 13 13:55:10 2010 -0400

    umount.nfs: Distinguish between nfs4 and nfs mounts

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



