Return-Path: linux-nfs-owner@vger.kernel.org
Received: from kms.syseleven.de ([176.74.58.26]:56455 "EHLO kms.syseleven.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756576Ab2IDJby convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Sep 2012 05:31:54 -0400
From: Andrew Holway <a.holway@syseleven.de>
Content-Type: text/plain; charset=us-ascii
Subject: NFS over RDMA small block DIRECT_IO bug
Date: Tue, 4 Sep 2012 11:31:49 +0200
Message-Id: <F416961E-A33A-44D3-A788-5EF598A0AAFE@syseleven.de>
To: kvm@vger.kernel.org, libvir-list@redhat.com, linux-nfs@vger.kernel.org
Mime-Version: 1.0 (Apple Message framework v1278)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello.

# Avi Kivity avi(a)redhat recommended I copy kvm in on this. It would also seem relevent to libvirt. #

I have a Centos 6.2 server and Centos 6.2 client.

[root@store ~]# cat /etc/exports 
/dev/shm				10.149.0.0/16(rw,fsid=1,no_root_squash,insecure)    (I have tried with non tempfs targets also)


[root@node001 ~]# cat /etc/fstab 
store.ibnet:/dev/shm             /mnt                 nfs          rdma,port=2050,defaults 0 0


I wrote a little for loop one liner that dd'd the centos net install image to a file called 'hello' then checksummed that file. Each iteration uses a different block size.

Non DIRECT_IO seems to work fine. DIRECT_IO with 512byte, 1K and 2K block sizes get corrupted.

I want to run my KVM guests on top of NFS over RDMA. My guests cannot create filesystems.

Thanks,

Andrew.

bug report: https://bugzilla.linux-nfs.org/show_bug.cgi?id=228

[root@node001 mnt]# for f in 512 1024 2048 4096 8192 16384 32768 65536 131072; do dd bs="$f" if=CentOS-6.3-x86_64-netinstall.iso of=hello iflag=direct oflag=direct && md5sum hello && rm -f hello; done

409600+0 records in
409600+0 records out
209715200 bytes (210 MB) copied, 62.3649 s, 3.4 MB/s
aadd0ffe3c9dfa35d8354e99ecac9276  hello -- 512 byte block 

204800+0 records in
204800+0 records out
209715200 bytes (210 MB) copied, 41.3876 s, 5.1 MB/s
336f6da78f93dab591edc18da81f002e  hello -- 1K block

102400+0 records in
102400+0 records out
209715200 bytes (210 MB) copied, 21.1712 s, 9.9 MB/s
f4cefe0a05c9b47ba68effdb17dc95d6  hello -- 2k block

51200+0 records in
51200+0 records out
209715200 bytes (210 MB) copied, 10.9631 s, 19.1 MB/s
690138908de516b6e5d7d180d085c3f3  hello -- 4k block

25600+0 records in
25600+0 records out
209715200 bytes (210 MB) copied, 5.4136 s, 38.7 MB/s
690138908de516b6e5d7d180d085c3f3  hello

12800+0 records in
12800+0 records out
209715200 bytes (210 MB) copied, 3.1448 s, 66.7 MB/s
690138908de516b6e5d7d180d085c3f3  hello

6400+0 records in
6400+0 records out
209715200 bytes (210 MB) copied, 1.77304 s, 118 MB/s
690138908de516b6e5d7d180d085c3f3  hello

3200+0 records in
3200+0 records out
209715200 bytes (210 MB) copied, 1.4331 s, 146 MB/s
690138908de516b6e5d7d180d085c3f3  hello

1600+0 records in
1600+0 records out
209715200 bytes (210 MB) copied, 0.922167 s, 227 MB/s
690138908de516b6e5d7d180d085c3f3  hello


