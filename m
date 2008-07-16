From: Eric Thibodeau <kyron-PfIpIgFSuk5Wk0Htik3J/w@public.gmane.org>
Subject: NFSv4 and nfsroot
Date: Tue, 15 Jul 2008 23:59:44 -0400
Message-ID: <487D7230.2050404@neuralbs.com>
Reply-To: kyron-PfIpIgFSuk5Wk0Htik3J/w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from modemcable086.140-70-69.static.videotron.ca ([69.70.140.86]:1751
	"EHLO kyron.neuralbs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753415AbYGPD7q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2008 23:59:46 -0400
Received: from [192.168.1.2] (kyron.neuralbs.com [192.168.1.2])
	by kyron.neuralbs.com (Postfix) with ESMTP id 0FFA06A78D0
	for <linux-nfs@vger.kernel.org>; Tue, 15 Jul 2008 23:59:45 -0400 (EDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've set up nfsroot based systems before but I am now attempting to do 
the same thing using nfsv4 using the _in-kernel_ nfsroot support (ie: no 
initrd with script that does the mounting). I have been unable to find 
"authoritative" references to how to accomplish this and wanted to ask 
for solid references before I start polluting the mailing list with my 
probably completely erroneous approach. Things that might be worth 
mentioning:

Some basic information, here is a sequence where I mount the nfsv4 
export onto the same machine exporting the tree:

/etc/exports, using FSID=0/root:

    livecd ~ # exportfs -v
    /tftproot/nfsroot/x86_64
                   
    10.0.0.0/255.255.255.0(ro,async,wdelay,no_root_squash,no_subtree_check,fsid=0)

Simple call to mount won't work, I'm assuming mount defaults to nfsv3:

    livecd ~ # mount 10.0.0.1:/ /mnt/gentoo/
    mount.nfs: access denied by server while mounting 10.0.0.1:/

Specifying nfs4 works:

    livecd ~ # mount -t nfs4 10.0.0.1:/ /mnt/gentoo/

Attempts to use the nfsv3 syntax fails (as expected since I put 
`--no-nfs-version 3 --no-nfs-version 2` as a startup arg for nfsd):

    livecd ~ # mount -t nfs4 10.0.0.1:/tftproot/nfsroot/x86_64 /mnt/cdrom/
    mount.nfs4: mounting 10.0.0.1:/tftproot/nfsroot/x86_64 failed,
    reason given by server:
      No such file or directory

Booting the diskless node, I get the following:

1- If the args are (v3 syntax, in pxelinux.cfg/default):

      append ip=dhcp nfsroot=10.0.0.1:/tftproot/nfsroot/x86_64,hard,intr
    init=/boot/stateless.sh

The node boots up to the point of calling init and panics because it 
can't find "/boot/stateless.sh" (screen shot: 
http://wiki.neuralbs.com/~kyron/soc2008/screenshoots/NFSv4WithV3CommandLine_no_init.png 
) But stateless is there and accessible (from the earlyer local mounting 
of the root):

    livecd ~ # ls -l /mnt/gentoo/boot/stateless.sh
    -rwxr-xr-x 1 4294967294 4294967294 3964 Jul 11 04:22
    /mnt/gentoo/boot/stateless.sh


2- If the args are (v4 syntax, in pxelinux.cfg/default):

      append ip=dhcp nfsroot=10.0.0.1:/,hard,intr init=/boot/stateless.sh

The node boots up but panics on mounting root (screen shot : 
http://wiki.neuralbs.com/~kyron/soc2008/screenshoots/NFSv4PanicOnMount.png )

What can be seen in the logs:

    livecd ~ # egrep -i '(nfs|mount)' /var/log/messages
    Jul 16 01:37:23 livecd Mount-cache hash table entries: 256
    Jul 16 01:37:36 livecd rc-scripts: ERROR:  cannot start nfsmount as
    rpc.statd could not start
    Jul 16 01:52:00 livecd aufs test_add:377:mount[27642]: uid/gid/perm
    /mnt/livecd/tftproot 0/0/0755, 0/0/01777
    Jul 16 01:52:11 livecd Installing knfsd (copyright (C) 1996
    okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org).
    Jul 16 01:52:12 livecd NFSD: Using /var/lib/nfs/v4recovery as the
    NFSv4 state recovery directory
    Jul 16 01:52:12 livecd NFSD: starting 90-second grace period
    Jul 16 02:05:17 livecd mountd[28146]: Caught signal 15,
    un-registering and exiting.
    Jul 16 02:05:17 livecd nfsd: last server has exited
    Jul 16 02:05:17 livecd nfsd: unexporting all filesystems
    Jul 16 02:05:17 livecd NFSD: Using /var/lib/nfs/v4recovery as the
    NFSv4 state recovery directory
    Jul 16 02:05:17 livecd NFSD: starting 90-second grace period
    Jul 16 02:05:40 livecd mountd[28441]: refused mount request from
    10.0.0.1 for / (/): not exported
    Jul 16 02:05:49 livecd nfsd: nfsv4 idmapping failing: has idmapd not
    been started?
    Jul 16 02:12:52 livecd dnsmasq[27954]: TFTP sent
    /tftproot/nfsroot/x86_64/boot/kernel to 10.0.0.55
    Jul 16 02:13:10 livecd mountd[28441]: authenticated mount request
    from 10.0.0.55:955 for /tftproot/nfsroot/x86_64
    (/tftproot/nfsroot/x86_64)
    Jul 16 02:13:10 livecd aufs aufs_encode_fh:529:nfsd[28447]: NFSv2
    client (max_len 6)?
    Jul 16 02:14:44 livecd dnsmasq[27954]: TFTP sent
    /tftproot/nfsroot/x86_64/boot/kernel to 10.0.0.55
    Jul 16 02:15:01 livecd mountd[28441]: authenticated mount request
    from 10.0.0.55:682 for /tftproot/nfsroot/x86_64
    (/tftproot/nfsroot/x86_64)
    Jul 16 02:24:55 livecd dnsmasq[28619]: TFTP sent
    /tftproot/nfsroot/x86_64/boot/kernel to 10.0.0.55
    Jul 16 02:25:12 livecd mountd[28441]: refused mount request from
    10.0.0.55 for / (/): not exported

NFS-booting-node's kernel config (nfs stuff), notice v3 client is disabled:

    kyron clustering-livecd # grep -i nfs
    /tmp/nfsboot_kernel/gentoo/usr/src/linux-2.6.26-rc5-mm3/.config
    CONFIG_NFS_FS=y
    # CONFIG_NFS_V3 is not set
    CONFIG_NFS_V4=y
    CONFIG_NFSD=m
    CONFIG_NFSD_V3=y
    # CONFIG_NFSD_V3_ACL is not set
    CONFIG_NFSD_V4=y
    CONFIG_ROOT_NFS=y
    CONFIG_NFS_COMMON=y

The server's kernel config (nfs):

    kyron clustering-livecd # grep -i nfs
    /var/tmp/catalyst/kerncache/default/livecd-stage2-amd64-2008.0/gentoo/usr/src/linux-2.6.24-gentoo-r8/.config
    CONFIG_NFS_FS=y
    # CONFIG_NFS_V3 is not set
    CONFIG_NFS_V4=y
    CONFIG_NFS_DIRECTIO=y
    CONFIG_NFSD=m
    CONFIG_NFSD_V3=y
    # CONFIG_NFSD_V3_ACL is not set
    CONFIG_NFSD_V4=y
    CONFIG_NFSD_TCP=y
    CONFIG_ROOT_NFS=y
    CONFIG_NFS_COMMON=y

...so, it seems kernel boot time nfs is not NFSv4 compatible (only v2/3 
is supported _in kernel_).

Eric

