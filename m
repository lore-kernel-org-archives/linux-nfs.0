Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.agmk.net ([91.192.224.71]:33193 "EHLO mail.agmk.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756667Ab3APTDV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jan 2013 14:03:21 -0500
From: =?utf-8?B?UGF3ZcWC?= Sikora <pawel.sikora@agmk.net>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, baggins@pld-linux.org,
        Trond.Myklebust@netapp.com
Subject: Re: mount.nfs: cannot allocate memory.
Date: Wed, 16 Jan 2013 20:03:14 +0100
Message-ID: <1435172.ktCUaNjhdC@localhost>
In-Reply-To: <2367820.SDlsSOm8Xm@localhost>
References: <2891788.0SBnrhN2VX@pawels> <50EADFED.1070505@RedHat.com> <2367820.SDlsSOm8Xm@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday 09 of January 2013 18:44:50 Paweł Sikora wrote:
> On Monday 07 of January 2013 09:47:09 Steve Dickson wrote:
> > 
> > On 05/01/13 05:08, Paweł Sikora wrote:
> > > On Thursday 03 of January 2013 09:42:01 Steve Dickson wrote:
> > >>
> > >> On 03/01/13 04:27, Paweł Sikora wrote:
> > >>> Hi,
> > >>>
> > >>> with the latest nfs-1.2.7/kernel-3.7.1 tools i've noticed an error during autofs mounting.
> > >>> reduced testcase shows that mount.nfs with 'vers=4' has a problem:
> > >>>
> > >>> [root@chufu ~]# mount.nfs -v -o vers=4 192.168.2.100:/home/atest/farm-local /mnt
> > >>> mount.nfs: timeout set for Thu Jan  3 10:22:00 2013
> > >>> mount.nfs: trying text-based options 'vers=4,addr=192.168.2.100,clientaddr=192.168.2.103'
> > >>> mount.nfs: mount(2): Cannot allocate memory
> > >>> mount.nfs: Cannot allocate memory
> > >>>
> > >>> while the vers=3 works fine:
> > >>>
> > >>> [root@chufu ~]# mount.nfs -v -o vers=3 192.168.2.100:/home/atest/farm-local /mnt
> > >>> mount.nfs: timeout set for Thu Jan  3 10:22:04 2013
> > >>> mount.nfs: trying text-based options 'vers=3,addr=192.168.2.100'
> > >>> mount.nfs: prog 100003, trying vers=3, prot=6
> > >>> mount.nfs: trying 192.168.2.100 prog 100003 vers 3 prot TCP port 2049
> > >>> mount.nfs: prog 100005, trying vers=3, prot=17
> > >>> mount.nfs: trying 192.168.2.100 prog 100005 vers 3 prot UDP port 42412
> > >>>
> > >>> no obvious errors in logs on nfs server/client side :(
> > >>> i can provide more info if you need to diagnose this issue.
> > >>
> > >> Please set the kernel debugging with 'rpcdebug -m nfs -s mount' then post the out put found in /var/log/messages.
> > > 
> > > [root@pawels ~]# mount.nfs -v -o vers=4 192.168.2.100:/home/atest/farm-local /mnt
> > > 
> > > mount.nfs: timeout set for Sat Jan  5 11:08:42 2013
> > > mount.nfs: trying text-based options 'vers=4,addr=192.168.2.100,clientaddr=10.0.2.35'
> > > mount.nfs: mount(2): Cannot allocate memory
> > > mount.nfs: Cannot allocate memory
> > > 
> > > [root@pawels ~]# dmesg|tail                                                      
> > > 
> > > [ 4187.654183] NFS: nfs mount opts='vers=4,addr=192.168.2.100,clientaddr=10.0.2.35'
> > > [ 4187.654188] NFS:   parsing nfs mount option 'vers=4'
> > > [ 4187.654193] NFS:   parsing nfs mount option 'addr=192.168.2.100'
> > > [ 4187.654198] NFS:   parsing nfs mount option 'clientaddr=10.0.2.35'
> > > [ 4187.654204] NFS: MNTPATH: '/home/atest/farm-local'
> > > [ 4187.654206] --> nfs4_try_mount()
> > > [ 4187.975255] <-- nfs4_try_mount() = -12 [error]
> > > 
> > Hmm... it appears to me that the kernel modules are not be loaded... 
> > What does 'lsmod | grep nfs' show, anything?
> > 
> > steved.
> 
> in fact, all modules are automatically loaded by kernel. better log attached.


with forced vers=3 the mount fails sometimes too :(
i've no idea where's the problem :(

# mount.nfs -v nexus:/R10 /mnt -o "rw,soft,vers=3"
mount.nfs: timeout set for Wed Jan 16 19:56:43 2013
mount.nfs: trying text-based options 'soft,vers=3,addr=10.0.2.28'
mount.nfs: prog 100003, trying vers=3, prot=6
mount.nfs: trying 10.0.2.28 prog 100003 vers 3 prot TCP port 2049
mount.nfs: prog 100005, trying vers=3, prot=17
mount.nfs: trying 10.0.2.28 prog 100005 vers 3 prot UDP port 50252
mount.nfs: mount(2): Stale NFS file handle
^C

[259176.973751] NFS: nfs mount opts='soft,addr=10.0.2.28,vers=3,proto=tcp,mountvers=3,mountproto=udp,mountport=50252'
[259176.973757] NFS:   parsing nfs mount option 'soft'
[259176.973759] NFS:   parsing nfs mount option 'addr=10.0.2.28'
[259176.973765] NFS:   parsing nfs mount option 'vers=3'
[259176.973769] NFS:   parsing nfs mount option 'proto=tcp'
[259176.973772] NFS:   parsing nfs mount option 'mountvers=3'
[259176.973776] NFS:   parsing nfs mount option 'mountproto=udp'
[259176.973779] NFS:   parsing nfs mount option 'mountport=50252'
[259176.973784] NFS: MNTPATH: '/R10'
[259176.973788] NFS: sending MNT request for nexus:/R10
[259176.974620] NFS: received 1 auth flavors
[259176.974623] NFS:   auth flavor[0]: 1
[259176.974640] NFS: MNT request succeeded
[259176.974643] NFS: using auth flavor 1
[259176.974688] --> nfs_init_server()
[259176.974691] --> nfs_get_client(nexus,v3)
[259176.974698] NFS: get client cookie (0xffff88021146f800/0xffff8800ceb06640)
[259176.975704] <-- nfs_init_server() = 0 [new ffff88021146f800]
[259176.975708] --> nfs_probe_fsinfo()
[259176.975711] NFS call  fsinfo
[259176.975959] NFS reply fsinfo: -116
[259176.975963] NFS call  fsinfo
[259176.976182] NFS reply fsinfo: -116
[259176.976184] nfs_probe_fsinfo: error = 116
[259176.976186] --> nfs_free_server()
[259176.976282] --> nfs_put_client({1})
[259176.976285] --> nfs_free_client(3)
[259176.976287] NFS: releasing client cookie (0xffff88021146f800/0xffff8800ceb06640)
[259176.976308] <-- nfs_free_client()
[259176.976322] <-- nfs_free_server()

