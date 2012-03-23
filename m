Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f174.google.com ([209.85.217.174]:39670 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751838Ab2CWLRG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Mar 2012 07:17:06 -0400
MIME-Version: 1.0
Date: Fri, 23 Mar 2012 16:47:04 +0530
Message-ID: <CAKX=r8A90b25VKXC1qtAota9DqDrj37xFT511DuvrZ=1Eux6Xw@mail.gmail.com>
Subject: NFS: low read/stat performance on small files
From: Vivek Trivedi <vtrivedi018@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Namjae Jeon <linkinjeon@gmail.com>
Cc: vtrivedi018@gmail.com, amit.sahrawat83@gmail.com
Content-Type: multipart/mixed; boundary=90e6ba25db951272db04bbe72ab7
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--90e6ba25db951272db04bbe72ab7
Content-Type: text/plain; charset=ISO-8859-1

Hi,
we are facing below 2 performance issue on NFS:

1. Read speed is low for small files
==========================

[ Log on NFS Client]

$ echo 3 > /proc/sys/vm/drop_caches
$ dd if=200KBfile.txt of=/dev/null
400+0 records in
400+0 records out
204800 bytes (200.0KB) copied, 0.027074 seconds, 7.2MB/s


Read speed for 200KB file is 7.2 MB


[ Log on NFS Client]

$ echo 3 > /proc/sys/vm/drop_caches
$ dd if=100MBfile.txt of=/dev/null
204800+0 records in
204800+0 records out
104857600 bytes (100.0MB) copied, 9.351221 seconds, 10.7MB/s

Read speed for 100MB file is 10.7 MB

As you see read speed for 200KB file is only 7.2MB/sec while it is
10.7 MB/sec when we read 100MB file.
Why there is so much difference in read performance ?
Is there any way to achieve high read speed for small files ?


2. Read/stat for a directory tree is slow on NFS than local
==========================================

we have lot of *.jpg files in a directory. If we try to "stat" and
"read" from this directory,
 performannce is very slow on NFS Client compared to Local(NFS server)
"stat" and "read"


[ Log on Local (NFS Server) ]

$ echo 3 > /proc/sys/vm/drop_caches
$ ./stat_read_files_test ./lot_of_jpg_files/
 Time Taken : 9288 msec


[ Log on NFS Client]

$ echo 3 > /proc/sys/vm/drop_caches
$ ./stat_read_files_test ./lot_of_jpg_files/
 Time Taken : 19966 msec

As you see, on NFS client time taken is almost *double* than that of
local(NFS server)
We are using UDP with rsize,wsize=32k on 100MB ethernet link.
I am attaching read/stat testcase.

Is there any way to improve this performance ?


Thanks,
Vivek

--90e6ba25db951272db04bbe72ab7
Content-Type: text/x-csrc; charset=US-ASCII; name="traversepath.c"
Content-Disposition: attachment; filename="traversepath.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_h054l8xe0

I2luY2x1ZGUgPHN0ZGlvLmg+DQojaW5jbHVkZSA8c3lzL3R5cGVzLmg+DQojaW5jbHVkZSA8c3lz
L3N0YXQuaD4NCiNpbmNsdWRlIDx1bmlzdGQuaD4NCiNpbmNsdWRlIDxmY250bC5oPg0KI2luY2x1
ZGUgPHN0cmluZy5oPg0KI2luY2x1ZGUgPHN5cy90aW1lLmg+DQoNCiNkZWZpbmUgQlVGRkVSU0la
RSA0MDk2DQpjaGFyIFJFQURCVUZGRVJbQlVGRkVSU0laRV07DQoNCiNpbmNsdWRlIDxkaXJlbnQu
aD4NCmludCBUcmF2ZXJzZVBhdGgoY2hhciAqcGF0aCkNCnsNCglzdHJ1Y3QgZGlyZW50ICpkID0g
TlVMTDsNCglESVIgKmRpciA9IE5VTEw7IC8qIHBvaW50ZXIgdG8gZGlyZWN0b3J5IGhlYWQqLw0K
CWNoYXIgYnVmWzI1NV09ezB9OyAvKiBidWZmZXIgdG8gc3RvcmUgdGhlIGNvbXBsZXRlIGZpbGUv
ZGlyIG5hbWUqLw0KCXN0cnVjdCBzdGF0IHN0YXRidWY7IC8qIHRvIG9idGFpbiB0aGUgc3RhdGlz
dGljcyBvZiBmaWxlL2RpciAqLw0KCWludCByZXR2YWwgPTA7IC8qIHRvIGhvbGQgdGhlIHJldHVy
biB2YWx1ZSovDQoJaW50IGZkID0gMDsNCg0KCW1lbXNldCgmc3RhdGJ1ZiwwLHNpemVvZihzdHJ1
Y3Qgc3RhdCkpOyANCg0KCXJldHZhbCA9IHN0YXQocGF0aCwmc3RhdGJ1Zik7DQoNCgkvKiBpZiB0
aGUgc3RhdCByZXR1cm5lZCBzdWNjZXNzIGFuZCBwYXRoIHByb3ZpZGVkIGlzIG9mIHZhbGlkIGRp
cmVjdG9yeSovDQoJaWYoU19JU0RJUihzdGF0YnVmLnN0X21vZGUpICYmIChyZXR2YWw9PTApKQ0K
CXsNCgkJZGlyID0gb3BlbmRpcihwYXRoKTsgLyogb3BlbiB0aGUgZGlyZWN0b3J5Ki8JDQoJCS8q
IHJlYWRzIGVudHJ5IG9uZSBieSBvbmUqLw0KCQl3aGlsZSgoZCA9IHJlYWRkaXIoZGlyKSkgIT0g
TlVMTCkNCgkJew0KCQkJaWYoKHN0cmNtcChkLT5kX25hbWUsIi4iKSE9MCkgJiYgKHN0cmNtcChk
LT5kX25hbWUsIi4uIikhPTApKQ0KCQkJew0KCQkJCXNwcmludGYoYnVmLCIlcy8lcyIscGF0aCxk
LT5kX25hbWUpOw0KCQkJCXJldHZhbCA9IHN0YXQoYnVmLCZzdGF0YnVmKTsNCgkJCQlpZihyZXR2
YWwgPT0gMCkNCgkJCQl7DQoJCQkJCWlmKCFTX0lTRElSKHN0YXRidWYuc3RfbW9kZSkpDQoJCQkJ
CXsJCQ0KCQkJCQkJLyogVGhpcyBpcyBmaWxlIC0gcmVhZCBmcm9tIHRoaXMsIFNpbmNlIHJlYWQg
YWhlYWQgDQoJCQkJCQkgKiB3aWxsIGl0c2VsZiBicmluZyAxMjhLQiwgc28gd2UgY2FuIGp1c3Qg
cmVhZCA0S0INCgkJCQkJCSAqIHRvIHN0YXJ0IHdpdGggKi8NCgkJCQkJCWZkID0gb3BlbihidWYs
T19SRE9OTFksKG1vZGVfdCk3NzcpOw0KCQkJCQkJaWYoZmQpIHsNCgkJCQkJCQlyZWFkKGZkLCBS
RUFEQlVGRkVSLCBCVUZGRVJTSVpFKTsNCgkJCQkJCQljbG9zZShmZCk7CQ0KCQkJCQkJfQ0KCQkJ
CQl9DQoJCQkJCWVsc2UNCgkJCQkJew0KCQkJCQkJLyoNCgkJCQkJCSAgIFRoaXMgaXMgYSBkaXJl
Y3RvcnksIHJlY3Vyc2l2ZSBzZWFyY2ggaW4gaXQNCgkJCQkJCSAgIG9uY2UgYWxsIGZpbGVzIGFy
ZSByZWFkDQoJCQkJCQkgKi8NCgkJCQkJCVRyYXZlcnNlUGF0aChidWYpOw0KCQkJCQl9DQoJCQkJ
fQ0KCQkJCWVsc2UNCgkJCQl7DQoJCQkJCXBlcnJvcigic3RhdCBmYWlsZWRcbiIpOw0KCQkJCX0N
CgkJCX0NCgkJfQ0KCX0NCgllbHNlDQoJew0KCQlwZXJyb3IoIkZhaWxlZCIpOw0KCX0JDQoJcmV0
dXJuIHJldHZhbDsNCn0NCg0KaW50IG1haW4oaW50IGFyZ2MsIGNoYXIgKiphcmd2KQkNCnsNCglz
dHJ1Y3QgdGltZXZhbCBydjsNCglzdHJ1Y3QgdGltZXZhbCBydjE7DQoNCglpbnQgc3RhdF90aW1l
ID0gMDsNCg0KCWlmKGFyZ2MgPCAyKSB7DQoJCXByaW50ZigiLi9UcmF2ZXJzZVBhdGggPHBhdGg+
IFxuIik7DQoJCXJldHVybiAwOw0KCX0JDQoNCgkvL1RyYXZlcnNlIHRoZSBjb21wbGV0ZSBwYXRo
IGluc2lkZSB0aW1pbmcgdW5pdA0KCWdldHRpbWVvZmRheSgmcnYsIDApOw0KCVRyYXZlcnNlUGF0
aChhcmd2WzFdKTsNCglnZXR0aW1lb2ZkYXkoJnJ2MSwgMCk7DQoNCglzdGF0X3RpbWUgPSAocnYx
LnR2X3NlYyAqIDEwMDAgKyBydjEudHZfdXNlYyAvIDEwMDApIC0gKHJ2LnR2X3NlYyAqIDEwMDAg
KyBydi50dl91c2VjIC8gMTAwMCk7DQoNCglwcmludGYoIiBUcmF2ZXJzZWQgUGF0aCA6ICVzIFxu
IiwgYXJndlsxXSk7DQoJcHJpbnRmKCIgVGltZSBUYWtlbiA6ICVkIG1zZWMgXG4iLHN0YXRfdGlt
ZSk7DQoNCglyZXR1cm4gMDsNCn0NCg==
--90e6ba25db951272db04bbe72ab7--
