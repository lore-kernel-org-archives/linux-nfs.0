From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: NFS performance degradation of local loopback FS.
Date: Thu, 19 Jun 2008 12:16:23 +0530
Message-ID: <OF31144E99.0651F8EE-ON6525746D.001E6B1B-6525746D.002534E9@in.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=EABBFEFEDF8DED8B8f9e8a93df938690918cEABBFEFEDF8DED8B"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([59.145.155.4]:35215 "EHLO
	e28esmtp04.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755480AbYFSGrF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2008 02:47:05 -0400
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id m5J6kgDN021998
	for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2008 12:16:42 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5J6kOx01351906
	for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2008 12:16:24 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id m5J6kfDq011917
	for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2008 12:16:41 +0530
Received: from d23ml172.in.ibm.com (d23ml172.in.ibm.com [9.124.105.37])
	by d28av02.in.ibm.com (8.13.1/8.12.11) with ESMTP id m5J6kfVB011914
	for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2008 12:16:41 +0530
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--0__=EABBFEFEDF8DED8B8f9e8a93df938690918cEABBFEFEDF8DED8B
Content-type: text/plain; charset=US-ASCII


Hi,

I am running 2.6.25 kernel on a [4 way, 3.2 x86_64, 4GB] system. The test
is doing I/O on a local ext3 filesystem, and measuring the bandwidth, and
then NFS mounting the filesystem loopback on the same system. I have
configured 64 nfsd's to run. The test script is attached at the bottom.

My configuration is:
      /dev/some-local-disk  :            /local
      NFS mount /local       :            /nfs

The result is:
      200 processes:
            /local: 108000 KB/s
            /nfs:     66000 KB/s: Drop of 40%

      300 processes (KB/s):
            /local: 112000 KB/s
            /nfs:    57000 KB/s: Drop of 50%

I am not using any tuning, though I have tested with both
sunrpc.tcp_slot_table_entries=16 & 128

Is this big a drop expected for a loopback NFS mount? Any
feedback/suggestions are very
appreciated.

Thanks,

- KK

(See attached file: nfs)
--0__=EABBFEFEDF8DED8B8f9e8a93df938690918cEABBFEFEDF8DED8B
Content-type: application/octet-stream;
	name="nfs"
Content-Disposition: attachment; filename="nfs"
Content-transfer-encoding: base64

dHlwZXNldCAtaSBpCgojIEFyZ3VtZW50czogSS9PIHNpemUsIFByb2Nlc3NlcywgVGltZSB0byBy
dW4sIEZpbGVzeXN0ZW0gcHJlZml4LCBlZzoKIwk0MDk2IDIwMCAxMCAvbG9jYWwvZGRwOyBBTkQ6
CiMJNDA5NiAyMDAgMTAgL25mcy9kZHAKIyBGb3IgYnVmc2l6ZTo0SywgcHJvY3M6MjAwLCB0aW1l
OjEwc2VjcywgRmlsZXN5c3RlbSBwcmVmaXg6IHJlbWFpbmRlci4KIyAgICAgICB3aGVyZSAvbG9j
YWwgaXMgYW4gZXh0MyBmaWxlc3lzdGVtIE5GU3YzIG1vdW50ZWQgb24gL25mcwoKYnVmc2l6ZT0k
MQptYXg9JDIKdGltZT0kMwpwcmVmaXg9JDQKCmRpcj1gZGlybmFtZSAkcHJlZml4YApsb2NhbHBy
ZWZpeD1gZWNobyAkcHJlZml4IHwgc2VkICdzL25mcy9sb2NhbC8nYAoKaT0wCndoaWxlIFsgJGkg
LWx0ICRtYXggXQpkbwoJZGQgaWY9L2Rldi96ZXJvIG9mPSRwcmVmaXguJGkgYnM9JGJ1ZnNpemUg
Y291bnQ9MTAwMDAwMDAwMDAwICYKCWk9JGkrMQpkb25lCgpzbGVlcCAkdGltZQoKa2lsbCAtOSBg
cHMgfCBncmVwIGRkIHwgZ3JlcCAtdiBncmVwIHwgYXdrICd7cHJpbnQgJDF9J2AgPiAvZGV2L251
bGwgMj4mMQoKIyBraWxsIHRha2VzIHRvbyBsb25nIHRvIGZpbmlzaCwgcHJlc2VydmUgdGhlIHN0
YXRlIHVzaW5nIHRoZSBsb2NhbAojIGZpbGVzeXN0ZW0gdG8gZ2V0IGltbWVkaWF0ZSBhbmQgcXVp
Y2sgcmVzdWx0cykuCmxzIC1sICRsb2NhbHByZWZpeCogPiAvdG1wLyQkCgp0b3RhbD1gY2F0IC90
bXAvJCQgfCBhd2sgJ3twcmludCAkNX0nIHwgYWRkYApidz1gZWNobyAiJHRvdGFsIC8gJHRpbWUg
LyAxMDI0IiB8IGJjYAplY2hvICJUb3RhbDogJHRvdGFsIGJ5dGVzIGluICR0aW1lIHNlYyA9ICRi
dyBLQi9zZWMiCg==

--0__=EABBFEFEDF8DED8B8f9e8a93df938690918cEABBFEFEDF8DED8B--

