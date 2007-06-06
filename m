From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: 2.6.21.3: NFS: Buggy server - nlink == 0!
Date: Wed, 6 Jun 2007 01:13:03 -0700
Message-ID: <20070606081303.GB7168@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759072AbXFFIN2@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

While running a dbench stress test on  a nfs mounted file system, I notice
the subject error message on the client machine.  The client machine is a 48
core box with NUMA characteristics and 1024 dbench processes running
continuously in a loop, while another memory hog application runs in parallel.
The client is on 2.6.21.3.  The server is booted up with 2.6.21.3 as well.
Attached is the server configuration.  Same test on a 2.6.16 client does not
spew out these messages.  Is this really the server issue, or is the NFS
client to be blamed here?

fstab on the client goes as:
vus2:/mnt/sda5          /nfstest                nfs  udp,wsize=32768,rsize=32768 0 0

/etc/exports on the server looks like:
/mnt/sda5 *(rw,no_root_squash,sync)

I will be happy to post full config/dmesg if required.

The client side NFS config goes as:
#
# Network File Systems
#
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
# CONFIG_NFS_V3_ACL is not set
# CONFIG_NFS_V4 is not set
CONFIG_NFS_DIRECTIO=y
CONFIG_NFSD=y
CONFIG_NFSD_V3=y
# CONFIG_NFSD_V3_ACL is not set
# CONFIG_NFSD_V4 is not set
CONFIG_NFSD_TCP=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_EXPORTFS=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
# CONFIG_RPCSEC_GSS_KRB5 is not set
# CONFIG_RPCSEC_GSS_SPKM3 is not set

The server side NFS config goes as:

#
# Network File Systems
#
CONFIG_NFS_FS=m
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
# CONFIG_NFS_V4 is not set
CONFIG_NFS_DIRECTIO=y
CONFIG_NFSD=m
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
CONFIG_NFSD_TCP=y
CONFIG_LOCKD=m
CONFIG_LOCKD_V4=y
CONFIG_EXPORTFS=m
CONFIG_NFS_ACL_SUPPORT=m
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=m

Thanks,
Kiran
