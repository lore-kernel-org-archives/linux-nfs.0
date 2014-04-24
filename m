Return-Path: linux-nfs-owner@vger.kernel.org
Received: from webservice-1.1a-surfen.de ([85.214.51.101]:40039 "EHLO
	1a-surfen.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752140AbaDXHM5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Apr 2014 03:12:57 -0400
Message-ID: <4393.145.253.139.210.1398323174.squirrel@webmail.1a-surfen.de>
Date: Thu, 24 Apr 2014 09:06:14 +0200 (CEST)
Subject: Incredible slow performance with noac option
From: "Markus Grell" <tapestry@military.de>
To: linux-nfs@vger.kernel.org
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Greetings!

We're observing a very strange (?) behavior when doing some simple NFS tests:

As soon as we add the nfs mount option 'noac' or 'actimeo=0', NFS
performance dramatically drops from say 100 MB/s to 2.5 MB/s.
I searched archives a little bit and read that this option might have a
"slight performance impact", but what we observe is far away from being
"slight"...

What we tested:

Fresh NFS server using Ubuntu 14.04 LTS
Fresh NFS server using RedHat Enterprise 6.4

Ubuntu 12.04 client
Redhat Enterprise 6.4 Client
Oracle 5.7 Client

Content of /etc/exports:

/shared *(rw,async,no_wdelay,insecure_locks,no_root_squash,no_subtree_check)


Mount options:
mount -t nfs -o actimeo=0,tcp,vers=3 nfsserver:/shared /mnt/

The mounted /mnt directory only contains a single file.

'Tests' are done using simple "dd if=/mnt/largefile of=/dev/null"

Output of 'nfsstat -c':

Client rpc stats:
calls      retrans    authrefrsh
1171668    0          1171668

Client nfs v3:
null         getattr      setattr      lookup       access       readlink
0         0% 1159569  98% 0         0% 1         0% 17        0% 0         0%
read         write        create       mkdir        symlink      mknod
12055     1% 0         0% 0         0% 0         0% 0         0% 0         0%
remove       rmdir        rename       link         readdir      readdirplus
0         0% 0         0% 0         0% 0         0% 0         0% 2         0%
fsstat       fsinfo       pathconf     commit
0         0% 6         0% 3         0% 0         0%


Output of 'nfsstat -s'

Server rpc stats:
calls      badcalls   badclnt    badauth    xdrcall
1265267    0          0          0          0

Server nfs v3:
null         getattr      setattr      lookup       access       readlink
8         0% 1251701  98% 0         0% 1         0% 23        0% 0         0%
read         write        create       mkdir        symlink      mknod
13510     1% 0         0% 0         0% 0         0% 0         0% 0         0%
remove       rmdir        rename       link         readdir      readdirplus
0         0% 0         0% 0         0% 0         0% 0         0% 3         0%
fsstat       fsinfo       pathconf     commit
0         0% 8         0% 3         0% 0         0%


Any explanation for this? What did I miss? what am I doing wrong?

I wouldn't use this option but unfortunately its required for Oracle RAC
over NFS...

Thanks for any help
Markus



