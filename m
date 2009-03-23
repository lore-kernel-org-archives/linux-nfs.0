Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:59740 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751069AbZCWV17 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Mar 2009 17:27:59 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1LlrgZ-0006NP-Ra
	for linux-nfs@vger.kernel.org; Tue, 24 Mar 2009 08:27:55 +1100
Message-ID: <49C7FF2A.60405@shadlen.org>
Date: Mon, 23 Mar 2009 14:29:14 -0700
From: Maria McKinley <maria@shadlen.org>
To: Paul Collins <paul@burly.ondioline.org>
References: <49C43847.9080206@shadlen.org>
	<874oxnllie.fsf@burly.wgtn.ondioline.org>
In-Reply-To: <874oxnllie.fsf@burly.wgtn.ondioline.org>
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] problem with rpc.statd
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Paul Collins wrote:
> Maria McKinley <maria@shadlen.org> writes:
> 
>> Things work well up until it is time to mount the file system from
>> fstab (ie, it mounts everything ro, makes it all the way through init 
>> and gives me a command prompt). The rw mount is not happening because 
>> rpc.statd never starts. If I try to start rpc.statd by hand, it 
>> complains that: Opening /var/run/rpc.statd.pid failed: Read-only file 
>> system. Since I am mounting the root directory over nfs, it makes sense 
>> for this file to be read-only until rpc.statd starts and  Is there any 
>> way I can start statd without a pid file until I get the root file 
>> system mounted rw? Or something else to try?
> 
> Try setting RAMRUN=yes in /etc/default/rcS, which will mount a tmpfs on
> /var/run early in the boot process.  I think I read something about
> defaulting this to yes being a release goal for squeeze, so there may be
> lenny packages that won't like this.
> 

Thank you so much, that got rpc.statd started! NFS is still not behaving 
quite right, unfortunately. The /etc/fstab file:

# /etc/fstab: static file system information.
#
# <file system> <mount point>   <type>  <options>    <dump>     <pass>
10.208.108.18:/tftpboot/oscar  /  nfs 
rw,rsize=8192,wsize=8192,nfsvers=3       0       0
proc            /proc           proc    defaults        0       0
10.208.108.18:/usr  /usr  nfs  rw,rsize=8192,wsize=8192,nfsvers=3 
0       0
/dev/fd0        /floppy         auto    defaults,user,noauto    0       0
/dev/cdrom      /cdrom          iso9660 defaults,ro,user,noauto 0       0
10.208.108.12:/home      /home   nfs 
rw,rsize=8192,wsize=8192,nfsvers=3,nosuid,nodev,async 0       0
10.208.108.12:/lab       /lab    nfs 
rw,rsize=8192,wsize=8192,nfsvers=3,nosuid,nodev 0       0

But, this is not how things are being mounted:
root@oscar:/# df -h
Filesystem            Size  Used Avail Use% Mounted on
/dev/hda1              19G  854M   17G   5% /
tmpfs                 1.9G     0  1.9G   0% /lib/init/rw
udev                   10M   64K   10M   1% /dev
tmpfs                 1.9G     0  1.9G   0% /dev/shm
df: `/tftpboot': No such file or directory
/dev/hda6              19G  854M   17G   5% /tmp
/dev/hda7              33G   11G   21G  34% /usr
/dev/hda2              19G  854M   17G   5% /var
rpc_pipefs             19G  854M   17G   5% /var/lib/nfs/rpc_pipefs
10.208.108.12:/lab     19G  854M   17G   5% /lab
10.208.108.12:/home    19G  854M   17G   5% /home

For some reason, it looks like things are being mounted locally, even 
though they cannot be (no local hard drive). The /lab and /home 
directories are actually not being mounted, they are empty. And all of 
the directories appear to be read-only.

If I try to remount, I get this:
root@oscar:/# mount -a
can't create lock file /etc/mtab~2820: Read-only file system (use -n 
flag to override)
root@oscar:/# mount -an
mount.nfs: /usr is busy or already mounted

It does not appear to even try to remount /lab or /home, and /  is still 
read only, even if I try to mount it by hand:

root@oscar:/# mount.nfs 10.208.108.18:/tftpboot/oscar / -v -rw -n -o 
rsize=8192,wsize=8192
mount.nfs: trying 10.208.108.18 prog 100003 vers 3 prot TCP port 2049
mount.nfs: trying 10.208.108.18 prog 100005 vers 3 prot UDP port 44350
10.208.108.18:/tftpboot/oscar on / type nfs (rsize=8192,wsize=8192)
root@oscar:/# touch /tmp/test
touch: cannot touch `/tmp/test': Read-only file system

Any ideas would be appreciated.

cheers,
maria



------------------------------------------------------------------------------
Apps built with the Adobe(R) Flex(R) framework and Flex Builder(TM) are
powering Web 2.0 with engaging, cross-platform capabilities. Quickly and
easily build your RIAs with Flex Builder, the Eclipse(TM)based development
software that enables intelligent coding and step-through debugging.
Download the free 60 day trial. http://p.sf.net/sfu/www-adobe-com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

