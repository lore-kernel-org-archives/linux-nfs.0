Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:6273 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753765Ab2KWE0a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Nov 2012 23:26:30 -0500
Message-ID: <50AEFC73.5040706@cn.fujitsu.com>
Date: Fri, 23 Nov 2012 12:32:51 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>, bfields@fieldses.org
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        =?ISO-2022-JP?B?GyRCZ3dEK0RyGyhC?= <fanchaoting@cn.fujitsu.com>
Subject: nfs cache bug (when server delete the file ,nfs client can read file
 also)
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,everyone. I found a big bug abount nfs cache.

when server delete the file ,nfs client can read file also.

the following is the reproduce.

ip: 192.168.0.19  nfs-client
ip: 192.168.0.20  nfs-client
ip: 192.168.0.21  nfs-server

############################################################################

/usr/bin/ssh -n 192.168.0.21 service nfs start
/usr/bin/ssh -n 192.168.0.21 /usr/sbin/rpc.idmapd
/usr/bin/ssh -n 192.168.0.19 /usr/sbin/rpc.idmapd
/usr/bin/ssh -n 192.168.0.20 /usr/sbin/rpc.idmapd
/usr/bin/ssh -n 192.168.0.21 "rm -rf /nfsroot; mkdir -p /nfsroot"
/usr/bin/ssh -n 192.168.0.21 /usr/sbin/exportfs -au
/usr/bin/ssh -n 192.168.0.21 /usr/sbin/exportfs -i -o insecure,no_root_squash,rw,fsid=0 *:/nfsroot
/usr/bin/ssh -n 192.168.0.19 test -d /nfsroot || (rm -rf /nfsroot; mkdir -p /nfsroot)
/usr/bin/ssh -n 192.168.0.20 test -d /nfsroot || (rm -rf /nfsroot; mkdir -p /nfsroot)

/usr/bin/ssh -n 192.168.0.19 umount /nfsroot
/usr/bin/ssh -n 192.168.0.20 umount /nfsroot
cmd="echo \"hello world\" > /nfsroot/tmpfile"
/usr/bin/ssh -n 192.168.0.21 $cmd
/usr/bin/ssh -n 192.168.0.21 mkdir /nfsroot/tmpdir
/usr/bin/ssh -n 192.168.0.21 touch /nfsroot/tmpdir/tmpdfile
/usr/bin/ssh -n 192.168.0.19 mount -t nfs4 192.168.0.21:/ /nfsroot
/usr/bin/ssh -n 192.168.0.20 mount -t nfs4 192.168.0.21:/ /nfsroot
/usr/bin/ssh -n 192.168.0.21 cat  /nfsroot/tmpfile
/usr/bin/ssh -n 192.168.0.21 ls -l /nfsroot/tmpdir
/usr/bin/ssh -n 192.168.0.19 cat  /nfsroot/tmpfile
/usr/bin/ssh -n 192.168.0.19 ls -l  /nfsroot/tmpdir
/usr/bin/ssh -n 192.168.0.20 cat  /nfsroot/tmpfile
/usr/bin/ssh -n 192.168.0.20 ls -l  /nfsroot/tmpdir
/usr/bin/ssh -n 192.168.0.19 cat /nfsroot/tmpfile > /dev/null
/usr/bin/ssh -n 192.168.0.20 cat /nfsroot/tmpfile > /dev/null
/usr/bin/ssh -n 192.168.0.21 rm -rf /nfsroot/tmpfile
echo -e "sleep 60~~~~~~~~\n"
sleep 60

#############################################################################

last: In 192.168.0.19 I do:

#cat /nfsroot/tmpfile           <--the nfs server delete the file,but nfs client can read the file
 hello world


I think  when the nfs server delete the file ,
the  server should notice the nfs client,
but the upstream kernel does't this.
 




