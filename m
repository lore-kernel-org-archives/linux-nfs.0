Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-out.cae.wisc.edu ([144.92.12.194]:48570 "EHLO
	smtp-out.cae.wisc.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754887AbaIRNHi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Sep 2014 09:07:38 -0400
Received: from smtp.cae.wisc.edu (smtp.cae.wisc.edu [144.92.12.51])
	by smtp-out.cae.wisc.edu (8.14.3/8.14.3/Debian-9.4) with ESMTP id s8ID2XW6004118
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Thu, 18 Sep 2014 08:02:33 -0500
Received: from [IPv6:2607:f388:1082:ffff:e967:18c3:7248:60ad] ([IPv6:2607:f388:1082:ffff:e967:18c3:7248:60ad])
	(authenticated bits=0)
	by smtp.cae.wisc.edu (8.14.3/8.14.3/Debian-9.4) with ESMTP id s8ID2T0i009447
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Thu, 18 Sep 2014 08:02:29 -0500
Message-ID: <541AD7E5.8020409@engr.wisc.edu>
Date: Thu, 18 Sep 2014 08:02:29 -0500
From: James Drews <drews@engr.wisc.edu>
Reply-To: drews@engr.wisc.edu
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: NFS Kernel Bug
Content-Type: multipart/mixed;
 boundary="------------060402020204070106090003"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060402020204070106090003
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Good morning!

I believe we have found a bug in the NFS kernel area.  The "bug" is a 
leak of a file handle where the NFS client never tells the server to 
close the file. The problem is very similar to one we had reported and 
got a fix for previously. We are using that patch, but ran in to another 
case where the client sends out an OPEN_DOWNGRADE but never sends a CLOSE.

Attached is a simple c program that we have been able to reproduce the 
bug with, along with a packet capture of what we see on the wire.

To reproduce the bug:
-compile the c code
-execute the c code with:

./test ; cat testfile3 > /dev/nul

-now if we try to remove the file we get a file in use error (server is 
using mandatory locking)

Things to note:

-if you just run the program without the immediate cat'ing of the file, 
the bug does not happen
suggesting a timing issue
-If you alter the program so the code mimics the cat of the file, the 
bug does not happen (ie, add an open, read file, close to the code).
-If you run the program as described above, and then run it again 
without the "; cat testfile3 > /dev/nul", the kernel squeaks out the 
file close to the server when the code does the close.

The attached packet capture is us doing:

./test ; cat testfile3 > /dev/null
rm testfile3
./test
rm testfile3

where we are denied the rm the first time, but not the second.


Thanks
James


--------------060402020204070106090003
Content-Type: application/softgrid-c;
 name="test.c"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="test.c"

I2luY2x1ZGUgPHN0ZGlvLmg+CiNpbmNsdWRlIDxzeXMvdHlwZXMuaD4KI2luY2x1ZGUgPHN5
cy9zdGF0Lmg+CiNpbmNsdWRlIDx1bmlzdGQuaD4KI2luY2x1ZGUgPGZjbnRsLmg+CiNpbmNs
dWRlIDxzdGRsaWIuaD4KCiNkZWZpbmUgVEhFRklMRSAidGVzdGZpbGUzIgoKdm9pZCBtYWlu
KHZvaWQpCnsKCWludCBmZD1vcGVuKFRIRUZJTEUsT19SRFdSfE9fQ1JFQVR8T19UUlVOQywg
MDY2Nik7CgkKCXZvaWQgKmJ1Zj1tYWxsb2MoNTAwMDAwKTsKCWlmKGJ1ZikKCXsKCQlsc2Vl
ayhmZCwgMTMxMDcyLCBTRUVLX1NFVCk7CgkJbHNlZWsoZmQsMjc2ODAsU0VFS19DVVIpOwoJ
CXdyaXRlKGZkLCJUSElTIElTIFNPTUUgREFUQSIsMTgpOwoJCWZyZWUoYnVmKTsKCX0KCWVs
c2UKCXsKCQlwcmludGYoIkkgY291bGRuJ3QgYWxsb2NhdGUgdGhlIGJ1ZmZlci5cbiIpOwoJ
fQoJY2xvc2UoZmQpOwoJCn0K
--------------060402020204070106090003
Content-Type: application/x-zip-compressed;
 name="nfsbug.zip"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="nfsbug.zip"

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
AAAAAA==
--------------060402020204070106090003--
