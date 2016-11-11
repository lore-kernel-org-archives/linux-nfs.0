Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail3.dit.upm.es ([138.4.2.18]:38784 "EHLO mail3.dit.upm.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756950AbcKKR6D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 11 Nov 2016 12:58:03 -0500
Subject: Re: possible bug in nfs-kernel-server
To: "J. Bruce Fields" <bfields@fieldses.org>
References: <20151218003722.GA1452@us.ibm.com> <5673C73C.2030109@redhat.com>
 <20151218152039.GC25074@fieldses.org> <56743FB6.80903@redhat.com>
 <20151218200840.GA28692@fieldses.org> <5677BCD4.4060009@redhat.com>
 <20151221164752.GA7869@fieldses.org> <56783DCC.1060201@redhat.com>
 <20151221201403.GB7869@fieldses.org>
 <2443f0d3-6937-ae92-d4d5-6e1f00a19e81@dit.upm.es>
 <20161108201611.GB26589@fieldses.org>
Cc: Soumya Koduri <skoduri@redhat.com>,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        =?UTF-8?Q?administraci=c3=b3n_del_centro_de_c=c3=a1lculo_del_dit?=
        <cdc@dit.upm.es>
From: Omar Walid Llorente <omar@dit.upm.es>
Message-ID: <37f8eaf5-128c-ecd5-ae65-3b340c990171@dit.upm.es>
Date: Fri, 11 Nov 2016 18:57:45 +0100
MIME-Version: 1.0
In-Reply-To: <20161108201611.GB26589@fieldses.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce, thanks for your answer, that is greatly appreciated.

This side of the problem feels a little bit lonely and maybe we can 
manage to get to know what is happening if you have some time.

We have been doing tests and we have found a way to replicate the 
problem in a virtual environment without ZFS, only with glusterfs and 
nfs-kernel-server, where we can give you root password or you can 
replicate it at home.

It is closely related to non-root users (with root credentials the 
problem does not happen).

If you think this is good news and feel like checking, tell me and next 
week we will prepare it and I'll forward you the data for both kind of 
tests.

Thank you very much for your time.

Omar


El 08/11/16 a las 21:16, J. Bruce Fields escribió:
> On Wed, Oct 19, 2016 at 07:53:37PM +0200, Omar Walid Llorente wrote:
>> Resending because it has not been accepted by
>> linux-nfs@vger.kernel.org because of the HTML... Sorry if you get it
>> twice.
>>
>> Thanks again.
>>
>> Omar
>>
>> --- Forwarded message ---
>>
>> Hi Bruce, others.
> Sory for the delayed response.  This is a fairly complicated setup that
> may require people with nfs, gluster, and zfs experience to debug.
>
> The server does need to be able to bypass certain permission checks on
> open so that it can open a newly created read-only file for write.
> Probably one of those lower layers is insisting on permission checks
> where it shouldn't.  That's all I can say from a quick look.
>
> --b.
>
>> I come back to this issue again in the hope that these evidences I
>> bring can help to give some light to the problem.
>>
>> We have exactly the same environment that last year when I came to
>> you, but with upgraded versions of gluster (3.8) and
>> nfs-kernel-server (1.2.8) this time over an updated Ubuntu 16.04.
>>
>> (NOTE: Environment: glusterfs-cluster made of ZFS datasets exports
>> via glusterfs a distributed volume + nfs-kernel server mounts via
>> fuse that glusterfs volume and reexports it via nfs-v3 + nfs-common
>> client mounts via nfs that nfs exported volume)
>>
>> The errors I get by the user side are exactly the same, but in the
>> server side, I have different messages, which I forward to you.
>>
>> * /TESTS/ and errors by the user side:
>>
>> u056@l056:~$ rm -f kk.txt 444.txt; echo "prueba" > 444.txt; chmod
>> 444 444.txt; cp -p 444.txt kk.txt; ls -ld 444.txt kk.txt
>> cp: cannot create regular file ‘kk.txt’: Permission denied
>> ls: cannot access kk.txt: No such file or directory
>> -r--r--r-- 1 u056 admincdc 7 oct 19  2016 444.txt
>> u056@l056:~$ ls -lrt
>> total 33
>> ---------- 1 u056 admincdc    0 ene  4  1970 kk.txt
>> drwx------ 2 u056 alumno   4096 oct  3  2014 Desktop
>> drwxr-xr-x 2 u056 alumno   4096 sep 23 12:20 Público
>> drwxr-xr-x 2 u056 alumno   4096 sep 23 12:20 Descargas
>> drwxr-xr-x 2 u056 alumno   4096 sep 23 12:20 Documentos
>> drwxr-xr-x 2 u056 alumno   4096 sep 23 12:20 Vídeos
>> drwxr-xr-x 2 u056 alumno   4096 sep 23 12:20 Música
>> drwxr-xr-x 2 u056 alumno   4096 sep 23 12:20 Plantillas
>> drwxr-xr-x 2 u056 alumno   4096 sep 23 12:22 Imágenes
>> -r--r--r-- 1 u056 admincdc    7 oct 19 17:34 444.txt
>>
>> u056@l056:~$ mount | grep cuentas09
>> cuentas09:/home-3/u056 on /home/u056 type nfs (rw,noatime,intr,fsc,nolock,rsize=262140,wsize=262140,vers=4,addr=138.4.30.80,clientaddr=138.4.31.56)
>> u056@l056:~$ df -h | grep cuentas09
>> cuentas09:/home-3/u056              40T   55G   40T   1% /home/u056
>> u056@l056:~$
>>
>> * /LOGS/ by the glusterfs client side (server side), versions of the
>> software, info of the kernel and related kernel modules:
>>
>> root@cuentas09-lab:/var/log/glusterfs# tail home-3.log
>> [2016-10-19 15:33:38.091300] I [io-stats.c:1574:io_stats_dump_fd]
>> 0-home-lab-3: --- fd stats ---
>> [2016-10-19 15:33:38.091331] I [io-stats.c:1579:io_stats_dump_fd]
>> 0-home-lab-3:       Filename : /u056/444.txt
>> [2016-10-19 15:33:38.091344] I [io-stats.c:1594:io_stats_dump_fd]
>> 0-home-lab-3:   BytesWritten : 7 bytes
>> [2016-10-19 15:33:38.091355] I [io-stats.c:1606:io_stats_dump_fd]
>> 0-home-lab-3: Write 000004b+ : 1
>> [2016-10-19 15:34:13.199285] I [io-stats.c:1574:io_stats_dump_fd]
>> 0-home-lab-3: --- fd stats ---
>> [2016-10-19 15:34:13.200291] I [io-stats.c:1579:io_stats_dump_fd]
>> 0-home-lab-3:       Filename : /u056/444.txt
>> [2016-10-19 15:34:13.200313] I [io-stats.c:1594:io_stats_dump_fd]
>> 0-home-lab-3:   BytesWritten : 7 bytes
>> [2016-10-19 15:34:13.200325] I [io-stats.c:1606:io_stats_dump_fd]
>> 0-home-lab-3: Write 000004b+ : 1
>> [2016-10-19 15:34:13.211696] E [MSGID: 114031]
>> [client-rpc-fops.c:444:client3_3_open_cbk] 0-home-lab-3-client-0:
>> remote operation failed. Path: /u056/kk.txt
>> (d8fc54a3-f2eb-4538-889a-17afdcfbb255) [Permission denied]
>> [2016-10-19 15:34:13.211758] W [fuse-bridge.c:989:fuse_fd_cbk]
>> 0-glusterfs-fuse: 630: OPEN() /u056/kk.txt => -1 (Permission denied)
>>
>> root@cuentas09-lab:/var/log/glusterfs# dpkg -l | grep -e gluster -e nfs
>> ii  glusterfs-client 3.8.5-ubuntu1~xenial1             amd64
>> clustered file-system (client package)
>> ii  glusterfs-common 3.8.5-ubuntu1~xenial1             amd64
>> GlusterFS common libraries and translator modules
>> ii  libnfsidmap2:amd64 0.25-5                            amd64
>> NFS idmapping library
>> ii  nfs-common 1:1.2.8-9ubuntu12                 amd64        NFS
>> support files common to client and server
>> ii  nfs-kernel-server 1:1.2.8-9ubuntu12                 amd64
>> support for NFS kernel server
>>
>> root@cuentas09-lab:/var/log/glusterfs# uname -a
>> Linux cuentas09-lab.lab.dit.upm.es 4.4.0-43-generic #63-Ubuntu SMP
>> Wed Oct 12 13:48:03 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
>>
>> root@cuentas09-lab:/var/log/glusterfs# lsmod | grep nfs
>> nfsd                  319488  13
>> auth_rpcgss            61440  1 nfsd
>> nfs_acl                16384  1 nfsd
>> lockd                  94208  1 nfsd
>> grace                  16384  2 nfsd,lockd
>> sunrpc                335872  21 nfsd,auth_rpcgss,lockd,nfs_acl
>> root@cuentas09-lab:/var/log/glusterfs#
>>
>> * /LOGS/ by the nfs-kernel server side and basic configuration of
>> the nfs-kernel-server:
>>
>> root@cuentas09-lab:~# less /var/log/kern.log
>> root@cuentas09-lab:~# tail -30 !$
>> tail -30 /var/log/kern.log
>> Oct 19 17:30:24 cuentas09-lab kernel: [ 1573.631498]
>> [<ffffffff810a0850>] ? kthread_create_on_node+0x1e0/0x1e0
>> Oct 19 17:30:24 cuentas09-lab kernel: [ 1573.631504]
>> [<ffffffff81831c4f>] ret_from_fork+0x3f/0x70
>> Oct 19 17:30:24 cuentas09-lab kernel: [ 1573.631507]
>> [<ffffffff810a0850>] ? kthread_create_on_node+0x1e0/0x1e0
>> Oct 19 17:30:24 cuentas09-lab kernel: [ 1573.631510] ---[ end trace
>> 34db7650fa22d1d0 ]---
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.814898] ------------[
>> cut here ]------------
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.814948] WARNING: CPU: 0
>> PID: 1373 at /build/linux-BwgxJb/linux-4.4.0/fs/nfsd/nfs4proc.c:464
>> nfsd4_open+0x515/0x780 [nfsd]()
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.814951]
>> nfsd4_process_open2 failed to open newly-created file! status=13
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.814954] Modules linked
>> in: vmw_vsock_vmci_transport vsock ppdev vmw_balloon coretemp joydev
>> input_leds serio_raw irda 8250_fintek parport_pc shpchp parport
>> i2c_piix4 crc_ccitt vmw_vmci mac_hid ib_iser nfsd rdma_cm iw_cm
>> ib_cm auth_rpcgss nfs_acl lockd grace ib_sa sunrpc ib_mad ib_core
>> ib_addr iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi autofs4
>> btrfs raid10 raid456 async_raid6_recov async_memcpy async_pq
>> async_xor async_tx xor raid6_pq libcrc32c raid1 raid0 multipath
>> linear vmwgfx ttm psmouse drm_kms_helper syscopyarea sysfillrect
>> sysimgblt fb_sys_fops mptspi mptscsih mptbase drm e1000
>> scsi_transport_spi pata_acpi floppy fjes
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.815018] CPU: 0 PID:
>> 1373 Comm: nfsd Tainted: G        W       4.4.0-43-generic
>> #63-Ubuntu
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.815021] Hardware name:
>> VMware, Inc. VMware Virtual Platform/440BX Desktop Reference
>> Platform, BIOS 6.00 09/22/2009
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.815024]
>> 0000000000000286 00000000c0e912c3 ffff8800b93c7c80 ffffffff813f1f93
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.815028]
>> ffff8800b93c7cc8 ffffffffc047b668 ffff8800b93c7cb8 ffffffff81081212
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.815031]
>> ffff8800b9e43240 ffff8800b9e44068 000000000d000000 ffff8800b85e6000
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.815035] Call Trace:
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.815047]
>> [<ffffffff813f1f93>] dump_stack+0x63/0x90
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.815055]
>> [<ffffffff81081212>] warn_slowpath_common+0x82/0xc0
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.815058]
>> [<ffffffff810812ac>] warn_slowpath_fmt+0x5c/0x80
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.815073]
>> [<ffffffffc04665db>] ? nfs4_free_ol_stateid+0x3b/0x40 [nfsd]
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.815085]
>> [<ffffffffc0459d05>] nfsd4_open+0x515/0x780 [nfsd]
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.815098]
>> [<ffffffffc045a2fa>] nfsd4_proc_compound+0x38a/0x660 [nfsd]
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.815108]
>> [<ffffffffc0446e78>] nfsd_dispatch+0xb8/0x200 [nfsd]
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.815132]
>> [<ffffffffc039eeac>] svc_process_common+0x40c/0x650 [sunrpc]
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.815151]
>> [<ffffffffc03a0273>] svc_process+0x103/0x1c0 [sunrpc]
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.815160]
>> [<ffffffffc04468cf>] nfsd+0xef/0x160 [nfsd]
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.815170]
>> [<ffffffffc04467e0>] ? nfsd_destroy+0x60/0x60 [nfsd]
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.815174]
>> [<ffffffff810a0928>] kthread+0xd8/0xf0
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.815178]
>> [<ffffffff810a0850>] ? kthread_create_on_node+0x1e0/0x1e0
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.815184]
>> [<ffffffff81831c4f>] ret_from_fork+0x3f/0x70
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.815187]
>> [<ffffffff810a0850>] ? kthread_create_on_node+0x1e0/0x1e0
>> Oct 19 17:34:13 cuentas09-lab kernel: [ 1802.815190] ---[ end trace
>> 34db7650fa22d1d1 ]---
>> root@cuentas09-lab:~#
>>
>> root@cuentas09-lab:~# showmount -e
>> Export list for cuentas09-lab.lab.dit.upm.es:
>> /home-4 138.4.30.0/23
>> /home-3 138.4.30.0/23
>>
>> root@cuentas09-lab:~# cat /etc/exports | grep -v ^#
>> /home-3 138.4.30.0/23(rw,fsid=3,insecure,no_subtree_check,async,no_root_squash)
>> /home-4 138.4.30.0/23(rw,fsid=4,insecure,no_subtree_check,async,no_root_squash)
>> root@cuentas09-lab:~#
>>
>> root@cuentas09-lab:~# cat /etc/default/nfs-kernel-server | grep -v ^#
>> RPCNFSDCOUNT="8 -V 3"
>> RPCNFSDPRIORITY=0
>> RPCMOUNTDOPTS="--manage-gids"
>> NEED_SVCGSSD=""
>> RPCSVCGSSDOPTS=""
>> RPCNFSDOPTS="-d -V 3"
>> root@cuentas09-lab:~#
>>
>> * LOGS by the glusterfs server side:
>>
>> # for i in 10 11 12 13; do echo recipiente$i; ssh recipiente$i tail
>> /var/log/glusterfs/bricks/data-recipiente$i-gluster-home-lab-3.log;
>> done
>> recipiente10
>> [2016-10-19 15:27:48.172858] I [io-stats.c:1606:io_stats_dump_fd]
>> 0-/data/recipiente10-gluster-home-lab-3: Write 000008b+ : 1
>> [2016-10-19 15:29:32.626450] I [io-stats.c:1574:io_stats_dump_fd]
>> 0-/data/recipiente10-gluster-home-lab-3: --- fd stats ---
>> [2016-10-19 15:29:32.626545] I [io-stats.c:1579:io_stats_dump_fd]
>> 0-/data/recipiente10-gluster-home-lab-3:       Filename :
>> /u056/.local/share/tracker/data/tracker-store.journal
>> [2016-10-19 15:29:32.626572] I [io-stats.c:1594:io_stats_dump_fd]
>> 0-/data/recipiente10-gluster-home-lab-3:   BytesWritten : 8 bytes
>> [2016-10-19 15:29:32.626594] I [io-stats.c:1606:io_stats_dump_fd]
>> 0-/data/recipiente10-gluster-home-lab-3: Write 000008b+ : 1
>> [2016-10-19 15:30:23.997592] E [MSGID: 115070]
>> [server-rpc-fops.c:1472:server_open_cbk] 0-home-lab-3-server: 372:
>> OPEN /u056/kk.txt (cc97d150-c725-42b6-9aa5-50328f281e06) ==>
>> (Permission denied) [Permission denied]
>> [2016-10-19 15:32:28.423380] I [io-stats.c:1574:io_stats_dump_fd]
>> 0-/data/recipiente10-gluster-home-lab-3: --- fd stats ---
>> [2016-10-19 15:32:28.423478] I [io-stats.c:1579:io_stats_dump_fd]
>> 0-/data/recipiente10-gluster-home-lab-3:       Filename :
>> /u056/.bashrc
>> [2016-10-19 15:32:28.423504] I [io-stats.c:1584:io_stats_dump_fd]
>> 0-/data/recipiente10-gluster-home-lab-3:       Lifetime : 280secs,
>> 232488usecs
>> [2016-10-19 15:34:13.176805] E [MSGID: 115070]
>> [server-rpc-fops.c:1472:server_open_cbk] 0-home-lab-3-server: 424:
>> OPEN /u056/kk.txt (d8fc54a3-f2eb-4538-889a-17afdcfbb255) ==>
>> (Permission denied) [Permission denied]
>> recipiente11
>> [2016-10-19 15:33:38.057524] I [io-stats.c:1579:io_stats_dump_fd]
>> 0-/data/recipiente11-gluster-home-lab-3:       Filename :
>> /u056/444.txt
>> [2016-10-19 15:33:38.057548] I [io-stats.c:1594:io_stats_dump_fd]
>> 0-/data/recipiente11-gluster-home-lab-3:   BytesWritten : 7 bytes
>> [2016-10-19 15:33:38.057570] I [io-stats.c:1606:io_stats_dump_fd]
>> 0-/data/recipiente11-gluster-home-lab-3: Write 000004b+ : 1
>> [2016-10-19 15:34:13.164629] I [io-stats.c:1574:io_stats_dump_fd]
>> 0-/data/recipiente11-gluster-home-lab-3: --- fd stats ---
>> [2016-10-19 15:34:13.164722] I [io-stats.c:1579:io_stats_dump_fd]
>> 0-/data/recipiente11-gluster-home-lab-3:       Filename :
>> /u056/444.txt
>> [2016-10-19 15:34:13.164769] I [io-stats.c:1594:io_stats_dump_fd]
>> 0-/data/recipiente11-gluster-home-lab-3:   BytesWritten : 7 bytes
>> [2016-10-19 15:34:13.164791] I [io-stats.c:1606:io_stats_dump_fd]
>> 0-/data/recipiente11-gluster-home-lab-3: Write 000004b+ : 1
>> [2016-10-19 15:36:29.066078] I [io-stats.c:1574:io_stats_dump_fd]
>> 0-/data/recipiente11-gluster-home-lab-3: --- fd stats ---
>> [2016-10-19 15:36:29.066180] I [io-stats.c:1579:io_stats_dump_fd]
>> 0-/data/recipiente11-gluster-home-lab-3:       Filename :
>> /u056/444.txt
>> [2016-10-19 15:36:29.066206] I [io-stats.c:1584:io_stats_dump_fd]
>> 0-/data/recipiente11-gluster-home-lab-3:       Lifetime : 136secs,
>> 894418usecs
>> recipiente12
>> [2016-10-19 15:29:06.022950] I [io-stats.c:1594:io_stats_dump_fd]
>> 0-/data/recipiente12-gluster-home-lab-3:   BytesWritten : 986 bytes
>> [2016-10-19 15:29:06.022972] I [io-stats.c:1606:io_stats_dump_fd]
>> 0-/data/recipiente12-gluster-home-lab-3: Write 000512b+ : 1
>> [2016-10-19 15:29:32.646111] I [io-stats.c:1574:io_stats_dump_fd]
>> 0-/data/recipiente12-gluster-home-lab-3: --- fd stats ---
>> [2016-10-19 15:29:32.646214] I [io-stats.c:1579:io_stats_dump_fd]
>> 0-/data/recipiente12-gluster-home-lab-3:       Filename :
>> /u056/.profile
>> [2016-10-19 15:32:28.423115] I [io-stats.c:1574:io_stats_dump_fd]
>> 0-/data/recipiente12-gluster-home-lab-3: --- fd stats ---
>> [2016-10-19 15:32:28.423219] I [io-stats.c:1579:io_stats_dump_fd]
>> 0-/data/recipiente12-gluster-home-lab-3:       Filename :
>> /u056/.bash_logout
>> [2016-10-19 15:32:28.423247] I [io-stats.c:1584:io_stats_dump_fd]
>> 0-/data/recipiente12-gluster-home-lab-3:       Lifetime : 202secs,
>> 412682usecs
>> [2016-10-19 15:32:28.423345] I [io-stats.c:1574:io_stats_dump_fd]
>> 0-/data/recipiente12-gluster-home-lab-3: --- fd stats ---
>> [2016-10-19 15:32:28.423378] I [io-stats.c:1579:io_stats_dump_fd]
>> 0-/data/recipiente12-gluster-home-lab-3:       Filename :
>> /u056/.bash_history
>> [2016-10-19 15:32:28.423400] I [io-stats.c:1584:io_stats_dump_fd]
>> 0-/data/recipiente12-gluster-home-lab-3:       Lifetime : 202secs,
>> 399903usecs
>> recipiente13
>> [2016-10-19 15:04:26.825754] I [io-stats.c:1574:io_stats_dump_fd]
>> 0-/data/recipiente13-gluster-home-lab-3: --- fd stats ---
>> [2016-10-19 15:04:26.825788] I [io-stats.c:1579:io_stats_dump_fd]
>> 0-/data/recipiente13-gluster-home-lab-3:       Filename : /u056/pp
>> [2016-10-19 15:04:26.825799] I [MSGID: 101055]
>> [client_t.c:415:gf_client_unref] 0-home-lab-3-server: Shutting down
>> connection cuentas09-lab.lab.dit.upm.es-1578-2016/10/19-05:00:48:464910-home-lab-3-client-3-0-0
>> [2016-10-19 15:04:26.825813] I [io-stats.c:1584:io_stats_dump_fd]
>> 0-/data/recipiente13-gluster-home-lab-3:       Lifetime : 25804secs,
>> 917102usecs
>> [2016-10-19 15:04:26.825991] I [io-stats.c:1574:io_stats_dump_fd]
>> 0-/data/recipiente13-gluster-home-lab-3: --- fd stats ---
>> [2016-10-19 15:04:26.826026] I [io-stats.c:1579:io_stats_dump_fd]
>> 0-/data/recipiente13-gluster-home-lab-3:       Filename :
>> /u056/.local/share/evolution/tasks/system/tasks.ics
>> [2016-10-19 15:04:26.826050] I [io-stats.c:1584:io_stats_dump_fd]
>> 0-/data/recipiente13-gluster-home-lab-3:       Lifetime : 25774secs,
>> 172800usecs
>> [2016-10-19 15:04:48.333183] I [MSGID: 115029]
>> [server-handshake.c:692:server_setvolume] 0-home-lab-3-server:
>> accepted client from cuentas09-lab.lab.dit.upm.es-1610-2016/10/19-15:04:46:807972-home-lab-3-client-3-0-0
>> (version: 3.8.5)
>> [2016-10-19 15:27:27.763705] E [MSGID: 115070]
>> [server-rpc-fops.c:1472:server_open_cbk] 0-home-lab-3-server: 149:
>> OPEN /u056/.Xauthority-c (a4fa9bc4-a09e-4eb8-968b-b77cb6d49fd3) ==>
>> (Permission denied) [Permission denied]
>> [2016-10-19 15:29:12.202792] E [MSGID: 115070]
>> [server-rpc-fops.c:1472:server_open_cbk] 0-home-lab-3-server: 267:
>> OPEN /u056/.Xauthority-c (ce222a86-9f74-42d1-8e18-1f80f607d766) ==>
>> (Permission denied) [Permission denied]
>> root@admin2:~#
>>
>> As you can see, the glusterfs client part of the server
>> fuse-mounting the volume shows a "/u056/kk.txt => -1 (Permission
>> denied)" error that comes from a similar error in the glusterfs
>> cluster, while at the nfs-kernel server log we can see a kernel
>> trace directly related to the glusterfs fuse mount of the volume
>> that says "nfsd4_process_open2 failed to open newly-created file!
>> status=13".
>>
>> This error can be reproduced any number of times exactly the same,
>> is not sporadic.
>>
>> Other test I've done at the client side with no logs at all at the
>> server side, but the same error for the user, is the following:
>>
>> u056@l056:~$ rm -f 444.txt; echo "prueba" > 444.txt; chmod 444
>> 444.txt; echo "kk" > 444.txt
>> -bash: 444.txt: Permission denied
>> u056@l056:~$
>>
>> We have been trying to reproduce this problem in a virtual
>> environment using KVM, nfs-kernel-server, glusterfs, and ZFS over
>> VFS, being unable to do it... This leads us to think that creating
>> glusterfs volumes over ZFS over phisical disks has something to do
>> with this problem, but we have no clue on how to track it down to
>> the ZFS level, as there are no traces on the kernel.log or the
>> syslog that we can use.
>>
>> Thank you for your time.
>>
>> Omar
>>
>> El 21/12/15 a las 21:14, J. Bruce Fields escribió:
>>> On Mon, Dec 21, 2015 at 11:28:36PM +0530, Soumya Koduri wrote:
>>>> On 12/21/2015 10:17 PM, J. Bruce Fields wrote:
>>>>> On Mon, Dec 21, 2015 at 02:18:20PM +0530, Soumya Koduri wrote:
>>>>>> On 12/19/2015 01:38 AM, J. Bruce Fields wrote:
>>>>>>> On Fri, Dec 18, 2015 at 10:47:42PM +0530, Soumya Koduri wrote:
>>>>>>>> On 12/18/2015 08:50 PM, J. Bruce Fields wrote:
>>>>>>>>> On Fri, Dec 18, 2015 at 02:13:40PM +0530, Soumya Koduri wrote:
>>>>>>>>>> On 12/18/2015 06:07 AM, Malahal Naineni wrote:
>>>>>>>>>>> IIRC, permission checks are done in open(). write/read syscalls should
>>>>>>>>>>> NOT do much access checks (at least based on POSIX). This is why once an
>>>>>>>>>>> open is done, you remove permissions for that process, but it should
>>>>>>>>>>> still be able to read/write based on the open flags it did when it
>>>>>>>>>>> opened the file.
>>>>>>>>>>>
>>>>>>>>>>> I don't know all the details of this defect, but gluster seems to be
>>>>>>>>>>> doing what it is supposed to do.
>>>>>>>>>>>
>>>>>>>>>> Right. Thanks for the correction. I assumed the behavior should be
>>>>>>>>>> same for both OPEN+WRITE vs CREATE+WRITE in the below scenario. But
>>>>>>>>>> looks like (from 'man creat')  the open() call that creates a
>>>>>>>>>> read-only file may well return a read/write file descriptor, which
>>>>>>>>>> is the reason the following WRITE can succeed.
>>>>>>>>> I forgot another complication, which is that knsfd actually does a
>>>>>>>>> temporary open before each read or write--I assume that's getting
>>>>>>>>> translated into fuse and gluster open operations?
>>>>>>>>>
>>>>>>>> yes. It is the OPEN done as part of NFS WRITE which fails with
>>>>>>>> EACCESS error (with both NFSv3 and NFSv4 mounts).
>>>>>>> Makes sense for v3, but I wouldn't normally expect the extra temporary
>>>>>>> open on v4 WRITEs.  Could you share any details?
>>>>>>>
>>>>>> I re-tried the test on v4 mount using Fedora23 machine, acting as
>>>>>> both NFS server and client (Linux#4.2.3-300.fc23.x86_64). Please
>>>>>> find the pkt trace attached.
>>>>>>
>>>>>>   56 07:23:25.567134          ::1 -> ::1          NFS 288 V4 Call
>>>>>> WRITE StateID: 0xf934 Offset: 0 Len: 7
>>>>>>   57 07:23:25.567233 192.168.122.17 -> 192.168.122.202 GlusterFS 188
>>>>>> V330 GETXATTR Call
>>>>>>   58 07:23:25.567732 192.168.122.202 -> 192.168.122.17 GlusterFS 112
>>>>>> V330 GETXATTR Reply (Call In 57)
>>>>>>   59 07:23:25.567881 192.168.122.17 -> 192.168.122.202 GlusterFS 164
>>>>>> V330 OPEN Call
>>>>> Remind me what kernel version your server is on?
>>>> NFS server is on fedora23 VM - Linux version 4.2.3-300.fc23.x86_64
>>> We did reshuffle the code that does the temporary open on WRITE around
>>> there--but it looks right to me, and I can't reproduce an open on WRITE
>>> on that kernel myself.
>>>
>>> Maybe there's some further fuse or gluster debugging that would help
>>> show where that open is coming from.
>>>
>>> --b.
>>>
>>>> Thanks,
>>>> Soumya
>>>>
>>>>> --b.
>>>>>
>>>>>
>>>>>>   60 07:23:25.568354 192.168.122.202 -> 192.168.122.17 GlusterFS 116
>>>>>> V330 OPEN Reply (Call In 59)
>>>>>>   61 07:23:25.568570          ::1 -> ::1          NFS 144 V4 Reply
>>>>>> (Call In 56) WRITE Status: NFS4ERR_ACCESS
>>>>>>
>>>>>> Thanks,
>>>>>> Soumya
>>>>>>
>>>>>>> --b.
>>>>>>>
>>>>>>>>   63 16:59:09.278651000          ::1 -> ::1          NFS 232 V3 WRITE
>>>>>>>> Call, FH: 0x49a35e54 Offset: 0 Len: 7 FILE_SYNC
>>>>>>>>   64 16:59:09.278926000 192.168.122.1 -> 192.168.122.202 GlusterFS
>>>>>>>> 164 V330 OPEN Call
>>>>>>>>   65 16:59:09.278937000 192.168.122.1 -> 192.168.122.202 GlusterFS
>>>>>>>> 164 [RPC retransmission of #64][TCP Retransmission] V330 OPEN Call
>>>>>>>>   66 16:59:09.279459000 192.168.122.202 -> 192.168.122.1 GlusterFS
>>>>>>>> 116 V330 OPEN Reply (Call In 64)
>>>>>>>>   67 16:59:09.279459000 192.168.122.202 -> 192.168.122.1 GlusterFS
>>>>>>>> 116 [RPC duplicate of #66][TCP Retransmission] V330 OPEN Reply (Call
>>>>>>>> In 64)
>>>>>>>>   68 16:59:09.279733000          ::1 -> ::1          NFS 212 V3 WRITE
>>>>>>>> Reply (Call In 63) Error: NFS3ERR_ACCES
>>>>>>>>
>>>>>>>>
>>>>>>>> Thanks,
>>>>>>>> Soumya
>>>>>>>>
>>>>>>>>> In which case it might be worth experimenting with NFSv4 or with Jeff
>>>>>>>>> Layton's filehandle-caching patches.  Neither's a real fix, but that
>>>>>>>>> could help confirm whether it's the temporary opens that are a problem.
>>>>>>>>>
>>>>>>>>> --b.
>>>>>>>>>
>>>>>>>>>> Thanks,
>>>>>>>>>> Soumya
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>>> Regards, Malahal.
>>>>>>>>>>>
>>>>>>>>>>> Soumya Koduri [skoduri@redhat.com] wrote:
>>>>>>>>>>>> As mentioned by Bruce, GlusterFS doesn't have owner-override rule
>>>>>>>>>>>> except for setattr.
>>>>>>>>>>>>
>>>>>>>>>>>> I did few experiments to check why this test case passes on plain
>>>>>>>>>>>> glusterfs fuse mount & NFS-Ganesha but fails with kernel-NFS.
>>>>>>>>>>>>
>>>>>>>>>>>> NFS-Ganesha (for most of the FSALs) seem to be passing the actual
>>>>>>>>>>>> request credentials to the back-end filesystem only for
>>>>>>>>>>>> CREATE(-like) and UNLINK fops. For all the remaining fops, it does
>>>>>>>>>>>> the access check at its end and then perform the operation with root
>>>>>>>>>>>> credentials. That's the reason WRITE succeeded in your case as
>>>>>>>>>>>> NFS-Ganesha (like kernel-NFS) skipped the access check if the
>>>>>>>>>>>> request caller_uid proved to be the file's owner.
>>>>>>>>>>>>
>>>>>>>>>>>> In case of native GlusterFS FUSE mount, there is no OPEN fop
>>>>>>>>>>>> involved. WRITE is performed on the fd returned by CREATE. And
>>>>>>>>>>>> strangely GlusterFS seem to be doing certain access checks only
>>>>>>>>>>>> during OPEN but not for WRITE (this seems like a bug and probably
>>>>>>>>>>>> needs to be fixed in Gluster).
>>>>>>>>>>>>
>>>>>>>>>>>> Thanks,
>>>>>>>>>>>> Soumya
>>>>>>>>>>>>
>>>>>>>>>>>> On 12/14/2015 10:27 PM, Omar Walid Llorente wrote:
>>>>>>>>>>>>> Thank you Bruce, others, for the responses. I send attached a complete
>>>>>>>>>>>>> capture of the issue, including the glusterfs transactions.
>>>>>>>>>>>>>
>>>>>>>>>>>>> Hope this helps to clear where may it be...
>>>>>>>>>>>>>
>>>>>>>>>>>>> Omar
>>>>>>>>>>>>>
>>>>>>>>>>>>> El 10/12/15 a las 15:44, J. Bruce Fields escribió:
>>>>>>>>>>>>>> On Thu, Dec 10, 2015 at 05:59:33PM +0530, Soumya Koduri wrote:
>>>>>>>>>>>>>>> On 12/10/2015 04:02 PM, Omar Walid Llorente wrote:
>>>>>>>>>>>>>>>> Hi, Jeff, Bruce, finally I got some time to get the capture of the nfs
>>>>>>>>>>>>>>>> packets (you can find them in attached file nfs-problem-nks.pcap.zip).
>>>>>>>>>>>>>>>> Sorry for being so late.
>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>> What I did was the following:
>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>> 1st) Create the RO file:
>>>>>>>>>>>>>>>> cdc@l056:~/prueba-git$ rm -f kk.txt 444.txt; echo "prueba" > 444.txt;
>>>>>>>>>>>>>>>> chmod 444 444.txt;
>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>> 2nd) Init the capture:
>>>>>>>>>>>>>>>> root@l056:~# tcpdump -i eth2 -w /tmp/nfs.pcap -s 512 port 2049
>>>>>>>>>>>>>>>> tcpdump: listening on eth2, link-type EN10MB (Ethernet), capture size
>>>>>>>>>>>>>>>> 512 bytes
>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>> GlusterFS protocol is added to wireshark from version 1.8.0 [1]. It
>>>>>>>>>>>>>>> may be helpful to see what GlusterFS operations are being processed
>>>>>>>>>>>>>>> as part of NFS WRITE call (which has failed in this case).
>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>> Could you please try taking the packet trace on the machine where
>>>>>>>>>>>>>>> NFS server is running (without filtering out based on the port
>>>>>>>>>>>>>>> number).
>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>> Also I tried out the same test on Fedora22 machine, but haven't run
>>>>>>>>>>>>>>> into any issue. What are the fuse mount options you have used to
>>>>>>>>>>>>>>> mount gluster volume?
>>>>>>>>>>>>>> Oh, I think this is a simple problem (but maybe hard to fix).  The
>>>>>>>>>>>>>> capture shows NFSv3 traffic like:
>>>>>>>>>>>>>>
>>>>>>>>>>>>>>     CREATE -> OK
>>>>>>>>>>>>>>     SETATTR (mode set to 0400) -> OK
>>>>>>>>>>>>>>     WRITE -> NFS3ERR_ACCES
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> That write would succeed locally (because the mode doesn't matter to a
>>>>>>>>>>>>>> local application that already holds the file open).  It would fail over
>>>>>>>>>>>>>> NFSv3, which doesn't know about the open--except that there's a hack for
>>>>>>>>>>>>>> this case: NFSv3 servers allow IO operations to ignore the mode, if the
>>>>>>>>>>>>>> operation comes from the owner of the file.  NFSv3 clients are then
>>>>>>>>>>>>>> careful to perform necessary access checks on open to ensure that this
>>>>>>>>>>>>>> owner-override rule doesn't grant too many permissions.
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> That allows NFSv3 applications to see behavior that's mostly like a
>>>>>>>>>>>>>> local filesystem, without opening much of a security hole (since the
>>>>>>>>>>>>>> owner could always chmod anyway).
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> So, knfsd is making this special exception--but gluster (which I believe
>>>>>>>>>>>>>> it's exporting in this case, via fuse?)--probably doesn't....  I'm not
>>>>>>>>>>>>>> sure what you can do about that.
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> --b.
>>>>>>>>>>>> --
>>>>>>>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>>>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>>>>>>>>
>>>>>>> --
>>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>>>
>> -- 
>> ----------------------------------------------------------------
>> Centro de Cálculo         Depto. Ingeniería Sistemas Telemáticos
>> E-mail: omar@dit.upm.es        Universidad Politécnica de Madrid
>> Fax:(+34) 913367333                 E.T.S. Ing. Telecomunicación
>> Tel:(+34) 915495700-Ext.3005                28040 Madrid (Spain)
>> Tel:(+34) 915495762-Ext.3005
>> Tel:(+34) 913367366-Ext.3005
>> ----------------------------------------------------------------
>>

-- 
----------------------------------------------------------------
Centro de Cálculo         Depto. Ingeniería Sistemas Telemáticos
E-mail: omar@dit.upm.es        Universidad Politécnica de Madrid
Fax:(+34) 913367333                 E.T.S. Ing. Telecomunicación
Tel:(+34) 915495700-Ext.3005                28040 Madrid (Spain)
Tel:(+34) 915495762-Ext.3005
Tel:(+34) 913367366-Ext.3005
----------------------------------------------------------------

