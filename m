Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.agmk.net ([91.192.224.71]:58391 "EHLO mail.agmk.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756027Ab3AQPAF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jan 2013 10:00:05 -0500
From: =?utf-8?B?UGF3ZcWC?= Sikora <pawel.sikora@agmk.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org,
        baggins@pld-linux.org, Trond.Myklebust@netapp.com
Subject: Re: mount.nfs: cannot allocate memory.
Date: Thu, 17 Jan 2013 15:59:57 +0100
Message-ID: <3670768.htx4NKnPRQ@pawels>
In-Reply-To: <20130117134959.GE6598@fieldses.org>
References: <2891788.0SBnrhN2VX@pawels> <4603964.W8GbJjCd8Z@localhost> <20130117134959.GE6598@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday 17 of January 2013 08:49:59 J. Bruce Fields wrote:
> On Wed, Jan 16, 2013 at 10:18:51PM +0100, Paweł Sikora wrote:
> > On Wednesday 16 of January 2013 15:15:10 J. Bruce Fields wrote:
> > > On Wed, Jan 16, 2013 at 09:07:45PM +0100, Paweł Sikora wrote:
> > > > On Wednesday 16 of January 2013 14:39:32 J. Bruce Fields wrote:
> > > > > On Wed, Jan 16, 2013 at 08:03:14PM +0100, Paweł Sikora wrote:
> > > > > > [259176.973751] NFS: nfs mount opts='soft,addr=10.0.2.28,vers=3,proto=tcp,mountvers=3,mountproto=udp,mountport=50252'
> > > > > > [259176.973757] NFS:   parsing nfs mount option 'soft'
> > > > > > [259176.973759] NFS:   parsing nfs mount option 'addr=10.0.2.28'
> > > > > > [259176.973765] NFS:   parsing nfs mount option 'vers=3'
> > > > > > [259176.973769] NFS:   parsing nfs mount option 'proto=tcp'
> > > > > > [259176.973772] NFS:   parsing nfs mount option 'mountvers=3'
> > > > > > [259176.973776] NFS:   parsing nfs mount option 'mountproto=udp'
> > > > > > [259176.973779] NFS:   parsing nfs mount option 'mountport=50252'
> > > > > > [259176.973784] NFS: MNTPATH: '/R10'
> > > > > > [259176.973788] NFS: sending MNT request for nexus:/R10
> > > > > > [259176.974620] NFS: received 1 auth flavors
> > > > > > [259176.974623] NFS:   auth flavor[0]: 1
> > > > > > [259176.974640] NFS: MNT request succeeded
> > > > > > [259176.974643] NFS: using auth flavor 1
> > > > > > [259176.974688] --> nfs_init_server()
> > > > > > [259176.974691] --> nfs_get_client(nexus,v3)
> > > > > > [259176.974698] NFS: get client cookie (0xffff88021146f800/0xffff8800ceb06640)
> > > > > > [259176.975704] <-- nfs_init_server() = 0 [new ffff88021146f800]
> > > > > > [259176.975708] --> nfs_probe_fsinfo()
> > > > > > [259176.975711] NFS call  fsinfo
> > > > > > [259176.975959] NFS reply fsinfo: -116
> > > > > 
> > > > > That's ESTALE.  Might be interesting to see the network traffic between
> > > > > client and server.
> > > > 
> > > > here's the tcpdump result:  http://pluto.agmk.net/kernel/nfs.mount.estale.dump
> > > 
> > > On just a very quick skim (you may want to verify to see I've got it
> > > right), frame 30 shows the server returning a filehandle in a MNT reply,
> > > then frame 48 shows the same client that got that MNT reply using the
> > > same filehandle in an FSINFO reply, and getting an NFS3ERR_STALE
> > > response.
> > > 
> > > Offhand seems like a server bug.  Might conceivably happen if there was
> > > some confusion whether the client was authorized to access that export?
> > 
> > i have such nfs problems with only one server which have complicated exports/local-binds:
> > 
> > fstab:
> > 
> > /dev/md0        /                       ext3    defaults                1 1
> > /dev/md1        /R0                     ext4    defaults,noatime        1 2
> > /dev/md2        /R10                    ext4    defaults,noatime        1 2
> > /home           /remote/nexus/home      none    bind
> > /R0/atest_home  /home/atest                     none    bind
> > /R0/farm/ftp    /var/lib/ftp            none    bind
> > /R0             /remote/nexus/R0        none    bind
> > /R10            /remote/nexus/R10       none    bind
> > 
> > exports:
> > 
> > /home           *(rw,sync,no_wdelay,no_subtree_check,no_root_squash,insecure_locks,nohide)
> > /R0             *(rw,async,no_wdelay,no_subtree_check,no_root_squash,insecure_locks,nohide,crossmnt)
> > /R0/farm/ftp    *(rw,async,no_wdelay,no_subtree_check,no_root_squash,insecure_locks,nohide,crossmnt)
> > /R10            *(rw,sync,no_wdelay,no_subtree_check,no_root_squash,insecure_locks,nohide,crossmnt)
> > /R10/farm       *(rw,sync,no_wdelay,no_subtree_check,no_root_squash,insecure_locks,nohide,crossmnt)
> > /R10/farm/sources       *(rw,sync,no_wdelay,no_subtree_check,no_root_squash,insecure_locks,nohide,crossmnt)
> > /R10/farm/soft          *(rw,sync,no_wdelay,no_subtree_check,no_root_squash,insecure_locks,nohide,crossmnt)
> > 
> > and finally, the /R0/farm contains cross symlinks to R10 via binded dirs:
> > 
> > soft -> /remote/nexus/R10/farm/soft
> > sources -> /remote/nexus/R10/farm/sources
> > 
> > 
> > maybe this crappy setup exposes some bug on the server side?
> 
> So in the above setup, /R0 and /remote/nexus/R0, for example, both point
> to the same superblock.
> 
> The filehandle contains only a reference to the superblock, with no
> information about how it was arrived at.  When nfsd gets the filehandle
> it's resolved in two steps:
> 
> 	- first it asks mountd to tell it a path for the given
> 	  filehandle data
> 	- then it asks mountd for export options for that path
> 
> You can see the former in /proc/net/rpc/nfsd.fh/content, and the latter
> in /proc/net/rpc/nfsd.export/content, so it might be interesting to
> compare those two after a success and after a failure.
> 
> Since there are multiple possible paths that each filehandle could be
> mapped to, I suspect the outcome depends on which mountd chooses, which
> could be random.  But I don't immediately see how that's causing the
> problem, since all your exports have the same option.

before failing mount attempt i see such values on the server side:

[root@nexus ~]# ./nfs_debug.sh
+ cat /proc/net/rpc/nfsd.fh/content
#domain fsidtype fsid [path]
* 6 0x40694572b34adc7d7535a982d692a864 /R10
* 1 0x00000000 /
* 6 0x0f5a4f040e452cbc5ba412a3a206b7c3 /R0
# * 6 0xa75dfe547f9b43ac0000000000000000
# * 6 0xf0ec5c351974d8650000000000000000
+ cat /proc/net/rpc/nfsd.export/content
#path domain(flags)
/       *(ro,no_root_squash,sync,no_wdelay,no_subtree_check,v4root,fsid=0,uuid=44053428:4cfdc05e:00000000:00000000)
/R0     *(rw,no_root_squash,sync,wdelay,nohide,crossmnt,no_subtree_check,insecure_locks,uuid=044f5a0f:bc2c450e:a312a45b:c3b706a2)
/R10    *(rw,no_root_squash,sync,wdelay,nohide,crossmnt,no_subtree_check,insecure_locks,uuid=72456940:7ddc4ab3:82a93575:64a892d6)


after R0 mount attempt there're two entries for R0 with different uuids. is it correct behaviour?

[root@nexus ~]# ./nfs_debug.sh
+ cat /proc/net/rpc/nfsd.fh/content
#domain fsidtype fsid [path]
* 6 0x40694572b34adc7d7535a982d692a864 /R10
* 1 0x00000000 /
* 6 0x0f5a4f040e452cbc5ba412a3a206b7c3 /R0
# * 6 0xa75dfe547f9b43ac0000000000000000
# * 6 0xf0ec5c351974d8650000000000000000
+ cat /proc/net/rpc/nfsd.export/content
#path domain(flags)
/       *(ro,no_root_squash,sync,no_wdelay,no_subtree_check,v4root,fsid=0,uuid=44053428:4cfdc05e:00000000:00000000)
/R0     *(rw,no_root_squash,sync,wdelay,nohide,crossmnt,no_subtree_check,insecure_locks,uuid=044f5a0f:bc2c450e:a312a45b:c3b706a2)
/R0     *(rw,no_root_squash,sync,wdelay,nohide,crossmnt,no_subtree_check,insecure_locks,uuid=54fe5da7:ac439b7f:00000000:00000000)
/R10    *(rw,no_root_squash,sync,wdelay,nohide,crossmnt,no_subtree_check,insecure_locks,uuid=72456940:7ddc4ab3:82a93575:64a892d6)

