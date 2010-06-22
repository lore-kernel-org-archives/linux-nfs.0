Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:57861 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752847Ab0FVTDn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jun 2010 15:03:43 -0400
Message-ID: <4C2108E7.6040909@oracle.com>
Date: Tue, 22 Jun 2010 15:03:03 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: NFSv3 list <linux-nfs@vger.kernel.org>
Subject: Connectathon locking test fails over NFSv3 with EBUSY
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

It looks like the connectathon tests race with the removal of deleted 
files.  The actual lock test is successful, but when the scripts attempt 
to reset the test directory for another pass, the RMDIR fails because 
the directory is full of ".nfsxxx" files.

Seems like RMDIR should wait for those silly deletes before trying to 
remove the parent directory.

I've seen this with both 2.6.34 and 2.6.35-rc3 clients, and it happens 
nearly every time.


Test #15 - Test 2nd open and I/O after lock and close.
	Parent: Second open succeeded.
	Parent: 15.0  - F_LOCK  [               0,          ENDING] PASSED.
	Parent: 15.1  - F_ULOCK [               0,          ENDING] PASSED.
	Parent: Closed testfile.
	Parent: Wrote 'abcdefghij' to testfile [ 0, 11 ].
	Parent: Read 'abcdefghij' from testfile [ 0, 11 ].
	Parent: 15.2  - COMPARE [               0,               b] PASSED.

** PARENT pass 1 results: 49/49 pass, 1/1 warn, 0/0 fail (pass/total).

**  CHILD pass 1 results: 64/64 pass, 0/0 warn, 0/0 fail (pass/total).
Congratulations, you passed the locking tests!
... Pass 2 ...

rm: cannot remove 
`/mnt/klimt/ellison.test/.nfs0000000000000d8e00000041': Device or 
resource busy
rm: cannot remove 
`/mnt/klimt/ellison.test/.nfs0000000000000df100000050': Device or 
resource busy
rm: cannot remove 
`/mnt/klimt/ellison.test/.nfs0000000000000dfb0000004a': Device or 
resource busy
rm: cannot remove 
`/mnt/klimt/ellison.test/.nfs0000000000000dec00000047': Device or 
resource busy
rm: cannot remove 
`/mnt/klimt/ellison.test/.nfs0000000000000df90000004b': Device or 
resource busy
rm: cannot remove 
`/mnt/klimt/ellison.test/.nfs0000000000000dfa0000004e': Device or 
resource busy
rm: cannot remove 
`/mnt/klimt/ellison.test/.nfs0000000000000df80000004f': Device or 
resource busy
rm: cannot remove 
`/mnt/klimt/ellison.test/.nfs0000000000000df20000004c': Device or 
resource busy
rm: cannot remove 
`/mnt/klimt/ellison.test/.nfs0000000000000deb00000051': Device or 
resource busy
rm: cannot remove 
`/mnt/klimt/ellison.test/.nfs0000000000000def00000048': Device or 
resource busy
rm: cannot remove 
`/mnt/klimt/ellison.test/.nfs0000000000000dea0000004d': Device or 
resource busy
rm: cannot remove 
`/mnt/klimt/ellison.test/.nfs0000000000000de900000049': Device or 
resource busy
Starting BASIC tests: test directory /mnt/klimt/ellison.test (arg: -t)
mkdir: cannot create directory `/mnt/klimt/ellison.test': File exists

./test1: File and directory creation test
rm: cannot remove 
`/mnt/klimt/ellison.test/.nfs0000000000000d8e00000041': Device or 
resource busy
rm: cannot remove 
`/mnt/klimt/ellison.test/.nfs0000000000000df100000050': Device or 
resource busy
rm: cannot remove 
`/mnt/klimt/ellison.test/.nfs0000000000000dfb0000004a': Device or 
resource busy
rm: cannot remove 
`/mnt/klimt/ellison.test/.nfs0000000000000dec00000047': Device or 
resource busy
rm: cannot remove 
`/mnt/klimt/ellison.test/.nfs0000000000000df90000004b': Device or 
resource busy
rm: cannot remove 
`/mnt/klimt/ellison.test/.nfs0000000000000dfa0000004e': Device or 
resource busy
rm: cannot remove 
`/mnt/klimt/ellison.test/.nfs0000000000000df80000004f': Device or 
resource busy
rm: cannot remove 
`/mnt/klimt/ellison.test/.nfs0000000000000df20000004c': Device or 
resource busy
rm: cannot remove 
`/mnt/klimt/ellison.test/.nfs0000000000000deb00000051': Device or 
resource busy
rm: cannot remove 
`/mnt/klimt/ellison.test/.nfs0000000000000def00000048': Device or 
resource busy
rm: cannot remove 
`/mnt/klimt/ellison.test/.nfs0000000000000dea0000004d': Device or 
resource busy
rm: cannot remove 
`/mnt/klimt/ellison.test/.nfs0000000000000de900000049': Device or 
resource busy
	./test1: (/home/cel/src/cthon04/basic) can't remove old test directory 
/mnt/klimt/ellison.test
basic tests failed
Tests failed, leaving /mnt/klimt mounted
[cel@ellison cthon04]$

-- 
Chuck Lever
