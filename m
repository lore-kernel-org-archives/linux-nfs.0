From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: [PATCH] zerocopy NFS for 2.5.35
Date: Mon, 16 Sep 2002 16:39:36 +0900 (JST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20020916.163936.74738298.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
List-ID: <nfs.lists.sourceforge.net>

Hello,

I announce to have ported the patches for for zerocopy NFS against
linux-2.5.35.
I added new feature that nfsd-write may use writev interface as 
writev is going to be faster than ever.
This feature can reduce not only cpu time but also overhead of
allocating HUGE socket buffers for NFS write.

1)
ftp://ftp.valinux.co.jp/pub/people/taka/2.5.35/va10-hwchecksum-2.5.35.patch
This patch enables HW-checksum against outgoing packets including UDP frames.

2)
ftp://ftp.valinux.co.jp/pub/people/taka/2.5.35/va11-udpsendfile-2.5.35.patch
This patch makes sendfile systemcall over UDP work. It also supports
UDP_CORK interface which is very similar to TCP_CORK. And you can call
sendmsg/senfile with MSG_MORE flags over UDP sockets.

3)
ftp://ftp.valinux.co.jp/pub/people/taka/2.5.35/va-csumpartial-fix-2.5.35.patch
This patch fixes the problem of x86 csum_partilal() routines which
can't handle odd addressed buffers.

4)
ftp://ftp.valinux.co.jp/pub/people/taka/2.5.35/va01-zerocopy-rpc-2.5.35.patch
This patch makes RPC can send some pieces of data and pages without copy.

5)
ftp://ftp.valinux.co.jp/pub/people/taka/2.5.35/va02-zerocopy-nfsdread-2.5.35.patch
This patch makes NFSD send pages in pagecache directly when NFS clinets request
file-read.

6)
ftp://ftp.valinux.co.jp/pub/people/taka/2.5.35/va03-zerocopy-nfsdreaddir-2.5.35.patch
nfsd_readdir can also send pages without copy.

7)
ftp://ftp.valinux.co.jp/pub/people/taka/2.5.35/va04-zerocopy-shadowsock-2.5.35.patch
This patch makes per-cpu UDP sockets so that NFSD can send UDP frames on
each prosessor simultaneously.
Without the patch we can send only one UDP frame at the time as a UDP socket
have to be locked during sending some pages to serialize them.

8)
ftp://ftp.valinux.co.jp/pub/people/taka/2.5.35/va05-zerocopy-nfsdwrite-2.5.35.patch
This patch enables NFS-write uses writev interface. NFSd can handle NFS
requests without reassembling IP fragments into one UDP frame.

9)
ftp://ftp.valinux.co.jp/pub/people/taka/2.5.35/va06-writev-2.5.35.patch
This patch makes writev for regular file work faster.

Caution:
       XFS doesn't support writev interface yet. NFS write on XFS might
       slow down with No.8 patch. I wish SGI guys will implement it.


10)
ftp://ftp.valinux.co.jp/pub/people/taka/2.5.35/va09-zerocopy-tempsendto-2.5.35.patch
If you don't want to use sendfile over UDP yet, you can apply it instead of No.1 and No.2 patches.


If you have any requests or comments, could you let me know.

Regards,
Hirokazu Takahashi
