Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:57050 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423Ab1A0TdV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jan 2011 14:33:21 -0500
Received: from rcsinet13.oracle.com (rcsinet13.oracle.com [148.87.113.125])
	by rcsinet10.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id p0RJXKgv018807
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 27 Jan 2011 19:33:21 GMT
Received: from acsmt354.oracle.com (acsmt354.oracle.com [141.146.40.154])
	by rcsinet13.oracle.com (Switch-3.4.2/Switch-3.4.1) with ESMTP id p0RJXHsp020315
	for <linux-nfs@vger.kernel.org>; Thu, 27 Jan 2011 19:33:17 GMT
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: Cthon basic test 6 fails over NFS v4
Date: Thu, 27 Jan 2011 14:32:36 -0500
Message-Id: <3C315A30-AD48-449B-8756-F5AAEEAB476F@oracle.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Client: Linux 2.6.38-rc2 x86_64
Server: OpenSolaris 5.11 snv_134
NFS version: 4.0

Connectathon basic test 6 fails over NFSv4, but not over NFSv3.

[cel@matisse cthon04]$ ./server -b
Start tests on path /mnt/klimt/matisse.test [y/n]? y

sh ./runtests  -b -t /mnt/klimt/matisse.test

Starting BASIC tests: test directory /mnt/klimt/matisse.test (arg: -t)

./test1: File and directory creation test
	created 155 files 62 directories 5 levels deep in 2.25 seconds
	./test1 ok.

./test2: File and directory removal test
	removed 155 files 62 directories 5 levels deep in 1.30 seconds
	./test2 ok.

./test3: lookups across mount point
	500 getcwd and stat calls in 0.0  seconds
	./test3 ok.

./test4: setattr, getattr, and lookup
	1000 chmods and stats on 10 files in 6.5  seconds
	./test4 ok.

./test5: read and write
	wrote 1048576 byte file 10 times in 0.72 seconds (14411197 bytes/sec)
	read 1048576 byte file 10 times in 0.0  seconds (-2147483648 bytes/sec)
	./test5 ok.

./test6: readdir
	./test6: (/mnt/klimt/matisse.test) didn't read expected 'file.12' dir entry, pass 0
	./test6: (/mnt/klimt/matisse.test) didn't read expected 'file.82' dir entry, pass 0
	./test6: (/mnt/klimt/matisse.test) didn't read expected 'file.164' dir entry, pass 0
	./test6: (/mnt/klimt/matisse.test) Test failed with 3 errors
basic tests failed
Tests failed, leaving /mnt/klimt mounted
[cel@matisse cthon04]$

"ls /mnt/klimt/matisse.test" shows the series of test files, missing the three called out above.

"ls /share/test/matisse.test" on the server shows all of the files, including the three called out above.

Unmounting and mounting /mnt/klimt/matisse.test shows the same result (these three missing).  A network trace captured during the "ls" shows that these files are returned by the server.

Unmounting and mounting /mnt/klimt/matisse.test with "vers=3" shows an identical list of files as "ls" on the server, and Cthon test 6 works fine over vers=3.

This failure is 100% reproducible: always three files are missing, but not always the same three.

Evidence suggests a problem with the client's NFSv4 readdir result decoder logic, but I wanted to check to see if anyone has a fix or suggestions about where to look first.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




