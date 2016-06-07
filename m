Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:34267 "EHLO
	mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754680AbcFGUFB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2016 16:05:01 -0400
Received: by mail-yw0-f172.google.com with SMTP id c127so180513428ywb.1
        for <linux-nfs@vger.kernel.org>; Tue, 07 Jun 2016 13:05:00 -0700 (PDT)
Message-ID: <1465329897.3024.38.camel@poochiereds.net>
Subject: Re: Files leak from nfsd in 4.7.1-rc1 (and more?)
From: Jeff Layton <jlayton@poochiereds.net>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>
Date: Tue, 07 Jun 2016 16:04:57 -0400
In-Reply-To: <0F21EDD6-5CBB-4B5B-A1FF-E066011D18D6@linuxhacker.ru>
References: <4EDA6CFD-1FE8-4FCA-ACCF-84250BE342CB@linuxhacker.ru>
	 <1465319435.3024.25.camel@poochiereds.net>
	 <0F21EDD6-5CBB-4B5B-A1FF-E066011D18D6@linuxhacker.ru>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2016-06-07 at 13:30 -0400, Oleg Drokin wrote:
> On Jun 7, 2016, at 1:10 PM, Jeff Layton wrote:
> 
> > 
> > On Tue, 2016-06-07 at 11:37 -0400, Oleg Drokin wrote:
> > > 
> > > Hello!
> > > 
> > >    I've been trying to better understand this problem I was having where sometimes
> > >    a formerly NFS-exported mountpoint becomes unmountable (after nfsd stop).
> > > 
> > >    I finally traced it to a leaked filedescriptor that was allocated from
> > >    nfsd4_open()->nfsd4_process_open2()->nfs4_get_vfs_file()->nfsd_open().
> > > 
> > >    Also together with it we see leaked credentials allocated along the same path from
> > >    fh_verify() and groups allocated from svcauth_unix_accept()->groups_alloc() that
> > >    are presumably used by the credentials.
> > > 
> > >    Unfortunately I was not able to make total sense out of the state handling in nfsd,
> > >    but it's clear that one of the file descriptors inside struct nfs4_file is
> > >    lost. I added a patch like this (always a good idea, so surprised it was not
> > >    there already):
> > > @@ -271,6 +274,9 @@ static void nfsd4_free_file_rcu(struct rcu_head *rcu)
> > >  {
> > >         struct nfs4_file *fp = container_of(rcu, struct nfs4_file, fi_rcu);
> > >  
> > > +       WARN_ON(fp->fi_fds[0]);
> > > +       WARN_ON(fp->fi_fds[1]);
> > > +       WARN_ON(fp->fi_fds[2]);
> > >         kmem_cache_free(file_slab, fp);
> > >  }
> > > 
> > >    And when the problem is hit, I am also triggering (Always this one which is fd[1])
> > > [ 3588.143002] ------------[ cut here ]------------
> > > [ 3588.143662] WARNING: CPU: 5 PID: 9 at /home/green/bk/linux/fs/nfsd/nfs4state.c:278 nfsd4_free_file_rcu+0x65/0x80 [nfsd]
> > > [ 3588.144947] Modules linked in: loop rpcsec_gss_krb5 joydev acpi_cpufreq tpm_tis i2c_piix4 tpm virtio_console pcspkr nfsd ttm drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops drm floppy serio_raw virtio_blk
> > > [ 3588.147135] CPU: 5 PID: 9 Comm: rcuos/0 Not tainted 4.7.0-rc1-vm-nfs+ #120
> > > [ 3588.153826] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> > > [ 3588.153830]  0000000000000286 00000000e2d5ccdf ffff88011965bd50 ffffffff814a11a5
> > > [ 3588.153832]  0000000000000000 0000000000000000 ffff88011965bd90 ffffffff8108806b
> > > [ 3588.153834]  0000011600000000 ffff8800c476a0b8 ffff8800c476a048 ffffffffc0110fc0
> > > [ 3588.153834] Call Trace:
> > > [ 3588.153839]  [] dump_stack+0x86/0xc1
> > > [ 3588.153841]  [] __warn+0xcb/0xf0
> > > [ 3588.153852]  [] ? trace_raw_output_fh_want_write+0x60/0x60 [nfsd]
> > > [ 3588.153853]  [] warn_slowpath_null+0x1d/0x20
> > > [ 3588.153859]  [] nfsd4_free_file_rcu+0x65/0x80 [nfsd]
> > > [ 3588.153861]  [] rcu_nocb_kthread+0x335/0x510
> > > [ 3588.153862]  [] ? rcu_nocb_kthread+0x27f/0x510
> > > [ 3588.153863]  [] ? rcu_cpu_notify+0x3e0/0x3e0
> > > [ 3588.153866]  [] kthread+0x101/0x120
> > > [ 3588.153868]  [] ? trace_hardirqs_on_caller+0xf4/0x1b0
> > > [ 3588.153871]  [] ret_from_fork+0x1f/0x40
> > > [ 3588.153872]  [] ? kthread_create_on_node+0x250/0x250
> > > 
> > > 
> > >   release_all_access() seems to be doing correct job of all that cleaning, so
> > >   there must be some other path that I do not quite see.
> > > 
> > >   Hopefully you are more familiar with the code and can see the problem right away ;)
> > Hmm...well I'm not seeing it right offhand, and haven't been able to
> > reproduce the problem so far after a couple of attempts by hand. What
> > sort of workload are you running before you see that warning pop?
> Well, the workload is a crazed twisty conflicting operations set in a very limited
> namespace (called racer.sh,
> http://git.whamcloud.com/fs/lustrerelease.git/tree/refs/heads/master:/lustre/tests/racer )
> 
> It does all sorts of crazy unimaginable stuff that is hard to predict, and typically I
> run it on several mountpoints all pointing to the same spot
> (now 3-ways: one instance on direct mount point in ext4, one on nfs mount mounted as
> mount -o nfs and one on mount -o nfs4).
> It must be hitting some rare race or a race + operations combination that leads to
> the leak.
> 
> To reproduce I run it like this until it stops (and it usually stops in
> 2 or 3 iterations, so it takes some time):
> $ cat ~/stress.sh 
> #!/bin/bash
> 
> set -x
> 
> cd /home/green/git/lustre-release/lustre/tests/racer
> dd if=/dev/zero of=/tmp/loop bs=1024k count=1024
> mkfs.ext4 /tmp/loop
> service rpcbind start
> mount none /var/lib/nfs -t tmpfs
> touch /var/lib/nfs/etab
> service nfs-mountd start
> 
> while :; do
> 
> mount /tmp/loop /mnt/lustre -o loop || exit 1
> mkdir /mnt/lustre/racer
> service nfs-server start || exit 2
> mount localhost:/mnt/lustre /mnt/nfs -t nfs -o nolock || exit 3
> mount localhost:/ /mnt/nfs2 -t nfs4 || exit 4
> DURATION=3600 sh racer.sh /mnt/nfs/racer &
> DURATION=3600 sh racer.sh /mnt/nfs2/racer &
> DURATION=3600 sh racer.sh /mnt/lustre/racer &
> wait %1 %2 %3
> umount /mnt/nfs || exit 5
> umount /mnt/nfs2 || exit 6
> service nfs-server stop || exit 7
> umount /mnt/lustre || exit 8
> e2fsck -n -f /tmp/loop || exit 9
> done
> 
> Please ignore all the Lustre references, the test is generic, it's just I am running
> off nfs-readonly-root setup, so want to reuse existing mountpoint locations,
> there's no Lustre in picture here).
> With all the other problems from before fixed, now it typically stops either for
> this leak discussed here, or for this other problem in nfs4 I described here:
> http://marc.info/?l=linux-nfs&m=146518324823160&w=2

Thanks. So it seems likely we're looking at a race of some sort then...

So, the way this is supposed to work is that the stateids each hold a
reference to the nfs4_file. They also take an fi_access reference for
the open modes that they represent. This is how we know when it's OK to
close one of the files in the fd[] slots. It might be interesting to
also print out the fi_access counters if the slot hasn't been zeroed
out if you feel up to it.

I think though that the open upgrade accounting may be wrong.
__nfs4_file_get_access does an unconditional atomic_inc, so if the
client does a open for write and then opens again for read/write, then
we may end up with too many write fi_access references taken.

That said, this code is quite subtle. I'd need to look over it in more
detail before I offer up any fixes. I'd also appreciate it if anyone
else wants to sanity check my analysis there.

-- 
Jeff Layton <jlayton@poochiereds.net>
