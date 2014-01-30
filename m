Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:52918 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753443AbaA3OIn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jan 2014 09:08:43 -0500
Date: Thu, 30 Jan 2014 14:08:34 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
        Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Subject: NFS client broken in Linus' tip
Message-ID: <20140130140834.GW15937@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I just booted Linus' tip (plus a few other patches to imx-drm and imx
code), and stumbled into this interesting scenario:

# touch test
touch: cannot touch `test': Operation not supported

I also tried mkdir and mknod, all result in the same error.  Hard and
symlinks links are creatable.

However, I can chmod existing files and rename them.  Files can also be
deleted, and the combination of this has left me without a /etc/mtab !

The machine is a iMX6 based ARM, running root-nfs, which was mounted via
ubuntu's initramfs (so not using the kernel's built-in root-nfs.)

/proc/mounts for the root mount gives:
192.168.1.123:/var/boot/ci / nfs rw,relatime,vers=3,rsize=65536,wsize=65536,namlen=255,hard,nolock,proto=tcp,port=2049,timeo=7,retrans=10,sec=sys,local_lock=all,addr=192.168.1.123 0 0

CONFIG_NFS_FS=y
CONFIG_NFS_V2=y
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=y
# CONFIG_NFS_SWAP is not set
# CONFIG_NFS_V4_1 is not set
CONFIG_ROOT_NFS=y
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
# CONFIG_NFSD is not set
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y

tcpdumping, I see:

13:59:51.713523 IP 192.168.1.252.1341245608 > 192.168.1.123.2049: 132 lookup fh Unknown/010007011040840000000000CC238FC8FBA0475D9D9F8356B4C44166CDC38700 "test"
13:59:51.714345 IP 192.168.1.123.2049 > 192.168.1.252.1341245608: reply ok 120 lookup ERROR: No such file or directory
13:59:51.751303 IP 192.168.1.252.797 > 192.168.1.123.nfs: . ack 3381 win 2625 <nop,nop,timestamp 474136 3431312924>

which is the only NFS packet(s) I see which mention "test".

and stracing touch:

open("test", O_WRONLY|O_CREAT|O_NOCTTY|O_NONBLOCK|O_LARGEFILE, 0666) = -1 EOPNOTSUPP (Operation not supported)
utimensat(AT_FDCWD, "test", NULL, 0)    = -1 ENOENT (No such file or directory)
write(2, "touch: ", 7touch: )                  = 7
write(2, "cannot touch `test'", 19cannot touch `test')     = 19
write(2, ": Operation not supported", 25: Operation not supported) = 25
write(2, "\n", 1
)                       = 1

I think it's down to this:

commit 013cdf1088d7235da9477a2375654921d9b9ba9f
Author: Christoph Hellwig <hch@infradead.org>
Date:   Fri Dec 20 05:16:53 2013 -0800

    nfs: use generic posix ACL infrastructure for v3 Posix ACLs

    This causes a small behaviour change in that we don't bother to set
    ACLs on file creation if the mode bit can express the access permissions
    fully, and thus behaving identical to local filesystems.

    Signed-off-by: Christoph Hellwig <hch@lst.de>
    Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

which adds:

+       status = posix_acl_create(dir, &sattr->ia_mode, &default_acl, &acl);
+       if (status)
+               goto out;

into nfs3_proc_create(), but this ends up calling down into nfs3_get_acl(),
which does this:

        if (!nfs_server_capable(inode, NFS_CAP_ACLS))
                return ERR_PTR(-EOPNOTSUPP);

-- 
FTTC broadband for 0.8mile line: 5.8Mbps down 500kbps up.  Estimation
in database were 13.1 to 19Mbit for a good line, about 7.5+ for a bad.
Estimate before purchase was "up to 13.2Mbit".
