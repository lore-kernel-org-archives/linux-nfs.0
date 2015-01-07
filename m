Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:46764 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751819AbbAGUEo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jan 2015 15:04:44 -0500
Received: from acsinet21.oracle.com (acsinet21.oracle.com [141.146.126.237])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t07K4h5T027605
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 7 Jan 2015 20:04:44 GMT
Received: from userz7021.oracle.com (userz7021.oracle.com [156.151.31.85])
	by acsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id t07K4gHT029723
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 7 Jan 2015 20:04:43 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by userz7021.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id t07K4gHE025481
	for <linux-nfs@vger.kernel.org>; Wed, 7 Jan 2015 20:04:42 GMT
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=windows-1252
Subject: close(2) behavior when client holds a write delegation
Date: Wed, 7 Jan 2015 15:04:40 -0500
Message-Id: <D6EB7F1B-ADD3-40F6-8A7C-A00CBBA02FC9@oracle.com>
Cc: Dai Ngo <dai.ngo@oracle.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

Dai noticed that when a 3.17 Linux NFS client is granted a
write delegation, it neglects to flush dirty data synchronously
with close(2). The data is flushed asynchronously, and close(2)
completes immediately. Normally that’s OK. But Dai observed that:

1. If the server can’t accommodate the dirty data (eg ENOSPC or
   EIO) the application is not notified, even via close(2) return
   code.

2. If the server is down, the application does not hang, but it
   can leave dirty data in the client’s page cache with no
   indication to applications or administrators.

   The disposition of that data remains unknown even if a umount
   is attempted. While the server is down, the umount will hang
   trying to flush that data without giving an indication of why.

3. If a shutdown is attempted while the server is down and there
   is a pending flush, the shutdown will hang, even though there
   are no running applications with open files.

4. The behavior is non-deterministic from the application’s
   perspective. It occurs only if the server has granted a write
   delegation for that file; otherwise close(2) behaves like it
   does for NFSv2/3 or NFSv4 without a delegation present
   (close(2) waits synchronously for the flush to complete).

Should close(2) wait synchronously for a data flush even in the
presence of a write delegation?

It’s certainly reasonable for umount to try hard to flush pinned
data, but that makes shutdown unreliable.

Thanks for any thoughts!

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



