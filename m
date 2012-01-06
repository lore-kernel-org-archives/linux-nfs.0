Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:48604 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752842Ab2AFRdB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jan 2012 12:33:01 -0500
Message-ID: <1325871176.4629.35.camel@lappy>
Subject: Boot regression caused by commit 6829a048
From: Sasha Levin <levinsasha928@gmail.com>
To: chuck.lever@oracle.com
Cc: linux@razik.name, Trond.Myklebust@netapp.com,
        Pekka Enberg <penberg@kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
Date: Fri, 06 Jan 2012 19:32:56 +0200
Content-Type: text/plain; charset="us-ascii"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I've noticed a boot regression caused by commit 6829a048 ("NFS: Retry
mounting NFSROOT") which has increased boot time by 95 seconds.

The scenario is as follows:
 - A virtual guest running under the KVM tool.
 - Guest is using kernel automatic IP DHCP configuration ("ip=dhcp").
 - Guest is booting from a 9p device (which is not detected as block,
and gets mounted after NFS tries to do its mounts).
 - No NFS server at all, no NFS parameters passed to the guest kernel.

Under this scenario, theres an additional 95 second delay before NFS
fails and tries to boot using 9p:

[...]
[    6.505269] md: autorun ...
[    6.506954] md: ... autorun DONE.
[  101.522716] VFS: Unable to mount root fs via NFS, trying floppy.
[  101.534499] VFS: Mounted root (9p filesystem) on device 0:18.
[...]

This probably happens since the NFS server isn't configured, so the
bootserver is automatically assumed to be the DHCP server, and with the
commit above we won't simply fail immediately when the NFS code fails
connecting to it.

I'm not quite sure about the correct solution for this. While I can
forcefully disable NFS, is it really the right solution? Should we be
retrying a NFS server even if one wasn't specifically set?

Thanks.

-- 

Sasha.

