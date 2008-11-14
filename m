From: "Mike Snitzer" <snitzer@gmail.com>
Subject: help understanding the current (and future) state of NFSv4 locking?
Date: Fri, 14 Nov 2008 15:34:56 -0500
Message-ID: <170fa0d20811141234m3faee54dh241b9a374b7201c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.179]:52777 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129AbYKNUe7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Nov 2008 15:34:59 -0500
Received: by ik-out-1112.google.com with SMTP id c29so1344554ika.5
        for <linux-nfs@vger.kernel.org>; Fri, 14 Nov 2008 12:34:56 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I'd like to understand the state of Linux's NFSv4 server regarding the
NFSv4 spec's _optional_ ordered blocking lock list implementation.
Without something like the following patch isn't there still concern
for NFSv4 clients being starved from ever getting a conflicting lock
(local POSIX or lockd waiters would race to get it first)?

"fair queuing" in Linux's fs/locks.c was developed but the patch was
never merged upstream:
http://www.citi.umich.edu/projects/nfsv4/linux/kernel-patches/2.6.13-1/linux-2.6.13-032-locks-posix-fair-queue.dif

http://wiki.linux-nfs.org/wiki/index.php/Cluster_Coherent_NFS_and_Byte_Range_Locking
http://www.eisler.com/2008-05-09/draft-ietf-nfsv4-minorversion1-23.html#blocking_locks


I'd also like to understand: what Linux NFSv4.1 support is intended
for the _optional_ CB_NOTIFY_LOCK?:

20.11.  Operation 13: CB_NOTIFY_LOCK - Notify of possible lock availability:
http://www.eisler.com/2008-05-09/draft-ietf-nfsv4-minorversion1-23.html#OP_CB_NOTIFY_LOCK

Any insight would be appreciated.

Thanks,
Mike
