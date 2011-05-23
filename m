Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:59146 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349Ab1EWFmm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 01:42:42 -0400
Received: by gxk21 with SMTP id 21so2026124gxk.19
        for <linux-nfs@vger.kernel.org>; Sun, 22 May 2011 22:42:41 -0700 (PDT)
Date: Mon, 23 May 2011 13:42:41 +0800
Message-ID: <BANLkTikCdr6P-WFBdshPwiBQ5_LK-qobLQ@mail.gmail.com>
Subject: Report bug: space not released when file deleted.
From: Sid Moore <learnmost@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

On Linux NFS, I found a file deleted but its space not released in
NFSv3. It is on 2.6.32.

The steps for reproducing are listed below.
1) create a ext3 filesystem on a device, mount it to local dir
/exports/fs1_ext3/, export /exports/fs1_ext3/ with no_subtree_check to
a NFS client. this client mount this exported dir with infinite
retrans.
2) on the ext3 fs, create a large regular file  (say: 600MB)
3) on NFS client, starts several processes who reading this file in 2)
in parallel
4) during step 3), kill all nfsd threads, umount this ext3 fs; then
mount this ext3 to /exports/fs1_ext3; start 8 nfsd threads.
5) after processes finished reading, delete this file. then, I found
the space occupied but this file not released.

during step 4), I think an anonymous dentry of this file was created
after fh_verify(). in step 5), a named dentry of this file also
created. So, there are two dentry on this inode. but when deleting,
only the named dentry deleted. only restart this ext3 fs or dcache
shrinked, the anonymous dentry will not be released and it referenced
the inode of this file. so its space not freed.

is my analysis correct?  anyone has encountered this issue before? or,
this issue was fixed by someone? Thanks.

--
Sid
