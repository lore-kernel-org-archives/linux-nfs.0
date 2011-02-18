Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:53322 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138Ab1BRVsv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Feb 2011 16:48:51 -0500
Subject: Re: umount.nfs4 is disturbed by /proc/mounts
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110218195605.GD25634@nb.net.home>
Date: Fri, 18 Feb 2011 13:48:31 -0800
Cc: Jeff Layton <jlayton@redhat.com>, Jan Engelhardt <jengelh@medozas.de>,
        linux-nfs@vger.kernel.org
Message-Id: <CDF38C6A-D879-4DA0-83BD-1F33A44E9383@oracle.com>
References: <alpine.LNX.2.01.1102180041530.20379@obet.zrqbmnf.qr> <AF3E1D8A-81C5-4B78-894A-49E29A775404@oracle.com> <20110218142828.0a35e9d7@corrin.poochiereds.net> <20110218195605.GD25634@nb.net.home>
To: Karel Zak <kzak@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Feb 18, 2011, at 11:56 AM, Karel Zak wrote:

> On Fri, Feb 18, 2011 at 02:28:28PM -0500, Jeff Layton wrote:
>> On Fri, 18 Feb 2011 09:11:54 -0800
>> Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>>> 
>>> On Feb 17, 2011, at 3:44 PM, Jan Engelhardt wrote:
>>> 
>>>> 
>>>> Recent distributions start to have /etc/mtab being a symlink to 
>>>> /proc/mounts with util-linux 2.19. Subsequently, this annoys umount.nfs4 
>>>> from nfs-client-1.2.3 and emits a warning:
>>>> 
>>>> jng-0:/ # grep nfs4 /proc/mounts
>>>> 10.10.1.1:/home/ /home nfs4 rw,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=10.10.1.212,minorversion=0,local_lock=none,addr=10.10.1.1 0 0
>>>> jng-0:/ # umount /home
>>>> umount.nfs4: invalid value for 'port=' option
>>> 
>>> I can take a look at this.
>>> 
>> 
>> FWIW, I just fixed mount.cifs recently based on recommendations from
>> Karel:
>> 
>>    http://git.samba.org/?p=cifs-utils.git;a=commitdiff;h=fba28cfe2f13dd8bdae3cec76178f42b001a40ca
>> 
>> ...this is the same approach that /bin/mount uses, so you're probably
>> safe to use a similar one for mount/umount.nfs.
> 
> This is not the same problem. The NFS umount/remount depends on
> (userspace) values from /etc/mtab.

Right, this problem is not dependent on the existence of mtab.  There is a real bug here, I suggest.  port=0 is a valid specification, and the mount option parser in mount.nfs and umount.nfs should accept it.  That's not dependent on whether /etc/mtab is a link or whether we are using libmount to do the work.

I have a very simple patch to fix this now, just needs testing.

> The solution is to link mount.nfs with libmount. I'm working on this
> change...  http://www.spinics.net/lists/linux-nfs/msg19165.html
> 
> 
> I have already talked about mtab issues at fedora-devel list, see
> http://lists.fedoraproject.org/pipermail/devel/2011-January/147995.html
> 
> The mount.nfs and pam_mount are on my TODO list for the next weeks.
> If the changes in mount.nfs will be successful then I'd like to link
> mount.cifs with libmount too.
> 
> Note that mount(8) in Fedora still supports regular mtab too, and
> the regular mtab is still util-linux upstream default.
> 
>    Karel
> 
> -- 
> Karel Zak  <kzak@redhat.com>
> http://karelzak.blogspot.com

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



