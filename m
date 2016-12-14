Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:48198 "EHLO
        heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751055AbcLNHhW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Dec 2016 02:37:22 -0500
Received: from G08CNEXCHPEKD03.g08.fujitsu.local (unknown [10.167.33.85])
        by cn.fujitsu.com (Postfix) with ESMTP id 5E5CC4670485
        for <linux-nfs@vger.kernel.org>; Wed, 14 Dec 2016 15:37:05 +0800 (CST)
From: Ditang Chen <chendt.fnst@cn.fujitsu.com>
Subject: Opening non-existent file returns different value when
 O_CREAT|O_DIRECTORY is used
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-ID: <46d6805b-7ead-1c9d-af2d-59caf4a87016@cn.fujitsu.com>
Date: Wed, 14 Dec 2016 15:33:43 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all

On NFSv3, NFSv4 and xfs, opening non-existent file returns different value when 
O_CREAT|O_DIRECTORY is used, Is this the right behavior?


TEST LOG:
# cat open_tets.py 
#!/bin/python
import posix
fd = posix.open("/mnt/XXXX/file",posix.O_CREAT|posix.O_DIRECTORY, 0777)
print fd
posix.close(fd)

*xfs*
# ./open_test.py 
3                                 -- Create a file and return fd.
# ./open_test.py 
Traceback (most recent call last):
  File "./open_test.py", line 3, in <module>
    fd = posix.open("/mnt/xfs/file",posix.O_CREAT|posix.O_DIRECTORY, 0777)
OSError: [Errno 20] Not a directory: '/mnt/xfs/file'

*NFSv3*
# ./open_test.py 
3                                -- Create a file and return fd.
# ./open_test.py 
Traceback (most recent call last):
  File "./open_test.py", line 3, in <module>
    fd = posix.open("/mnt/nfsv3/file",posix.O_CREAT|posix.O_DIRECTORY, 0777)
OSError: [Errno 20] Not a directory: '/mnt/nfsv3/file'

*NFSv4.x*
# ./open_test.py 
Traceback (most recent call last):      -- return ENOENT err directly.
  File "./open_test.py", line 3, in <module>
    fd = posix.open("/mnt/nfsv4/file",posix.O_CREAT|posix.O_DIRECTORY, 0777)
OSError: [Errno 2] No such file or directory: '/mnt/nfsv4/file'

--


