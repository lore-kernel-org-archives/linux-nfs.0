From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: [PATCH] zerocopy NFS for 2.5.33
Date: Mon, 09 Sep 2002 16:11:23 +0900 (JST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20020909.161123.74745039.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hello,

I updated the patches for zerocopy NFS. You can apply them against
linux-2.5.33 and zerocopy NFS over UDP/TCP works very fine.

1)
ftp://ftp.valinux.co.jp/pub/people/taka/tune/2.5.33/va10-hwchecksum-2.5.33.patch
This patch enables HW-checksum against outgoing packets including UDP frames.

2)
ftp://ftp.valinux.co.jp/pub/people/taka/tune/2.5.33/va11-udpsendfile-2.5.33.patch
This patch makes sendfile systemcall over UDP work. It also supports
UDP_CORK interface which is very similar to TCP_CORK. And you can call
sendmsg/senfile with MSG_MORE flags over UDP sockets too.

Using TSO code is commented out at this moment as TSO for UDP isn't
implemented yet. I'm waiting for it so that we would remove "#ifdef NotYet"
to send jumbo UDP frames without any fragmentation and any checksumming.
Then I hope we will get great performance.

3)
ftp://ftp.valinux.co.jp/pub/people/taka/tune/2.5.33/va-csumpartial-fix-2.5.33.patch
This patch fixes the problem of x86 csum_partilal() routines which
can't handle odd addressed buffers.

4)
ftp://ftp.valinux.co.jp/pub/people/taka/tune/2.5.33/va01-zerocopy-rpc-2.5.33.patch
This patch makes RPC be able to send some pieces of data and pages
without any copies.

5)
ftp://ftp.valinux.co.jp/pub/people/taka/tune/2.5.33/va02-zerocopy-nfsdread-2.5.33.patch
This patch makes NFSD pass pages in pagecache to RPC layer directly
when NFS clinets request file-read.

6)
ftp://ftp.valinux.co.jp/pub/people/taka/tune/2.5.33/va03-zerocopy-nfsdreaddir-2.5.33.patch
nfsd_readdir can also send pages without copy.

7)
ftp://ftp.valinux.co.jp/pub/people/taka/tune/2.5.33/va04-zerocopy-shadowsock-2.5.33.patch
This patch makes per-cpu UDP sockets so that NFSD can send UDP frames on
each prosessor simultaneously.
Without the patch we can send only one UDP frame at the time as a UDP socket
have to be locked during sending some pages to serialize them.

8)
ftp://ftp.valinux.co.jp/pub/people/taka/tune/2.5.33/va05-zerocopy-tempsendto-2.5.33.patch
If you don't want to use sendfile over UDP yet, you can apply it instead
of 1) and 2) .


If you have any requests or comments, could you let me know.


Thank you,
Hirokazu Takahashi.
