Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47947 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751791Ab1BRTYe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Feb 2011 14:24:34 -0500
Date: Fri, 18 Feb 2011 14:28:28 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jan Engelhardt <jengelh@medozas.de>, linux-nfs@vger.kernel.org,
        kzak@redhat.com
Subject: Re: umount.nfs4 is disturbed by /proc/mounts
Message-ID: <20110218142828.0a35e9d7@corrin.poochiereds.net>
In-Reply-To: <AF3E1D8A-81C5-4B78-894A-49E29A775404@oracle.com>
References: <alpine.LNX.2.01.1102180041530.20379@obet.zrqbmnf.qr>
	<AF3E1D8A-81C5-4B78-894A-49E29A775404@oracle.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 18 Feb 2011 09:11:54 -0800
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Feb 17, 2011, at 3:44 PM, Jan Engelhardt wrote:
> 
> > 
> > Recent distributions start to have /etc/mtab being a symlink to 
> > /proc/mounts with util-linux 2.19. Subsequently, this annoys umount.nfs4 
> > from nfs-client-1.2.3 and emits a warning:
> > 
> > jng-0:/ # grep nfs4 /proc/mounts
> > 10.10.1.1:/home/ /home nfs4 rw,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=10.10.1.212,minorversion=0,local_lock=none,addr=10.10.1.1 0 0
> > jng-0:/ # umount /home
> > umount.nfs4: invalid value for 'port=' option
> 
> I can take a look at this.
> 

FWIW, I just fixed mount.cifs recently based on recommendations from
Karel:

    http://git.samba.org/?p=cifs-utils.git;a=commitdiff;h=fba28cfe2f13dd8bdae3cec76178f42b001a40ca

...this is the same approach that /bin/mount uses, so you're probably
safe to use a similar one for mount/umount.nfs.

-- 
Jeff Layton <jlayton@redhat.com>
