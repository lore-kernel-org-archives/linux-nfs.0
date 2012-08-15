Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtprelay04.ispgateway.de ([80.67.31.27]:32781 "EHLO
	smtprelay04.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041Ab2HOMBG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Aug 2012 08:01:06 -0400
Message-ID: <502B8E9A.9010601@cape-horn-eng.com>
Date: Wed, 15 Aug 2012 13:57:14 +0200
From: Richard Ems <richard.ems@cape-horn-eng.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Al Viro <viro@ZenIV.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfs_lookup_revalidate BUG ?
References: <502A21A1.7020206@cape-horn-eng.com> <4FA345DA4F4AE44899BD2B03EEEC2FA93A4848@SACEXCMBX04-PRD.hq.netapp.com> <20120814183512.GI23464@ZenIV.linux.org.uk> <4FA345DA4F4AE44899BD2B03EEEC2FA93A4DFC@SACEXCMBX04-PRD.hq.netapp.com> <20120814151143.30fb9ca9@tlielax.poochiereds.net>
In-Reply-To: <20120814151143.30fb9ca9@tlielax.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/14/2012 09:11 PM, Jeff Layton wrote:
> One way to determine this would be to follow the instructions here,
> substituting nfs.ko for cifs.ko:
> 
>     http://wiki.samba.org/index.php/LinuxCIFS_troubleshooting#Oopses

Hi all, thanks for your responses. I first tried Jeff's proposal, here are the results:

c5n12:~ # gdb /lib/modules/3.5.1-2-default/kernel/fs/nfs/nfs.ko

GNU gdb (GDB) SUSE (7.3-41.1.2)
Copyright (C) 2011 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "x86_64-suse-linux".
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>...
Reading symbols from /lib/modules/3.5.1-2-default/kernel/fs/nfs/nfs.ko...Reading symbols from /usr/lib/debug/lib/modules/3.5.1-2-default/kernel/fs/nfs/nfs.ko.debug...done.
done.

(gdb) list *(nfs_lookup_revalidate+0x2d)
0x59cd is in nfs_lookup_revalidate (/usr/src/debug/kernel-default-3.5.1/linux-3.5/fs/nfs/dir.c:1129).
1124            struct dentry *parent;
1125            struct nfs_fh *fhandle = NULL;
1126            struct nfs_fattr *fattr = NULL;
1127            int error;
1128
1129            if (nd->flags & LOOKUP_RCU)
1130                    return -ECHILD;
1131
1132            parent = dget_parent(dentry);
1133            dir = parent->d_inode;


(gdb) list *(nfs_lookup_revalidate+0x2d/0x480)
0x59a0 is in nfs_lookup_revalidate (/usr/src/debug/kernel-default-3.5.1/linux-3.5/fs/nfs/dir.c:1121).
1116     *
1117     * If the parent directory is seen to have changed, we throw out the
1118     * cached dentry and do a new lookup.
1119     */
1120    static int nfs_lookup_revalidate(struct dentry *dentry, struct nameidata *nd)
1121    {
1122            struct inode *dir;
1123            struct inode *inode;
1124            struct dentry *parent;
1125            struct nfs_fh *fhandle = NULL;


Does this info help?
Trond, should I go ahead and apply that patch to fs/nfs/dir.c ? It's long time ago that I last applied patches to the kernel and recompiled modules ... 8)
And I will have to wait for the bug to trigger, since it just happens only sometimes, it could be days waiting for it.

Many thanks,
Richard


-- 
Richard Ems       mail: Richard.Ems@Cape-Horn-Eng.com

Cape Horn Engineering S.L.
C/ Dr. J.J. Dómine 1, 5º piso
46011 Valencia
Tel : +34 96 3242923 / Fax 924
http://www.cape-horn-eng.com
