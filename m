Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37233 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755146Ab1BRT4J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Feb 2011 14:56:09 -0500
Date: Fri, 18 Feb 2011 20:56:06 +0100
From: Karel Zak <kzak@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Jan Engelhardt <jengelh@medozas.de>,
        linux-nfs@vger.kernel.org
Subject: Re: umount.nfs4 is disturbed by /proc/mounts
Message-ID: <20110218195605.GD25634@nb.net.home>
References: <alpine.LNX.2.01.1102180041530.20379@obet.zrqbmnf.qr> <AF3E1D8A-81C5-4B78-894A-49E29A775404@oracle.com> <20110218142828.0a35e9d7@corrin.poochiereds.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110218142828.0a35e9d7@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Feb 18, 2011 at 02:28:28PM -0500, Jeff Layton wrote:
> On Fri, 18 Feb 2011 09:11:54 -0800
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
> > 
> > On Feb 17, 2011, at 3:44 PM, Jan Engelhardt wrote:
> > 
> > > 
> > > Recent distributions start to have /etc/mtab being a symlink to 
> > > /proc/mounts with util-linux 2.19. Subsequently, this annoys umount.nfs4 
> > > from nfs-client-1.2.3 and emits a warning:
> > > 
> > > jng-0:/ # grep nfs4 /proc/mounts
> > > 10.10.1.1:/home/ /home nfs4 rw,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=10.10.1.212,minorversion=0,local_lock=none,addr=10.10.1.1 0 0
> > > jng-0:/ # umount /home
> > > umount.nfs4: invalid value for 'port=' option
> > 
> > I can take a look at this.
> > 
> 
> FWIW, I just fixed mount.cifs recently based on recommendations from
> Karel:
> 
>     http://git.samba.org/?p=cifs-utils.git;a=commitdiff;h=fba28cfe2f13dd8bdae3cec76178f42b001a40ca
> 
> ...this is the same approach that /bin/mount uses, so you're probably
> safe to use a similar one for mount/umount.nfs.

 This is not the same problem. The NFS umount/remount depends on
 (userspace) values from /etc/mtab.
 
 The solution is to link mount.nfs with libmount. I'm working on this
 change...  http://www.spinics.net/lists/linux-nfs/msg19165.html


 I have already talked about mtab issues at fedora-devel list, see
 http://lists.fedoraproject.org/pipermail/devel/2011-January/147995.html

 The mount.nfs and pam_mount are on my TODO list for the next weeks.
 If the changes in mount.nfs will be successful then I'd like to link
 mount.cifs with libmount too.

 Note that mount(8) in Fedora still supports regular mtab too, and
 the regular mtab is still util-linux upstream default.

    Karel

-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com
