Return-Path: linux-nfs-owner@vger.kernel.org
Received: from kms.syseleven.de ([176.74.58.26]:58162 "EHLO kms.syseleven.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753037Ab2IDMwn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Sep 2012 08:52:43 -0400
Subject: Re: NFS over RDMA small block DIRECT_IO bug
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Andrew Holway <a.holway@syseleven.de>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908F82C6C@SACEXCMBX04-PRD.hq.netapp.com>
Date: Tue, 4 Sep 2012 14:52:33 +0200
Cc: "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
        "libvir-list@redhat.com" <libvir-list@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <35F7A1E0-49C5-4F8D-A00D-B11BC575708B@syseleven.de>
References: <F416961E-A33A-44D3-A788-5EF598A0AAFE@syseleven.de> <4FA345DA4F4AE44899BD2B03EEEC2FA908F82C6C@SACEXCMBX04-PRD.hq.netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> 
> That is expected behaviour. DIRECT_IO over RDMA needs to be page aligned
> so that it can use the more efficient RDMA READ and RDMA WRITE memory
> semantics (instead of the SEND/RECEIVE channel semantics).

Yes, I think I am understanding that now.

I need to find a way of getting around the lib-virt issue.

http://lists.gnu.org/archive/html/qemu-devel/2011-12/msg01570.html

Thanks,

Andrew


> 
>> I want to run my KVM guests on top of NFS over RDMA. My guests cannot create filesystems.
>> 
>> Thanks,
>> 
>> Andrew.
>> 
>> bug report: https://bugzilla.linux-nfs.org/show_bug.cgi?id=228
>> 
>> [root@node001 mnt]# for f in 512 1024 2048 4096 8192 16384 32768 65536 131072; do dd bs="$f" if=CentOS-6.3-x86_64-netinstall.iso of=hello iflag=direct oflag=direct && md5sum hello && rm -f hello; done
>> 
>> 409600+0 records in
>> 409600+0 records out
>> 209715200 bytes (210 MB) copied, 62.3649 s, 3.4 MB/s
>> aadd0ffe3c9dfa35d8354e99ecac9276  hello -- 512 byte block 
>> 
>> 204800+0 records in
>> 204800+0 records out
>> 209715200 bytes (210 MB) copied, 41.3876 s, 5.1 MB/s
>> 336f6da78f93dab591edc18da81f002e  hello -- 1K block
>> 
>> 102400+0 records in
>> 102400+0 records out
>> 209715200 bytes (210 MB) copied, 21.1712 s, 9.9 MB/s
>> f4cefe0a05c9b47ba68effdb17dc95d6  hello -- 2k block
>> 
>> 51200+0 records in
>> 51200+0 records out
>> 209715200 bytes (210 MB) copied, 10.9631 s, 19.1 MB/s
>> 690138908de516b6e5d7d180d085c3f3  hello -- 4k block
>> 
>> 25600+0 records in
>> 25600+0 records out
>> 209715200 bytes (210 MB) copied, 5.4136 s, 38.7 MB/s
>> 690138908de516b6e5d7d180d085c3f3  hello
>> 
>> 12800+0 records in
>> 12800+0 records out
>> 209715200 bytes (210 MB) copied, 3.1448 s, 66.7 MB/s
>> 690138908de516b6e5d7d180d085c3f3  hello
>> 
>> 6400+0 records in
>> 6400+0 records out
>> 209715200 bytes (210 MB) copied, 1.77304 s, 118 MB/s
>> 690138908de516b6e5d7d180d085c3f3  hello
>> 
>> 3200+0 records in
>> 3200+0 records out
>> 209715200 bytes (210 MB) copied, 1.4331 s, 146 MB/s
>> 690138908de516b6e5d7d180d085c3f3  hello
>> 
>> 1600+0 records in
>> 1600+0 records out
>> 209715200 bytes (210 MB) copied, 0.922167 s, 227 MB/s
>> 690138908de516b6e5d7d180d085c3f3  hello
>> 
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


