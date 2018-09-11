Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cliff.cs.toronto.edu ([128.100.3.120]:40478 "EHLO
        cliff.cs.toronto.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726863AbeIKVTM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Sep 2018 17:19:12 -0400
From: Chris Siebenmann <cks@cs.toronto.edu>
To: linux-nfs@vger.kernel.org
cc: cks@cs.toronto.edu
Subject: A NFS client partial file corruption problem in recent/current kernels
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 11 Sep 2018 11:59:33 -0400
Message-Id: <20180911155933.CAAD2322562@apps1.cs.toronto.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 We've found a readily reproducable situation where the current
NFS client code will provide zero bytes instead of actual data at the
end of the file (sort of) to user programs. This can result in program
failure, or permanent file corruption if the program reading the file
writes the bad data back to the file; otherwise, the corruption goes
away when the client's cached data is pushed out of memory (or explicitly
dropped by dropping the pagecache through /proc/sys/vm/drop_caches).

 The reproduction steps are:

* on a NFS client, open the file read-write and read to the end of the
  file (possibly just read the end of the file).
* hold the file open read-write and wait for the file size to grow.

  All the bits of these first two steps appear to be required; you must
  read the end of the file, you must have the file open read-write,
  and you must hold it open read-write.

* on either another NFS client or the NFS server, append data to the
  file.

* now that your program sees the new file size, try to read the new
  data (from the old end of the file to the new end of the file).
  Any data from the old end of file up to the next 4 KB boundary will
  be zero bytes instead of its actual content; after that, it will be
  the proper new content.

I have a demonstration reproduction program here:
	https://www.cs.toronto.edu/~cks/vendors/linux-nfs/

This issue isn't present in the Ubuntu 16.04 LTS server kernel (labeled
as '4.4.0', plus years of Ubuntu changes) and is present in the Ubuntu
18.04 LTS kernel (labeled 4.15.0) and the Fedora 28 4.17.9 and 4.18.5
kernels. It happens on both NFSv3 and NFSv4 mounts (both with 'sec=sys')
and the NFS fileserver OS and the filesystem type (on Linux) doesn't
appear to matter; we initially saw this against OmniOS NFS servers using
ZFS and have reproduced this against Linux NFS servers on ext4, tmpfs,
and ZFS (ZFS on Linux) with both Ubuntu 18.04 and Fedora 28 kernels.

 This bug causes Alpine to fail when accessing your /var/mail inbox
over NFS (and you get new mail delivered to it). There are probably other
programs affected, although hopefully not many programs hold files open
read-write while other programs are appending data.

 I'd be happy to answer any further questions, but we have limited
ability to try different kernels or kernel changes to see if they change
the situation (we don't run stock kernels on any machines; they're all
vendor-based ones).

	- cks
