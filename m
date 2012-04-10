Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:48887 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756626Ab2DJIGj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Apr 2012 04:06:39 -0400
Received: from mailserver.fnst.cn.fujitsu.com (tang.cn.fujitsu.com [127.0.0.1])
	by tang.cn.fujitsu.com (8.14.3/8.13.1) with ESMTP id q3A86cGt019283
	for <linux-nfs@vger.kernel.org>; Tue, 10 Apr 2012 16:06:38 +0800
Message-ID: <4F83EA6E.6020504@cn.fujitsu.com>
Date: Tue, 10 Apr 2012 16:08:14 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: [Fwd: oops  when I mount  nfs with -o fsc]
Content-Type: multipart/mixed;
 boundary="------------040605060001050403010000"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--------------040605060001050403010000
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8


--------------040605060001050403010000
Content-Transfer-Encoding: 7bit
Content-Type: message/rfc822;
 name="oops  when I mount  nfs with -o fsc.eml"
Content-Disposition: inline;
 filename="oops  when I mount  nfs with -o fsc.eml"

X-Mozilla-Keys: 
Message-ID: <4F83E9FE.6010609@cn.fujitsu.com>
Date: Tue, 10 Apr 2012 16:06:22 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
User-Agent: Thunderbird 2.0.0.9 (Windows/20071031)
MIME-Version: 1.0
To: linux-nfs-owner@vger.kernel.org
Subject: oops  when I mount  nfs with -o fsc
Content-Type: multipart/mixed;
 boundary="------------050005050504050800010207"

This is a multi-part message in MIME format.
--------------050005050504050800010207
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

Hi all : in nfs(2.6.38), i do as following.=20
#cat /etc/exports
    /nfsroot      *(rw,no_root_squash,fsid=3D0,insecure)
#mount =E2=80=93t nfs4 =E2=80=93o fsc localhost:/   /nfsmnt
#sh create_file.sh

wait a while, i find oops.

PID: 4196   TASK: ffff88012365b580  CPU: 0   COMMAND: "sh"
 #0 [ffff880139435750] machine_kexec at ffffffff810310db
 #1 [ffff8801394357b0] crash_kexec at ffffffff810b63b2
 #2 [ffff880139435880] oops_end at ffffffff814dec50
 #3 [ffff8801394358b0] die at ffffffff8100f2fb
 #4 [ffff8801394358e0] do_trap at ffffffff814de544
 #5 [ffff880139435940] do_invalid_op at ffffffff8100ceb5
 #6 [ffff8801394359e0] invalid_op at ffffffff8100bf5b
    [exception RIP: __nfs_fscache_invalidate_page+121]
 #7 [ffff880139435ab0] nfs_invalidate_page at ffffffffa06fff6e [nfs]
 #8 [ffff880139435ad0] do_invalidatepage at ffffffff811243d5
 #9 [ffff880139435ae0] truncate_inode_page at ffffffff811245f2
#10 [ffff880139435b00] truncate_inode_pages_range at ffffffff811248f0
#11 [ffff880139435bf0] truncate_inode_pages at ffffffff81124c05
#12 [ffff880139435c00] truncate_pagecache at ffffffff81124c57
#13 [ffff880139435c30] nfs_setattr_update_inode at ffffffffa07033ab [nfs]=

#14 [ffff880139435c70] nfs4_proc_setattr at ffffffffa071bb45 [nfs]
#15 [ffff880139435cb0] nfs_setattr at ffffffffa07043e0 [nfs]
#16 [ffff880139435cf0] notify_change at ffffffff8118e0c8
#17 [ffff880139435d60] do_truncate at ffffffff81170a84
#18 [ffff880139435dd0] do_filp_open at ffffffff81182ba9
#19 [ffff880139435f20] do_sys_open at ffffffff8116f849
#20 [ffff880139435f70] sys_open at ffffffff8116f960
#21 [ffff880139435f80] tracesys at ffffffff8100b387 (via system_call)





--------------050005050504050800010207
Content-Type: text/plain;
 name="create_file.sh"
Content-Disposition: inline;
 filename="create_file.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/bash
i=3D0
BEGIN=5FTIME=3D$(date +%s)
TIME=5FOUT=3D14400 #Set the testTime.
SERVER=5FFILE=3D"/nfsroot/file"
CLIENT=5FFILE=3D"/nfsmnt/file"
while :
do
    dd if=3D/dev/zero of=3D"$SERVER=5FFILE$i" bs=3D1b count=3D1 &>/dev/null
    cat "$CLIENT=5FFILE$i" &>/dev/null
    echo "good" > "$CLIENT=5FFILE$i"
    rm -fr "$CLIENT=5FFILE$i"
    now=3D$(date +%s)
    if (($now - $BEGIN=5FTIME > $TIME=5FOUT))
    then
        break
    fi
        let i=3Di+1
done

echo "This probleam may be fix.\n"
=

--------------050005050504050800010207--


--------------040605060001050403010000--
