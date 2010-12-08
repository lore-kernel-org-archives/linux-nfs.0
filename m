Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout0.mh.bbc.co.uk ([132.185.144.151]:37920 "EHLO
	mailout0.mh.bbc.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756196Ab0LHSwU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Dec 2010 13:52:20 -0500
Received: from gateh.kw.bbc.co.uk (gateh.kw.bbc.co.uk [132.185.132.17])
	by mailout0.mh.bbc.co.uk (8.14.4/8.14.3) with ESMTP id oB8FXfoT002606
	for <linux-nfs@vger.kernel.org>; Wed, 8 Dec 2010 15:33:41 GMT
Received: from mailhub.rd.bbc.co.uk ([172.29.120.130])
	by gateh.kw.bbc.co.uk (8.13.6/8.13.6) with ESMTP id oB8FXeAb002486
	for <linux-nfs@vger.kernel.org>; Wed, 8 Dec 2010 15:33:41 GMT
Date: Wed, 8 Dec 2010 15:33:40 +0000
From: David Flynn <davidf@rd.bbc.co.uk>
To: linux-nfs@vger.kernel.org
Cc: David Flynn <davidf@rd.bbc.co.uk>
Subject: NFSv4: "Viminfo file is not writable" -- stat(2) uid/gid incorrect
Message-ID: <20101208153340.GD20844@rd.bbc.co.uk>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Dear all;

On an NFS4 client (mounting a solaris ufs export), for a long time i've
been experiencing vim complaining when exiting:
  E137: Viminfo file is not writable: /home/davidf/.viminfo

Further examination has revealed this to occur when vim has been used on
multiple systems using the same nfs filesystem.  Vim tries to identify if it
has permission to modify .viminfo by stat'ing it, whereupon stat returns
an incorrect st_uid/st_gid and vim gives up.

Assuming two systems (A and B) with clean caches:
  A> vim
  :q
  B> vim
  :q
  A> vim
  :q
  E137: ...
  A> vim
  :q
  E137: ...

It should be noted that:
 - (A) must be using nfs4, although sec=sys/sec=krb5 do not affect behaviour.
 - (B) can be nfs4 or nfs3 (or possibly anything else)
 - Dropping caches on (A) will clear the fault

This fault is very reproducible using kernel 2.6.35.  I'm also able to
reproduce on 2.6.32.11  I have not been able to reproduce on a 2.6.26 system.

More succinctly, the following transcript reproduces the problem.
  - vcfe0 corresponds to (A) above.
  - lxg1 corresponds to (B) above.
  - ~/test-stat-open-stat is a program that does:
       stat(argv[1], &st);
       printf("stat(\".%s\"...), st_uid=%u, st_gid=%u\n",
              argv[1], st.st_uid, st.st_gid);

       int fd = open(argv[1], O_RDONLY);
       printf("open(\"%s\", O_RDONLY) = %d\n", argv[1], fd);
       stat(argv[1], &st);
       printf("stat(\".%s\"...), st_uid=%u, st_gid=%u\n",
              argv[1], st.st_uid, st.st_gid);

       close(fd);
       printf("close(%d)\n", fd);
       stat(argv[1], &st);
       printf("stat(\".%s\"...), st_uid=%u, st_gid=%u\n",
              argv[1], st.st_uid, st.st_gid);

vcfe0:~/z$ bash <<EOF
echo === truncate === ; \
echo foo >.file ; \
echo === remote unlink, create === ; \
ssh lxg1 "rm $PWD/.file; echo barbar >$PWD/.file" ; \
echo === 'stat(1)' === ; \
stat .file ; \
echo === stat,open,stat,close,stat === ; \
~/test-stat-open-stat .file ; \
echo === 'stat(1)' === ; \
stat .file
EOF

=== truncate ===
=== remote unlink, create ===
=== stat(1) ===
  File: `.file'
  Size: 4               Blocks: 0          IO Block: 1048576 regular file
Device: 18h/24d Inode: 5678963     Links: 1
Access: (0644/-rw-r--r--)  Uid: ( 1179/  davidf)   Gid: ( 1000/      rd)
Access: 2010-11-29 16:50:03.414109000 +0000
Modify: 2010-11-29 17:00:17.698839000 +0000
Change: 2010-11-29 17:00:17.698839000 +0000
=== stat,open,stat,close,stat ===
stat(".file"...), st_uid=1179, st_gid=1000
open(".file", O_RDONLY) = 3
stat(".file"...), st_uid=4294967294, st_gid=4294967294
close(3)
stat(".file"...), st_uid=4294967294, st_gid=4294967294
=== stat(1) ===
  File: `.file'
  Size: 7               Blocks: 2          IO Block: 1048576 regular file
Device: 18h/24d Inode: 5678906     Links: 1
Access: (0644/-rw-r--r--)  Uid: (4294967294/ UNKNOWN)   Gid: (4294967294/ UNKNOWN)
Access: 2010-11-29 17:00:18.059076000 +0000
Modify: 2010-11-29 17:00:18.064360000 +0000
Change: 2010-11-29 17:00:18.064360000 +0000

Kind regards,

..david
